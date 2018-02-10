---
title: 博客自启动
date: 2018-02-11 10:24:13
updated: 2018-02-11 10:24:13
tags:
  - HTTPS
categories: 
  - Hexo博客
---
这个纯属偶然看到一篇博文里面的，觉得`https`很好高大上，于是我也想玩玩

[Let's Encrypt][1]是一个免费、自动化、开放的证书签发服务。它由`ISRG`（`Internet Security Research Group`，互联网安全研究小组）提供服务，而`ISRG`是来自于美国加利福尼亚州的一个公益组织。`Let's Encrypt`得到了`Mozilla`、`Cisco`、`Akamai`、`Electronic Frontier Foundation`和`Chrome`等众多公司和机构的支持，发展十分迅猛。

<!-- more -->
申请`Let's Encrypt`证书不但免费，还非常简单，虽然每次只有90天的有效期，但可以通过脚本定期更新，配好之后一劳永逸。本文记录本站申请过程和遇到的问题。

# 获取免费证书
[Certbot][2]是`Let's Encrypt`官方推荐的获取证书的客户端，可以帮我们获取免费的`Let's Encrypt`证书。`Certbot`是支持所有`Unix`内核的操作系统的，我的博客服务器系统是`CentOS`，这篇教程也是通过在个人博客上启用`HTTPS`的基础上完成的。

- 安装`Certbot`客户端
	- `wget https://dl.eff.org/certbot-auto`
	- `chmod +x certbot-auto`
- 获取证书
	- `webroot`模式
		- `certbot certonly --webroot -w /var/www/example -d example.com -d www.example.com`
		- 这个命令会为`example.com`和`www.example.com`这两个域名生成一个证书，使用`--webroot`模式会在`/var/www/example`中创建`.well-known`文件夹，这个文件夹里面包含了一些验证文件，`certbot`会通过访问`example.com/.well-known/acme-challenge`来验证你的域名是否绑定的这个服务器。这个命令在大多数情况下都可以满足需求
	- `standalone`模式
		- 但是，有时候我们没有根目录，例如一些微服务和本博客。这时候使用`--webroot`就走不通了。`certbot`还有另外一种模式`--standalone`，这种模式不需要指定网站根目录，他会自动启用服务器的443端口，来验证域名的归属。我们有其他服务（例如`nginx`）占用了443端口，就必须先停止这些服务，在证书生成完毕后，再启用。
		- `certbot certonly --standalone -d example.com -d www.example.com`
		- 证书生成完毕后，我们可以在`/etc/letsencrypt/live/`目录下看到对应域名的文件夹，里面存放了指向证书的一些快捷方式。

# Nginx配置启用HTTPS
客系统使用的是Nginx 服务器来转发请求，这里贴一下我的Nginx配置。
```
server
{
    listen 443;
    server_name blog.winsky.wang ;
    ssl on;
    ssl_certificate /etc/letsencrypt/live/blog.winsky.wang/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/blog.winsky.wang/privkey.pem;
		
	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:4000/;
    }
}

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

# 自动更新SSL证书
`Let's Encrypt`提供的证书只有90天的有效期，我们必须在证书到期之前，重新获取这些证书，`certbot`给我们提供了一个很方便的命令，那就是`certbot renew`。
通过这个命令，他会自动检查系统内的证书，并且自动更新这些证书。

我们可以运行这个命令测试一下`certbot renew --dry-run `。不过，运行时候出现了错误
```
Attempting to renew cert (blog.winsky.wang) from /etc/letsencrypt/renewal/blog.winsky.wang.conf produced an unexpected error: Problem binding to port 80: Could not bind to IPv4 or IPv6.. Skipping.
All renewal attempts failed. The following certs could not be renewed:
  /etc/letsencrypt/live/blog.winsky.wang/fullchain.pem (failure)
```
这是因为生成证书的时候使用的是`--standalone`模式，验证域名的时候，需要启用443端口，这个错误的意思就是要启用的端口已经被占用了。这时候必须把`nginx`先关掉，才可以成功。果然，先运行`service nginx stop`运行这个命令，就没有报错了，所有的证书都刷新成功

证书是90天才过期，我们只需要在过期之前执行更新操作就可以了。 这件事情就可以直接交给定时任务来完成。新建了一个文件`certbot-auto-renew-cron`，这个是一个`cron`计划，这段内容的意思就是每隔两个月的凌晨`4:00`执行更新操作
```
00 4 * */2 * certbot renew --pre-hook "service nginx stop" --post-hook "service nginx start"
```
- `--pre-hook`这个参数表示执行更新操作之前要做的事情
- `--post-hook`这个参数表示执行更新操作完成后要做的事情

最后我们启动这个定时任务`crontab certbot-auto-renew-cron`

# 填坑
虽然上面的过程看上去一帆风顺，但是实际操作过程中还是碰到了很多问题

## Python版本
我的服务器是`CentOS 6.6`的，上面默认的`Python`版本是`2.6.6`，安装时会报错`No supported Python package available to install. Aborting bootstrap!`。所以需要升级一下Python版本
```
wget http://python.org/ftp/python/2.7.3/Python-2.7.3.tar.bz2 #下载Python-2.7.3
tar -jxvf Python-2.7.3.tar.bz2 #解压
cd Python-2.7.3 #更改工作目录
./configure #安装
make all #安装
make install #安装
make clean #安装
make distclean #安装
/usr/local/bin/python2.7 -V  #查看版本信息
mv /usr/bin/python /usr/bin/python2.6.6 #建立软连接，使系统默认的 python指向 python2.7
ln -s /usr/local/bin/python2.7 /usr/bin/python #建立软连接，使系统默认的 python指向 python2.7
python -V #检验Python 版本
vi /usr/bin/yum  #将文件头部的#!/usr/bin/python 改成#!/usr/bin/python2.6.6
```

## 端口占用
在执行`certbot certonly --standalone -d blog.winsky.wang`时会提示端口占用，这是因为服务器上`Nginx`服务开着，占用了端口，所以在安装、更新证书的时候需要先停止`Nginx`服务

> [Let's Encrypt 使用教程，免费的SSL证书，让你的网站拥抱 HTTPS](https://diamondfsd.com/article/e221b455-b0e7-40b7-a6c7-9bb7e3e35657)

> [搬瓦工VPS申请Let’s Encrypt免费SSL证书时报错解决办法](https://www.wn789.com/14419.html)

---
[1]: https://letsencrypt.org/ "Let's Encrypt"
[2]: https://certbot.eff.org/ "Certbot"