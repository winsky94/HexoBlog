---
title: Spring容器中Bean的作用域
date: 2018-03-31 09:57:14
updated: 2018-03-31 09:57:14
tags:
  - Spring
categories: 
  - Spring
---

当通过Spring容器创建一个Bean实例时，不仅可以完成Bean实例的实例化，还可以为Bean指定特定的作用域。

本文介绍了Spring中Bean的作用域的用法，作用域包括singleton、prototype、request、session和globalsession5种。

<!-- more -->

Spring支持如下5种作用域：
- **singleton**：单例模式，在整个Spring IoC容器中，使用singleton定义的Bean将只有一个实例

- **prototype**：原型模式，每次通过容器的getBean方法获取prototype定义的Bean时，都将产生一个新的Bean实例

- **request**：对于每次HTTP请求，使用request定义的Bean都将产生一个新实例，即每次HTTP请求将会产生不同的Bean实例。只有在Web应用中使用Spring时，该作用域才有效

- **session**：对于每次HTTP Session，使用session定义的Bean豆浆产生一个新实例。同样只有在Web应用中使用Spring时，该作用域才有效

- **globalsession**：每个全局的HTTP Session，使用session定义的Bean都将产生一个新实例。典型情况下，仅在使用portlet context的时候有效。同样只有在Web应用中使用Spring时，该作用域才有效

***其中比较常用的是singleton和prototype两种作用域***。

对于singleton作用域的Bean，每次请求该Bean都将获得相同的实例。容器负责跟踪Bean实例的状态，负责维护Bean实例的生命周期行为；如果一个Bean被设置成prototype作用域，程序每次请求该id的Bean，Spring都会新建一个Bean实例，然后返回给程序。在这种情况下，Spring容器仅仅使用new关键字创建Bean实例，一旦创建成功，容器不在跟踪实例，也不会维护Bean实例的状态。

***如果不指定Bean的作用域*，Spring默认使用singleton作用域**。

Java在创建Java实例时，需要进行内存申请；销毁实例时，需要完成垃圾回收，这些工作都会导致系统开销的增加。因此，prototype作用域Bean的创建、销毁代价比较大。而singleton作用域的Bean实例一旦创建成功，可以重复使用。因此，除非必要，否则尽量避免将Bean被设置成prototype作用域。

设置Bean的基本行为，通过scope属性指定，该属性可以接受singleton、prototype、request、session、globlesession5个值，分别代表以上5种作用域。下面的配置片段中，singleton和prototype各有一个：
```XML
<!-- 默认的作用域：singleton -->
<bean id="p1" class="com.abc.Person" /> 
<!-- 指定的作用域：prototype -->
<bean id="p2" class="com.abc.Person" scope="prototype" />
```

下面是一个测试类
```Java
public class BeanTest {
　　public static void main(String args[]) {
　　　　//加载类路径下的beans.xml文件以初始化Spring容器
　　　　ApplicationContext context = new ClassPathXmlApplicationContext();
　　　　//分两次分别取同一个Bean，比较二者是否是同一个对象
　　　　System.out.println(context.getBean("p1") == context.getBean("p1"));
　　　　System.out.println(context.getBean("p2") == context.getBean("p2"));
　　}
}
```

执行结果分别是：true和false

从结果可以看出，正如上文所述：对于singleton作用域的Bean，每次请求该id的Bean，都将返回同一个实例，而prototype作用域的Bean，每次请求都将产生全新的实例。

注意：早期指定Bean的作用域也可通过singleton属性指定，该属性只接受两个属性值：true和false，分别代表singleton和prototype的作用域。使用singleton属性则无法指定其他三个作用域。实际上Spring2.X不推荐使用singleton属性指定Bean的作用域，singleton属性是Spring 1.2.X的使用方式。

对于request作用域，查看如下Bean定义：
```XML
<bean id="loginAction" class="com.abc.LoginAction" scope="request" />
```
针对每次HTTP请求，Spring容器会根据loginActionBean定义创建一个全新的LoginAction实例，且该loginAction实例尽在当前HTTPRequest内有效。因此，如果程序需要，完全可以自由更改Bean实例的内部状态；其他请求所获得的loginAction实例无法感觉到这种内部状态的改变。当处理请求结束时，request作用域的Bean将会被销毁。

***注意：request、session作用域的Bean只对Web应用才真正有效。实际上通常只会将Web应用的控制器Bean才指定成request作用域***

session作用域与request作用域完全类似，区别在于：request作用域的Bean对于每次HTTP请求有效，而session作用域的Bean对于每次Session有效。在Web应用中，为了让request和session作用域生效，必须将HTTP请求对象绑定到为该请求提供服务的线程上，这使得具有request和session作用域的Bean实例能够在后面的调用链中被访问到。

为此我们有两种配置方式：采用Listener配置或者采用Filter配置。当使用Servlet 2.4及以上规范的Web容器时，我们可以在Web应用的web.xml文件中增加Listener配置，该Listener负责为request作用域生效：
```XML
<listener>
　  <listener-class>
　      org.springframework.web.context.request.RequestContextListener
　  </listener-class>
</listener>
```

如果使用了只支持Servlet 2.4以前规范的Web容器，则该容器不支持Listener规范，故无法使用这种配置方式，只能改为使用Filter配置方式，配置片段如下：
```XML
<filter>
　　 <filter-name>requestContextFilter</filter-name>
　　 <filter-class>
　　　   org.springframework.web.filter.RequestContextFilter
　　 </filter-class>
</filter>
<filter-mapping>
　　<filter-name>requestContextFilter</filter-name>
　　<url-pattern>/*</url-pattern>
</filter-mapping>
```
一旦在web.xml中增加了如上任意一种配置，程序就可以在Spring配置文件中使用request或者session作用域了。下面是Spring配置文件的片段：
```
<bean id="p3" class="com.abc.Person" scope="request" />
```

这样，Spring容器会每次HTTP请求都生成一个Person实例，当该请求响应结束时，该实例也随之消失。

如果Web应用直接使用Spring MVC作为MVC框架，即使用SpringDispatcherServlet或DispatcherPortlet来连接所有用户请求，则无需这些额外的配置，因为他们已经处理了所有和请求有关的状态处理。

注意：Spring 3.0 不仅可以为Bean指定已经存在的5个作用域，还支持自定义作用域，关于自定义作用域的内容，请参看Spring官方文档等资料。