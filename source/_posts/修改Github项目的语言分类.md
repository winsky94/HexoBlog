---
title: 修改Github项目的语言分类
date: 2018-02-10 15:26:14
updated: 2018-02-10 15:26:14
tags:
  - Git
categories: 
  - Git
---

自己辛辛苦苦写的`Java`项目，因其中包含了一定了前端代码，在传到`Github`上被标记成了`JavaScript`语言，这是一件多么蛋疼的事儿

那如何修改Github项目的语言分类呢？？

<!-- more -->

在开始正文之前，请允许我先描述一下遇到这个问题的背景。

早上起来看到论坛上有人说[TaoCode][1]快关闭了，打开电脑登录一看还真是
![taocode下线通知][2]

想起来，`TaoCode SVN`还是上软工2开始接触的第一个版本控制工具。当时，钦哥哥要求将代码部署在`SVN`上，本来是要自己搭建`SVN`服务器的，后来我们取巧，发现`TaoCode`已经帮我们部署好了`SVN`服务器，于是我们便欢快地注册账号使用起来（注册于`2014-09-20`）

这一用便是三四年的时间，虽然大四在阿里实习的时候，接触到了另一个版本控制工具`Git`，便不怎么使用了`TaoCode SVN`了。但可以说`TaoCode`陪伴我从一个啥都不会的小白成长为如今的合格 ~~程序猿~~ 研发工程师，此中别有一番感情[捂脸]

在`TaoCode`上还存在着大大小小近10个项目，如今`TaoCode`即将停止服务，所以我便想着将自己的代码迁移到[Github][3]上来。`Github`本身提供了从`SVN`导入仓库的功能，这个使用起来很方便。然鹅，导入的项目被`Github`自动识别成了`JavaScript`语言，我可是纯正的`Java web`项目啊。那要怎么修改Github项目的语言分类呢？？

注意，前方高能~~~下面正式介绍如何修改Github项目的语言分类

在项目目录中创建一个名为`.gitattributes`的文件，添加以下代码：
```
*.js linguist-language=Java
```
然后重新上传到`Github`上，就可以发现项目的语言变成`Java`了，其他语言同理

根据我的理解，如果项目中没有`.gitattributes`的文件来显式指出项目的语言，那么`Github`会自动根据项目文件出现最多的后缀来判断项目的语言，所以，一个`Java web`项目很容易就被判定成`JavaScript`语言

上述的解决办法是通过将`.js`结尾的文件当成`Java`文件来统计，类似的还有
```
*.html linguist-language=Java
*.js linguist-language=Java
*.css linguist-language=Java
....
```
其他可以自由变通

---
[1]: http://code.taobao.org/ "TaoCode"
[2]: http://taocode-uploads.oss-cn-hangzhou.aliyuncs.com/Snip20180125_2.png "taocode下线通知"
[3]: https://github.com/winsky94 "Github"
