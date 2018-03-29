---
title: Java8移除永久代
date: 2018-03-10 13:41:14
updated: 2018-03-10 13:41:14
tags:
  - Java
  - JVM
categories: 
  - Java
  - JVM
---

最近看深入理解Java虚拟机, 在实战OutOfMemoryError的运行时常量池溢出时, 我的Intellij提示如下:
```Java
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=10m; support was removed in 8.0
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=10m; support was removed in 8.0
```
原书没有说会出现这个警告,所以上网详细查下相关资料,汇总如下。

<!-- more -->
在`JDK1.7`中,已经把原本放在永久代的字符串常量池移出,放在堆中.为什么这样做呢? 

因为使用永久代来实现方法区不是个好主意, 很容易遇到内存溢出的问题.我们通常使用`PermSize`和`MaxPermSize`设置永久代的大小,这个大小就决定了永久代的上限,但是我们不是总是知道应该设置为多大的,如果使用默认值容易遇到OOM错误.

找下`JDK1.8`的[Milestones](http://openjdk.java.net/projects/jdk8/milestones) 其中 `JEP 122: Remove the Permanent Generation`说的就是移除永久代.

文中说实现目标: 

类的元数据,字符串池,类的静态变量将会从永久代移除,放入`Java heap`或者`native memory`.
- 其中建议`JVM`的实现中将**类的元数据放入`native memory`**
- 将**字符串池和类的静态变量放入`Java`堆**中.
- 这样可以加载多少类的元数据就不在由`MaxPermSize`控制,而由系统的实际可用空间来控制.

为什么这么做呢? 
- 减少OOM只是表因
- 更深层的原因还是要合并`HotSpot`和`JRockit`的代码
- `JRockit`从来没有一个叫永久代的东西,但是运行良好,也不需要开发运维人员设置这么一个永久代的大小.

当然不用担心运行性能问题了,在覆盖到的测试中,程序启动和运行速度降低不超过`1%`,但是这一点性能损失换来了更大的安全保障.


> 转自[Java8移除永久代](http://www.voidcn.com/article/p-evhbuujr-nq.html)