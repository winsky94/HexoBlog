---
title: HashMap为什么线程不安全
date: 2018-02-24 14:59:14
updated: 2018-02-24 14:59:14
tags:
  - Java
  - 源码阅读
categories: 
  - Java
  - 源码阅读
---

HashMap是我们平台开发中最经常使用数据结构之一。我们都知道，HashMap不是一个线程安全的数据结构，那它到底为什么线程不安全呢？它的不安全体现在什么地方呢？

<!-- more -->

# Map概述
HashMap不保证遍历的顺序和插入的顺序是一致的。**HashMap允许有一条记录的key为null，但是对值是否为null不做要求。**

HashTable类是线程安全的，它使用synchronize来做线程安全，全局只有一把锁，在线程竞争比较激烈的情况下hashtable的效率是比较低下的。因为当一个线程访问hashtable的同步方法时，其他线程再次尝试访问的时候，会进入阻塞或者轮询状态，比如当线程1使用put进行元素添加的时候，线程2不但不能使用put来添加元素，而且不能使用get获取元素。所以，竞争会越来越激烈。

相比之下，ConcurrentHashMap使用了分段锁技术来提高了并发度，不在同一段的数据互相不影响，多个线程对多个不同的段的操作是不会相互影响的。每个段使用一把锁。所以在需要线程安全的业务场景下，推荐使用ConcurrentHashMap，而HashTable不建议在新的代码中使用，如果需要线程安全，则使用ConcurrentHashMap，否则使用HashMap就足够了。

LinkedHashMap属于HashMap的子类，与HashMap的区别在于LinkedHashMap保存了记录插入的顺序。

TreeMap实现了SortedMap接口，TreeMap有能力对插入的记录根据key排序，默认按照升序排序，也可以自定义比较强，在使用TreeMap的时候，key应当实现Comparable。

# HashMap实现
Java7和Java8在实现HashMap上有所区别，当然Java8的效率要更好一些，主要是Java8的HashMap在Java7的基础上增加了红黑树这种数据结构，使得在桶里面查找数据的复杂度从O(n)降到O(logn)，当然还有一些其他的优化，比如resize的优化等。

介于Java8的HashMap较为复杂，本文将基于Java7的HashMap实现来说明，主要的实现部分还是一致的，Java8的实现上主要是做了一些优化，内容还是没有变化的，依然是线程不安全的。

HashMap的实现使用了一个数组，每个数组项里面有一个链表的方式来实现，因为HashMap使用key的hashCode来寻找存储位置，不同的key可能具有相同的hashCode，这时候就出现哈希冲突了，也叫做哈希碰撞，为了解决哈希冲突，有开放地址方法，以及链地址方法。HashMap的实现上选取了链地址方法，也就是将哈希值一样的entry保存在同一个数组项里面，可以把一个数组项当做一个桶，桶里面装的entry的key的hashCode是一样的。
> [Hash冲突的解决办法](http://blog.csdn.net/u012104435/article/details/47951357)

![image](https://upload-images.jianshu.io/upload_images/7853175-19775bb2353f3364.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)
上面的图片展示了我们的描述，其中有一个非常重要的数据结构`Node<K,V>`，这就是实际保存我们的key-value对的数据结构，下面是这个数据结构的主要内容：
```
final int hash;    
final K key;
V value;
Node<K,V> next;
```
一个Node就是一个链表节点，也就是我们插入的一条记录，明白了HashMap使用链地址方法来解决哈希冲突之后，我们就不难理解上面的数据结构，hash字段用来定位桶的索引位置，key和value就是我们的数据内容，需要注意的是，我们的key是final的，也就是不允许更改，这也好理解，因为HashMap使用key的hashCode来寻找桶的索引位置，一旦key被改变了，那么key的hashCode很可能就会改变了，所以随意改变key会使得我们丢失记录（无法找到记录）。next字段指向链表的下一个节点。

HashMap的初始桶的数量为16，loadFact为0.75,当桶里面的数据记录超过阈值的时候，HashMap将会进行扩容则操作，每次都会变为原来大小的2倍，直到设定的最大值之后就无法再resize了。

下面对HashMap的实现做简单的介绍，具体实现还得看代码，对于Java8中的HashMap实现，还需要能理解红黑树这种数据结构。

1. 根据key的hashCode来决定应该将该记录放在哪个桶里面，无论是插入、查找还是删除，这都是第一步，计算桶的位置。因为HashMap的length总是2的n次幂，所以可以使用下面的方法来做模运算：
    ```
    h&(length-1)
    ```
    h是key的hashCode值，计算好hashCode之后，使用上面的方法来对桶的数量取模，将这个数据记录落到某一个桶里面。当然取模是Java7中的做法，Java8进行了优化，做得更加巧妙，因为我们的length总是2的n次幂，所以在一次resize之后，当前位置的记录要么保持当前位置不变，要么就向前移动length就可以了。所以Java8中的HashMap的resize不需要重新计算hashCode。我们可以通过观察Java7中的计算方法来抽象出算法，然后进行优化，具体的细节看代码就可以了。
2. HashMap的put方法
    ![image](https://upload-images.jianshu.io/upload_images/7853175-a8950349acda7799.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)
    上图展示了Java8中put方法的处理逻辑，比Java7多了红黑树部分，以及在一些细节上的优化，put逻辑和Java7中是一致的。
3. resize机制
    HashMap的扩容机制就是重新申请一个容量是当前的2倍的桶数组，然后将原先的记录逐个重新映射到新的桶里面，然后将原先的桶逐个置为null使得引用失效。后面会讲到，HashMap之所以线程不安全，就是resize这里出的问题。

# 为什么HashMap线程不安全
HashMap在resize操作的时候会造成线程不安全。下面将举两个可能出现线程不安全的地方。

1. put的时候导致的多线程数据不一致
    
    比如有两个线程A和B，首先A希望插入一个key-value对到HashMap中，首先计算记录所要落到的桶的索引坐标，然后获取到该桶里面的链表头结点，此时线程A的时间片用完了，而此时线程B被调度得以执行，和线程A一样执行，只不过线程B成功将记录插到了桶里面，假设线程A插入的记录计算出来的桶索引和线程B要插入的记录计算出来的桶索引是一样的，那么当线程B成功插入之后，线程A再次被调度运行时，它依然持有过期的链表头但是它对此一无所知，以至于它认为它应该这样做，如此一来就覆盖了线程B插入的记录，这样线程B插入的记录就凭空消失了，造成了数据不一致的行为。
2. 另外一个比较明显的线程不安全的问题是HashMap的get操作可能因为resize而引起死循环（cpu100%），具体分析如下：

    下面的代码是resize的核心内容
    ```Java
    void transfer(Entry[] newTable, boolean rehash) {  
        int newCapacity = newTable.length;  
        for (Entry<K,V> e : table) {  
  
            while(null != e) {  
                Entry<K,V> next = e.next;           
                if (rehash) {  
                    e.hash = null == e.key ? 0 : hash(e.key);  
                }  
                int i = indexFor(e.hash, newCapacity);   
                e.next = newTable[i];  
                newTable[i] = e;  
                e = next;  
            } 
        }  
    }
    ```
    这个方法的功能是将原来的记录重新计算在新桶的位置，然后迁移过去
    ![image](https://upload-images.jianshu.io/upload_images/7853175-ab75cd3738471507.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)
    我们假设有两个线程同时需要执行resize操作，我们原来的桶数量为2，记录数为3，需要resize桶到4，原来的记录分别为：[3,A],[7,B],[5,C]，在原来的map里面，我们发现这三个entry都落到了第二个桶里面。
    
    假设线程thread1执行到了transfer方法的Entry next = e.next这一句，然后时间片用完了，此时的e = [3,A], next = [7,B]。线程thread2被调度执行并且顺利完成了resize操作，需要注意的是，此时的[7,B]的next为[3,A]。此时线程thread1重新被调度运行，此时的thread1持有的引用是已经被thread2 resize之后的结果。线程thread1首先将[3,A]迁移到新的数组上，然后再处理[7,B]，而[7,B]被链接到了[3,A]的后面，处理完[7,B]之后，就需要处理[7,B]的next了啊，而通过thread2的resize之后，[7,B]的next变为了[3,A]，此时，[3,A]和[7,B]形成了环形链表，在get的时候，如果get的key的桶索引和[3,A]和[7,B]一样，那么就会陷入死循环。

# fail-fast策略
另外，如果在使用迭代器的过程中有其他线程修改了map，那么将抛出ConcurrentModificationException，这就是所谓fail-fast策略。

这一策略在源码中的实现是通过modCount域，modCount顾名思义就是修改次数，对HashMap内容的修改都将增加这个值，那么在迭代器初始化过程中会将这个值赋给迭代器的expectedModCount。
```Java
HashIterator() {  
    expectedModCount = modCount;  
    if (size > 0) { // advance to first entry  
        Entry[] t = table;  
        while (index < t.length && (next = t[index++]) == null)  
            ;  
    }  
} 
```
在迭代过程中，判断modCount跟expectedModCount是否相等，如果不相等就表示已经有其他线程修改了Map：

注意到modCount声明为volatile，保证线程之间修改的可见性。
```Java
final Entry<K,V> nextEntry() {  
    if (modCount != expectedModCount)       
        throw new ConcurrentModificationException();
```

# 为什么String, Interger这样的wrapper类适合作为键？

String, Interger这样的wrapper类作为HashMap的键是再适合不过了，而且String最为常用。因为String是不可变的，也是final的，而且已经重写了equals()和hashCode()方法了。其他的wrapper类也有这个特点。

不可变性是必要的，因为为了要计算hashCode()，就要防止键值改变，如果键值在放入时和获取时返回不同的hashcode的话，那么就不能从HashMap中找到你想要的对象。

不可变性还有其他的优点如线程安全。如果你可以仅仅通过将某个field声明成final就能保证hashCode是不变的，那么请这么做吧。因为获取对象的时候要用到equals()和hashCode()方法，那么键对象正确的重写这两个方法是非常重要的。如果两个不相等的对象返回不同的hashcode的话，那么碰撞的几率就会小些，这样就能提高HashMap的性能。

> [为什么HashMap线程不安全
](https://www.jianshu.com/p/e2f75c8cce01)