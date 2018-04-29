---
title: Spring框架的作用
date: 2018-02-25 10:10:14
updated: 2018-02-25 10:10:14
tags:
  - Spring
categories: 
  - Spring
---

Spring框架是时下非常流行的Java web开发框架。Spring 可以做非常多的事情。 但归根结底， 支撑Spring的仅仅是少许的基本理念， 所有的理念都可以追溯到Spring最根本的使命上： 简化Java开发。

Spring的目标是致力于全方位的简化Java开发。 这势必引出更多的解释， Spring是如何简化Java开发的？

<!-- more -->

为了降低Java开发的复杂性， Spring采取了以下4种关键策略：
- 基于POJO的轻量级和最小侵入性编程
- 通过依赖注入和面向接口实现松耦合
- 基于切面和惯例进行声明式编程
- 通过切面和模板减少样板式代码

几乎Spring所做的任何事情都可以追溯到上述的一条或多条策略。

本文通过具体的案例进一步阐述这些理念， 以此来证明Spring是如何完美兑现它的承诺的， 也就是简化Java开发。

# 激发POJO的潜能
如果你从事Java编程有一段时间了， 那么你或许会发现（可能你也实际使用过） 很多框架通过强迫应用继承它们的类或实现它们的接口从而导致应用与框架绑死。

这种侵入式的编程方式在早期版本的Struts以及无数其他的Java规范和框架中都能看到。

Spring竭力避免因自身的API而弄乱你的应用代码。Spring不会强迫你实现Spring规范的接口或继承Spring规范的类， 相反， 在基于Spring构建的应用中，它的类通常没有任何痕迹表明你使用了Spring。 最坏的场景是，一个类或许会使用Spring注解， 但它依旧是POJO。

举例说明，参考下面的`HelloWorldBean`
```Java
public class HelloWorldBean {
  public String sayHello() {
    return "Hello World";
  }
}
```
可以看到，这是一个简单普通的Java类——POJO。没有任何地方表明它是一个Spring组件。Spring的非侵入编程模型意味着这个类在Spring应用和非Spring应用中都可以发挥同样的作用。

Spring的非入侵式就是不强制类要实现Spring的任何接口或类，没有任何地方表明它是一个Spring组件。意味着这个类在Spring应用和非Spring应用中都可以发挥同样的作用。

尽管形式看起来很简单，但POJO一样可以具有魔力。Spring赋予POJO魔力的方式之一就是通过DI来装配它们。让我们看看DI是如何帮助应用对象彼此之间保持松散耦合的。

# 依赖注入
任何一个有实际意义的应用（肯定比Hello World示例更复杂）都会由两个或者更多的类组成，这些类相互之间进行协作来完成特定的业务逻辑。按照传统的做法， 每个对象负责管理与自己相互协作的对象（即它所依赖的对象）的引用， 这将会导致高度耦合和难以测试的代码。

举个例子，考虑下程序所展现的Knight类
```Java
public class DamselRescuingKnight implements Knight {

  private RescueDamselQuest quest;

  public DamselRescuingKnight() {
    this.quest = new RescueDamselQuest();
  }

  public void embarkOnQuest() {
    quest.embark();
  }
}
```
DamselRescuingKnight只能执行RescueDamselQuest探险任务。

可以看到，DamselRescuingKnight在它的构造函数中自行创建了RescueDamselQuest。 这使得DamselRescuingKnight紧密地和RescueDamselQuest耦合到了一起， 因此极大地限制了这个骑士执行探险的能力。 如果一个少女需要救援，这个骑士能够召之即来。但是如果一条恶龙需要杀掉，那么这个骑士就爱莫能助了。

更糟糕的是，为这个DamselRescuingKnight编写单元测试将出奇地困难。在这样的一个测试中，你必须保证当骑士的embarkOnQuest()方法被调用的时候，探险的embark()方法也要被调用。但是没有一个简单明了的方式能够实现这一点。 很遗憾，DamselRescuingKnight将无法进行测试。

耦合具有两面性（two-headed beast） 
- 一方面， 紧密耦合的代码难以测试、 难以复用、难以理解，并且典型地表现出“打地鼠”式的bug特性（修复一个bug， 将会出现一个或者更多新的bug）
- 另一方面，一定程度的耦合又是必须的——完全没有耦合的代码什么也做不了。 为了完成有实际意义的功能，不同的类必须以适当的方式进行交互。总而言之， 耦合是必须的，但应当被小心谨慎地管理。

通过DI， 对象的依赖关系将由系统中负责协调各对象的第三方组件在创建对象的时候进行设定。对象无需自行创建或管理它们的依赖关系， 如下图所示， 依赖关系将被自动注入到需要它们的对象当中去。
![image](http://upload-images.jianshu.io/upload_images/1234352-d3041991a8c08307.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

依赖注入会将所依赖的关系自动交给目标对象， 而不是让对象自己去获取依赖。

为了展示这一点，让我们看一看以下的BraveKnight，这个骑士不仅勇敢，而且能挑战任何形式的探险。
```Java
public class BraveKnight implements Knight {

  private Quest quest;

  public BraveKnight(Quest quest) {
    this.quest = quest;
  }

  public void embarkOnQuest() {
    quest.embark();
  }
}
```

我们可以看到，不同于之前的DamselRescuingKnight，BraveKnight没有自行创建探险任务，而是在构造的时候把探险任务作为构造器参数传入。这是依赖注入的方式之一，即**构造器注入**（constructor injection）。

更重要的是，传入的探险类型是Quest， 也就是所有探险任务都必须实现的一个接口。所以，BraveKnight能够响应RescueDamselQuest、SlayDragonQuest、 MakeRound TableRounderQuest等任意的Quest实现。

这里的要点是BraveKnight没有与任何特定的Quest实现发生耦合。对它来说， 被要求挑战的探险任务只要实现了Quest接口，那么具体是哪种类型的探险就无关紧要了。这就是DI所带来的最大收益——松耦合。

如果一个对象只通过接口（而不是具体实现或初始化过程）来表明依赖关系， 那么这种依赖就能够在对象本身毫不知情的情况下，用不同的具体实现进行替换。

现在BraveKnight类可以接受你传递给它的任意一种Quest的实现，但该怎样把特定的Query实现传给它呢？ 假设， 希望BraveKnight所要进行探险任务是杀死一只怪龙，那么以下程序中的SlayDragonQuest也许是挺合适的。
```Java
import java.io.PrintStream;

public class SlayDragonQuest implements Quest {

  private PrintStream stream;

  public SlayDragonQuest(PrintStream stream) {
    this.stream = stream;
  }

  public void embark() {
    stream.println("Embarking on quest to slay the dragon!");
  }
}
```
SlayDragonQuest是要注入到BraveKnight中的Quest实现

我们可以看到，SlayDragonQuest实现了Quest接口，这样它就适合注入到BraveKnight中去了。与其他的Java入门样例有所不同，SlayDragonQuest没有使用System.out.println()，而是在构造方法中请求一个更为通用的PrintStream。 这里最大的问题在于:
- 我们该如何将SlayDragonQuest交给BraveKnight呢？
- 又如何将PrintStream交给SlayDragonQuest呢？

创建应用组件之间协作的行为通常称为装配（wiring）。Spring有多种装配bean的方式，采用XML是很常见的一种装配方式。 以下程序展现了一个简单的Spring配置文件：knights.xml，该配置文件将BraveKnight、SlayDragonQuesth和PrintStream装配到了一起。
```XML
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.springframework.org/schema/beans 
      http://www.springframework.org/schema/beans/spring-beans.xsd">

  <bean id="knight" class="sia.knights.BraveKnight">
    <constructor-arg ref="quest" />
  </bean>

  <bean id="quest" class="sia.knights.SlayDragonQuest">
    <constructor-arg value="#{T(System).out}" />
  </bean>
</beans>
```
装配的作用就是创建类的实例，同时将类的构造函数或者setter函数参数设置好，这是为了配置对象和对象之间的关系。

在这里， BraveKnight和SlayDragonQuest被声明为Spring中的bean。就BraveKnight bean来讲，它在构造时传入了对SlayDragonQuest bean的引用， 将其作为构造器参数。 同时， SlayDragonQuest bean的声明使用了Spring表达式语言（Spring Expression Language），将System.out（这是一个PrintStream）传入到了SlayDragonQuest的构造器中。

Spring还支持使用Java来描述配置。
```Java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import sia.knights.BraveKnight;
import sia.knights.Knight;
import sia.knights.Quest;
import sia.knights.SlayDragonQuest;

@Configuration
public class KnightConfig {

  @Bean
  public Knight knight() {
    return new BraveKnight(quest());
  }
  
  @Bean
  public Quest quest() {
    return new SlayDragonQuest(System.out);
  }
}
```
尽管BraveKnight依赖于Quest，但是它并不知道传递给它的是什么类型的Quest， 也不知道这个Quest来自哪里。与之类似， SlayDragonQuest依赖于PrintStream，但是在编码时它并不需要知道这个PrintStream是什么样子的。只有Spring通过它的配置，能够了解这些组成部分是如何装配起来的。这样的话， 就可以在不改变所依赖的类的情况下， 修改依赖关系。

## 观察它如何工作
Spring通过应用上下文（Application Context）装载bean的定义并把它们组装起来。 Spring应用上下文全权负责对象的创建和组装。Spring自带了多种应用上下文的实现，它们之间主要的区别仅仅在于如何加载配置。

因为knights.xml中的bean是使用XML文件进行配置的，所以选择ClassPathXmlApplicationContext作为应用上下文相对是比较合适的。该类加载位于应用程序类路径下的一个或多个XML配置文件。 以下程序中的main()方法调用ClassPathXmlApplicationContext加载knights.xml，并获得Knight对象的引用。
```Java
import org.springframework.context.support.
                   ClassPathXmlApplicationContext;

public class KnightMain {

  public static void main(String[] args) throws Exception {
    ClassPathXmlApplicationContext context = 
        new ClassPathXmlApplicationContext(
            "META-INF/spring/knight.xml");
    Knight knight = context.getBean(Knight.class);
    knight.embarkOnQuest();
    context.close();
  }
}
```
这里的main()方法基于knights.xml文件创建了Spring应用上下文。随后它调用该应用上下文获取一个ID为knight的bean。得到Knight对象的引用后，只需简单调用embarkOnQuest()方法就可以执行所赋予的探险任务了。注意这个类完全不知道我们的英雄骑士接受哪种探险任务，而且完全没有意识到这是由BraveKnight来执行的。只有knights.xml文件知道哪个骑士执行哪种探险任务。

# 应用切面
DI能够让相互协作的软件组件保持松散耦合，而面向切面编程（aspect-oriented programming，AOP）允许你把遍布应用各处的功能分离出来形成可重用的组件。

面向切面编程往往被定义为促使软件系统实现关注点的分离一项技术。系统由许多不同的组件组成，每一个组件各负责一块特定功能。除了实现自身核心的功能之外，这些组件还经常承担着额外的职责。诸如日志、事务管理和安全这样的系统服务经常融入到自身具有核心业务逻辑的组件中去，这些系统服务通常被称为横切关注点，因为它们会跨越系统的多个组件。

如果将这些关注点分散到多个组件中去，你的代码将会带来双重的复杂性。
- 实现系统关注点功能的代码将会重复出现在多个组件中。这意味着如果你要改变这些关注点的逻辑，必须修改各个模块中的相关实现。
- 即使你把这些关注点抽象为一个独立的模块，其他模块只是调用它的方法， 但方法的调用还是会重复出现在各个模块中。
- 组件会因为那些与自身核心业务无关的代码而变得混乱。一个向地址簿增加地址条目的方法应该只关注如何添加地址，而不应该关注它是不是安全的或者是否需要支持事务

在整个系统内，关注点（例如日志和安全）的调用经常散布到各个模块中， 而这些关注点并不是模块的核心业务

AOP能够使这些服务模块化，并以声明的方式将它们应用到它们需要影响的组件中去。所造成的结果就是这些组件会具有更高的内聚性并且会更加关注自身的业务，完全不需要了解涉及系统服务所带来复杂性。总之，AOP能够确保POJO的简单性。

我们可以把切面想象为覆盖在很多组件之上的一个外壳。应用是由那些实现各自业务功能的模块组成的。借助AOP，可以使用各种功能层去包裹核心业务层。这些层以声明的方式灵活地应用到系统中，你的核心应用甚至根本不知道它们的存在。这是一个非常强大的理念，可以将安全、事务和日志关注点与核心业务逻辑相分离。

利用AOP，系统范围内的关注点覆盖在它们所影响组件之上

为了示范在Spring中如何应用切面，让我们重新回到骑士的例子，并为它添加一个切面。

每一个人都熟知骑士所做的任何事情，这是因为吟游诗人用诗歌记载了骑士的事迹并将其进行传唱。假设我们需要使用吟游诗人这个服务类来记载骑士的所有事迹。如下程序展示了我们会使用的Minstrel类。
```Java
import java.io.PrintStream;

public class Minstrel {

  private PrintStream stream;
  
  public Minstrel(PrintStream stream) {
    this.stream = stream;
  }

  public void singBeforeQuest() {
    stream.println("Fa la la, the knight is so brave!");
  }

  public void singAfterQuest() {
    stream.println("Tee hee hee, the brave knight " +
    		"did embark on a quest!");
  }
}
```
Minstrel是只有两个方法的简单类。在骑士执行每一个探险任务之前，singBeforeQuest()方法会被调用；在骑士完成探险任务之后，singAfterQuest()方法会被调用。在这两种情况下，Minstrel都会通过一个PrintStream类来歌颂骑士的事迹，这个类是通过构造器注入进来的。

把Minstrel加入你的代码中并使其运行起来，这对你来说是小事一桩。我们适当做一下调整从而让BraveKnight可以使用Minstrel。如下是将BraveKnight和Minstrel组合起来的第一次尝试。
```Java
public class BraveKnight implements Knight {

  private Quest quest;
  private Minstrel minstrel;

  public BraveKnight(Quest quest, Minstrel minstrel) {
    this.quest = quest;
	this.minstrel = minstrel;
  }

  public void embarkOnQuest() {
	minstrel.singBeforeQuest();
    quest.embark();
	minstrel.singAfterQuest();
  }
}
```
这应该可以达到预期效果。现在，你所需要做的就是回到Spring配置中，声明Minstrel bean并将其注入到BraveKnight的构造器之中。

但是， 请稍等……

我们似乎感觉有些东西不太对。管理他的吟游诗人真的是骑士职责范围内的工作吗？在我看来，吟游诗人应该做他份内的事，根本不需要骑士命令他这么做。毕竟，用诗歌记载骑士的探险事迹，这是吟游诗人的职责。为什么骑士还需要提醒吟游诗人去做他份内的事情呢？此外，因为骑士需要知道吟游诗人，所以就必须把吟游诗人注入到BarveKnight类中。这不仅使BraveKnight的代码复杂化了，而且还让我疑惑是否还需要一个不需要吟游诗人的骑士呢？如果Minstrel为null会发生什么呢？我是否应该引入一个空值校验逻辑来覆盖该场景？

简单的BraveKnight类开始变得复杂，如果你还需要应对没有吟游诗人时的场景，那代码会变得更复杂。但利用AOP，你可以声明吟游诗人必须歌颂骑士的探险事迹，而骑士本身并不用直接访问Minstrel的方法。

要将Minstrel抽象为一个切面， 你所需要做的事情就是在一个Spring配置文件中声明它。 下面是更新后的knights.xml文件， Minstrel被声明为一个切面。
```XML
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:aop="http://www.springframework.org/schema/aop"
  xsi:schemaLocation="http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop.xsd
		http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

  <bean id="knight" class="sia.knights.BraveKnight">
    <constructor-arg ref="quest" />
  </bean>

  <bean id="quest" class="sia.knights.SlayDragonQuest">
    <constructor-arg ref="fakePrintStream" />
  </bean>

  <bean id="minstrel" class="sia.knights.Minstrel">
    <constructor-arg ref="fakePrintStream" />
  </bean>

  <bean id="fakePrintStream" class="sia.knights.FakePrintStream" />

  <aop:config>
    <aop:aspect ref="minstrel">
      <aop:pointcut id="embark"
          expression="execution(* *.embarkOnQuest(..))"/>
        
      <aop:before pointcut-ref="embark" 
          method="singBeforeQuest"/>

      <aop:after pointcut-ref="embark" 
          method="singAfterQuest"/>
    </aop:aspect>
  </aop:config>
</beans>
```
这里使用了Spring的aop配置命名空间把Minstrel bean声明为一个切面。
- 首先，需要把Minstrel声明为一个bean
- 然后在元素中引用该bean
- 为了进一步定义切面，声明（使用）在embarkOnQuest()方法执行前调用Minstrel的singBeforeQuest()方法。这种方式被称为前置通知（before advice）
- 同时声明（使用）在embarkOnQuest()方法执行后调用singAfterQuest()方法。这种方式被称为后置通知（after advice）

首先，Minstrel仍然是一个POJO， 没有任何代码表明它要被作为一个切面使用。当我们按照上面那样进行配置后，在Spring的上下文中，Minstrel实际上已经变成一个切面了。

其次，也是最重要的，Minstrel可以被应用到BraveKnight中，而BraveKnight不需要显式地调用它。实际上，BraveKnight完全不知道Minstrel的存在。

必须还要指出的是，尽管我们使用Spring魔法把Minstrel转变为一个切面，但首先要把它声明为一个Spring bean。能够为其他Spring bean做到的事情都可以同样应用到Spring切面中， 例如为它们注入依赖。

# 使用模板消除样板式代码
你是否写过这样的代码，当编写的时候总会感觉以前曾经这么写过？我的朋友，这不是似曾相识。这是样板式的代码（boilerplate code）。通常为了实现通用的和简单的任务，你不得不一遍遍地重复编写这样的代码。

遗憾的是，它们中的很多是因为使用Java API而导致的样板式代码。样板式代码的一个常见范例是使用JDBC访问数据库查询数据。举个例子，如果你曾经用过JDBC，那么你或许会写出类似下面的代码。

![image](http://upload-images.jianshu.io/upload_images/1234352-b65b39e1811ada63.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

正如你所看到的，这段JDBC代码查询数据库获得员工姓名和薪水。我打赌你很难把上面的代码逐行看完，这是因为少量查询员工的代码淹没在一堆JDBC的样板式代码中。首先你需要创建一个数据库连接， 然后再创建一个语句对象， 最后你才能进行查询。

为了平息JDBC可能会出现的怒火，你必须捕捉SQLException，这是一个检查型异常，即使它抛出后你也做不了太多事情。

最后，毕竟该说的也说了，该做的也做了，你不得不清理战场，关闭数据库连接、 语句和结果集。同样为了平息JDBC可能会出现的怒火，你依然要捕SQLException。

上面的代码和你实现其他JDBC操作时所写的代码几乎是相同的。只有少量的代码与查询员工逻辑有关系，其他的代码都是JDBC的样板代码。

JDBC不是产生样板式代码的唯一场景。在许多编程场景中往往都会导致类似的样板式代码，JMS、JNDI和使用REST服务通常也涉及大量的重复代码。

Spring旨在通过模板封装来消除样板式代码。Spring的JdbcTemplate使得执行数据库操作时，避免传统的JDBC样板代码成为了可能。

举个例子，使用Spring的JdbcTemplate（利用了Java5特性的JdbcTemplate实现）重写的getEmployeeById()方法仅仅关注于获取员工数据的核心逻辑，而不需要迎合JDBC API的需求。 下图展示了修订后的getEmployeeById()方法。

![image](http://upload-images.jianshu.io/upload_images/1234352-f09025a45751125e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

正如你所看到的，新版本的getEmployeeById()简单多了，而且仅仅关注于从数据库中查询员工。模板的queryForObject()方法需要一个SQL查询语句，一个RowMapper对象（把数据映射为一个域对象），零个或多个查询参数。GetEmployeeById()方法再也看不到以前的JDBC样板式代码了，它们全部被封装到了模板中。