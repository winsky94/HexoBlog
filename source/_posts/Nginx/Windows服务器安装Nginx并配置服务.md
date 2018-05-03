---
title: Windows服务器安装Nginx并配置服务
date: 2018-05-03 10:20:43
updated: 2018-05-03 10:20:43
tags:
  - Nginx
  - Windows服务
categories: 
  - Nginx
---

Nginx是俄罗斯人编写的十分轻量级的HTTP服务器。Nginx，它的发音为“engine X”，是一个高性能的HTTP和反向代理服务器，同时也是一个IMAP/POP3/SMTP代理服务器。

Nginx以事件驱动的方式编写，所以有非常好的性能，同时也是一个非常高效的反向代理、负载平衡。目前，国内越来越多的站点采用Nginx作为Web服务器，如国内知名的新浪、163、腾讯、Discuz、豆瓣等。

因为学校的服务器大多数是Windows Server的环境，所以本文总结了几次Windows上Nginx安装配置的过程，以作记录。

> 服务器采用Windows Server 2012 R2
<!-- more -->

# 安装
首先去[Nginx官网](http://nginx.org/)下载最新稳定版的Nginx程序

下载之后解压到服务器上某个具体文件夹，比如这里我放在了`G:/`目录下

![Nginx安装目录][1]

# 启动
**注意不要直接双击nginx.exe，这样会导致修改配置后重启、停止nginx无效，需要手动关闭任务管理器内的所有nginx进程**

在nginx.exe目录，打开命令行工具，用命令 启动/关闭/重启nginx 

`start nginx` : 启动nginx

`nginx -s reload` ：修改配置后重新加载生效

`nginx -s reopen` ：重新打开日志文件

`nginx -t -c /path/to/nginx.conf` ：测试nginx配置文件是否正确

关闭nginx：
```
nginx -s stop  :快速停止nginx
nginx -s quit  ：完整有序的停止nginx
```

如果遇到报错：`bash: nginx: command not found`

有可能是你再linux命令行环境下运行了windows命令，

如果你之前是运行`nginx -s reload`报错， 试下`./nginx -s reload`，或者 用windows系统自带命令行工具运行

# 访问
上面的启动过程前，我们并没有更改Nginx的配置文件，所以我们采用了Nginx默认的配置文件，启动了Nginx服务

通过访问`http://127.0.0.1/`我们可以看到Nginx的默认主页

![Nginx默认主页][2]

至此，Nginx安装过程到此结束。

# 配置成Windows服务
一般在Linux服务器上，我们可以简单地通过在`/etc/rc.local`文件中加入启动命令来配置服务自启。在Windows Server上，我们当然也希望服务能自启了，本节就教大家如何在Windows 服务器上将自己的程序配置成Windows服务。

考虑到文章结构和内容的需要，特将本段单独整理成一篇博文，大家可以点击下面的链接阅读。

> [将自己的程序配置成Windows服务][3]


# Nginx配置
前面我们只是使用了默认的配置启动了Nginx服务，一般来说，这不能满足我们实际生产环境中的需求，这就需要我们自己配置Nginx的配置文件。

具体配置方法，可以参照下面这篇博文

> [Nginx配置教程]

[1]: https://pic.winsky.wang/images/2018/05/03/Nginx.png "Nginx安装目录"
[2]: https://pic.winsky.wang/images/2018/05/03/Nginxcfdc5.png "Nginx默认主页"
[3]: https://blog.winsky.wang/Windows/将自己的程序配置成Windows服务 "将自己的程序配置成Windows服务"
[4]: https://blog.winsky.wang/Nginx/Nginx服务配置 "Nginx配置教程"