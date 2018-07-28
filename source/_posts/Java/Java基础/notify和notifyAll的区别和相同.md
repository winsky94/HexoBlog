---
title: notify和notifyAll的区别和相同
date: 2018-07-28 19:58:14
updated: 2018-07-28 19:58:14
tags:
  - 多线程
  - notify
categories: 
  - Java
  - Java基础
---

今天被问到一道题目，如何实现多个线程同时进行，谷歌之，发现网上有篇文章提到可以用`wait`和`notifyall`来实现，想着以前看过`wait`和`notify`的区别，今天正好有机会来看下`notifyall`。

本文记录了notify和notifyAll的区别和相同，以便不时之时查阅。

<!-- more -->
```
wait,notify,notifyAll：此方法只应由作为此对象监视器的所有者的线程来调用。通过以下三种方法之一，线程可以成为此对象监视器的所有者：
- 通过执行此对象的同步实例方法。 
- 通过执行在此对象上进行同步的`synchronized`语句的正文。 
- 对于`Class`类型的对象，可以通过执行该类的同步静态方法。 
 
一次只能有一个线程拥有对象的监视器。
```

以上说法，摘自javadoc。意思即，在调用中，必须持有对象监视器(即锁），我们可以理解为需要在synchronized方法内运行。

那么由此话的隐含意思，即如果要继续由同步块包含的代码块，需要重新获取锁才可以。这句话，在javadoc中这样描述：
```
wait：此方法导致当前线程（称之为T）将其自身放置在对象的等待集中，然后放弃此对象上的所有同步要求。出于线程调度目的，在发生以下四种情况之一前，线程T被禁用，且处于休眠状态：
- 其他某个线程调用此对象的 notify 方法，并且线程 T 碰巧被任选为被唤醒的线程。 
- 其他某个线程调用此对象的 notifyAll 方法。 
- 其他某个线程中断线程T。 
- 大约已经到达指定的实际时间。但是，如果 timeout 为零，则不考虑实际时间，在获得通知前该线程将一直等待。 

然后，从对象的等待集中删除线程T，并重新进行线程调度。该线程以常规方式与其他线程竞争，以获得在该对象上同步的权利；一旦获得对该对象的控制权，该对象上的所有其同步声明都将被恢复到以前的状态，这就是调用wait方法时的情况。

然后，线程 T 从 wait 方法的调用中返回。

所以，从 wait 方法返回时，该对象和线程 T 的同步状态与调用 wait 方法时的情况完全相同。
```

即必须重新进行获取锁，这样对于notifyAll来说，虽然所有的线程都被通知了。但是这些线程都会进行竞争，且只会有一个线程成功获取到锁，在这个线程没有执行完毕之前，其他的线程就必须等待了（只是这里不需要再notifyAll通知了，因为已经notifyAll了，只差获取锁了）有如下一个代码，可以重现这个现象。
```Java
public class RunningGame {
    public static final Object RACE_TRACK = new Object();

    public static void main(String[] args) {
        for (int i = 0; i < 8; i++) {
            Runner runner = new Runner(i + 1);
            runner.start();
        }

        Referee referee = new Referee();
        referee.start();
    }
}

class Runner extends Thread {
    private int index;

    public Runner(int index) {
        this.index = index;
    }

    @Override
    public void run() {
        synchronized (RunningGame.RACE_TRACK) {
            System.out.println(index + "号选手准备就位");
            try {
                RunningGame.RACE_TRACK.wait();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            System.out.println(index + "号选手出发，时间：" + System.currentTimeMillis());
            try {
                sleep(5000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }
}

class Referee {
    public void start() {
        synchronized (RunningGame.RACE_TRACK) {
            System.out.println();
            System.out.println("Ready!Go!");
            RunningGame.RACE_TRACK.notifyAll();
        }
    }
}
```
注意上面的run方法内部，我们在wait()之后，打印一句话，然后将当前代码，暂停5秒。关于sleep方法，该线程不丢失任何监视器的所属权，即仍然持有锁。

输出：
```
1号选手准备就位
2号选手准备就位
3号选手准备就位
4号选手准备就位
5号选手准备就位
6号选手准备就位
7号选手准备就位
8号选手准备就位

Ready!Go!
8号选手出发，时间：1532790388738
7号选手出发，时间：1532790393742
6号选手出发，时间：1532790398746
5号选手出发，时间：1532790403751
4号选手出发，时间：1532790408754
3号选手出发，时间：1532790413758
2号选手出发，时间：1532790418761
1号选手出发，时间：1532790423765
```

在上面的输出中，在wait之后，只有一个线程输出了”在运行了”语句，并且在一段时间内（这里为5秒），不会有其他输出。即表示，在当前代码持有锁之间，其他线程是不会输出的。

最后结论就是：被wait的线程，想要继续运行的话，它必须满足2个条件：
- 由其他线程notify或notifyAll了，并且当前线程被通知到了
- 经过和其他线程进行锁竞争，成功获取到锁了

2个条件，缺一不可。

其实在实现层面，notify和notifyAll都达到相同的效果，都只会有一个线程继续运行。但notifyAll免去了线程运行完了通知其他线程的必要，因为已经通知过了。

什么时候用notify，什么时候使用notifyAll，这就得看实际的情况了。

同时，我们使用notifyall来实现所有的线程同时开始执行就没有任何意义了，因为这些线程还需要争夺锁资源，其仍然是顺序执行的。
