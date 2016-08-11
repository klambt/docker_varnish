vcl 4.0;

backend default {
  .host = "backend";
  .port = "80";
}

acl refresh {
   "localhost";
   "127.0.0.1";
}

###########################################
#      Respond to incoming Requests       #
#            ---------------              #
###########################################

# Respond to incoming requests.
sub vcl_recv {
  if (req.method == "PURGE") {
    if (client.ip !~ refresh) {
      return (synth(405,"Not Allowed"));
    }
    set req.hash_always_miss = true;
    unset req.http.Cookie;
    set req.method = "GET";
  }


  if (req.http.Authorization) {
    return(pipe);
  }

  # We only deal with GET and HEAD by default
  if (req.method != "GET" && req.method != "HEAD") {
    return (pass);
  }

  return (hash);
}

sub vcl_backend_fetch {
  return (fetch);
}

sub vcl_pass {
  return (fetch);
}

sub vcl_hit {
  set req.http.X-Varnish-TTL = obj.ttl;
  set req.http.X-Varnish-GRACE = obj.grace;
  if (obj.ttl >= 0s) {
    // A pure unadultered hit, deliver it
    return (deliver);
  }
  if (obj.ttl + obj.grace > 0s) {
    // Object is in grace, deliver it
    // Automatically triggers a background fetch
    return (deliver);
  }

  // fetch & deliver once we get the result
  return (fetch);
}

sub vcl_deliver {
  # Is it a Cached Response?
  if (obj.hits > 0) {
     set resp.http.X-Cache = "|VC:HIT - " + obj.hits  + " - (" + resp.http.X-Varnish + ")";
  } else {
     set resp.http.X-Cache = "|VC:MISS (" + resp.http.X-Varnish + ")";
  }
  return (deliver);
}

sub vcl_init {
    return (ok);
}

sub vcl_fini {
    return (ok);
}


