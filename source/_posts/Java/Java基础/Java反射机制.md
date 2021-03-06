---
title: Java反射机制
date: 2018-03-18 20:31:14
updated: 2018-03-18 20:31:14
tags:
  - 反射
categories: 
  - Java
  - Java基础
---

反射机制可以说是Java语言比较一个突出的特点。反射机制允许JVM在运行时知道一个对象的所有信息。本文介绍了Java中的反射机制及其在开发中的应用。

<!-- more -->

# 反射的定义
- 反射机制是在运行时， 对于任意一个类， 都能够知道这个类的所有属性和方法； 对于任意一个对象， 都能够调用它的任意一个方法。 在Java中，只要给定类的名字， 那么就可以通过反射机制来获得类的所有信息。
- 反射机制主要提供了以下功能：
    - 在运行时判定任意一个对象所属的类；
    - 在运行时创建对象；
    - 在运行时判定任意一个类所具有的成员变量和方法；
    - 在运行时调用任意一个对象的方法；
    - 生成动态代理。

# 哪里用到反射机制？
jdbc 中有一行代码：`Class.forName(‘com.mysql.jdbc.Driver.class’);//加载MySql的驱动类。`这就是反射。

现在很多框架都用到反射机制， hibernate， struts 都是用反射机制实
现的。

# 反射的实现方式
在 Java 中实现反射最重要的一步， 也是第一步就是获取Class对象，得到Class对象后可以通过该对象调用相应的方法来获取该类中的属性、方法以及调用该类中的方法。

有 4 种方法可以得到 Class 对象：
- `Class.forName(“类的路径” );`
- 类名.class
- 对象名.getClass()
- 如果是基本类型的包装类， 则可以通过调用包装类的 Type 属性来获得该包装类的 Class 对象, `Class<?> clazz = Integer.TYPE;`
## 实现Java反射的类
1. Class：它表示正在运行的 Java 应用程序中的类和接口。
2. Field：提供有关类或接口的属性信息， 以及对它的动态访问权限。
3. Constructor：提供关于类的单个构造方法的信息以及对它的访问权限
4. Method：提供关于类或接口中某个方法信息。

注意：Class类是Java反射中最重要的一个功能类，所有获取对象的信息(包括： 方法/属性/构造方法/访问权限)都需要它来实现。

# 反射机制的优缺点
## 优点
- 能够运行时动态获取类的实例， 大大提高程序的灵活性。
- 与 Java 动态编译相结合， 可以实现无比强大的功能。

## 缺点
- 使用反射的性能较低。Java反射是要解析字节码，将内存中的对象进行解析。
    - 解决方案：
        - 由于JDK的安全检查耗时较多， 所以通过setAccessible(true)的方式关闭安全检查来（取消对访问控制修饰符的检查） 提升反射速度。
        - 需要多次动态创建一个类的实例的时候，有缓存的写法会比没有缓存要快很多:
        - ReflectASM 工具类 ， 通过字节码生成的方式加快反射速度。
- 使用反射相对来说不安全，破坏了类的封装性，可以通过反射获取这个类的私有方法和属性。
