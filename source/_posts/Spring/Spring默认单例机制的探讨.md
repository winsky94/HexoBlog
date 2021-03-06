---
title: Spring默认单例机制的探讨
date: 2018-04-01 15:57:14
updated: 2018-04-01 15:57:14
tags:
  - Spring
categories: 
  - Spring
---

使用过Spring的程序员都知道，我们的bean（controller、service和Dao，实体bean除外）都是通过Spring的IoC容器统一管理的，同时这些bean默认都是单例的，即一个bean在一个IoC容器中只有一个实例。这一点跟设计模式中的单例略有不同，设计模式中的单例是整个应用中只有一个实例。

最近看一个同学去面试，其中一个问题是关于Spring单例的，本文就整理一下我对Spring单例的理解。

<!-- more -->

我们把bean放在IOC容器中统一进行管理，只在初始化加载的时候实例化一次，一方面提高了效率,另一方面大大降低了内存开销。spring的依赖反转原则降低了程序之间的耦合性，也提高了我们的开发效率，不用每次都手动去new了。

单例模式确实有很多优点，但是说到单例我们就会想到线程安全，并发访问情况下spring中bean是线程安全的吗？

到底是不是线程安全的，要根据实际场景判断。为什么这么说呢？首先，大多数时候客户端都在访问我们应用中的业务对象，而这些业务对象并没有做线程的并发限制，因此不会出现各个线程之间的等待问题，或是死锁问题。这一部分不在考虑。

再有就是成员变量这一重要因素了。在并发访问的时候这些成员变量将会是并发线程中的共享对象，也是影响线程安全的重要因素。成员变量又分为基本类型的成员变量和引用类型的成员变量。

其中引用类型的成员变量即我们在controller中注入的service，在service中注入的dao，这里将其定义为成员变量主要是为了实例化进而调用里面的业务方法，在这些类中一般不会有全局变量，因此只要我们的业务方法不含有独立的全局变量即使是被多线程共享，也是线程安全的。

再有就是基本类型成员变量，刚刚说了service层和dao层一般不会有全局变量，这里主要针对于controller层。基本类型成员变量的定义又分为两种情况：如果此成员变量是final类型修饰的不可被修改的，则仍是线程安全的。另外一种情况就是不安全的了，解决方法：要么把全局变量定义成局部的，要么修改controller的单例模式把它定义成prototype类型的。

从文中开始我们就提到过，实体bean不是单例的，并没有交给spring来管理，每次我们都手动去new一个实例。从客户端传递到后台的controller-->service-->Dao,这一个流程中，即使处理我们提交数据的业务处理类是被多线程共享的，但是他们处理的数据并不是共享的，数据是每一个线程都有自己的一份，所以在数据这个方面是不会出现线程同步方面的问题的。

