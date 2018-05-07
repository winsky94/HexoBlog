---
title: sleep和wait的区别
date: 2018-03-01 19:58:14
updated: 2018-03-01 19:58:14
tags:
  - 多线程
categories: 
  - Java
  - Java基础
---

多线程中会使用到两个延迟的函数，wait和sleep。 

wait是Object类中的方法，而sleep是Thread类中的方法。

那，他们两者到底有什么区别呢？？

<!-- more -->

# sleep和wait的区别
sleep是Thread类中的静态方法。无论是在a线程中调用b的sleep方法，还是b线程中调用a的sleep方法，谁调用，谁睡觉。

最主要的是sleep方法调用之后，并没有释放锁。使得线程仍然可以同步控制。

sleep不会让出系统资源（这里的资源，应该是指锁资源，sleep会让出CPU）；而wait是进入线程等待池中等待，让出系统资源。

调用wait方法的线程，不会自己唤醒，需要线程调用 notify / notifyAll 方法唤醒等待池中的所有线程，才会进入就绪队列中等待系统分配资源。

sleep方法会自动唤醒，如果时间不到，想要唤醒，可以使用interrupt方法强行打断。 

Thread.sleep(0) // 触发操作系统立刻重新进行一次CPU竞争。

**使用范围：**

sleep可以在任何地方使用。而wait，notify，notifyAll只能在同步控制方法或者同步控制块中使用。

sleep必须捕获异常，而wait，notify，notifyAll的不需要捕获异常。

# 释放CPU
- sleep()方法: 

    当程序运行到Thread.sleep(100L);时,休眠100毫秒,同时交出CPU时间片,100毫秒后,重新进入可运行状态,等待CPU重新分配时间片,而线程交出时间片时,CPU拿到时间片,由操作系统负责在可运行状态的线程中选中并分配时间片 
- wait()方法:

    程序在运行时,遇到wait()方法,这时线程进入当前对象的等待队列并交出CPU,等待其他线程notifyAll()时,才能重新回到可运行状态,等待OS分配CPU

# 释放锁
调用obj.wait()会立即释放锁，以便其他线程可以执行obj.notify()，但是notify()不会立刻立刻释放sycronized（obj）中的obj锁，必须要等notify()所在线程执行完synchronized（obj）块中的所有代码才会释放这把锁.

而 yield(),sleep()不会释放锁。