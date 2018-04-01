---
title: Spring中Bean的生命周期
date: 2018-04-01 16:65:14
updated: 2018-04-01 16:45:14
tags:
  - Spring
categories: 
  - Spring
---

去一些企业面试时，经常会被问到Spring的问题，有一次就被问到关于Spring中Bean的生命周期是怎样的？其实这也是在业务中经常会遇到的，但容易遗忘，所以专门总结一下以备不时之需。

PS：可以借鉴Servlet的生命周期，实例化、初始init、接收请求service、销毁destroy。

<!-- more -->

Spring上下文中的Bean也类似，【Spring上下文的生命周期】

# 概括版描述

1. 实例化一个Bean，也就是我们通常说的new
2. 按照Spring上下文对实例化的Bean进行配置，也就是IOC注入
3. 如果这个Bean实现了BeanNameAware接口，会调用它实现的setBeanName(String beanId)方法，此处传递的是Spring配置文件中Bean的ID
4. 如果这个Bean实现了BeanFactoryAware接口，会调用它实现的setBeanFactory()，传递的是Spring工厂本身（可以用这个方法获取到其他Bean）
5. 如果这个Bean实现了ApplicationContextAware接口，会调用setApplicationContext(ApplicationContext)方法，传入Spring上下文，该方式同样可以实现步骤4，但比4更好，因为ApplicationContext是BeanFactory的子接口，有更多的实现方法
6. 如果这个Bean关联了BeanPostProcessor接口，将会调用postProcessBeforeInitialization(Object obj, String s)方法，BeanPostProcessor经常被用作是Bean内容的更改，并且由于这个是在Bean初始化结束时调用After方法，也可用于内存或缓存技术
7. 如果这个Bean在Spring配置文件中配置了init-method属性会自动调用其配置的初始化方法
8. 如果这个Bean关联了BeanPostProcessor接口，将会调用postAfterInitialization(Object obj, String s)方法注意：以上工作完成以后就可以用这个Bean了，那这个Bean是一个single的，所以一般情况下我们调用同一个ID的Bean会是在内容地址相同的实例
9. 当Bean不再需要时，会经过清理阶段，如果Bean实现了DisposableBean接口，会调用其实现的destroy方法
10. 最后，如果这个Bean的Spring配置中配置了destroy-method属性，会自动调用其配置的销毁方法

以上10步骤可以作为面试或者笔试的模板，另外我们这里描述的是应用Spring上下文Bean的生命周期，如果应用Spring的工厂也就是BeanFactory的话去掉第5步就Ok了

# 详细描述
## ApplicationContext Bean生命周期
Spring Bean的完整生命周期从创建Spring容器开始，直到最终Spring容器销毁Bean，这其中包含了一系列关键点。

### 流程图

![image](https://pic.winsky.wang/images/2018/04/01/spring5-2.jpg)

若容器注册了以上各种接口，程序那么将会按照以上的流程进行。下面将仔细讲解各接口作用。

### 各种接口方法分类
Bean的完整生命周期经历了各种方法调用，这些方法可以划分为以下几类：

1. Bean自身的方法：这个包括了Bean本身调用的方法和通过配置文件中<bean>的init-method和destroy-method指定的方法

2. Bean级生命周期接口方法：这个包括了BeanNameAware、BeanFactoryAware、InitializingBean和DiposableBean这些接口的方法

3. 容器级生命周期接口方法：这个包括了InstantiationAwareBeanPostProcessor和 BeanPostProcessor这两个接口实现，一般称它们的实现类为“后处理器”。容器中每个bean初始化都要经过这一步。

4. 工厂后处理器接口BeanFactoryPostProcessor方法：这个包括了AspectJWeavingEnabler,ConfigurationClassPostProcessor, CustomAutowireConfigurer等等非常有用的工厂后处理器接口的方法。工厂后处理器也是容器级的，在应用上下文装配配置文件之后立即调用。

### 流程说明
1. 首先容器启动后，会对scope为singleton且非懒加载(lazy-init=false)的bean进行实例化，
2. 按照Bean定义信息配置信息，注入所有的属性
3. 如果Bean实现了BeanNameAware接口，会回调该接口的setBeanName()方法，传入该Bean的id，此时该Bean就获得了自己在配置文件中的id
4. 如果Bean实现了BeanFactoryAware接口,会回调该接口的setBeanFactory()方法，传入该Bean的BeanFactory，这样该Bean就获得了自己所在的BeanFactory
5. 如果Bean实现了ApplicationContextAware接口,会回调该接口的setApplicationContext()方法，传入该Bean的ApplicationContext，这样该Bean就获得了自己所在的ApplicationContext
6. 如果有Bean实现了BeanPostProcessor接口，则会回调该接口的postProcessBeforeInitialzation()方法
7. 如果Bean实现了InitializingBean接口，则会回调该接口的afterPropertiesSet()方法
8. 如果Bean配置了init-method方法，则会执行init-method配置的方法
9. 如果有Bean实现了BeanPostProcessor接口，则会回调该接口的postProcessAfterInitialization()方法
10. 经过流程9之后，就可以正式使用该Bean了,对于scope为singleton的Bean,Spring的ioc容器中会缓存一份该bean的实例，而对于scope为prototype的Bean,每次被调用都会new一个新的对象，生命周期就交给调用方管理了，不再是Spring容器进行管理了
11. 容器关闭后，如果Bean实现了DisposableBean接口，则会回调该接口的destroy()方法
12. 如果Bean配置了destroy-method方法，则会执行destroy-method配置的方法，至此，整个Bean的生命周期结束

## BeanFactory Bean生命周期
BeanFactoty容器中, Bean的生命周期如下图所示，与ApplicationContext相比，有如下几点不同:

1. BeanFactory容器中，不会调用ApplicationContextAware接口的setApplicationContext()方法

2. BeanPostProcessor接口的postProcessBeforeInitialzation()方法和postProcessAfterInitialization()方法不会自动调用，必须自己通过代码手动注册

3. BeanFactory容器启动的时候，不会去实例化所有Bean,包括所有scope为singleton且非懒加载的Bean也是一样，而是在调用的时候去实例化。

### 流程图
![image](https://pic.winsky.wang/images/2018/04/01/spring5-1.jpg)

### 流程说明
1. 当调用者通过 getBean(name)向 容器寻找Bean时，如果容器注册了org.springframework.beans.factory.config.InstantiationAwareBeanPostProcessor接口，在实例bean之前，将调用该接口的 postProcessBeforeInstantiation()方法
2. 容器寻找Bean的定义信息，并将其实例化
3. 使用依赖注入，Spring按照Bean定义信息配置Bean的所有属性
4. 如果Bean实现了BeanNameAware接口，工厂调用Bean的setBeanName()方法传递Bean的id
5. 如果实现了BeanFactoryAware接口，工厂调用setBeanFactory()方法传入工厂自身
6. 如果BeanPostProcessor和Bean关联，那么它们的postProcessBeforeInitialization()方法将被调用（需要手动进行注册！）
7. 如果Bean实现了InitializingBean接口，则会回调该接口的afterPropertiesSet()方法
8. 如果Bean指定了init-method方法，就会调用init-method方法
9. 如果BeanPostProcessor和Bean关联，那么它的postProcessAfterInitialization()方法将被调用（需要手动注册！）
10. 现在Bean已经可以使用了
    1. scope为singleton的Bean缓存在Spring IOC容器中
    2. scope为prototype的Bean生命周期交给客户端
11. 销毁
    1. 如果Bean实现了DisposableBean接口，destory()方法将会被调用
    2. 如果配置了destory-method方法，就调用这个方法