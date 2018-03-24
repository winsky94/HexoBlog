---
title: 个人博客Hexo搭建
date: 2018-02-03 17:49:21
updated: 2018-02-04 10:26:43
tags:
	- HEXO
	- 博客
categories: 
    - Hexo博客
---
# 前言
最近沉迷各种折腾，无心学习 T^T

VPS基本折腾完了，现在又想开始折腾自己搭建一个博客来耍耍

这篇笔记的博客也是搭建在[搬瓦工VPS][1]上的

<!-- more -->

# 安装过程
- 安装[nodejs](http://nodejs.org/)
- 安装[git](http://git-scm.com/)
- 安装hexo
    - `npm install -g hexo`
- 新建一个文件
    - `mkdir blog`
- 生成模板
    - `cd blog`
    - `hexo init`
- 安装依赖
    - `cd blog`
    - `npm install`
- 启动服务
    - `hexo s`，当控制台提示如下信息时表示启动成功
    ```
    [root@bwh themes]# hexo s
    INFO  Start processing
    INFO  Hexo is running at http://localhost:4000/. Press Ctrl+C to stop.
    ```
    - 通过`localhost:4000`来访问博客

# 切换主题
- 可以在[Themes-Hexo](https://hexo.io/themes/)页面查看各种各样的主题
- 将喜欢的主题下载下来，放到博客目录下的`themes`文件夹
- 之后修改博客的`_config.yml`文件
```
# Extensions
## Plugins: https://hexo.io/plugins/
## Themes: https://hexo.io/themes/
theme: next # 修改成你的主题文件夹名
```
- Hexo 默认主题是 landscape。我使用的是next主题，清晰简约，非常符合我的喜好。Next主题的配置可以参考
> [Next主题下载](https://github.com/theme-next/hexo-theme-next/releases)

> [Next主题中文文档](http://theme-next.iissnan.com/)
- 博客的具体配置，后面专门开一篇博文来记录一下

*** 2018-02-04 更新***
[Hexo博客Next主题配置][2]


# 参考文章
> [Hexo](https://hexo.io/)

> [Hexo搭建博客教程](https://thief.one/2017/03/03/Hexo%E6%90%AD%E5%BB%BA%E5%8D%9A%E5%AE%A2%E6%95%99%E7%A8%8B/)

> [Next主题中文文档](http://theme-next.iissnan.com/)


[1]: https://bwh1.net/aff.php?aff=29080 "搬瓦工VPS"
[2]: https://blog.winsky.wang/Hexo%E5%8D%9A%E5%AE%A2/%E8%87%AA%E5%8A%A8%E5%B0%86%E6%9B%B4%E6%96%B0%E9%83%A8%E7%BD%B2%E5%88%B0VPS/ "Hexo博客Next主题配置"