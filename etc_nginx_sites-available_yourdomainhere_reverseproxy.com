server {
    listen yoursslporthere ssl http2;
#    listen [::]:443 ssl http2;

    server_name yourdomainhere.com;
    root /var/www/yourdomainhere.com/public;

    # SSL
    ssl_certificate /etc/letsencrypt/live/yourdomainhere.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomainhere.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/yourdomainhere.com/chain.pem;

    # security
#    include nginxconfig.io/security.conf;

    # reverse proxy
    location / {
	proxy_pass http://127.0.0.1:8080;
#	include nginxconfig.io/proxy.conf;
    }

    # additional config
#    include nginxconfig.io/general.conf;
}

# subdomains redirect
server {
    listen yoursslporthere ssl http2;
#    listen [::]:443 ssl http2;

    server_name *.yourdomainhere.com;

    # SSL
    ssl_certificate /etc/letsencrypt/live/yourdomainhere.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomainhere.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/yourdomainhere.com/chain.pem;

    return 301 https://yourdomainhere.com$request_uri;
}

# HTTP redirect
server {
    listen 80;
    listen [::]:80;

    server_name .yourdomainhere.com;

#    include nginxconfig.io/letsencrypt.conf;

    location / {
	return 301 https://yourdomainhere.com$request_uri;
    }
}