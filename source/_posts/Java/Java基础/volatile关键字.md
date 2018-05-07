---
title: volatile关键字
date: 2018-03-14 20:01:14
updated: 2018-03-14 20:01:14
tags:
  - 多线程
categories: 
  - Java
  - Java基础
---

Java语言支持多线程，为了解决线程并发的问题，在语言内部引入了同步块synchronized和volatile关键字机制。在java线程并发处理中，关键字volatile比较少用，原因是：一、JDK1.5之前该关键字在不同的操作系统上有不同的表现，所带来是问题就是移植性差，二、是设计困难，而且误用较多。

<!-- more -->

# synchronized
同步块，通过 synchronized 关键字来实现，所有加上synchronized 和块语句，在多线程访问的时候，同一时刻只能有一个线程能够用synchronized修饰的方法 或者 代码块。

# volatile
用volatile修饰的变量，线程在每次使用变量的时候，都会读取变量修改后的最新的值。volatile很容易被误用，用来进行原子性操作，它不能保证多个线程修改的安全性。

这个关键字，还保证Java指令代码不被虚拟机重排。

# 示例
下面使用一个例子来说明这个特性。
```Java
public class NovolatileCounter {
    public static  int count = 0;
 
    /**
     * 自增运算，每次自增1
     */
    public static void increase() {
 
        //这里延迟1毫秒，使得结果明显
        try {
            Thread.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
 
        count++;
    }
 
    public static void main(String[] args) {
 
        // 启动1000个线程，去进行自增运算
        for (int i = 0; i < 1000; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    NovolatileCounter.increase();
                }
            }).start();
        }

        //这里延迟10毫秒，使得所有线程都执行完毕
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        //这里每次运行的值都有可能不同，可能为1000
        System.out.println("Result: NovolatileCounter.count=" + NovolatileCounter.count);
    }
}
```
![image](https://pic.winsky.wang/images/2018/05/07/Center.png)

```Java
public class VolatileCounter {
    public static volatile int count = 0;
 
    /**
     * 自增运算，每次自增1
     */
    public static void increase() {
 
        //这里延迟1毫秒，使得结果明显
        try {
            Thread.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
 
        count++;
    }
 
    public static void main(String[] args) {
 
        // 启动1000个线程，去进行自增运算
        for (int i = 0; i < 1000; i++) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    VolatileCounter.increase();
                }
            }).start();
        }
 
        //这里延迟10毫秒，使得所有线程都执行完毕
        try {
            Thread.sleep(10);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        
        //这里每次运行的值都有可能不同，可能为1000
        System.out.println("Result: VolatileCounter.count=" + VolatileCounter.count);
    }
}
```
![image](https://pic.winsky.wang/images/2018/05/07/Center9d015.png)

运行结果依然不是期望的1000，下面分析一下原因

![image](https://pic.winsky.wang/images/2018/05/07/Center81e8f.png)

从上图可以看到，对于一般变量的访问，线程在初始化时从主内存中加载所需要的变量值到工作内存中，然后在线程运行时，如果读取，则直接从工作内存中读取，如果需要写入则先写入到工作内存中，之后在刷新到主内存中，但是这样的结构在多线程的情况下可能会出现问题。

如果A线程修改了变量的值，也刷新到主内存中去，但是B，C线程在此时间内读取的还是本线程的工作内存，也就是说读取的不是最新鲜的值，此时就出现了不同线程持有公共资源不同步的情况，可以使用synchronized同步代码块，也可以使用Lock锁来解决。

Java可以使用volatile关键字，确保每个线程对本地变量的访问和修改都直接与主内存交互，而不是与本地线程的工作内存交互的，保证每个线程都能获得最新的值。volatile变量的只剩如下图所示。

![image](https://pic.winsky.wang/images/2018/05/07/Center83c66.png)

由上图可以看出，volatile变量的读写是分开进行的，如一个线程A读取了一个volatile变量，并且修改了这个变量，在修改的值写回主内存前，另一个线程B也读取了volatile变量，则B线程读取到的是原来的值，会造成数据的不一致。由此可以说明，volatile变量关键字并不能保证线程安全，它只能保证当线程需要该变量的值时，能够获得最近被修改的值，而不能保证多个线程的安全性。