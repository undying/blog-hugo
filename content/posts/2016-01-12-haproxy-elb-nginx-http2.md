---
title: "Enabling HTTP/2.0 support with Haproxy -> Amazon ELB -> Nginx"
date: 2016-01-12 20:35:00 +0300
tags:
- haproxy
- nginx
- elb
- http/2
commentIssueId: 2
---

I have a Haproxy balancer that routes traffic for multiple projects with different host names and now, I need to enable HTTP/2.0 support for couple or all of them. The problem is that current version of Haproxy not supporting HTTP/2.0 protocol.
Also, In my case I have multiple backends. To some of them I need to send http/1.1 traffic and to some of them http/2.0.

The main problem is the mix of tcp/http modes in Haproxy. Without it everything is simple. Just use tcp mode and that's it. But here I need balancer to handle SSL for some projects, that's why simple tcp mode is not the solution. Here is the idea.

```goat
	http/https
	----------> |---------|
	----------> | Haproxy |
	http/2.0    |_________|
                    /\
          http/1.1 /  \ http/2.0
          ________/_  _\_________
         | http/1.1 | | http/2.0 |
         | backend  | | backend  |
         |__________| |__________|
```

One more requirement is to keep client ip. So, the final scheme will looks this way.

```goat
	             _________                                 _______
	http/https  |         |            http               |       |
	----------> | Haproxy | --------------------------->  | nginx |
	            |_________| X-Forwarded-For: <client_ip>  |_______|
	                   |
	             proxy-protocol
	               http/2.0      http/2.0  _______
	             ______|___   /---------> | nginx |
	            |    ELB   | /
	            | tcp mode |/
	            |__________|\
	                         \  http/2.0   _______
	                          \---------> | nginx |
```

Now the most interesting part - configuration.

<h4><b>Haproxy Configuration</b></h4>

Haproxy must be built with OpenSSL that supports ALPN. This support was introduced in version 1.0.2. Haproxy ALPN support was implemented in 1.5-dev18 version. 
```
	global
	  maxconn 81920
	  tune.ssl.default-dh-param 2048
	  pidfile /run/haproxy.pid
	  stats socket /run/haproxy.sock level admin
	
	defaults
	  mode http
	  option forwardfor
	  maxconn 20480
	  timeout connect 2s
	  timeout client 180000
	  timeout server 180000
	  stats enable
	  stats uri /status/
	  stats realm Name\ Yourself
	  stats auth name:password
	
	frontend listen_http
	  bind 0.0.0.0:80
	  reqadd X-Forwarded-Proto:\ http
	
	  use_backend project1 if { hdr(host) -i project1.domain.local }
	  default_backend project2-http
	
	frontend listen_https
	  mode tcp
	  bind 0.0.0.0:443 ssl crt /etc/haproxy/ssl/cert_key.pem alpn h2 ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA

	  reqadd X-Forwarded-Proto:\ https
	
	  use_backend project1 if { ssl_fc_sni -i project1.domain.local }
	  use_backend project2-http2 if { ssl_fc_alpn -i h2 }
	
	  default_backend project2-https
	
	backend project1
	  server project1 172.17.0.10:80 check
	
	backend project2-http
	  server project2 172.17.0.20:80 check send-proxy
	
	backend project2-https
	  mode tcp
	  server project2 172.17.0.20:443 check send-proxy ssl verify none
	
	backend project2-http2
	  mode tcp
	  server project2 172.17.0.20:8443 check send-proxy
```

<h4>Details</h4>

```
reqadd X-Forwarded-Proto:\ http
```

Handle http->https redirect on backend side.

```
option forwardfor
```

Send client ip to http backends with header X-Forwarded-For.

```
bind 0.0.0.0:443 ssl crt /etc/haproxy/ssl/cert_key.pem alpn h2 ciphers ...
```

Here we are terminating ssl and enabling support for http/2.0 over TLS with `alpn h2`. Pay attention with ciphers, Google Chrome need <i>strong</i> ciphers to use.

```
use_backend project1 if { ssl_fc_sni -i project1.domain.local }
```

Use backend project1 if SSL SNI matches <b>project1.domain.local</b>. This is useful when we can't use http mode and parse headers.

`
use_backend project2-http2 if { ssl_fc_alpn -i h2 }
`

Pass clients to project2-http2 backend if SSL ALPN field matches h2 (http/2.0).


	backend project2-http2
	  mode tcp
	  server project2 172.17.0.20:8443 check send-proxy


`send-proxy` Enables proxy-protocol to send Client IP to the backend.

<h4>Nginx Configuration</h4>

In nginx everything is pretty simple. Modifying listen attribute for http2 support. Nginx must be built with module ngx_http_v2_module. This module was introduced in version 1.9.5.

```nginx
listen 8443 http2 proxy_protocol;
```

Thats it.
