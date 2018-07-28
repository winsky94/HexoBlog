---
title: JAVA虚拟机关闭钩子(Shutdown Hook)
date: 2018-07-28 23:58:14
updated: 2018-07-28 23:58:14
tags:
  - JVM
  - 关闭钩子
categories: 
  - Java
  - JVM
---

前几天看到蚂蚁开源的sofa框架，其中提供了应用关闭后的回调方法，看了原理之后发现是利用了JAVA虚拟机关闭钩子(Shutdown Hook)来实现的。

Java程序经常也会遇到进程挂掉的情况，一些状态没有正确的保存下来，这时候就需要在JVM关掉的时候执行一些清理现场的代码。JAVA中的ShutdownHook提供了比较好的方案。

<!-- more -->

JDK提供了Java.Runtime.addShutdownHook(Thread hook)方法，可以注册一个JVM关闭的钩子，这个钩子可以在一下几种场景中被调用：
- 程序正常退出
- 使用System.exit()
- 终端使用Ctrl+C触发的中断
- 系统关闭
- OutOfMemory宕机
- 使用Kill pid命令干掉进程（注：在使用kill -9 pid时，是不会被调用的）

下面是JDK1.7中关于钩子的定义：
```Java
public void addShutdownHook(Thread hook)
param：
    hook - An initialized but unstarted Thread object 
throw： 
    IllegalArgumentException - If the specified hook has already been registered, or if it can be determined that the hook is already running or has already been run 
    IllegalStateException - If the virtual machine is already in the process of shutting down 
    SecurityException - If a security manager is present and it denies RuntimePermission("shutdownHooks")
from：
    1.3 
see：
    removeShutdownHook(java.lang.Thread), halt(int), exit(int)
```

直接上测试代码
```Java
public class ShutdownHookTest {
    private void addHook() {
        Runtime.getRuntime().addShutdownHook(new Thread(() -> System.out.println("Execute Hook.....")));
    }

    public void case1() {
        System.out.println("case1: The Application is doing something");

        try {
            TimeUnit.MILLISECONDS.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void case2() {
        System.out.println("case2: The Application is doing something");
        System.exit(0);
    }

    public void case3() {
        Thread thread = new Thread(() -> {
            while (true) {
                System.out.println("thread is running....");
                try {
                    TimeUnit.MILLISECONDS.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        });
        thread.start();

    }

    public void case5() {
        System.out.println("case5: The Application is doing something");
        byte[] b = new byte[500 * 1024 * 1024];
        System.out.println("init finish");
    }


    public static void main(String[] args) {
        ShutdownHookTest hookTest = new ShutdownHookTest();
        hookTest.addHook();

        // hookTest.case1();
        // hookTest.case2();
        // hookTest.case3();
        hookTest.case5();
    }
}
```

首先来测试第一种，程序正常退出的情况：
```
case1: The Application is doing something
Execute Hook.....

Process finished with exit code 0
```
如上可以看到，当main线程运行结束之后就会调用关闭钩子。


再看第二种情况：
```
case2: The Application is doing something
Execute Hook.....

Process finished with exit code 0
```
当系统推出后，也会调用关闭钩子。

接着看第三种情况，程序启动之后过一会儿关闭程序。输出：
```
thread is running....
thread is running....
thread is running....
Execute Hook.....

Process finished with exit code 130 (interrupted by signal 2: SIGINT)
```

最后我们看下第五种情况，运行参数设置为：-Xmx20M  这样可以保证会有OutOfMemoryError的发生。结果：
```
case5: The Application is doing something
Exception in thread "main" java.lang.OutOfMemoryError: Java heap space
	at com.winsky.logs.ShutdownHookTest.case5(ShutdownHookTest.java:47)
	at com.winsky.logs.ShutdownHookTest.main(ShutdownHookTest.java:59)
Execute Hook.....
```

其他还有几种情况就不一一演示了，有兴趣可以自行撸代码尝试一下。