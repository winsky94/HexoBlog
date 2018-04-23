---
title: CentOS 7 下 MySQL 连接数被限制为214个
date: 2018-04-15 00:24:16
updated: 2018-04-15 00:24:16
tags:
  - MySQL
  - MySQL配置
categories: 
  - 数据库
---

今天环院的同学反馈说，河流生态地图应用出bug了，我上去一看，MySQL数据库提示`Too many connections`。出现这个错，是由于连接数过多，需要增加连接数。我在配置系统的时候明明已经在`/etc/my.cnf`中添加了`max_connections = 1000`，但是，实际连接数一直被限制在214。

经过一番研究，终于发现了原因，本文特做记录。

<!-- more -->

> 本文基于 CentOS 7.3 和 MySQL 5.6 、Mariadb 5.6环境

> 阿里云1核1G服务器

# 各种尝试
## 尝试一：更改 MySQL 在 Linux 的最大文件描述符限制

原先服务器上装的是MySQL 5.6，Google说如果配置了`max_connections = 1000`不生效的话，可选的是**更改 MySQL 在 Linux 的最大文件描述符限制**
- 编辑`/usr/lib/systemd/system/mysqld.service`，在文件最后添加
```
LimitNOFILE=65535
LimitNPROC=65535
```
- 保存后，执行下面命令，使配置生效
```
systemctl daemon-reload
systemctl restart  mysqld.service
```
- 实际连接数到 1000 了
```
mysql> show variables like "max_connections";
+-----------------+-------+
| Variable_name   | Value |
+-----------------+-------+
| max_connections | 1000  |
+-----------------+-------+
1 row in set
```

看上去问题是解决了，愉快地去玩耍了。

下午，环院的同学又来反馈问题依旧啊。我打算上服务器看看情况。然而，此时竟然连SSh登录服务器都无法登录了。走阿里云控制台VNC登录上去一看，sshd服务整个都挂了，提示分配内存不足。具体SSH无法登录的问题排查可以参照[SSH 无法远程登录问题的处理思路](https://yq.aliyun.com/articles/74547)，这里不赘述过程了，我这里纯粹的是因为内存不足导致sshd不能正常服务了。

通过`free -m`查看了一下机器内存使用情况，发现竟然可用内存只剩8M了。MySQL一个进程就占了500M左右的内存。这不太对啊。重启MySQL服务，竟然都无法成功启动。想着难道是更改 MySQL 在 Linux 的最大文件描述符限制的锅？把添加的两行配置注释掉之后，果然MySQL很快就启起来了。

可是，不改最大文件描述符的话，MySQL的最大连接数就只有214，无法达到文件中配置的1000。

## 尝试二：更换数据库为Mariadb
想起来以前在点盈实习的时候，公司用的Mariadb，当时我也自己调整过最大连接数，一下就成功了。难道是因为MySQL的锅？

卸载MySQL、安装Mariadb，重新按照上述配置调整配置文件。经过一番尝试，最大连接数仍然只有214。

## 尝试三：open_files_limit（解决）
说实话，经过上面一番尝试我基本已经绝望了，我甚至都想让环院同学直接升级机器配置了。

询问了一下环院的同学，他们只有一个人在使用这个系统，那就应该不是机器配置的问题呀。没办法，我又开始了我的谷歌之路。

> 面向谷歌编程

还是原先的那篇教程，解决方案中有一句
> 在配置文件中添加`open_files_limit = 65535`实际也没有生效

在一开始看的时候，我直接忽略的这句，毕竟人家都没生效嘛，我就不去尝试了。再次看到这里，我想，难道是这个的问题？

抱着死马当活马医的态度，我在Mariadb的配置文件中也加入了这句配置，重启Mariadb后，奇迹发生了，最大连接数终于变成1000了

# 问题出现的原因
MySQL官方文档里面说了
> The maximum number of connections MySQL can support depends on the quality of the thread library on a given platform, the amount of RAM available, how much RAM is used for each connection, the workload from each connection, and the desired response time. Linux or Solaris should be able to support at 500 to 1000 simultaneous connections routinely and as many as 10,000 connections if you have many gigabytes of RAM available and the workload from each is low or the response time target undemanding. Windows is limited to (open tables × 2 + open connections) < 2048 due to the Posix compatibility layer used on that platform.
>
> Increasing open-files-limit may be necessary. Also see Section 2.5, “Installing MySQL on Linux”, for how to raise the operating system limit on how many handles can be used by MySQL.

大概意思是 MySQL 能够支持的最大连接数量受限于操作系统,必要时可以增大 open-files-limit。换言之，连接数与文件打开数有关。

# 解决方案
执行`ulimit -n`查看最大文件描述符数（我这里是65535）

在MySQL配置文件中添加`open_files_limit = 65535`

到这里应该就OK了，如果还是不行，可以继续尝试下面的步骤，但是，**此方案可能造成MySQL因为内存不足无法正常启动，或者即使正常启动了，也可能耗尽系统的内存。**

更改 MySQL 在 Linux 的最大文件描述符限制，编辑`/usr/lib/systemd/system/mysqld.service`文件，在文件最后添加:
```
LimitNOFILE=65535
LimitNPROC=65535
```
保存后执行下面的命令
```shell
systemctl daemon-reload
systemctl restart  mysqld.service
```
这样最大连接数就是你配置的数量了

一把辛酸泪啊~~

> [MySQL 5.7 Reference Manual：Too many connections](https://dev.mysql.com/doc/refman/5.7/en/too-many-connections.html)






