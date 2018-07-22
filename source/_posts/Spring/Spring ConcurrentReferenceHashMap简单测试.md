---
title: Spring ConcurrentReferenceHashMap简单测试
date: 2018-07-22 15:15:14
updated: 2018-07-22 15:15:14
tags:
  - Spring
categories: 
  - Spring
---

这周在写代码的时候，由于配置了IDE的快捷提示，一不留神使用了`ConcurrentReferenceHashMap`这个新奇的类，虽然不会引发什么bug，但是还是在CR的时候被师兄发现了。

本文就来探讨一下`ConcurrentReferenceHashMap`这个map具体是什么类。


<!-- more -->

ConcurrentReferenceHashMap是自spring3.2后增加的一个同步的软(虚)引用Map。关于软引用(SoftRefrence)和虚引用(WeakRefrence可以参见[Java四种引用类型[1]。废话不多说直接上测试代码:

```Java
@Test
public void test() throws InterruptedException {
    String key = new String("key");
    String value = new String("val");
    Map<String, String> map = new ConcurrentReferenceHashMap<>(8, ReferenceType.WEAK);
    map.put(key, value);
    System.out.println(map);
    key = null;
    System.gc();
    TimeUnit.SECONDS.sleep(5);
    System.out.println(map);
}
```
![image](https://pic.winsky.wang/images/2018/07/22/123.jpg)

神奇的事发生了。通过代码我们可以看到。我先构建了一个虚引用的map对象（也就是本文主角ConcurrentReferenceHashMap），然后新建对象key,value并将两个对象放入Map中进行保存。然后使key对象的强引用置为null。然后调用系统GC。由于系统GC的特殊性质并不能保证系统立马进行GC操作所已紧接着让主线程睡眠5s。接着打印我们的map对象发现map中的对象自动被移除了。 

接下来我不置空key而将value置空发现结果相同。 

结论： 

查看ConcurrentReferenceHashMap源码发现起底层实现依赖的是RefrenceQueue完成自动移除操作。时间有限就写到这里。有时间再进行完善。




[1]: "Java四种引用类型"