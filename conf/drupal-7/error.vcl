vcl 4.0;

sub backend_error {
    synthetic({"
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html>
          <head>
            <title>"} + beresp.status + " " + beresp.reason + {"</title>
          </head>
          <body>
            <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
            <p>"} + beresp.reason + {"</p>
            <h3>Guru Meditation:</h3>
            <p>XID: "} + bereq.xid + {"</p>
            <hr>
            <p>Varnish cache server</p>
          </body>
        </html>
    "});
}

sub client_error {
    synthetic({"
        <?xml version="1.0" encoding="utf-8"?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
        <html>
          <head>
            <title>"} + resp.status + " " + resp.reason + {"</title>
          </head>
          <body>
            <h1>Error "} + resp.status + " " + resp.reason + {"</h1>
            <p>"} + resp.reason + {"</p>
            <h3>Guru Meditation:</h3>
            <p>XID: "} + req.xid + {"</p>
            <hr>
            <p>Varnish cache server</p>
          </body>
        </html>
    "});
}