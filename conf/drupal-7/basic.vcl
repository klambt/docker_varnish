vcl 4.0;

sub normalise_requests {
    ####
    # Fix Accept Encoding
    ####
    if (req.http.Accept-Encoding) {
       if (req.url ~ "\.(jpg|png|gif|gz|tgz|bz2|tbz|mp3|ogg)$") {
          # No point in compressing these
          unset req.http.Accept-Encoding;
       } elsif (req.http.Accept-Encoding ~ "gzip") {
          set req.http.Accept-Encoding = "gzip";
       } elsif (req.http.Accept-Encoding ~ "deflate" && req.http.user-agent !~ "MSIE") {
          set req.http.Accept-Encoding = "deflate";
       } else {
          # unkown algorithm
          unset req.http.Accept-Encoding;
       }
    }
    
    if (req.url != "/") {
	    # Strip hash, server doesn't need it.
	    if (req.url ~ "\#") {
	        set req.url = regsub(req.url, "\#.*$", "");
	    }

	    # Strip a trailing ? if it exists
	    if (req.url ~ "\?$") {
	       set req.url = regsub(req.url, "\?$", "");
	    }

	    # Varnish doesn't like url containing double slashes
	    # as such, we change double slashes to simple slashes
	    if(req.url ~ "^(.*)//(.*)$") {
	         set req.url = regsub(req.url,"^(.*)//(.*)$","\1/\2");
	    }
	    //normalize URL (removing /)
	    #set req.url = regsuball(req.url, "//", "/");
	    #set req.url = regsub(req.url, "/([?])?$", "\1");


	    # Strip google analytics params and mailchimp params
	    if(req.url ~ "(\?|&|\%3F)(itok|topic|wx_id|hc_location|type|dtd|image|\_|gclid|utm_[a-z]+|mc_[a-z]+)(=|\%3D)") {
	       set req.url = regsuball(req.url, "(itok|topic|wx_id|hc_location|type|dtd|image|\_|gclid|utm_[a-z]+|mc_[a-z]+)(=|\%3D)[^\&]+&?", "");
	       set req.url = regsub(req.url, "(\?|&|\%3F)$", "");
	    }

	    // Always cache the following file types for all users. This list of extensions
	    // appears twice, once here and again in vcl_fetch so make sure you edit both
	    // and keep them equal.
	    if ((req.url ~ "(?i)\.(pdf|asc|dat|txt|doc|xls|ppt|tgz|csv|png|gif|jpeg|jpg|ico|swf|css|js)(\?.*)?$") || req.url ~ "^/standalone" || req.url ~ "/thema/.*/rss" || req.url ~ "/sites/default/files/") {
	      unset req.http.X-Forwarded-Proto;
	      unset req.http.Cookie;
	      return(hash);
	    } 
    }

    ###
    #  Cookie Section
    ###
    if (req.http.Cookie) {
       // 1. Append a semi-colon to the front of the cookie string.
       // 2. Remove all spaces that appear after semi-colons.
       // 3. Match the cookies we want to keep, adding the space we removed
       //    previously back. (\1) is first matching group in the regsuball.
       // 4. Remove all other cookies, identifying them by the fact that they have
       //    no space after the preceding semi-colon.
       // 5. Remove all spaces and semi-colons from the beginning and end of the
       //    cookie string.

       set req.http.Cookie = ";" + req.http.Cookie;
       set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
       set req.http.Cookie = regsuball(req.http.Cookie, ";(SESS[a-z0-9]+|SSESS[a-z0-9]+|NO_CACHE|THEME|qtrans\_[a-z0-9\_]+|stagepass|wordpress\_[a-z0-9\_]+)=", "; \1=");
       set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
       set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");

       if (req.http.Cookie == "") {
          // If there are no remaining cookies, remove the cookie header. If there
          // aren't any cookie headers, Varnish's default behavior will be to cache
          // the page.
          unset req.http.Cookie;
        }
    }

    ###
    # Add Information
    ###
    if (req.restarts == 0) {
       if (req.http.X-Forwarded-For) {
          set req.http.X-Forwarded-For = req.http.X-Forwarded-For;
       } 
       else {
          set req.http.X-Forwarded-For = client.ip;
       }
    }
    set req.http.X-Client-IP = client.ip;

    if (!req.http.X-Original-Client-IP) {
      set req.http.X-Forwarded-Varnish-Proto = req.http.X-Forwarded-Proto;
      set req.http.X-Original-Client-IP = req.http.X-Forwarded-For;
    }
}