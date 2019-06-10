---
title: CentOS服务器挂载Swap分区
date: 2019-06-10 13:25:14
updated: 2019-06-10 13:25:14
tags:
  - Linux
categories: 
  - Linux
---

经常购买使用一些Linux的服务器，有些厂商提供的CentOS模板中并没有配置swap分区，这就使得服务器的内存有点捉襟见肘（尤其是小内存的情况下）。本文也就记录如何在CentOS系统下给服务器添加swap分区， 增大内存。


<!-- more -->

# 什么是swap分区

在开始前，我们还是先了解一下基础知识，什么是swap分区。已经了解的也可以直接跳到[操作步骤](#如何配置swap分区)

Linux中Swap（即：交换分区），类似于Windows的虚拟内存，就是当内存不足的时候，把一部分硬盘空间虚拟成内存使用，从而解决内存容量不足的情况。

交换分区，英文的说法是swap，意思是“交换”、“实物交易”。它的功能就是在内存不够的情况下，操作系统先把内存中暂时不用的数据，存到硬盘的交换空间，腾出内存来让别的程序运行，和Windows的虚拟内存（pagefile.sys）的作用是一样的。

需要注意的是，虽然这个SWAP分区能够作为"虚拟"的内存,但它的速度比物理内存可是慢多了，因此如果需要更快的速度的话,并不能寄厚望于SWAP，最好的办法仍然是加大物理内存。

SWAP分区只是临时的解决办法。

# 如何配置swap分区

 添加Swap分区通常有两种方法：
 - 1.使用未划分的磁盘空间，创建一个分区，然后格式化为swap格式，之后挂载使用。 
 - 2.使用dd命令创建一个整块文件，然后格式化为swap格式，作为swap分区使用，之后挂载使用。当然这种方法创建的swap分区性能比第一种方法差一些。

 我这里因为整个磁盘在系统初始化的的时候都已经被全部使用，所以只能采取第二种方法。

## 1.使用dd命令创建一个4G的整块文件
```
dd if=/var/zero of=/var/swap bs=1M count=4096
```

## 2.把/var/swap格式化为swap分区
```
mkswap /var/swap
```

## 3.使用swapon命令开启交换分区
```
swapon /var/swap
```

现在使用free -m命令查看，就可以看到Swap已经可以用了。
```
free -m
			  total       used       free     shared    buffers     cached
Mem:          1875       1808         67          0          6       1389
-/+ buffers/cache:        412       1463
Swap:         4095          0       4095
```

## 4.设置开机自动挂载Swap分区
前面使用swapon开启交换分区的操作，在系统重启之后就会失效。所以，我们这里需要通过修改`/etc/fstab`文件，设置成开机自动挂载Swap分区。

```
echo '/var/swap    swap    ext3   defaults   0 0' >> /etc/fstab
```

## 5.设置Swap分区使用规则
Swap分区虽然已经启用，但是used一直为0。这是因为Swap分区的启用是有一定规则的。我们可以查看`/proc/sys/vm/swappiness`文件。
```
cat /proc/sys/vm/swappiness
0
```

这个值的意思就是：当内存使用100%-0%=100%的时候，采用Swap分区。

当然，这个0的意思并不是绝对的当内存用完了到时候，才使用Swap，只是说尽可能不使用Swap。

阿里云服务器默认这个值为0，是因为，采用Swap会频繁读取硬盘，加大IO负担,所以让程序运行尽可能的使用内存而不是Swap。当然，当内存吃紧的时候，还是要用的。

这个值通常设置为40%-60%。

```
echo "40">/proc/sys/vm/swappiness
```

这种修改方式只会临时有效，当系统重启之后，就会失效。想要彻底有效需要修改`/etc/sysctl.conf`配置文件，里面有一参数`vm.swappiness = 0`，把它修改为需要的值。

```
vim /etc/sysctl.conf
```

这是因为系统启动的时候，会先读取`/etc/sysctl.conf`里面的参数`vm.swappiness`。通过这个参数来设置`/proc/sys/vm/swappiness`的值。

现在查看，Swap就可以被使用了。



