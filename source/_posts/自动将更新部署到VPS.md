---
title: 自动将更新部署到VPS
date: 2018-02-10 11:55:23
updated: 2018-02-10 11:55:23
tags:
	- HEXO
  	- 博客
  	- 部署
categories: 
	- Hexo博客
---
---
博客雏形搭建好了之后，又浪了几天没有折腾。昨天晚上自己买了个域名，想着是时候好好把博客完善起来了。下面继续开始折腾...

前面我们介绍了如何在[搬瓦工VPS][1]上[快速搭建自己的个人博客][2]，做了相关的[主题美化][3]，同时也进行了简单的[SEO优化][4]。

在这个过程中，每次需要更新，我都是直接手动将文件拖到VPS上的。作为一个“懒人”，这个过程还是太烦了。今天我们就来学习一下如何自动将博客部署到VPS上。

这篇文章将如何搭建hexo，以及如何通过git webhooks实现远程vps的自动部署

<!-- more -->

具体流程：先在本机搭建好hexo环境，push到git仓库，再部署到服务器上

# 准备工作
## 本地安配置hexo环境
在本地用hexo搭建一个个人博客很简单，分分钟可以搞定。如果以前没有接触过，可以参考我前面的博文：[个人博客Hexo搭建][2]

## 提交到远程仓库
首先需要一个在线的仓库，可以选择[github](https://github.com/)或者[Coding.net](https://coding.net/)。这里我选择了常用的[github](https://github.com/)

先在`github`上创建一个项目`HexoBlog`，并拷贝仓库`ssh`地址（使用`ssh`需要配置`ssh`公钥和私钥，如果不会配可以`google`一下或使用`http`地址）。注意，如果需要通过webhooks实现服务器自动化部署，推荐使用ssh会更方便一些

然后在本地`hexo`目录初始化本地仓库并提交到`github`
```
git init
git add * 
git commit -m "first commit"
git remote add origin git@github.com:winsky94/HexoBlog.git
git push -u origin master
```








> [通过Git Hooks自动部署Hexo到VPS](https://blog.yizhilee.com/post/deploy-hexo-to-vps/)

---
[1]: https://bwh1.net/aff.php?aff=24742 "搬瓦工VPS"
[2]: http://blog.winsky.wang/2018/02/03/%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A2Hexo%E6%90%AD%E5%BB%BA/ "快速搭建自己的个人博客"
[3]: http://blog.winsky.wang/2018/02/04/Hexo%E5%8D%9A%E5%AE%A2Next%E4%B8%BB%E9%A2%98%E9%85%8D%E7%BD%AE/ "主题美化"
[4]: http://blog.winsky.wang/2018/02/06/%E5%A6%82%E4%BD%95%E8%AE%A9%E8%B0%B7%E6%AD%8C%E5%92%8C%E7%99%BE%E5%BA%A6%E6%90%9C%E7%B4%A2%E5%88%B0%E8%87%AA%E5%B7%B1%E7%9A%84%E5%8D%9A%E5%AE%A2/ "SEO优化"