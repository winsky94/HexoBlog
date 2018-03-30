---
title: ThreadLocal源码阅读(待补充)
date: 2018-03-13 15:00:14
updated: 2018-03-13 15:00:14
tags:
  - Java
  - 源码阅读
categories: 
  - Java
  - 源码阅读
---

在多并发的环境下，如果不注意考虑线程安全的问题，很容易使应用程序出现各种意料之外的结果。

为了解决线程安全问题，我们主要有三种方式：加锁、使用`synchronized`关键字和使用`ThreadLocal`。

平时我使用锁和`synchronized`关键字比较多，对`ThreadLocal`是一知半解。本文就来重点介绍一下`ThreadLocal`的使用及源码实现。

<!-- more -->

# 使用ThreadLocal的原因
在多线程访问的时候，为了解决线程安全问题，使用`synchronized`关键字来实现线程同步的可以解决多线程并发访。但是在这种解决方案存在有性能问题，多个线程访问到的都是同一份变量的内容，在多线程同时访问的时候每次只允许一个线程读取变量内容，对变量值进行访问或者修改，其他线程只能处于排队等候状态，顺序执行，谁先抢占到系统资源谁先执行，导致系统效率低下。这是一种以延长访问时间来换取线程安全性的策略。简单来说就是以时间长度换取线程安全，在多用户并发访问的时候，由于等待时间太长，这对用户来说是不能接受的。

而使用`ThreadLocal`类，该类在每次实例化创建线程的时候都为每一个线程在本地变量中创建了自己独有的变量副本。每个线程都拥有了自己独立的一个变量，竞争条件被彻底消除了，那就没有必要使用`synchronized`关键字对这些线程进行同步，它们也能最大限度的使用系统资源，由`CPU`调度并发执行。并且由于每个线程在访问该变量时，读取和修改的，都是自己独有的那一份变量拷贝副本，不会对其他的任何副本产生影响，并发错误出现的可能也完全消除了。对比前一种方案，这是一种以空间来换取线程安全性的策略。在效率上来说比同步高了很多，可以应对多线程并发访问。

# 源码阅读
通过查看`ThreadLocal`类源码，该类中提供了两个主要的方法`get()`和`set()`，还有一个用于回收本地变量中的方法`remove()`。

## set方法源码
```Java
/**
 * Sets the current thread's copy of this thread-local variable
 * to the specified value.  Most subclasses will have no need to
 * override this method, relying solely on the {@link #initialValue}
 * method to set the values of thread-locals.
 *
 * @param value the value to be stored in the current thread's copy of
 *        this thread-local.
 */
public void set(T value) {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null)
        map.set(this, value);
    else
        createMap(t, value);
}
```
在`set()`中通过`getMap(Thread t)`方法获取一个和当前线程相关的 `ThreadLocalMap`，然后将变量的值设置到这个`ThreadLocalMap`对象中，如果获取到的`ThreadLocalMap`对象为空，就通过`createMap()`方法创建。

线程隔离的秘密，就在于`ThreadLocalMap`这个类。`ThreadLocalMap`是`ThreadLocal`类的一个静态内部类，它实现了键值对的设置和获取（类似于`Map<K,V> `存储的`key-value`），每个线程中都有一个独立的`ThreadLocalMap`副本，它所存储的值，只能被当前线程读取和修改。`ThreadLocal`类通过操作每一个线程特有的`ThreadLocalMap`副本，从而实现了变量访问在不同线程中实现隔离。因为每个线程的变量都是自己特有的，完全不会有并发错误。还有一点就是，`ThreadLocalMap`存储的键值对中的键是`this`对象指向的`ThreadLocal`对象，而值就是你所设置的对象了。

来分析源码中出现的getMap和createMap方法的实现：
```Java
/**
 * Get the map associated with a ThreadLocal. Overridden in
 * InheritableThreadLocal.
 *
 * @param  t the current thread
 * @return the map
 */
ThreadLocalMap getMap(Thread t) {
    return t.threadLocals;
}

/**
 * Create the map associated with a ThreadLocal. Overridden in
 * InheritableThreadLocal.
 *
 * @param t the current thread
 * @param firstValue value for the initial entry of the map
 */
void createMap(Thread t, T firstValue) {
    t.threadLocals = new ThreadLocalMap(this, firstValue);
}
```
通过源码分析可以看出，通过获取和设置`Thread`内的`threadLocals`变量，而这个变量的类型就是`ThreadLocalMap`，这样进一步验证了上文中的观点：每个线程都有自己独立的`ThreadLocalMap`对象。打开`java.lang.Thread`类的源代码，我们能得到更直观的证明：
```Java
/* ThreadLocal values pertaining to this thread. This map is maintained
 * by the ThreadLocal class. */
ThreadLocal.ThreadLocalMap threadLocals = null;
```

## get方法源码
```Java
/**
 * Returns the value in the current thread's copy of this
 * thread-local variable.  If the variable has no value for the
 * current thread, it is first initialized to the value returned
 * by an invocation of the {@link #initialValue} method.
 *
 * @return the current thread's value of this thread-local
 */
public T get() {
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null) {
        ThreadLocalMap.Entry e = map.getEntry(this);
        if (e != null) {
            @SuppressWarnings("unchecked")
            T result = (T)e.value;
            return result;
        }
    }
    return setInitialValue();
}

/**
 * Variant of set() to establish initialValue. Used instead
 * of set() in case user has overridden the set() method.
 *
 * @return the initial value
 */
private T setInitialValue() {
    T value = initialValue();
    Thread t = Thread.currentThread();
    ThreadLocalMap map = getMap(t);
    if (map != null)
        map.set(this, value);
    else
        createMap(t, value);
    return value;
}
```
通过以上源码的分析，在获取和当前线程绑定的值时，`ThreadLocalMap`对象是以`this `指向的`ThreadLocal`对象为键进行查找的，`set()`方法是设置变量的拷贝副本，`get()`方法通过键值对的方式获取到这个本地变量的副本的`value`。

## remove方法源码
```Java
/**
 * Removes the current thread's value for this thread-local
 * variable.  If this thread-local variable is subsequently
 * {@linkplain #get read} by the current thread, its value will be
 * reinitialized by invoking its {@link #initialValue} method,
 * unless its value is {@linkplain #set set} by the current thread
 * in the interim.  This may result in multiple invocations of the
 * {@code initialValue} method in the current thread.
 *
 * @since 1.5
 */
public void remove() {
    ThreadLocalMap m = getMap(Thread.currentThread());
    if (m != null)
        m.remove(this);
}
```
通过源码可以知道，该方法就是通过`this`找到`ThreadLocalMap`中保存的变量副本做回收处理。

> 后续补充 [并发编程 | ThreadLocal源码深入分析](http://www.sczyh30.com/posts/Java/java-concurrent-threadlocal/)