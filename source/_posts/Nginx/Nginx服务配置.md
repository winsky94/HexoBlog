---
title: Nginx服务配置
date: 2018-05-03 20:57:43
updated: 2018-05-03 20:57:43
tags:
  - Nginx
categories: 
  - Nginx
---
前面一篇博文我们介绍了Nginx的安装，并以默认配置成功启动了Nginx服务。需要的同学可以参考[Windows服务器安装Nginx并配置服务][1]

当然，我对Nginx的理解还处于一知半解的地步，对Nginx的原理部分、甚至配置文件的详细配置，也有待进一步提高。这篇博文主要是介绍Nginx的各种配置。本文的写作思路，是根据平时自己的生产实践中所用到的一些配置，加以整合修改，所以随着对Nginx的深入使用，本文也将持续更新。

<!-- more -->

# 不同域名提供不同服务
这种方式是我在接触到Nginx的时候学会的最简单的转发设置方式。配置文件格式如下：参照本站博客的配置情况
```
server
{
    listen 80;
    server_name blog.winsky.wang ;
		
	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:4000/;
    }
}
```
`listen`表示监听的端口

`server_name`表示监听的访问域名

`location`表示资源位置，其中具体的内容表示将来自`blog.winsky.wang`域名80端口的服务转到本机4000端口上。

上面四行`proxy_set_header`是配置本地服务可以正确得到访问者的来源ip等信息。

这种方式一般适用于在服务器上开一个服务，监听某个端口并提供服务。但是他也有一个缺点，那就是每新来一个服务，都要新建一个域名解析，这会带来不必要的操作

# 不同路径转发不同服务
之前我一直都是用的根据域名来转发的这种挫挫的方式，直到，学院有台电脑，只有ip，没有映射到外网的域名，所以只能采用根据不同路径抓发不同的路径的方式。

这种方式的参考配置文件如下，基本是在默认配置的基础上更改了location的位置
```
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
		
		location /t/ {
			proxy_set_header HOST $host;
			proxy_set_header X-Forwarded-Proto $scheme;
			proxy_set_header X-Real-IP $remote_addr;
			proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
			proxy_pass http://localhost:8080/;
		}
    }
}
```

[1]: https://blog.winsky.wang/Windows/将自己的程序配置成Windows服务/ "Windows服务器安装Nginx并配置服务"