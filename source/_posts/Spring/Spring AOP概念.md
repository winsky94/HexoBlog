---
title: Spring AOP概念
date: 2018-03-18 15:57:14
updated: 2018-03-18 15:57:14
tags:
  - Spring
categories: 
  - Spring
---

面向切面编程（AOP）通过提供另外一种思考程序结构的途经来弥补面向对象编程（OOP）的不足。在OOP中模块化的关键单元是类（classes），而在AOP中模块化的单元则是切面。切面能对关注点进行模块化，例如横切多个类型和对象的事务管理。（在AOP术语中通常称作横切（crosscutting）关注点。）

AOP框架是Spring的一个重要组成部分。但是Spring IoC容器并不依赖于AOP，这意味着你有权利选择是否使用AOP，AOP做为Spring IoC容器的一个补充,使它成为一个强大的中间件解决方案。

<!-- more -->

# AOP概念
首先让我们从一些重要的AOP概念和术语开始。这些术语不是Spring特有的。不过AOP术语并不是特别的直观，如果Spring使用自己的术语，将会变得更加令人困惑。

- 切面（Aspect）：一个关注点的模块化，这个关注点可能会横切多个对象。事务管理是J2EE应用中一个关于横切关注点的很好的例子。在Spring AOP中，切面可以使用基于模式或者基于@Aspect注解的方式来实现。

- 连接点（Joinpoint）：在程序执行过程中某个特定的点，比如某方法调用的时候或者处理异常的时候。在Spring AOP中，一个连接点总是表示一个方法的执行。

- 通知（Advice）：在切面的某个特定的连接点上执行的动作。其中包括了“around”、“before”和“after”等不同类型的通知（通知的类型将在后面部分进行讨论）。许多AOP框架（包括Spring）都是以拦截器做通知模型，并维护一个以连接点为中心的拦截器链。
    - 前置通知（Before advice）：在某连接点之前执行的通知，但这个通知不能阻止连接点之前的执行流程（除非它抛出一个异常）。
    - 后置通知（After returning advice）：在某连接点正常完成后执行的通知：例如，一个方法没有抛出任何异常，正常返回。
    - 异常通知（After throwing advice）：在方法抛出异常退出时执行的通知。
    - 最终通知（After (finally) advice）：当某连接点退出的时候执行的通知（不论是正常返回还是异常退出）。
    - 环绕通知（Around Advice）：包围一个连接点的通知，如方法调用。这是最强大的一种通知类型。环绕通知可以在方法调用前后完成自定义的行为。它也会选择是否继续执行连接点或直接返回它自己的返回值或抛出异常来结束执行。

- 切入点（Pointcut）：匹配连接点的断言。通知和一个切入点表达式关联，并在满足这个切入点的连接点上运行（例如，当执行某个特定名称的方法时）。切入点表达式如何和连接点匹配是AOP的核心：Spring缺省使用AspectJ切入点语法。

- 引入（Introduction）：用来给一个类型声明额外的方法或属性（也被称为连接类型声明（inter-type declaration））。Spring允许引入新的接口（以及一个对应的实现）到任何被代理的对象。例如，你可以使用引入来使一个bean实现IsModified接口，以便简化缓存机制。

- 目标对象（Target Object）： 被一个或者多个切面所通知的对象。也被称做被通知（advised）对象。 既然Spring AOP是通过运行时代理实现的，这个对象永远是一个被代理（proxied）对象。

- AOP代理（AOP Proxy）：AOP框架创建的对象，用来实现切面契约（例如通知方法执行等等）。在Spring中，AOP代理可以是JDK动态代理或者CGLIB代理。

- 织入（Weaving）：把切面连接到其它的应用程序类型或者对象上，并创建一个被通知的对象。这些可以在编译时（例如使用AspectJ编译器），类加载时和运行时完成。Spring和其他纯Java AOP框架一样，在运行时完成织入。

# Spring AOP的功能和目标
Spring AOP使用纯Java实现。它不需要专门的编译过程。Spring AOP不需要控制类装载器层次，因此它适用于J2EE web容器或应用服务器。

Spring目前仅支持使用方法调用作为连接点（join point）（在Spring bean上通知方法的执行）。虽然可以在不影响到Spring AOP核心API的情况下加入对成员变量拦截器支持，但Spring并没有实现成员变量拦截器。如果你需要把对成员变量的访问和更新也作为通知的连接点，可以考虑其它的语言，如AspectJ。

Spring实现AOP的方法跟其他的框架不同。Spring并不是要提供最完整的AOP实现（尽管Spring AOP有这个能力），相反的，它其实侧重于提供一种AOP实现和Spring IoC容器之间的整合，用于帮助解决在企业级开发中的常见问题。

因此，Spring的AOP功能通常都和Spring IoC容器一起使用。切面使用普通的bean定义语法来配置（尽管Spring提供了强大的"自动代理（autoproxying）"功能）：与其他AOP实现相比这是一个显著的区别。有些事使用Spring AOP是无法轻松或者高效完成的，比如说通知一个细粒度的对象（例如典型的域对象）：这种时候，使用AspectJ是最好的选择。不过经验告诉我们，对于大多数在J2EE应用中适合用AOP来解决的问题，Spring AOP都提供了一个非常好的解决方案。

Spring AOP从来没有打算通过提供一种全面的AOP解决方案来与AspectJ竞争。我们相信无论是基于代理（proxy-based）的框架如Spring AOP或者是成熟的框架如AspectJ都是很有价值的，他们之间应该是互补而不是竞争的关系。Spring 2.0可以无缝的整合Spring AOP，IoC和AspectJ，使得所有的AOP应用完全融入基于Spring的应用体系。这样的集成不会影响Spring AOP API或者AOP Alliance API；Spring AOP保持了向下兼容性。下一章会详细讨论Spring AOP的API。

# AOP代理
Spring缺省使用J2SE 动态代理（dynamic proxies）来作为AOP的代理。 这样任何接口（或者接口集）都可以被代理。

Spring也可以使用CGLIB代理. 对于需要代理类而不是代理接口的时候CGLIB代理是很有必要的。如果一个业务对象并没有实现一个接口，默认就会使用CGLIB。作为面向接口编程的最佳实践，业务对象通常都会实现一个或多个接口。但也有可能会强制使用CGLIB，在这种情况（希望不常有）下，你可能需要通知一个没有在接口中声明的方法，或者需要传入一个代理对象给方法作为具体类型

