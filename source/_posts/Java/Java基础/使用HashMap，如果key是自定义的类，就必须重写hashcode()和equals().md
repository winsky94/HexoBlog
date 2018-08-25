---
title: 使用HashMap，如果key是自定义的类，就必须重写hashcode()和equals()
date: 2018-08-25 22:35:14
updated: 2018-08-25 22:35:14
tags:
  - Java
  - HashMap
categories: 
  - Java
  - Java基础
---

hashcode()和equals()都继承于Object，并且Object都提供了默认实现，具体可以参考[Java根类Object的方法说明][1]。关于Java中HashMap的相关原理可以参考前面的两篇文章，[HashMap源码阅读][2]和[HashMap为什么线程不安全][3]。

在实际使用中，如果HashMap中的key是自定义的类，一般我们都会重写hashcode()和equals()，这是为什么呢？？

<!-- more -->
首先我们先回顾一下Object中hashcode()和equals()两个方法的默认实现。
```Java
public boolean equals(Object obj){
    return (this == obj);
}

// 是一个本地方法，返回的对象的地址值。
public native int hashCode();
```
默认的根类Object提供了两个方法的实现，为什么我们还需要重写它们呢？解答这个问题，需要从两个方面展开。

**1. hashcode()和equals()是在哪里被用到的？什么用的？**

HashMap是基于散列函数，以数组和链表的方式实现的。

而对于每一个对象，通过其hashCode()方法可为其生成一个整形值（散列码），该整型值被处理后，将会作为数组下标，存放该对象所对应的Entry（存放该对象及其对应值）。

equals()方法则是在HashMap中插入值或查询时会使用到。当HashMap中插入值或查询值对应的散列码与数组中的散列码相等时，则会通过equals方法比较key值是否相等，所以想以自建对象作为HashMap的key，必须重写该对象继承object的equals方法。

**2. 本来不就有hashcode()和equals()了么？干嘛要重写，直接用原来的不行么？**
     
HashMap中，如果要比较key是否相等，要同时使用这两个函数！因为自定义的类的hashcode()方法继承于Object类，其hashcode码为默认的内存地址，这样即便有相同含义的两个对象，比较也是不相等的，例如，
```Java
Student st1 = new Student("wei","man");

Student st2 = new Student("wei","man"); 
```
正常理解这两个对象再存入到hashMap中应该是相等的，但如果你不重写 hashcode（）方法的话，比较是其地址，不相等！

HashMap中的比较key是这样的，先求出key的hashcode(),比较其值是否相等，若相等再比较equals(),若相等则认为他们是相等 的。若equals()不相等则认为他们不相等。如果只重写hashcode()不重写equals()方法，当比较equals()时只是看他们是否为 同一对象（即进行内存地址的比较）,所以必定要两个方法一起重写。HashMap用来判断key是否相等的方法，其实是调用了HashSet判断加入元素 是否相等。



[1]: https://blog.winsky.wang/Java/源码阅读/Java根类Object的方法说明/ "Java根类Object的方法说明"
[2]: https://blog.winsky.wang/Java/源码阅读/HashMap源码阅读/ "HashMap源码阅读"
[3]: https://blog.winsky.wang/Java/源码阅读/HashMap为什么线程不安全/ "HashMap为什么线程不安全"


