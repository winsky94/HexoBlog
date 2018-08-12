---
title: JDK各版本区别(简明版)
date: 2018-03-08 19:54:14
updated: 2018-03-08 19:54:14
tags:
  - JDK
categories: 
  - JVM
---

Java是一种广泛使用的计算机编程语言，拥有跨平台、面向对象、泛型编程的特性，广泛应用于企业级Web应用开发和移动应用开发。

1995年5月23日，Java语言诞生。1996年1月，第一个JDK-JDK1.0诞生，到现在，已经有了JDK8了，甚至前一段时间连JDK9都出来了。

本文简单介绍了最近几代JDK的各版本中引入的重要新特性。

<!-- more -->

# JDK 5
- 自动装箱与拆箱：
- 枚举
- 静态导入
- 可变参数
- 内省
- 泛型
- For-Each循环

# JDK 6
- Desktop类和SystemTray类
- 使用JAXB2来实现对象与XML之间的映射
- 理解StAX
- 使用Compiler API
- 轻量级Http Server API
- 插入式注解处理API(Pluggable Annotation Processing API)
- 用Console开发控制台程序
- **对脚本语言的支持**如: ruby, groovy, javascript.
- Common Annotations
- Web服务元数据
- JTable的排序和过滤
- 更简单,更强大的JAX-WS
- **嵌入式数据库 Derby**

# JDK 7
- 对集合（Collections）的增强支持
- **在Switch中可用String**
- 数值可加下划线 例如：int one_million = 1_000_000;
- 支持二进制文字 例如：int binary = 0b1001_1001;
- 简化了可变参数方法的调用
- 运用`List tempList = new ArrayList<>();` 即**泛型实例化类型自动推断**
- 语法上支持集合，而不一定是数组
- 新增一些取环境信息的工具方法
- Boolean类型反转，空指针安全,参与位运算
- 两个char间的equals
- 安全的加减乘除
- map集合支持并发请求，且可以写成 Map map = {name:”xxx”,age:18};

# JDK 8
- **允许在接口中有默认方法和静态方法实现**
    - 常量
    - 抽象方法
    - 默认方法
    - 静态方法
- **Lambda 表达式**
- **函数式接口** @FunctionalInterface
- 方法与构造函数引用
- **使用 ::关键字来传递方法或者构造函数引用**
```
bomDetail.forEach(System.out::println);
```
- java.util.stream
- **支持多重注解**
- IO/NIO 的改进
- 安全性上的增强
- 新的日期/时间API java.time

# JDK 9
- 模块化系统
- JShell
- 平台日志API和服务:System.LoggerFinder用来管理JDK使用的日志记录器实现
- 统一 JVM 日志，可以使用新的命令行选项-Xlog 来控制 JVM 上 所有组件的日志记录
- CMS垃圾回收器已经被声明为废弃
- **Java 9 允许在接口中使用私有方法和私有静态方法**
    - 常量
    - 抽象方法
    - 默认方法
    - 静态方法
    - 私有方法
    - 私有静态方法