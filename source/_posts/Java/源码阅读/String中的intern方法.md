---
title: String中的intern方法
date: 2018-03-12 12:38:43
updated: 2018-03-12 12:38:43
tags:
  - Java
  - 源码阅读
categories: 
  - Java
  - 源码阅读
---

在`JAVA`语言中有8种基本类型和一种比较特殊的类型`String`。这些类型为了使他们在运行过程中速度更快，更节省内存，都提供了一种常量池的概念。常量池就类似一个`JAVA`系统级别提供的缓存。

8种基本类型的常量池都是系统协调的，`String`类型的常量池比较特殊。它的主要使用方法有两种：
- 直接使用双引号声明出来的`String`对象会直接存储在常量池中。
- 如果不是用双引号声明的`String`对象，可以使用`String`提供的`intern`方法。`intern`方法会从字符串常量池中查询当前字符串是否存在，若不存在就会将当前字符串放入常量池中

今天我们主要来学习一下`String`中的`intern`方法

<!-- more -->

# Java实现
`String#intern`方法是一个`native`的方法，注释写的非常明了。
> “如果常量池中存在当前字符串，就会直接返回当前字符串. 如果常量池中没有此字符串，会将此字符串放入常量池中后，再返回”。

`String#intern`方法的具体实现是`c++`的代码，这里我们不过多的关注，有兴趣的同学可以去[深入解析String#intern][1]中第一节自行查看相关源码。这里我们介绍一下它的大概实现过程：

`JAVA`使用`jni`调用`c++`实现的`StringTable`的`intern`方法，`StringTable`的`intern`方法跟`Java`中的`HashMap`的实现是差不多的，只是不能自动扩容。默认大小是1009。

要注意的是，`String`的`StringPool`是一个固定大小的`Hashtable`，默认值大小长度是1009，如果放进`StringPool`的`String`非常多，就会造成`Hash`冲突严重，从而导致链表会很长，而链表长了后直接会造成的影响就是当调用`String.intern`时性能会大幅下降（因为要一个一个找）。

在`JDK6`中`StringTable`是固定的，就是1009的长度，所以如果常量池中的字符串过多就会导致效率下降很快。在`JDK7`中，`StringTable`的长度可以通过一个参数指定：
- `-XX:StringTableSize=99991`

# JDK 6和JDK 7下intern的区别

相信很多`JAVA`程序员都做做类似`String s = new String("abc")`这个语句创建了几个对象的题目。

这种题目主要就是为了考察程序员对字符串对象的常量池掌握与否。上述的语句中是创建了2个对象，第一个对象是`abc`字符串存储在常量池中，第二个对象在`JAVA Heap`中的`String`对象。

比如：
```Java
public static void main(String[] args) {
    String s = new String("1");
    s.intern();
    String s2 = "1";
    System.out.println(s == s2);

    String s3 = new String("1") + new String("1");
    s3.intern();
    String s4 = "11";
    System.out.println(s3 == s4);
}
```
打印结果是
- JDK 6下：`false false`
- JDK 7下：`false true`

具体为什么稍后再解释，然后将`s3.intern();`语句下调一行，放到`String s4 = "11";`后面。将`s.intern(); 放到String s2 = "1";`后面。是什么结果呢？
```Java
public static void main(String[] args) {
    String s = new String("1");
    String s2 = "1";
    s.intern();
    System.out.println(s == s2);

    String s3 = new String("1") + new String("1");
    String s4 = "11";
    s3.intern();
    System.out.println(s3 == s4);
}
```
打印结果为：
- JDK 6下：`false false`
- JDK 7下：`false false`

## JDK 6的解释
![image](https://tech.meituan.com/img/in_depth_understanding_string_intern/jdk6.png)

> 注：图中绿色线条代表`string`对象的内容指向。黑色线条代表地址指向。

如上图所示。首先说一下`JDK6`中的情况，在`JDK6`中上述的所有打印都是`false`的，因为`JDK6`中的常量池是放在`Perm`区中的，`Perm`区和正常的`JAVA Heap`区域是完全分开的。

上面说过如果是使用引号声明的字符串都是会直接在字符串常量池中生成，而`new`出来的`String`对象是放在`JAVA Heap`区域。

所以拿一个`JAVA Heap`区域的对象地址和字符串常量池的对象地址进行比较肯定是不相同的，即使调用`String.intern`方法也是没有任何关系的。

## JDK 7的解释
再说说`JDK7`中的情况。这里要明确一点的是，在`JDK6`以及以前的版本中，字符串的常量池是放在堆的`Perm`区的，`Perm`区是一个类静态的区域，主要存储一些加载类的信息、常量池、方法片段等内容，默认大小只有`4M`，一旦常量池中大量使用`intern`是会直接产生`java.lang.OutOfMemoryError: PermGen space`错误的。

所以在`JDK7`的版本中，字符串常量池已经从`Perm`区移到正常的`Java Heap`区域了。为什么要移动，`Perm`区域太小是一个主要原因，现在`JDK8`已经直接取消了`Perm`区域，而新建立了一个元区域。应该是`JDK`开发者认为`Perm`区域已经不适合现在`JAVA`的发展了。

正式因为字符串常量池移动到`JAVA Heap`区域后，再来解释为什么会有上述的打印结果。

![image](https://tech.meituan.com/img/in_depth_understanding_string_intern/jdk7_1.png)

- 在第一段代码中，先看`s3`和`s4`字符串。`String s3 = new String("1") + new String("1");`，这句代码中现在生成了2个对象，是字符串常量池中的“1” 和`JAVA Heap`中的`s3`引用指向的对象。中间还有2个匿名的`new String("1")`我们不去讨论它们。此时`s3`引用对象内容是"11"，但此时常量池中是没有 “11”对象的。
- 接下来`s3.intern();`这一句代码，是将`s3`中的“11”字符串放入`String`常量池中，因为此时常量池中不存在“11”字符串，因此常规做法是跟`JDK6`图中表示的那样，在常量池中生成一个 "11" 的对象，关键点是`JDK7`中常量池不在`Perm`区域了，这块做了调整。常量池中不需要再存储一份对象了，可以直接存储堆中的引用。这份引用指向`s3`引用的对象。也就是说引用地址是相同的。
- 最后`String s4 = "11";`这句代码中"11"是显示声明的，因此会直接去常量池中创建，创建的时候发现已经有这个对象了，此时也就是指向`s3`引用对象的一个引用。所以`s4`引用就指向和`s3`一样了。因此最后的比较`s3 == s4`是`true`。
- 再看`s`和`s2`对象。`String s = new String("1");`第一句代码，生成了2个对象。常量池中的“1” 和`JAVA Heap`中的字符串对象。`s.intern();`这一句是`s`对象去常量池中寻找后发现 “1” 已经在常量池里了。

    接下来`String s2 = "1";`这句代码是生成一个`s2`的引用指向常量池中的“1”对象。 结果就是`s`和`s2`的引用地址明显不同。图中画的很清晰。

![image](http://pic.winsky.wang/images/2018/03/30/jdk7_2.jpg)

- 来看第二段代码，从上边第二幅图中观察。第一段代码和第二段代码的改变就是`s3.intern();`的顺序是放在`String s4 = "11";`后了。这样，首先执行`String s4 = "11";`声明`s4`的时候常量池中是不存在“11”对象的，执行完毕后，“11“对象是`s4`声明产生的新对象。然后再执行`s3.intern();`时，常量池中“11”对象已经存在了，因此`s3`和`s4`的引用是不同的。
- 第二段代码中的`s`和`s2`代码中，`s.intern();`，这一句往后放也不会有什么影响了，因为对象池中在执行第一句代码`String s = new String("1");`的时候已经生成“1”对象了。下边的`s2`声明都是直接从常量池中取地址引用的。`s`和`s2`的引用地址是不会相等的。

## 总结
从上述的例子代码可以看出`JDK7`版本对`intern`操作和常量池都做了一定的修改。主要包括2点：
- 将`String`常量池从`Perm`区移动到了`Java Heap`区
- `String#intern`方法时，如果存在堆中的对象，会直接保存对象的引用，而不会重新创建对象。





[1]: https://tech.meituan.com/in_depth_understanding_string_intern.html "深入解析String#intern"

