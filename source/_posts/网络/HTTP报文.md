---
title: HTTP报文
date: 2018-03-17 11:21:21
updated: 2018-03-17 11:21:21
tags:
  - 网络
categories: 
  - 网络
---

HTTP报文是面向文本的，报文中的每一个字段都是一些ASCII码串，各个字段的长度是不确定的。HTTP有两类报文：请求报文和响应报文。

本文主要介绍HTTP报文的格式和具体内容。

<!-- more -->

# HTTP请求报文

一个HTTP请求报文由**请求行（request line）、请求头部（header）、空行和请求数据**4个部分组成，下图给出了请求报文的一般格式。

![image](https://pic.winsky.wang/images/2018/04/16/5832cc77ea1dbbdc281758e48b5d49c5.jpg)

## 请求行
请求行由**请求方法字段、URL字段和HTTP协议版本字段**3个字段组成，它们用空格分隔。例如，GET /index.html HTTP/1.1。

HTTP协议的请求方法有GET、POST、HEAD、PUT、DELETE、OPTIONS、TRACE、CONNECT。

## 请求头部
请求头部由**关键字/值对**组成，每行一对，关键字和值用英文冒号“:”分隔。请求头部通知服务器有关于客户端请求的信息，典型的请求头有：
```
User-Agent：产生请求的浏览器类型。

Accept：客户端可识别的内容类型列表。

Host：请求的主机名，允许多个域名同处一个IP地址，即虚拟主机。
```

## 空行
最后一个请求头之后是一个空行，发送回车符和换行符，通知服务器以下不再有请求头。

## 请求数据
请求数据不在GET方法中使用，而是在POST方法中使用。POST方法适用于需要客户填写表单的场合。与请求数据相关的最常使用的请求头是Content-Type和Content-Length。

# HTTP响应报文
HTTP响应也由三个部分组成，分别是：**状态行、消息报头、响应正文**。
```
＜status-line＞

＜headers＞

＜blank line＞

[＜response-body＞]
```
 正如你所见，在响应中唯一真正的区别在于第一行中用状态信息代替了请求信息。状态行（status line）通过提供一个状态码来说明所请求的资源情况。

状态行格式如下：

HTTP-Version Status-Code Reason-Phrase CRLF

其中，HTTP-Version表示服务器HTTP协议的版本；Status-Code表示服务器发回的响应状态代码；Reason-Phrase表示状态代码的文本描述。状态代码由三位数字组成，第一个数字定义了响应的类别，且有五种可能取值。

- 1xx：指示信息--表示请求已接收，继续处理。
- 2xx：成功--表示请求已被成功接收、理解、接受。
- 3xx：重定向--要完成请求必须进行更进一步的操作。
- 4xx：客户端错误--请求有语法错误或请求无法实现。
- 5xx：服务器端错误--服务器未能实现合法的请求。

常见状态代码、状态描述的说明如下。
- 200 OK：客户端请求成功。
- 400 Bad Request：客户端请求有语法错误，不能被服务器所理解。
- 401 Unauthorized：请求未经授权，这个状态代码必须和WWW-Authenticate报头域一起使用。
- 403 Forbidden：服务器收到请求，但是拒绝提供服务。
- 404 Not Found：请求资源不存在，举个例子：输入了错误的URL。
- 500 Internal Server Error：服务器发生不可预期的错误。
- 503 Server Unavailable：服务器当前不能处理客户端的请求，一段时间后可能恢复正常。


举个例子：HTTP/1.1 200 OK（CRLF）。