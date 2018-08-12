---
title: Spring AOP @Before、@Around、@After等执行顺序
date: 2018-03-13 12:07:14
updated: 2018-03-13 12:07:14
tags:
  - Spring
  - AOP
categories: 
  - Spring
---

我们都知道，Spring AOP中常用的拦截注解有@Before，@Around，@After。

那么问题来了，你知道他们的执行顺序是怎样的吗？恐怕这个问题还是有很多同学回答不上来，没关系，阅读完本文你就知道啦。

<!-- more -->

先上结论：
# 一个方法只被一个Aspect类拦截

在一个方法只被一个`aspect`类拦截时，`aspect`类内部的`advice`将按照以下的顺序进行执行：

## 正常流程
![image](https://pic.winsky.wang/images/2018/08/12/726e052bf36fbaee.png)

## 异常流程
注意，这里的图有误，执行完`method`触发异常之后，是转到`After`去执行

![image](https://pic.winsky.wang/images/2018/08/12/579c224beb0ac168.png)

# 同一个方法被多个Aspect类拦截
这种情况下，`aspect1`和`aspect2`的执行顺序是未知的。

为了指定每个`aspect`的执行顺序，可以使用两种方法：
- 实现`org.springframework.core.Ordered`接口，实现它的`getOrder()`方法
- 给`aspect`添加`@Order`注解，该注解全称为：`org.springframework.core.annotation.Order`

不管采用上面的哪种方法，都是值越小的`aspect`越先执行。 

![image](https://pic.winsky.wang/images/2018/08/12/aspect.png)

**【注意】**

如果在同一个`aspect`类中，针对同一个`pointcut`，定义了两个相同的`advice`(比如，定义了两个`@Before`)，那么这两个`advice`的执行顺序是无法确定的，哪怕你给这两个`advice`添加了`@Order`这个注解，也不行。这点切记。



> [Spring AOP @Before @Around @After 等 advice 的执行顺序](http://blog.csdn.net/rainbow702/article/details/52185827)