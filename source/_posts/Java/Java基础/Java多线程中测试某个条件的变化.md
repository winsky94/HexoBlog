---
title: Java多线程中测试某个条件的变化
date: 2018-03-13 15:20:14
updated: 2018-03-13 15:20:14
tags:
  - Java
categories: 
  - Java
  - Java基础
---

`wait`和`notify`方法，有个地方要注意，就是经典的生产者和消费模式，使用`wait`和`notify`实现，判断条件为什么要用`while`而不能使用`if`呢？

**其实是因为当线程`wait`之后，又被唤醒的时候，是从`wait`后面开始执行，而不是又从头开始执行的。**

所以如果用`if`的话，被唤醒之后就不会在判断`if`中的条件，而是继续往下执行了，如果`list`只是添加了一个数据，而存在两个消费者被唤醒的话，就会出现溢出的问题了，因为不会在判断`size`是否`==0`就直接执行`remove`了。但是如果使用`while`的话，从`wait`下面继续执行，还会返回执行`while`的条件判断，`size>0`了才会执行`remove`操作，所以这个必须使用`while`，而不能使用`if`来作为判断。

<!-- more -->

基于以上认知，下面这个是使用wait和notify函数的规范代码模板：
```Java
// The standard idiom for calling the wait method in Java   
synchronized (sharedObject) {   
    while (condition) {   
        sharedObject.wait();   
        // (Releases lock, and reacquires on wakeup)   
    }   
    // do action based upon condition e.g. take or put into queue   
}
```