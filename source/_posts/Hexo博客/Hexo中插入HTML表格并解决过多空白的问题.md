---
title: Hexo中插入HTML表格并解决过多空白的问题
date: 2019-10-07 17:49:21
updated: 2019-10-07 17:49:21
tags:
	- HEXO
	- 博客
categories: 
    - Hexo博客
---

今天在写博文时，发现markdown无法支持复杂的表格，不支持单元格合并，只能借助HTML语言来绘制表格。

本文介绍如何快速地生成HTML表格，并解决HEXO样式下HTML表格有大量空白的问题。

<!-- more -->

我用下面的HTML代码做一个表格。
```
<table style="undefined;table-layout: fixed; width: 400px">
  <tr>
    <th rowspan="3">资产</th>
    <th>负债</th>
  </tr>
  <tr>
    <td>应付票据 $5</td>
  </tr>
  <tr>
    <th>所有者权益</th>
  </tr>
  <tr>
    <td>现金 $10</td>
    <td>初始投资 $5</td>
  </tr>
  <tr>
    <td>总计 $10</td>
    <td>总计 $10</td>
  </tr>
</table>
```

在有道云笔记中预览时，一切展示正常，但是部署到博客上的时候，却出现了大量的空白。

我们可以在浏览器中右击“查看源代码”，找到这个表格会看到，多出很多<br>标签来。html中<br>标签用于换行。

我后来在hexo的Issues中也发现了其他人出现了这个问题。然后开始各种找解决办法,下面给出两种解决办法。

## 方法一
将代码改为紧凑模式，修改代码如下
```
<table style="undefined;table-layout: fixed; width: 402px"><colgroup><col style="width: 201px"><col style="width: 201px"></colgroup><tr><th rowspan="3">资产</th><th>负债</th></tr><tr><td>应付票据 $5</td></tr><tr><td>应付账款 $10</td></tr><tr><td>现金 $12</td><td>所有者权益</td></tr><tr><td>应收账款 $3</td><td>初始投资 $5</td></tr><tr><td>存货 $0</td><td>利润</td></tr><tr><td>固定资产 $10</td><td>盈利 $5</td></tr><tr><td>总计 $25</td><td>总计 $25</td></tr></table>
```

也就是说代码标签之间不要留白，全部改为紧贴着的。

我们还可以利用这个[Table Generator](http://www.tablesgenerator.com/html_tables)在线工具来编辑表格，提供了html表格和markdown表格来生成用于hexo的表格。


## 方法二(推荐)
```
{% raw %}
html tags & content
{% endraw %}
```

我们可以利用上面的格式来编写表格，我个人认为这种最为简单便捷。
我们只需要把代码修改为以下这样即可。
```
{% raw %}
<table style="undefined;table-layout: fixed; width: 400px">
  <tr>
    <th rowspan="3">资产</th>
    <th>负债</th>
  </tr>
  <tr>
    <td>应付票据 $5</td>
  </tr>
  <tr>
    <th>所有者权益</th>
  </tr>
  <tr>
    <td>现金 $10</td>
    <td>初始投资 $5</td>
  </tr>
  <tr>
    <td>总计 $10</td>
    <td>总计 $10</td>
  </tr>
</table>
{% endraw %}
```

生成的表格同样不会出现大量空白，具体效果可以参考 [小白学借贷记账法](https://blog.winsky.wang/财务知识/小白学借贷记账法)
