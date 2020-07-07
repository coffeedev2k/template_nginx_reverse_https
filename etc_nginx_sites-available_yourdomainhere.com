server {
    listen                  yourporthereas_4545 ssl http2;
    listen                  [::]:yourporthereas_4545 ssl http2;
    server_name             yourdomainhere.com;

	root /var/www/html/;

	# Add index.php to the list if you are using PHP
	index index.php index.html index.htm index.nginx-debian.html;

	client_max_body_size 1000m;
        client_body_timeout 240s; # Default is 60, May need to be increased for very large uploads

	server_name _;
	location / {
	    try_files $uri $uri/ /index.php?$query_string;
	}

#	location / {
		# First attempt to serve request as file, then
		# as directory, then fall back to displaying a 404.
#		try_files $uri $uri/ =404;
#	}

	# pass PHP scripts to FastCGI server
	#
	location ~ \.php$ {
		include snippets/fastcgi-php.conf;
	#
	#	# With php-fpm (or other unix sockets):
		fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
	#	# With php-cgi (or other tcp sockets):
	#	fastcgi_pass 127.0.0.1:9000;
	}

	# deny access to .htaccess files, if Apache's document root
	# concurs with nginx's one
	#
	#location ~ /\.ht {
	#	deny all;
	#}



    # SSL
    ssl_certificate         /etc/letsencrypt/live/yourdomainhere.com/fullchain.pem;
    ssl_certificate_key     /etc/letsencrypt/live/yourdomainhere.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/yourdomainhere.com/chain.pem;
}

# HTTP redirect
server {
    listen  yourporthere_nonsecure_as_8080;
    listen  [::]:yourporthere_nonsecure_as_8080;
    server_name             yourdomainhere.com;

	root /var/www/html;



    location / {
        return 301 https://yourdomainhere.com:yourporthereas_4545$request_uri;
    }
}

