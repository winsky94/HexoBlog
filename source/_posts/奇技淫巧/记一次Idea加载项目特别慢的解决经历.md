title: 记一次Idea加载项目特别慢的解决经历
author: winsky
tags:
  - IDEA
categories:
  - 奇技淫巧
date: 2019-12-09 23:54:00
---
公司的小二后台项目，刚开始引入项目的时候，idea打开项目挺快。今天想运行一下一个web前端页面（使用了React框架）。我使用npm安装运行后，idea这里就开始变得特别慢，一直卡在构建index菊花圈中。

并且一直扫描的是node_modules目录，大概就是node_modules目录引起的。

解决方案：重新打开一个小项目，在`Perferencs->Editor->File Types->ignore files and folders`添加`node_modules`, 重启idea。


问题完美解决，希望能帮助遇到类似问题的童鞋们。

<!-- more -->