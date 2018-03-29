---
title: 内存溢出、OutOfMemoryError、StackOverflowError
date: 2018-03-10 13:47:14
updated: 2018-03-10 13:47:14
tags:
  - Java
  - JVM
categories: 
  - Java
  - JVM
---

虽然`Java`不需要开发人员显示的分配和回收内存，但了解`JVM`内存管理和回收机制，有助于我们在日常工作中排查各种内存溢出或泄露问题，解决性能瓶颈，达到更高的并发量，写出更高效的程序。本文重点介绍`Java`中的几个内存管理相关的异常
我们可以带着以下几个问题去学习自动内存管理机制：
- 什么操作可能导致内存溢出？
- 有哪些种类的内存溢出？
- 都是在内存的哪些区域溢出？

<!-- more --> 

![image](http://img.blog.csdn.net/20140227110650421)

# 运行时的数据区域
Java虚拟机在执行Java程序的过程中会把它所管理的内存划分为若干个不同的数据区域，如下图所示
![image](http://img.blog.csdn.net/20140227111132671)

其中虚拟机栈、本地方法栈和程序技术器是线程私有的，方法区和堆是线程共享的.

> 本篇着重关注每个区域可能抛出的异常，对JVM中每个区域的描述，也可以参考[Java内存管理及GC机制][1]中的相关描述

## 程序计数器
作用:当前线程所执行的字节码的行号指示器
- 字节码解释器工作时通过改变它的值来选取下一条需要执行的字节码指令
- 分支、循环、跳转、异常处理和线程恢复都依赖于它

## 虚拟机栈
栈的作用：栈用于存储局部变量表、操作数栈、动态链接和方法出口等信息.

其中局部变量表用于存放`8`种基本数据类型(`boolean，byte，char，short，int，float，long，double`)和`reference`类型

`reference`类型：
- 指向对象起始地址的引用指针
- 指向一个代表对象的句柄
- 指向一条字节码指令的地址

可抛出两种异常状况：
- 线程请求的栈深度大于虚拟机所允许的栈深度，抛出`StackOverflowError`异常
- 当扩展时无法申请到足够的内存时会抛出`OutOfMemoryError`异常

## 本地方法栈
与虚拟机栈的作用非常相似.其区别是虚拟机栈执行`Java`方法服务，而本地方法栈则为虚拟机使用到的`Native`方法服务

同时也会抛出`StackOverflowError`和`OutOfMemoryError`异常

## 堆
堆的作用：分配所有的对象实例和数组

可以抛出`OutOfMemoryError`异常。

## 方法区
方法区的作用:用于存储已被虚拟机加载的类信息(`Class`)、常量(`final`修饰)、静态变量(`static`)和即时编译器编译后的代码(`code`)

可以抛出`OutOfMemoryError`异常

## 运行时常量池
属于方法区的一部分，用于存放编译期生成的各种字面量和符号引用，在类加载后存放到方法区的运行时常量池中。可抛出`OutOfMemoryError`异常

# 对象访问
> 参考[Java内存管理及GC机制][1]中的相关描述

# OutOfMemoryError异常
在`Java`虚拟机规范的描述中，除了程序计数器外，虚拟机内存的其他几个运行时区域都有发生`OutOfMemoryError`异常的可能。

下面通过若干实例来验证异常发生的场景。**以下代码的开头都注释了执行时所需要设置的虚拟机启动参数，这些参数对实验结果有直接影响，请调试代码的时候不要忽略掉。**

## Java堆溢出
堆里放的是`new`出来的对象，所以这部分很简单不断的`new`对象就可以了，但是为了防止对象`new`出来之后被`GC`，所以把对象`new`出来的对象放到一个`List`中去即可。为了有更好的效果，可以在运行前，调整堆的参数。
```Java
/**
 * author: winsky
 * date: 2018/3/10
 * description:堆溢出
 * VM Args: -Xms20m -Xmx20m -XX:+HeapDumpOnOutOfMemoryError
 */
public class HeapOOM {
    private static class OOMObject {
    }

    public static void main(String[] args) {
        List<OOMObject> list = new ArrayList<>();
        while (true) {
            list.add(new OOMObject());
        }
    }
}
```
输出结果：
```
java.lang.OutOfMemoryError: Java heap space
Dumping heap to java_pid949.hprof ...
Heap dump file created [28011659 bytes in 0.165 secs]
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
	at java.util.Arrays.copyOf(Arrays.java:3210)
	at java.util.Arrays.copyOf(Arrays.java:3181)
	at java.util.ArrayList.grow(ArrayList.java:261)
	at java.util.ArrayList.ensureExplicitCapacity(ArrayList.java:235)
	at java.util.ArrayList.ensureCapacityInternal(ArrayList.java:227)
	at java.util.ArrayList.add(ArrayList.java:458)
	at com.winsky.learn.jvm.HeapOOM.main(HeapOOM.java:19)
```

## 虚拟机栈溢出
在单线程的堆中我们不断的让一个成员变量自增，容纳这个变量的单元无法承受这个变量了，就抛出`StackOverflowError`了。

可以开尽量多的线程，并在每个线程里调用`native`的方法，就自然会抛出 `OutOfMemoryError`了。
```Java
/**
 * author: winsky
 * date: 2018/3/10
 * description:
 */
public class JavaVMStackSOF {
    private int stackLength = 1;

    private void stackLeak() {
        stackLength++;
        stackLeak();
    }

    public static void main(String[] args) {
        JavaVMStackSOF oom = new JavaVMStackSOF();
        try {
            oom.stackLeak();
        } catch (Throwable e) {
            System.out.println("Stack length:" + oom.stackLength);
            throw e;
        }
    }
}
```
输出结果：
```
Exception in thread "main" java.lang.StackOverflowError
Stack length:18775
	at com.winsky.learn.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:13)
	at com.winsky.learn.jvm.JavaVMStackSOF.stackLeak(JavaVMStackSOF.java:13)
```

## 方法区溢出
最近看深入理解Java虚拟机，在实战OutOfMemoryError的运行时常量池溢出时，我的Intellij提示如下:
```Java
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=10m; support was removed in 8.0
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=10m; support was removed in 8.0
```
具体描述可以参见[Java8移除永久代][2]

## 运行时常量池溢出
同方法区溢出的道理，`Java8`之后也不会看到`java.lang.OutOfMemoryError: PermGen space`了


[1]: https://blog.winsky.wang/Java/JVM/Java%E5%86%85%E5%AD%98%E7%AE%A1%E7%90%86%E5%8F%8AGC%E6%9C%BA%E5%88%B6/ "Java内存管理及GC机制"
[2]: https://blog.winsky.wang/Java/JVM/Java8%E7%A7%BB%E9%99%A4%E6%B0%B8%E4%B9%85%E4%BB%A3/ "Java8移除永久代"