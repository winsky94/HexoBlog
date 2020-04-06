title: Linux索引节点(Inode)用满导致空间不足
author: winsky
tags:
  - Linux
  - Inode
categories:
  - Linux
date: 2020-04-06 18:22:00
---
好不容易有个周末，今天想在博客上整理下之前的一些笔记，结果发现Hexo-Admin管理页面打开白屏了，简单排查后了解原来是系统Inode用完了，经过一番排查后终于得以顺利写下这篇记录文章。

本文着重介绍了如何解决Linux系统由于INode用完而导致的`No space left on device`的问题。

<!-- more -->

## 问题描述
打开Hexo-Admin管理后台时，发现竟然白屏了。一脸懵逼

考虑到自己服务器性能一般的现状，加上“重启解决99%的问题”的指导系统，先给服务器来了一波reboot。然鹅重启完成后打开页面仍然是白屏。

没办法，只能观察日志了，Nginx日志中有如下报错：
```
2020/04/06 18:07:14 [crit] 21499#0: *26403 open() "/usr/local/nginx/proxy_temp/1/00/0000000001" failed (28: No space left on device) while reading upstream, client: *.*.*.*, server: *.winsky.wang, request: "GET /admin/bundle.js HTTP/2.0", upstream: "http://127.0.0.1:4000/admin/bundle.js", host: "*.winsky.wang", referrer: "https://*.winsky.wang/*/"
```
报错倒是很明确，`No space left on device`，难道是服务器磁盘满了？`df -h`看一把
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda2        11G  7.4G  2.6G  75% /
tmpfs           254M     0  254M   0% /dev/shm
/dev/sda1       283M  146M  122M  55% /boot
```
虽然磁盘使用率不低，但是仍然有一定空间，排除是磁盘的锅了。

那，难道是索引节点Inode停工了？`df -i`看一波
```
Filesystem         Inodes  IUsed      IFree IUse% Mounted on
/dev/sda2          696256 696256     	0   100% /
tmpfs               64903      1      64902    1% /dev/shm
/dev/sda1           76912     58      76854    1% /boot
```
太惨了，果然是Inode被剥削光了，导致系统无法创建新目录和文件。

## 解决方案
定位到问题后，解决就相对方便多了，本质就一句话，服务器上小文件太多了，Linux系统都撑不住了，删掉一些就好了。

首先考虑到的是/tmp目录，这个文件夹下经常会有一些临时文件，直接删除之。`rm -rf /tmp/*`

再次查看Inode的使用情况，释放了大概一千多个可用索引节点，还不够啊。

借助`for i in /*; do echo $i; find $i |wc -l|sort -nr; done`命令看了下机器上每个文件夹下的文件数量，发现`/var/spool/clientmqueue`文件下超级多小文件。阿西，原来是机器上跑着的定时任务，输出内容没有重定向，导致产出了超级无敌多的小文件，蚕食了系统的Inode资源。依次执行下面的命令，然后问题就都解决了。

```shell
cd /var/spool/clientmqueue
# 这儿不要直接用rm -rf *，你会得到参数太多的报错提示的。
find /var/spool/clientmqueue  -type f -exec rm {} \;
```
安静的等待删除脚本执行完成，应急也就算OK了。删除后的Inode使用情况：
```
Filesystem         Inodes  IUsed      IFree IUse% Mounted on
/dev/sda2          696256 224577     471679   33% /
tmpfs               64903      1      64902    1% /dev/shm
/dev/sda1           76912     58      76854    1% /boot
```
世界瞬间干净了许多，完美。


## 拓展思考
### 问题根因
Inode译成中文就是索引节点，每个存储设备（例如硬盘）或存储设备的分区被格式化为文件系统后，应该有两部分，一部分是Inode，另一部分是Block，Block是用来存储数据用的。而Inode呢，就是用来存储这些数据的信息，这些信息包括文件大小、属主、归属的用户组、读写权限等。Inode为每个文件进行信息索引，所以就有了Inode的数值。操作系统根据指令，能通过Inode值最快的找到相对应的文件。

而这台服务器的Block虽然还有剩余，但Inode已经用满，因此在创建新目录或文件时，系统提示磁盘空间不足。

Inode的数量是有限制的，每个文件对应一个Inode，通过`df -i`可以查看Inode的最大数量和当前使用情况。

### Linux系统之Inode
**索引节点Inode**：保存的其实是实际的数据的一些信息，这些信息称为“元数据”(也就是对文件属性的描述)。例如：文件大小，设备标识符，用户标识符，用户组标识符，文件模式，扩展属性，文件读取或修改的时间戳，链接数量，指向存储该内容的磁盘区块的指针，文件分类等等。
(注意数据分成：元数据+数据本身)

同时注意：Inode有两种，一种是VFS的Inode，一种是具体文件系统的Inode。前者在内存中，后者在磁盘中。所以每次其实是将磁盘中的Inode调进填充内存中的Inode，这样才是算使用了磁盘文件Inode。

**Inode怎样生成的**：每个Inode节点的大小，一般是128字节或256字节。Inode节点的总数，在格式化时就给定(现代OS可以动态变化)，一般每2KB就设置一个Inode。一般文件系统中很少有文件小于2KB的，所以预定按照2KB分，一般Inode是用不完的。所以Inode在文件系统安装的时候会有一个默认数量，后期会根据实际的需要发生变化。

**Inode号**：Inode号是唯一的，表示不同的文件。其实在Linux内部的时候，访问文件都是通过Inode号来进行的，所谓文件名仅仅是给用户容易使用的。当我们打开一个文件的时候，首先，系统找到这个文件名对应的Inode号；然后，通过Inode号，得到Inode信息，最后，由Inode找到文件数据所在的block，现在可以处理文件数据了。

**Inode和文件的关系**：当创建一个文件的时候，就给文件分配了一个Inode。一个Inode只对应一个实际文件，一个文件也会只有一个Inode。Inode最大数量就是文件的最大数量。

> [阮一峰的网络日志：理解inode](https://www.ruanyifeng.com/blog/2011/12/inode.html)

### 定时任务接锅
本案例中，`/var/spool/clientmqueue`文件夹中文件最多，原因竟然是，crontab中配置的定时任务，执行的程序有输出内容，输出内容会以邮件形式发给cron的用户，而sendmail没有启动所以就产生了这些文件。

需要
本案例中，`/var/spool/clientmqueue`文件夹中文件最多，原因竟然是，crontab中配置的定时任务，执行的程序有输出内容，输出内容会以邮件形式发给cron的用户，而sendmail没有启动所以就产生了这些文件。

将crontab里面的命令后面加上` > /dev/null 2>&1 `或者` > /dev/null`，这样就不会在定时任务每次执行时产生一堆小文件了。