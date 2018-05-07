---
title: synchronized关键字的使用
date: 2018-03-10 19:58:14
updated: 2018-03-10 19:58:14
tags:
  - 多线程
categories: 
  - Java
  - Java基础
---

Java语言的关键字，当它用来修饰一个方法或者一个代码块的时候，能够保证在同一时刻最多只有一个线程执行该段代码。

当多条线程同时访问共享数据时，如果不进行同步，就会发生错误。Java提供的解决方案是：只要将操作共享数据的语句在某一时间段让一个线程执行完，在执行过程中其他线程不能进来执行。

<!-- more -->

使用synchronized时会有两种方式，一种是同步方法，一种是同步代码块

synchronized(this)是锁定当前对象实例。在函数m1()里面写synchronized(this )，这个和public synchronized void m1() 等价

对静态方法和静态变量使用synchronized方法，锁定的都是类，该类所有的实例都得排队等待已经取得锁的对象实例释放锁

类锁和对象锁是两个不一样的锁，控制着不同的区域，它们是互不干扰的。同样，线程获得对象锁的同时，也可以获得该类锁，即同时获得两个锁，这是允许的。

synchronized(Object)锁定的是类中的成员变量，所有进行了synchronized(Object)的代码块都是互斥的

下面来看具体例子:

同一对象中，synchronized代码块和synchronized方法，锁定的对象
1. 创建一个有4个方法的对象`syncBlock`，其中一个synchronized方法，一个synchronized代码块，锁定this对象，还有两个synchronized代码块，锁定syncBlock中的一个对成员变量
2. 先启动一个线程(Thread-0), 并让其进入syncBlock对象的sychronized方法(add)内, 并使其停在synchronized方法内
3. 再启动一个线程(Thread-1),并执行syncBlock对象的一个synchronized(this)代码块的方法(minus), 看看能否进入此方法内
4. 再启动一个线程(Thread-2),并执行syncBlock对象的一个synchronized(processing)代码块的方法(times), 看看能否进入此方法内
5. 再启动一个线程(Thread-3),并执行syncBlock对象的一个synchronized(processing)代码块的方法(division), 看看能否进入此方法内
```Java
public class SyncBlock {
    private int sum = 1;
    private Object processing = new Object();

    public synchronized void add() {
        try {
            System.out.println(Thread.currentThread().getName() + " add方法, 已经获取内置锁`SyncBlock`");
            Thread.sleep(5000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        sum += 100;
        System.out.println(Thread.currentThread().getName() + " add方法, 即将释放内置锁`SyncBlock`");
    }

    public void minus() {
        synchronized (this) {
            try {
                System.out.println(Thread.currentThread().getName() + " minus方法, 已经获取内置锁`SyncBlock.this`");
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            sum -= 80;
            System.out.println(Thread.currentThread().getName() + " minus方法, 即将释放内置锁`SyncBlock.this`");
        }
    }

    public void times() {
        synchronized (processing) {
            try {
                System.out.println(Thread.currentThread().getName() + " times方法, 已经获取内置锁`processing`");
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            sum *= 20;
            System.out.println(Thread.currentThread().getName() + " times方法, 即将释放内置锁`processing`");
        }
    }

    public void division() {
        synchronized (processing) {
            try {
                System.out.println(Thread.currentThread().getName() + " division方法, 已经获取内置锁`processing`");
                Thread.sleep(4000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            sum /= 2;
            System.out.println(Thread.currentThread().getName() + " division方法, 即将释放内置锁`processing`");
        }
    }

    public int getSum() {
        return sum;
    }
}

class BlockThread1 extends Thread {
    SyncBlock syncBlock;

    public BlockThread1(SyncBlock syncBlock) {
        this.syncBlock = syncBlock;
    }

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + " running ...");
        syncBlock.add();
    }
}

class BlockThread2 extends Thread {
    SyncBlock syncBlock;

    public BlockThread2(SyncBlock syncBlock) {
        this.syncBlock = syncBlock;
    }

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + " running ...");
        syncBlock.minus();
    }
}

class BlockThread3 extends Thread {
    SyncBlock syncBlock;

    public BlockThread3(SyncBlock syncBlock) {
        this.syncBlock = syncBlock;
    }

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + " running ...");
        syncBlock.times();
    }
}

class BlockThread4 extends Thread {
    SyncBlock syncBlock;

    public BlockThread4(SyncBlock syncBlock) {
        this.syncBlock = syncBlock;
    }

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + " running ...");
        syncBlock.division();
    }
}

class BlockThread5 extends Thread {
    SyncBlock syncBlock;

    public BlockThread5(SyncBlock syncBlock) {
        this.syncBlock = syncBlock;
    }

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + " running ...");
        while (true) {
            System.out.println("sum=" + syncBlock.getSum());
            try {
                sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class TestSynBlock {
    public static void main(String[] args) throws InterruptedException {
        SyncBlock syncBlock = new SyncBlock();
        BlockThread1 thread1 = new BlockThread1(syncBlock);
        BlockThread2 thread2 = new BlockThread2(syncBlock);
        BlockThread3 thread3 = new BlockThread3(syncBlock);
        BlockThread4 thread4 = new BlockThread4(syncBlock);
        BlockThread5 thread5 = new BlockThread5(syncBlock);

        thread5.start();

        thread1.start();//先执行, 以便抢占锁
        Thread.sleep(500); //放弃cpu, 让thread1执行, 以便获的锁

        thread2.start();//先执行, 以便抢占锁
        Thread.sleep(500); //放弃cpu, 让thread2执行, 以便获的锁

        thread3.start();//先执行, 以便抢占锁
        Thread.sleep(500); //放弃cpu, 让thread3执行, 以便获的锁

        thread4.start();//先执行, 以便抢占锁
        Thread.sleep(500); //放弃cpu, 让thread4执行, 以便获的锁
    }
}
```
程序输出如下:
```
Thread-0 running ...
Thread-4 running ...
Thread-0 add方法, 已经获取内置锁`SyncBlock`
sum=1
Thread-1 running ...
Thread-2 running ...
Thread-2 times方法, 已经获取内置锁`processing`
sum=1
Thread-3 running ...
sum=1
Thread-2 times方法, 即将释放内置锁`processing`
Thread-3 division方法, 已经获取内置锁`processing`
sum=20
sum=20
Thread-0 add方法, 即将释放内置锁`SyncBlock`
Thread-1 minus方法, 已经获取内置锁`SyncBlock.this`
sum=120
sum=120
Thread-3 division方法, 即将释放内置锁`processing`
sum=60
Thread-1 minus方法, 即将释放内置锁`SyncBlock.this`
sum=-20
sum=-20
```

结果分析:

观察显示, 在输出`Thread-1 running ...`后会暂停数秒(Thread-1无法获得锁而被挂起, 因为锁已经被Thread-0持有).

在输出`Thread-3 running ...`后会暂停数秒(Thread-3无法获得锁而被挂起, 因为锁已经被Thread-2持有)

synchronized方法和synchronized(this)的代码块，二者取得的是同一个锁，都是当前对象的实例

synchronized(processing)代码块，二者取得的锁是processing对象