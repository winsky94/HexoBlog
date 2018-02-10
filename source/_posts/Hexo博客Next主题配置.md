---
title: Hexo博客Next主题配置
date: 2018-02-04 10:49:21
updated: 2018-02-04 10:49:21
tags:
  - HEXO
  - Next
  - 博客
categories: 
  - Hexo博客
---
前面我们介绍了如何在[搬瓦工VPS][1]上[快速搭建自己的个人博客][2],不会的小伙伴赶快去学习一下

其中我们也介绍了如何将`Hexo`默认的主题替换为`Next`主题，但是`Next`的原始配置还是太过简洁，看上去不尽人意

因此这次我们就来学习一下如何优化`Next`的配置，丰富其功能。一起来吧~~

<!-- more -->

# 站点设置
## 展示社交联系方式
- 编辑`站点配置文件`
- 修改`socal`字段，并注释相应的字段，修改值

## 设置社交链接居中对齐
- 修改`themes\next\source\css\_common\components\sidebar\sidebar-author-links.styl`文件，添加如下样式
```
.links-of-author-item {
  text-align: center;
}
```

## 添加友链
- 编辑`主题配置文件`
- 添加如下内容
```
# title, chinese available
links_title: 友情链接
# links
links:
  百度: https://www.baidu.com/
```
- 修改`Blog rolls`下的`links_title`为中文

## 设置友链左对齐
- 本博客侧栏友情链接使用了与侧栏社交链接相同的css样式，但文本左对齐
- 实现方法为：
修改`themes\next\layout\_macro\sidebar.swig`，将如下内容
```
<ul class="links-of-blogroll-list">
  {% for name, link in theme.links %}
    <li class="links-of-blogroll-item">
      <a href="{{ link }}" title="{{ name }}" target="_blank">
        {{ name }}
      </a>
    </li>
  {% endfor %}
</ul>
```
修改为
```
<ul class="links-of-blogroll-list">
    {% for name, link in theme.links %}
        <span class="links-of-author-item" style="text-align:left">
            <a href="{{ link }}" title="{{ name }}" target="_blank">
                {{ name }}
            </a>
        </span>
    {% endfor %}
</ul>
```

## SEO推广
### sitemap
- Sitemap用于通知搜索引擎网站上有哪些可供抓取的网页，以便搜索引擎可以更加智能地抓取网站
- 执行命令`npm install hexo-generator-sitemap --save`和`npm install hexo-generator-baidu-sitemap --save`，安装插件，用于生成`sitemap`
- 运行`hexo g`生成站点文件
- 在`站点配置文件`中添加如下字段
```
# Sitemap Setting
sitemap:
  path: sitemap.xml
baidusitemap:
  path: baidusitemap.xml
```
### 添加 robots.txt
- 文件放在站点的source文件夹下
```
User-agent: *
Allow: /
Allow: /archives/

Disallow: /js/
Disallow: /css/
Disallow: /fonts/
Disallow: /lib/
Disallow: /fancybox/

Sitemap: http://www.cylong.com/sitemap.xml
Sitemap: http://www.cylong.com/baidusitemap.xml

```

## 添加字数统计
- 安装`hexo-wordcount`插件`npm install hexo-wordcount --save`
- 在`站点配置文件`中开启字数统计配置
```
# 字数统计
word_count: true
```
- 然后在`/themes/next/layout/_partials/footer.swig`文件尾部加上
```
<div class="theme-info">
  <div class="powered-by"></div>
  <span class="post-count">博客全站共{{ totalcount(site) }}字</span>
</div>
```

# 主题设定 
- version: 6.0.3
## 选择 Scheme
- `Scheme`是`NexT`提供的一种特性
- 借助于`Scheme`，`NexT`提供了多种不同的外观
- 同时，几乎所有的配置都可以在`Scheme`之间共用
- 目前`NexT`支持三种`Scheme`，他们是：
    - `Muse` - 默认`Scheme`，这是 `NexT`最初的版本，黑白主调，大量留白
    - `Mist` - `Muse`的紧凑版本，整洁有序的单栏外观
    - `Pisces` - 双栏`Scheme`，小家碧玉似的清新
- `Scheme`的切换通过更改`主题配置文件`，搜索`scheme`关键字，你会看到有三行`Scheme`的配置，将你需用启用的`scheme`前面注释`#`去除即可
```
# ---------------------------------------------------------------
# Scheme Settings
# ---------------------------------------------------------------

# Schemes
#scheme: Muse
#scheme: Mist
scheme: Pisces
#scheme: Gemini
```

## 设置语言
- 编辑`站点配置文件`，将`language`设置成你所需要的语言
- 具体支持的语言可以查看[官网说明](http://theme-next.iissnan.com/getting-started.html#select-language)
- 建议明确设置你所需要的语言，例如选用简体中文，配置如下
```
language: zh-CN
```

## 设置菜单
### 展示菜单内容
- 菜单配置包括三个部分
    - 第一是菜单项（名称和链接）
    - 第二是菜单项的显示文本
    - 第三是菜单项对应的图标。`NexT`使用的是`Font Awesome`提供的图标，`Font Awesome`提供了`600+`的图标，可以满足绝大的多数的场景，同时无须担心在`Retina`屏幕下图标模糊的问题。
- 编辑`主题配置文件`，修改以下内容：
    - 设定菜单内容，对应的字段是`menu`菜单内容的设置格式是：`item name: link`。其中`item name`是一个名称，这个名称并不直接显示在页面上，她将用于匹配图标以及翻译
    ```
    # ---------------------------------------------------------------
    # Menu Settings
    # ---------------------------------------------------------------
    
    # When running the site in a subdirectory (e.g. domain.tld/blog), remove the leading slash from link value (/archives -> archives).
    # Usage: `Key: /link/ || icon`
    # Key is the name of menu item. If translate for this menu will find in languages - this translate will be loaded; if not - Key name will be used. Key is case-senstive.
    # Value before `||` delimeter is the target link.
    # Value after `||` delimeter is the name of FontAwesome icon. If icon (with or without delimeter) is not specified, question icon will be loaded.
    menu:
      home: / || home
      archives: /archives/ || archive
      tags: /tags/ || tags
      categories: /categories/ || th
      about: /about/ || user
      #schedule: /schedule/ || calendar
      #sitemap: /sitemap.xml || sitemap
      #commonweal: /404/ || heartbeat
    ```
    - 注意：若你的站点运行在子目录中，请将链接前缀的`/`去掉
    - `NexT`默认的菜单项有（斜体的项表示需要手动创建这个页面）
    
    键值 | 设定值 | 显示文本（简体中文）
    ---|--- | ---
    home | home: / | 主页
    archives | archives: /archives | 归档页
    categories | categories: /categories | *分类页*
    tags | tags: /tags | *标签页* 
    about | about: /about | *关于页面* 
    commonweal | commonweal: /404.html | *公益 404*
    
    - 设置菜单项的显示文本。在第一步中设置的菜单的名称并不直接用于界面上的展示。Hexo 在生成的时候将使用 这个名称查找对应的语言翻译，并提取显示文本。这些翻译文本放置`NexT`主题目录下的`languages/{language}.yml`（`{language}` 为你所使用的语言）
    以简体中文为例，若你需要添加一个菜单项，比如`something`。那么就需要修改简体中文对应的翻译文`languages/zh-Hans.yml`

### 添加标签页
- 在站点`source`文件夹下，建立`tags`目录
- 在`tags`目录中创建`index.md`，内容如下：
```
---
title: 标签
date: 2018-02-04 21:33:54
type: "tags"
comments: false
---
```

### 添加分类页
- 在站点`source`文件夹下，建立`categories`目录
- 在`categories`目录中创建`index.md`，内容如下：
```
---
title: 分类
date: 2018-02-04 21:33:54
type: "categories"
comments: false
---
```

### 添加关于页
- 在站点`source`文件夹下，建立`about`目录
- 在`about`目录中创建`index.md`，具体内容参加`github`源码

## 设置侧栏
- 默认情况下，侧栏仅在文章页面（拥有目录列表）时才显示，并放置于右侧位置。 可以通过修改`主题配置文件`中的`sidebar`字段来控制侧栏的行为。
- 侧栏的设置包括两个部分，其一是侧栏的位置， 其二是侧栏显示的时机。
    - 设置侧栏的位置，修改`sidebar.position`的值，支持的选项有
        - `left` - 靠左放置
        - `right` - 靠右放置
     ```
     sidebar:
        position: left
     ```
    - 设置侧栏显示的时机，修改`sidebar.display`的值，支持的选项有
        - `post` - 默认行为，在文章页面（拥有目录列表）时显示
        - `always` - 在所有页面中都显示
        - `hide` - 在所有页面中都隐藏（可以手动展开）
        - `remove` - 完全移除
    ```
    sidebar:
        display: post
    ```
## 设置头像
- 编辑`站点配置文件`， 添加字段`avatar`，值设置成头像的链接地址
- 其中，头像的链接地址可以是：
    - 完整的互联网 URI
    - 站点内的地址
        - 将头像放置主题目录下的`source/uploads/`（新建`uploads`目录若不存在），配置为：`avatar:/uploads/avatar.png`
        - 或者 放置在 `source/images/`目录下，配置为：`avatar: /images/avatar.png`
```
# Avatar
avatar: /images/avatar.jpg
```

## 设置作者昵称
- 编辑`站点配置文件`
- 设置`author`为你的昵称

## 设置站点描述
- 编辑`站点配置文件`
- 设置`description`为你的站点描述。站点描述可以是你喜欢的一句签名:)

## 设置首页预览和阅读全文
- 编辑`主题配置文件`
- 设置`auto_excerpt`的配置
```
auto_excerpt:
  enable: true
  length: 300
```
## 关闭打开文章自动跳转到more
- 编辑`主题配置文件`
- 修改`scroll_to_more`值为`false`

# 集成第三方服务
## 百度统计
- 登录[百度统计](http://tongji.baidu.com/), 定位到站点的代码获取页面
- 复制 hm.js? 后面那串统计脚本 id，如
![image](http://theme-next.iissnan.com/uploads/five-minutes-setup/analytics-baidu-id.png)
- 编辑`主题配置文件`，修改字段 `baidu_analytics`字段，值设置成你的百度统计脚本`id`

## 谷歌统计
- 需科学上网
- 登录[谷歌统计](https://www.google.com/intl/zh-CN/analytics/)， 定位到管理页面
- 创建新的媒体资源，获取跟踪`id`
- 编辑`主题配置文件`，添加字段 `google_analytics`字段，值设置成你的谷歌统计跟踪`id`

## 集成Disqus评论
- 注册登陆[Disqus](https://disqus.com/)
- 点击`Admin`进入管理页面
- 选择第二个`I want to install Disqus on my site`
- 按照表单填写信息，记住`Website Name`这条属性，配置文件中需要用到
- 接下来按照指引填写信息（基本都是默认就行）
- 安装过程中会出现下面页面，这里面会有disqus在不同博客系统上或者其他系统上对应的代码。因为hexo自带支持disqus，所以不需要这里面的代码，这个页面的内容会在其他除hexo之外的博客系统中用到，如果是hexo搭建博客disqus，可以跳过
![image](http://img.blog.csdn.net/20160220003532601)
- 接下来配置主题下面的`config.yml`文件
```
# Disqus
disqus:
  enable: true
  shortname: winsky #就是前面填写的Website Name属性
  count: true
  lazyload: false
```

## 不蒜子
- 编辑`主题配置文件`中的`busuanzi_count`的配置项
```
busuanzi_count:
  # count values only if the other configs are false
  enable: true
  # custom uv span for the whole site
  site_uv: true
  site_uv_header: <i class="fa fa-user"></i>
  site_uv_footer: 人
  # custom pv span for the whole site
  site_pv: true
  site_pv_header: <i class="fa fa-eye"></i>
  site_pv_footer: 次
  # custom pv span for one page only
  page_pv: true
  page_pv_header: <i class="fa fa-file-o"></i>
  page_pv_footer:
```
> [不蒜子][]

# 参考文章
> [next中文手册](http://theme-next.iissnan.com/)

> [Hexo+nexT主题搭建个人博客](http://www.wuxubj.cn/2016/08/Hexo-nexT-build-personal-blog/)

> [为Hexo NexT主题添加字数统计功能](https://eason-yang.com/2016/11/05/add-word-count-to-hexo-next/)

> [Github 搭建 hexo （四）——更换主题，disqus，RSS](http://blog.csdn.net/u010053344/article/details/50701191)

---
[1]: https://bwh1.net/aff.php?aff=24742 "搬瓦工VPS"
[2]: https://blog.winsky.wang/2018/02/03/%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A2Hexo%E6%90%AD%E5%BB%BA/ "快速搭建自己的个人博客"
[不蒜子]: http://ibruce.info/2015/04/04/busuanzi/ "不蒜子"