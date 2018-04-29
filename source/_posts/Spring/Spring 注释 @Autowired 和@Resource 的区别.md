---
title: Spring 注释 @Autowired 和@Resource 的区别
date: 2018-03-11 10:10:14
updated: 2018-03-11 10:10:14
tags:
  - Spring
categories: 
  - Spring
---


`@Autowired`和`@Resource`是`Spring`中进行依赖注入时常用的两个注解。

它们都可以进行依赖注入，那它们有什么区别呢？

在实际生产应用中，我们应该偏向于使用哪种呢？

<!-- more -->

`@Autowired`和`@Resource`都可以用来装配`bean`，都可以写在字段上，或者方法上。

`@Autowired`属于`Spring`的；`@Resource`为`JSR-250`标准的注释，属于`J2EE`的。

`@Autowired`默认按类型装配，默认情况下必须要求依赖对象必须存在，如果要允许`null`值，可以设置它的`required`属性为`false`，例如：`@Autowired(required=false)` ，如果我们想使用名称装配可以结合`@Qualifier`注解进行使用，如下：
```Java
@Autowired() 
@Qualifier("baseDao")
private BaseDao baseDao;
```

`@Resource`，默认安装名称进行装配，名称可以通过`name`属性进行指定，如果没有指定`name`属性，当注解写在字段上时，默认取字段名进行安装名称查找，如果注解写在`setter`方法上默认取属性名进行装配。当找不到与名称匹配的`bean`时才按照类型进行装配。但是需要注意的是，**如果name属性一旦指定，就只会按照名称进行装配**。
```Java
@Resource(name="baseDao")
private BaseDao baseDao;
```

推荐使用：`@Resource`注解在字段上，这样就不用写`setter`方法了，并且这个注解是属于`J2EE`的，减少了与`Spring`的耦合。这样代码看起就比较优雅。