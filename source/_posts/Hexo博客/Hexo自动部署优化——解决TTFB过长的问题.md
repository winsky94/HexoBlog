---
title: Hexo自动部署优化——解决TTFB过长的问题
date: 2019-01-05 18:40:44
tags:
  - HEXO
  - Next
  - 博客
categories: 
  - Hexo博客
---

差不多去年这个时候，自己萌生了玩VPS和搭建自己的博客的想法，眨眼间博客也运行快一年了。博客使用过程中，中途发现自己的站点打开速度很慢，之前也零零碎碎地看过这个问题，但是一直没能解决。今天周末好不容易闲下来，终于研究出了问题所在。

博客访问慢的直接原因在于，网站的 TTFB 等待过长，关于什么是TTFB，我们文末再介绍。问题的解决方案，就是，之前VPS上自动部署的方式不对，没有依赖静态页面，而是利用了Hexo的服务器。通过直接访问Hexo提前生成好的静态页面，博客加载速度有了明显提高。

<!-- more -->

# 背景及起因

关于之前的自动部署方式，可以参考这篇文章 [自动将更新部署到VPS.md][1]

当时采用的在博客上运行`hexo server`来提供网站服务。实际上，这种方式是本地编写文章时测试用的，用在VPS上提供博客站点服务，就会显得访问速度没有理想的那么快（因为这是实时编译生成的网页，非静态的资源页面），TTFB时间过长。

![TTFB.png](https://pic.winsky.wang/images/2019/01/05/TTFB.png)

# 解决方案
找到了问题，就可以很方便的对症下药了。

Hexo提供了`hexo -g`来生成博客中所有文章对应的静态页面，我们要做的就是在访问博客的时候直接访问VPS上的静态页面。

## 多分支管理
为了方便管理，我新建了一个分支`dev`，在这个分支上进行博客的编写，同时删除了原先在Master分支上的全部内容
```shell
# 新建分支
git checkout -b dev
git push origin dev

# 清空Master分支内容
git checkout master
# @@注意备份@@
rm -rf *
git add .
git commit -m "rm all files in master"
git push origin master
```

## 自动部署Master分支
我们借助`hexo -d`命令来实现自动部署。

首先，修改站点的`_config.yml`配置文件，修改其中的deploy节点
```
# Deployment
## Docs: https://hexo.io/docs/deployment.html
deploy:
  type: git
  repo: https://github.com/winsky94/HexoBlog.git
  branch: master
```
这样通过使用`hexo -d`命令可以来自动部署文章到github。如果提示错误，可能你需要安装`hexo-deployer-git`
```
npm install hexo-deployer-git --save
```

## 自动部署到VPS
上一步的deploy参数正确配置后，文章写完使用hexo g -d命令就可以直接部署，并提交到GitHub上的Master分支。

然后在VPS上clone下来Master分支，我的存储路径是`/home/blog/HexoBlog`，然后借助Nginx提供静态站点的访问

> 什么，你还不知道Nginx？出门左转谷歌一下，你就知道

修改原先的`/usr/local/nginx/conf/vhost/blog.conf`，改成如下内容
```
server
{
    listen 443;
    server_name blog.winsky.wang ;
    ssl on;
    ssl_certificate /etc/letsencrypt/live/blog.winsky.wang/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/blog.winsky.wang/privkey.pem;

    index index.html index.htm index.php default.html default.htm default.php;
    #这里要改成网站的根目录
    root  /home/blog/HexoBlog;

    include other.conf;
    #error_page   404   /404.html;
    location ~ .*\.(ico|gif|jpg|jpeg|png|bmp|swf)$
    {
        access_log   off;
        expires      1d;
    }

    location ~ .*\.(js|css|txt|xml)?$
    {
        access_log   off;
        expires      12h;
    }
}

server
{
    server_name blog.winsky.wang ;
    listen 80;

    rewrite ^/(.*) https://$server_name$1 permanent;#跳转到Https
}
```

然后重启一下Nginx站点配置`nginx -s reload`，然后再访问`https://blog.winsky.wang/`，发现站点已经快了很多。爽歪歪，有木有！！

先别急着爽，作为一个大忙（lan）人，我可不想每次更新都要登上VPS手动拉取最新的更新。之前我们使用了`webhook`来自动部署，现在还一样，不过脚本要有一点小小的变动了。

修改之前的`deploy.sh`脚本，更新内容如下
```shell
cd /home/blog/HexoBlog
git reset --hard
git pull origin master
```

每次写完文章，执行一下`hexo clean && hexo generate && hexo deploy`就可以借助webhook自动更新VPS上的文件内容了。是不是真的很方便，要不要点个赞！


## 修改推送到dev分支
网站页面是保存了，部署也自动执行了，但这时候我们还没有保存我们的hexo原始文件，包括我们的文章md文件，我们千辛万苦修改的主题配置等。。。

接下来使用下面的步骤将他们都统统推送到hexo分支上去。
```
git add .
git commit -m “change description”
git push origin dev
```

这样就OK了，万事大吉~

# 什么是 TTFB

TTFB 是 Time to First Byte 的缩写，指的是浏览器开始收到服务器响应数据的时间（后台处理时间+重定向时间），是反映服务端响应速度的重要指标。

就像你问朋友了一个问题，你的朋友思考了一会儿才给你答案，你朋友思考的时间就相当于 TTFB。你朋友思考的时间越短，就说明你朋友越聪明或者对你的问题越熟悉。

对服务器来说，TTFB 时间越短，就说明服务器响应越快。





[1]: https://blog.winsky.wang/Hexo博客/自动将更新部署到VPS/ "自动将更新部署到VPS"