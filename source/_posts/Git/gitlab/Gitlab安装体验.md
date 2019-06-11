---
title: Gitlab安装体验
date: 2019-06-11 15:26:14
updated: 2018-06-11 15:26:14
tags:
  - Gitlab
categories: 
  - Git
  - gitlab
---

GitLab是由GitLab Inc.开发，使用MIT许可证的基于网络的Git仓库管理工具，且具有wiki和issue跟踪功能。

由于项目开发代码托管需求，需要在阿里云上部署一套独立的Gitlab仓库，来进行项目代码管控。本文记录了如何在阿里云上安装部署自己的Gitlab仓库。

<!-- more -->

# Gitlab安装

官方的安装教程：https://about.gitlab.com/installation/#centos-7

进入官方安装教程，我们发现 Gitlab 提供了很多不同的版本，如下

![Gitlab版本.png](https://pic.winsky.wang/images/2019/06/11/20180124100605385.png)

我的阿里云系统是 CentOS7 , 所以我直接选择 CentOS7 。然后下面就会出现安装的命令。

## 第一步 防火墙放行

在系统防火墙中打开HTTP和SSH访问，有部署自己的Gitlab的同学一定会这种操作，这里不展开了。

## 第二步 安装邮件通知服务

安装Postfix 邮件通知服务，其实这一步是可以省略的，在 Gitlab 安装完成后还可以配置。安装命令如下，依次运行下面的命令就OK了。

```
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
```

## 第三步 安装软件包

安装 Gitlab 软件包，这个才是真正的主角。

```
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
```

接下来就是漫长的安装过程了，这个没有办法，只能耐心等待。

## 第四步 安装Gitlab

配置 Gitlab 访问的域名并安装，这里我使用了自己注册的一个域名，并配置了一个git的二级域名专门用于访问。命令中的`gitlab.example.com`需要替换成自己的域名。如果服务器没有绑定域名，这里也可以先使用公网ip代替。这个 域名/ip 以后可以在浏览器中访问 Gitlab 服务。安装配置命令如下：

```
sudo EXTERNAL_URL="http://gitlab.example.com" yum install -y gitlab-ee
```
![安装过程图.png](https://pic.winsky.wang/images/2019/06/11/20180123203755393.png)

下载完成后会自动安装，直至安装完成。

![安装完成图.png](https://pic.winsky.wang/images/2019/06/11/20180123204950803.png)

到这里就表示 GitLab 已经安装完成了。图中的http地址就可以直接访问gitlab了，版本号是：`gitlab-ee , 10.4.0`

## 第五步 设置初始密码

下面我们在浏览器中访问刚刚配置的地址，就可以看到Gitlab的页面了

![gitlab页面.png](https://pic.winsky.wang/images/2019/06/11/20180123205422958.png)

需要设置初始密码，连续输入两遍，然后点击下面的按钮。密码设置完成后，就会跳转到登录界面，登录用户名默认是 root，密码就是刚才设置的

登录完成后，就可以看到如下的界面。

![登录后的管理页面.png](https://pic.winsky.wang/images/2019/06/11/20180123210439053.png)

至此，Gitlab 已经安装完成了。

# 修改端口
Gitlab本身采用80端口，如安装前服务器有占用80，安装完访问会报错。需更改Gitlab的默认端口，比如我们将Gitlab的默认端口改为9090 。

## 第一步 更改配置文件

修改 Gitlab 默认端口配置 
打开`/etc/gitlab/gitlab.rb`文件，找到`external_url`字段，如下图所示，将原先配置的IP或者域名后面加上对应的端口号

![更改端口.png](https://pic.winsky.wang/images/2019/06/11/cefb38d9ec434a57.png)

## 第二步 重启
然后重新加载配置并重启应用程序
```
gitlab-ctl reconfigure
gitlab-ctl restart
```

然后在浏览器中访问对应的域名+端口就可以看到Gitlab的页面了。

## 可选的第三步
如果就是想用80端口来访问，这里提供一种思路，使用Nginx转发对应的端口，这里贴下对应的Nginx配置文件，不再具体描述其中的步骤。

```
server {
	listen 80;
	server_name git.example.com;
	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass http://localhost:9090/;
	}
}
```

