vcl 4.0;
include "backend.vcl";
include "acl_refresh.vcl";
include "error.vcl";
include "basic.vcl";

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

  call normalise_requests;

  # We only deal with GET and HEAD by default
  if (req.method != "GET" && req.method != "HEAD") {
    return (pass);
  }

  if (req.http.Cookie ~ "(SESS[a-z0-9]+|SSESS[a-z0-9]+|NO_CACHE)") {
       // If there is any cookies left (a session or NO_CACHE cookie), do not
       // cache the page. Pass it on to Apache directly.
       set req.http.X-Varnish-Info = "Session Cookie available";
       return (pass);
  }

  ##
  #  Non Cachable 
  ##
  if (req.url ~ "^/status\.php$" ||
      req.url ~ "^/update\.php$" ||
      req.url ~ "^/install\.php$" ||
      req.url ~ "^/cron\.php$" ||
      req.url ~ "^/admin$" ||
      req.url ~ "^/admin/.*$" ||
      req.url ~ "^/admin_menu/.*$" ||
      req.url ~ "^/flag/.*$" ||
      req.url ~ "^.*/ajax/.*$" ||
      req.url ~ "^.*/ahah/.*$" 
      ) {
        set req.http.X-Varnish-Info = "URL not cachable";
        return (pass);
    }

  return (hash);
}

sub vcl_backend_fetch {
  return (fetch);
}

sub vcl_backend_response {
    //unset cookies for static content
    if (bereq.url ~  "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
        unset beresp.http.set-cookie;
        if (beresp.status == 200) {
           set beresp.grace = 7d;
        }
    }

    set beresp.do_esi = true;
    unset beresp.http.Via;
    unset beresp.http.Server;
    unset beresp.http.X-Generator;
    unset beresp.http.X-Varnish;
    unset beresp.http.X-Powered-By;
    unset beresp.http.X-BLOCK-CACHE;
    return (deliver);
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

sub vcl_backend_error {
    set beresp.http.Content-Type = "text/html; charset=utf-8";
    set beresp.http.Retry-After = "5";
    set beresp.ttl = 15s;

    if (bereq.url ~ "/(esi|sitemap|rss)" || bereq.url ~  "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") { 
       synthetic(beresp.status);
       return (deliver);
    }

    call backend_error;
    return (deliver);
}

sub vcl_synth {        
    if (resp.status>=500 && resp.status<=599) {
       set resp.http.Content-Type = "text/html; charset=utf-8";
       set resp.http.Retry-After = "5";
       set resp.http.Cache-Control = "Cache-Control: max-age=60";

       if (req.url ~ "/(esi|sitemap|rss)" || req.url ~  "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") {
          synthetic({"<span class="varnish_error_info">CERROR:"}+resp.status+{"</span>"});
          return (deliver);
       }

       call client_error;
       return (deliver);
     }
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


