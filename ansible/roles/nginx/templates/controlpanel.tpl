server {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    listen 80;
    server_name ivcp.dev;
    root /var/www/controlpanel/web;
    client_max_body_size 64M;
    
    ##
    # Gzip Settings
    ##

    gzip on;
    gzip_disable "msie6";

    gzip_comp_level 6;
    #gzip_comp_level 9;
    gzip_min_length  1100;
    gzip_buffers 16 8k;
    gzip_proxied any;
    # gzip_http_version 1.1;
    gzip_types       text/plain application/xml text/css text/js text/xml application/x-javascript text/javascript application/json application/xml+rss;
    # =====
       
    proxy_buffers 8 64k;
    proxy_buffer_size 128k;

    fastcgi_buffers 8 64k;
    fastcgi_buffer_size 128k;
    
    location ~* \.(png|gif|jpg|jpeg|css|js|swf|ico|txt|xml|bmp|pdf|doc|docx|ppt|pptx|zip)$ {
        access_log off;
        expires 30d;
    }

    location / {
        # try to serve file directly, fallback to rewrite
        root   /var/www/controlpanel/web;
        index  app_dev.php;
        try_files $uri @rewriteapp;
        
        expires 30d; ## Assume all files are cachable
        if ($request_uri ~* "\.(png|gif|jpg|jpeg|css|js|swf|ico|txt|xml|bmp|pdf|doc|docx|ppt|pptx|zip)$") {
            access_log off;
            expires max;
        }
    }

    location @rewriteapp {
        # rewrite all to app.php
        rewrite ^(.*)$ /app_dev.php/$1 last;
    }

    location ~ ^/(app|app_dev|config)\.php(/|$) {
        root    /var/www/controlpanel/web;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        fastcgi_split_path_info ^(.+\.php)(/.*)$;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTPS off;
    }
    
    error_log /var/log/nginx/controlpanel.error.log;
    access_log /var/log/nginx/controlpanel.access.log;
}