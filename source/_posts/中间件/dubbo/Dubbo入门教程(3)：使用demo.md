---
title: Dubbo入门教程(3)：使用demo
date: 2018-05-14 23:54:14
updated: 2018-05-14 23:54:14
tags:
  - 中间件
  - dubbo
categories: 
  - 中间件
  - dubbo
---


在[Dubbo入门教程(1)：Dubbo介绍][1]我们从电子商务系统的演变历史，引出了什么是Dubbo，介绍了Dubbo的架构个各部分组件的作用。

在[Dubbo入门教程(2):Dubbo环境搭建][2]中我们搭建好了dubbo的服务器环境。

接下来就是编写实际的应用代码了。本文给出了一个Spring-Dubbo-Zookeeper的小demo，以供学习。

<!-- more -->

# 构建maven项目
首先构建MAVEN项目，导入所需要的jar包依赖

需要导入的有spring, dubbo, zookeeper等jar包。 

见[github源代码][3]

# 创建dubbo-api
dubbo-api是一个MAVEN项目(有独立的pom.xml，用来打包供提供者消费者使用)

在项目中定义服务接口：该接口需单独打包，在服务提供方和消费方共享。 

![image](https://pic.winsky.wang/images/2018/05/14/dubbo-api.png)

```Java
package com.winsky.dubbo.demo;

import java.util.List;

/**
 * author: winsky
 * date: 2018/5/14
 * description:
 */
public interface DemoService {
    List<String> getPermissions(Long id);
}
```

# 创建dubbo-provider
dubbo-provider是一个MAVEN项目(有独立的pom.xml，用来打包供消费者使用)

实现公共接口，此实现对消费者隐藏：

```Java
package com.winsky.dubbo.demo.impl;

import com.winsky.dubbo.demo.DemoService;

import java.util.ArrayList;
import java.util.List;

/**
 * author: winsky
 * date: 2018/5/14
 * description:
 */
public class DemoServiceImpl implements DemoService {

    @Override
    public List<String> getPermissions(Long id) {
        List<String> demo = new ArrayList<>();
        demo.add(String.format("Permission_%d", id - 1));
        demo.add(String.format("Permission_%d", id));
        demo.add(String.format("Permission_%d", id + 1));
        return demo;
    }
}
```

注意，需要在dubbo-provider的maven依赖中加入公共接口所在的依赖
```xml
<dependencies>
    <dependency>
        <groupId>com.winsky</groupId>
        <artifactId>dubbo-api</artifactId>
        <version>1.0-SNAPSHOT</version>
    </dependency>
</dependencies>
```

用Spring配置声明暴露服务
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://code.alibabatech.com/schema/dubbo
       http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
    <!--定义了提供方应用信息，用于计算依赖关系；在 dubbo-admin 或 dubbo-monitor 会显示这个名字，方便辨识-->
    <dubbo:application name="demotest-provider" owner="programmer" organization="dubbox"/>
    <!--使用 zookeeper 注册中心暴露服务，注意要先开启 zookeeper-->
    <dubbo:registry address="zookeeper://test.ufeng.top:2181"/>
    <!-- 用dubbo协议在20880端口暴露服务 -->
    <dubbo:protocol name="dubbo" port="20880"/>
    <!--使用 dubbo 协议实现定义好的 api.PermissionService 接口-->
    <dubbo:service interface="com.winsky.dubbo.demo.DemoService" ref="demoService" protocol="dubbo"/>
    <!--具体实现该接口的 bean-->
    <bean id="demoService" class="com.winsky.dubbo.demo.impl.DemoServiceImpl"/>
</beans>
```

启动远程服务：
```Java
package com.winsky.dubbo.demo.impl;

import org.springframework.context.support.ClassPathXmlApplicationContext;

import java.io.IOException;

/**
 * author: winsky
 * date: 2018/5/14
 * description:
 */
public class Provider {
    public static void main(String[] args) throws IOException {
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("provider.xml");
        System.out.println(context.getDisplayName() + ": here");
        context.start();
        System.out.println("服务已经启动...");
        System.in.read();
    }
}
```

# 创建dubbo-consumer
dubbo-consumer是一个MAVEN项目(可以有多个consumer，但是需要配置好)。

调用所需要的远程服务：

通过Spring配置引用远程服务：
```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:dubbo="http://code.alibabatech.com/schema/dubbo"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
       http://code.alibabatech.com/schema/dubbo http://code.alibabatech.com/schema/dubbo/dubbo.xsd">
    <dubbo:application name="demotest-consumer" owner="programmer" organization="dubbox"/>
    <!--向 zookeeper 订阅 provider 的地址，由 zookeeper 定时推送-->
    <dubbo:registry address="zookeeper://test.ufeng.top:2181"/>
    <!--使用 dubbo 协议调用定义好的 api.PermissionService 接口-->
    <dubbo:reference id="permissionService" interface="com.winsky.dubbo.demo.DemoService"/>
</beans>
```

启动Consumer,调用远程服务：
```Java
package com.winsky.dubbo.consumer;

import com.winsky.dubbo.demo.DemoService;
import org.springframework.context.support.ClassPathXmlApplicationContext;

/**
 * author: winsky
 * date: 2018/5/14
 * description:
 */
public class Consumer {
    public static void main(String[] args) {
        //测试常规服务
        ClassPathXmlApplicationContext context = new ClassPathXmlApplicationContext("consumer.xml");
        context.start();
        System.out.println("consumer start");
        DemoService demoService = context.getBean(DemoService.class);
        System.out.println("consumer");
        System.out.println(demoService.getPermissions(1L));
    }
}
```

# 运行项目
先确保provider已被运行后再启动consumer模块

运行提供者：

![image](https://pic.winsky.wang/images/2018/05/14/provider.png)

消费者成功调用提供者所提供的远程服务： 

![image](https://pic.winsky.wang/images/2018/05/14/consumer.png)


当然，这只是一个模拟的项目，实际中有多提供者多消费者情况，比这要复杂的多，当然只有这样才能体现dubbo的特性。


[1]: https://blog.winsky.wang/中间件/dubbo/Dubbo入门教程(1)：Dubbo介绍/ "Dubbo入门教程(1)：Dubbo介绍"
[2]: https://blog.winsky.wang/中间件/dubbo/Dubbo入门教程(2):Dubbo环境搭建/ "Dubbo入门教程(2):Dubbo环境搭建"
[3]: https://github.com/winsky94/dubbo_demo "github源代码"