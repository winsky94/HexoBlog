---
title: Java中的异常机制
date: 2018-04-10 19:50:14
updated: 2018-04-10 19:50:14
tags:
  - Java
  - 异常
categories: 
  - Java
  - Java基础
---

在这个世界不可能存在完美的东西，不管完美的思维有多么缜密，细心，我们都不可能考虑所有的因素，这就是所谓的智者千虑必有一失。同样的道理，计算机的世界也是不完美的，异常情况随时都会发生，我们所需要做的就是避免那些能够避免的异常，处理那些不能避免的异常。

这里我将介绍Java中的异常机制。

<!-- more -->

# 为什么要使用异常
首先我们可以明确一点就是异常的处理机制可以确保我们程序的健壮性，提高系统可用率。

虽然我们不是特别喜欢看到它，但是我们不能不承认它的地位和作用。有异常就说明程序存在问题，有助于我们及时改正。在我们的程序设计当中，任何时候任何地方因为任何原因都有可能会出现异常，在没有异常机制的时候我们是这样处理的：通过函数的返回值来判断是否发生了异常（这个返回值通常是已经约定好了的），调用该函数的程序负责检查并且分析返回值。虽然可以解决异常问题，但是这样做存在几个缺陷：
- 容易混淆。如果约定返回值为-11111时表示出现异常，那么当程序最后的计算结果真的为-1111呢？
- 代码可读性差。将异常处理代码和程序代码混淆在一起将会降低代码的可读性。
- 由调用函数来分析异常，这要求程序员对库函数有很深的了解。

在OO中提供的异常处理机制是提供代码健壮的强有力的方式。

> 使用异常机制，能够降低错误处理代码的复杂度，如果不使用异常，那么就必须检查特定的错误，并在程序中的许多地方去处理它。而如果使用异常，那就不必在方法调用处进行检查，因为异常机制将保证能够捕获这个错误，并且，只需在一个地方处理错误，即所谓的异常处理程序中。这种方式不仅节约代码，而且把“概述在正常执行过程中做什么事”的代码和“出了问题怎么办”的代码相分离。总之，与以前的错误处理方法相比，异常机制使代码的阅读、编写和调试工作更加井井有条。

> ——摘自《Think in Java》

在初学时，总是听老师说把有可能出错的地方记得加异常处理，刚刚开始还不明白，有时候还觉得只是多此一举，现在随着自己的不断深入，实际生产项目做的多了，渐渐明白了异常是非常重要的。

# 基本定义
 在《Think in java》中是这样定义异常的：***异常情形是指阻止当前方法或者作用域继续执行的问题***。
 
 在这里一定要明确一点：异常代表某种程度的错误，尽管Java有异常处理机制，但是我们不能以“正常”的眼光来看待异常，异常处理机制的原因就是告诉你：这里可能会或者已经产生了错误，您的程序出现了不正常的情况，可能会导致程序失败！



# 异常体系简介
异常是指由于各种不期而至的情况，导致程序中断运行的一种指令流,如：文件找不到、非法参数、网络超时等。

为了保证正序正常运行，在设计程序时必须考虑到各种异常情况，并正确的对异常进行处理。

异常也是一种对象，java当中定义了许多异常类，并且定义了基类java.lang.Throwable作为所有异常的超类。Java语言设计者将异常划分为两类：Error和Exception，其体系结构大致如下图所示：

![image](https://pic.winsky.wang/images/2018/04/10/1354439580_6933.png)

从上面这幅图可以看出，Throwable是java语言中所有错误和异常的超类（万物即可抛）。它有两个子类：Error、Exception。

## Error(错误)
Error是程序中无法处理的错误，表示运行应用程序中出现了严重的错误。此类错误一般表示代码运行时JVM出现问题。通常有Virtual MachineError（虚拟机运行错误）、NoClassDefFoundError（类定义错误）等。比如说当jvm耗完可用内存时，将出现OutOfMemoryError。此类错误发生时，JVM将终止线程。

这些错误是不可查的，非代码性错误。因此，当此类错误发生时，应用不应该去处理此类错误。

## Exception(异常)
程序本身可以捕获并且可以处理的异常。

Exception这种异常又分为两类：运行时异常和编译异常。

### 运行时异常(不受检异常)
RuntimeException类及其子类表示JVM在运行期间可能出现的错误。比如说试图使用空值对象的引用（NullPointerException）、数组下标越界（ArrayIndexOutBoundException）。此类异常属于不可查异常，一般是由程序逻辑错误引起的，**在程序中可以选择捕获处理，也可以不处理**。

### 编译异常(受检异常)
Exception中除RuntimeException及其子类之外的异常。如果程序中出现此类异常，比如说IOException，必须对该异常进行处理，否则编译不通过。在程序中，通常不会自定义该类异常，而是直接使用系统提供的异常类。

## 可查异常与不可查异常
Java的所有异常可以分为可查异常（checked exception）和不可查异常（unchecked exception）。

### 可查异常
编译器要求必须处理的异常。正确的程序在运行过程中，经常容易出现的、符合预期的异常情况。一旦发生此类异常，就必须采用某种方式进行处理。除RuntimeException及其子类外，其他的Exception异常都属于可查异常。编译器会检查此类异常，也就是说当编译器检查到应用中的某处可能会此类异常时，将会提示你处理本异常——要么使用try-catch捕获，要么使用throws语句抛出，否则编译不通过。

### 不可查异常
编译器不会进行检查并且不要求必须处理的异常，也就说当程序中出现此类异常时，即使我们没有try-catch捕获它，也没有使用throws抛出该异常，编译也会正常通过。

**该类异常包括运行时异常（RuntimeException及其子类）和错误（Error）。**

# 异常处理流程
在java应用中，异常的处理机制分为抛出异常和捕获异常。

## 抛出异常
当一个方法出现错误而引发异常时，该方法会将该异常类型以及异常出现时的程序状态信息封装为异常对象，并交给本应用。运行时，该应用将寻找处理异常的代码并执行。任何代码都可以通过throw关键词抛出异常，比如Java源代码抛出异常、自己编写的代码抛出异常等。

## 捕获异常
一旦方法抛出异常，系统自动根据该异常对象寻找合适异常处理器（Exception Handler）来处理该异常。所谓合适类型的异常处理器指的是异常对象类型和异常处理器类型一致。

## 异常处理方式
对于不同的异常，java采用不同的异常处理方式：
1. 运行异常将由系统自动抛出，应用本身可以选择处理或者忽略该异常。
2. 对于方法中产生的Error，该异常一旦发生JVM将自行处理该异常，因此Java允许应用不抛出此类异常。
3. 对于所有的可查异常，必须进行捕获或者抛出该方法之外交给上层处理。也就是当一个方法存在异常时，要么使用try-catch捕获，要么使用该方法使用throws将该异常抛调用该方法的上层调用者。

### 捕获异常
#### try-catch语句
```Java
try {
    //可能产生的异常的代码区，也成为监控区
}catch (ExceptionType1 e) {
    //捕获并处理try抛出异常类型为ExceptionType1的异常
}catch(ExceptionType2 e) {
    //捕获并处理try抛出异常类型为ExceptionType2的异常
}
```
监控区一旦发生异常，则会根据当前运行时的信息创建异常对象，并将该异常对象抛出监控区，同时系统根据该异常对象依次匹配catch子句，若匹配成功（抛出的异常对象的类型和catch子句的异常类的类型或者是该异常类的子类的类型一致），则运行其中catch代码块中的异常处理代码，一旦处理结束，那就意味着整个try-catch结束。

**含有多个catch子句，一旦其中一个catch子句与抛出的异常对象类型一致时，其他catch子句将不再有匹配异常对象的机会。**

#### try-catch-finally
```Java
try {
    //可能产生的异常的代码区
}catch (ExceptionType1 e) {
    //捕获并处理try抛出异常类型为ExceptionType1的异常
}catch (ExceptionType2 e){
    //捕获并处理try抛出异常类型为ExceptionType2的异常
}finally{
    //无论是出现异常，finally块中的代码都将被执行
}
```
try-catch-finally代码块的执行顺序：
1) try没有捕获异常时，try代码块中的语句依次被执行，跳过catch。如果存在finally则执行finally代码块，否则执行后续代码。
2) try捕获到异常时，如果没有与之匹配的catch子句，则该异常交给JVM处理。如果存在finally，则其中的代码仍然被执行，但是finally之后的代码不会被执行。
3) try捕获到异常时，如果存在与之匹配的catch，则跳到该catch代码块执行处理。如果存在finally则执行finally代码块，执行完finally代码块之后继续执行后续代码；否则直接执行后续代码。另外注意，try代码块出现异常之后的代码不会被执行。

#### finally语句
1. 如果没有finally代码块，整个方法在执行完try代码块后返回相应的值来结束整个方法；
2. 如果有finally代码块，此时程序执行到try代码块里的return语句之时并不会立即执行return，而是先去执行finally代码块里的代码， 
    1. 若finally代码块里没有return或没有能够终止程序的代码，程序将在执行完finally代码块代码之后再返回try代码块执行return语句来结束整个方法；
    2. 若finally代码块里有return或含有能够终止程序的代码，方法将在执行完finally之后被结束，不再跳回try代码块执行return。

`Talk is cheap, show me the code.`单单通过语言描述太抽象了，我们还是通过一个具体的代码实例来真正体验一下吧

情况1：
```Java
public class ExceptionTest {
    public static void main(String[] args) {
        System.out.println(tryCatchTest());
    }

    public static String tryCatchTest() {
        try {
            // int i = 1 / 0;      //引发异常的语句
            System.out.println("try 块中语句被执行");
            return "try 块中语句 return";
        } catch (Exception e) {
            System.out.println("catch 块中语句被执行");
            return "catch 块中语句 return";
        }
        // finally {
        // System.out.println("finally 块中语句被执行");
        // return "finally 块中语句 return";
        // }
    }
}
```
输出：
```
try 块中语句被执行
try 块中语句 return
```

情况2.1：
```Java
public class ExceptionTest {
    public static void main(String[] args) {
        System.out.println(tryCatchTest());
    }

    public static String tryCatchTest() {
        try {
            // int i = 1 / 0;      //引发异常的语句
            System.out.println("try 块中语句被执行");
            return "try 块中语句 return";
        } catch (Exception e) {
            System.out.println("catch 块中语句被执行");
            return "catch 块中语句 return";
        } finally {
            System.out.println("finally 块中语句被执行");
            // return "finally 块中语句 return";
        }
    }
}
```
输出：
```
try 块中语句被执行
finally 块中语句被执行
try 块中语句 return
```

情况2.2：
```Java
public class ExceptionTest {
    public static void main(String[] args) {
        System.out.println(tryCatchTest());
    }

    public static String tryCatchTest() {
        try {
            // int i = 1 / 0;      //引发异常的语句
            System.out.println("try 块中语句被执行");
            return "try 块中语句 return";
        } catch (Exception e) {
            System.out.println("catch 块中语句被执行");
            return "catch 块中语句 return";
        } finally {
            System.out.println("finally 块中语句被执行");
            return "finally 块中语句 return";
        }
    }
}
```
输出：
```
try 块中语句被执行
finally 块中语句被执行
finally 块中语句 return
```

如果有catch块，基本和上面情况相似，只不过是把catch块续到try块引发异常语句后面，finally的地位依旧。

#### 总结
try代码块：用于捕获异常。其后可以接零个或者多个catch块。如果没有catch块，后必须跟finally块，来完成资源释放等操作，另外建议不要在finally中使用return，不用尝试通过catch来控制代码流程。

catch代码块：用于捕获异常，并在其中处理异常。

finally代码块：无论是否捕获异常，finally代码总会被执行。如果try代码块或者catch代码块中有return语句时，finally代码块将在方法返回前被执行。注意以下几种情况，finally代码块不会被执行：
- 在前边的代码中使用System.exit()退出应用
- 程序所在的线程死亡或者cpu关闭
- 如果在finally代码块中的操作又产生异常，则该finally代码块不能完全执行结束，同时该异常会覆盖前边抛出的异常

### 抛出异常
#### throws抛出异常
如果一个方法可能抛出异常，但是没有能力处理该异常或者需要通过该异常向上层汇报处理结果，可以在方法声明时使用throws来抛出异常。这就相当于计算机硬件发生损坏，但是计算机本身无法处理，就将该异常交给维修人员来处理。
```Java
public methodName throws Exception1,Exception2….(params){
    
}
```
其中Exception1,Exception2…为异常列表。一旦该方法中某行代码抛出异常，则该异常将由调用该方法的上层方法处理。如果上层方法无法处理，可以继续将该异常向上层抛。

#### throw抛出异常
在方法内，用throw来抛出一个Throwable类型的异常。一旦遇到到throw语句，后面的代码将不被执行。然后，便是进行异常处理——包含该异常的try-catch最终处理，也可以向上层抛出。注意我们只能抛出Throwable类和其子类的对象。
```Java
throw newExceptionType;
```
比如我们可以抛出：throw new Exception();

也有时候我们也需要在catch中抛出异常,这也是允许的，比如说：
```Java
Try{
    //可能会发生异常的代码
}catch(Exceptione){
    throw newException(e);
}
```

# 异常关系链
在实际开发过程中经常在捕获一个异常之后抛出另外一个异常，并且我们希望在新的异常对象中保存原始异常对象的信息，实际上就是异常传递，即把底层的异常对象传给上层，一级一级，逐层抛出。当程序捕获了一个底层的异常，而在catch处理异常的时候选择将该异常抛给上层…这样异常的原因就会逐层传递，形成一个由低到高的异常链。

但是异常链在实际应用中一般不建议使用，同时异常链每次都需要就将原始的异常对象封装为新的异常对象，消耗大量资源。现在（JDK 1.4之后）所有的Throwable的子类构造中都可以接受一个cause对象，这个cause也就是原始的异常对象。

# 异常转义
异常转义就是将一种类型的异常转成另一种类型的异常，然后再抛出异常。之所以要进行转译，是为了更准确的描述异常。

就我个人而言，我更喜欢称之为异常类型转换。在实际应用中，为了构建自己的日志系统，经常需要把系统的一些异常信息描述成我们想要的异常信息，就可以使用异常转译。异常转译针对所有Throwable类的子类而言，其子类型都可以相互转换。

通常而言，更为合理的转换方式是：
1. Error——>Exception
2. Error——>RuntimeException
3. Exception——>RuntimeException,

# Throwable类中常用的方法
像catch(Exception e)中的Exception就是异常的变量类型，e则是形参。通常在进行异常输出时有如下几个方法可用：
- e.getCause():返回抛出异常的原因。
- e.getMessage():返回异常信息。
- e.printStackTrace():发生异常时，跟踪堆栈信息并输出。

