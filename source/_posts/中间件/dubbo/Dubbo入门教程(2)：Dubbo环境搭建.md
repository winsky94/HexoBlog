---
title: Dubbo入门教程(2)：Dubbo环境搭建
date: 2018-05-14 17:54:14
updated: 2018-05-14 17:54:14
tags:
  - 中间件
  - dubbo
categories: 
  - 中间件
  - dubbo
---

上一篇文章我们从电子商务系统的演变历史，引出了什么是Dubbo，介绍了Dubbo的架构个各部分组件的作用。

本文以CentOS为例，介绍如何搭建一个Dubbo环境，采用Zookeeper作为注册中心。

> 基于阿里云学生机CentOS 7.3系统

<!-- more -->

Dubbo环境的的搭建，主要分为以下几个步骤
- 安装Zookeeper,启动； 
- 安装maven，方便编译Dubbo-admin
- 安装Dubbo-admin，实现监控。

# Zookeeper安装
本Demo中的Dubbo注册中心采用的是Zookeeper。为什么采用Zookeeper呢？

Zookeeper是一个分布式的服务框架，是树型的目录服务的数据存储，能做到集群管理数据，这里能很好的作为Dubbo服务的注册中心。

Dubbo能与Zookeeper做到集群部署，当提供者出现断电等异常停机时，Zookeeper注册中心能自动删除提供者信息，当提供者重启时，能自动恢复注册数据，以及订阅请求

1. 首先下载zookeeper项目，我安装时最新版本是[zookeeper-3.4.12](https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/stable/zookeeper-3.4.12.tar.gz)。你也可以去[官网](https://zookeeper.apache.org/releases.html)查看并下载最新的版本。
2. 将下载下来的压缩包解压`tar -xzvf zookeeper-3.4.12.tar.gz`
3. 将conf目录下的`zoo_sample.cfg`复制成zookeeper默认读取的配置文件zoo.cfg；（cp zoo_sample.cfg zoo.cfg）
4. 修改zoo.cfg文件内容：
- 如果不需要集群，需要配置的参数为
```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/home/zookeeper/data
clientPort=2181
```
- 如果需要配置集群环境，则需要配置的参数为
```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/home/zookeeper/data
clientPort=2181
server.1=127.0.0.1:2888:3888（两个server的端口不能一样，第一端口是server间通讯用，第二个是选举leader用）
server.2=127.0.0.2:2889:3889
```
- 需要保证dataDir指向的目录实际是存在；
- 如果是集群环境，则要在这个目录里加一个myid名字的文件，文件内容为server.x这个x值。
5. 到此为止，zookeeper已经安装配置完毕，可以启动了。启动命令为：`$ZKPATH/bin/zkServer.sh start`

# maven安装
1. 下载最新的安装包，我安装时的最新版本是[apache-maven-3.5.3](http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz)。你也可以去[官网](http://maven.apache.org/download.cgi)查看并下载最新的版本。
2. 将下载下来的压缩包解压`tar -xzvf apache-maven-3.5.3-bin.tar.gz`
3. 配置环境变量`vi /etc/profile`，加入以下内容
```
export M2_HOME=/usr/local/apache-maven
export PATH=$PATH:$M2_HOME/bin
```
使环境变量shengxiao`source /etc/profile`
4. 验证是否安装成功`mvn -version`

# dubbo安装
1. 在github上获得dubbo-admin源码`git clone https://github.com/apache/incubator-dubbo-ops.git`
2. 将dubbo-admin编译并打包
    1. 进入`incubator-dubbo-ops\dubbo-admin`目录，输入下面命令`mvn clean package`
    2. 打包成功之后将在`incubator-dubbo-ops\dubbo-admin\target`目录下生成`dubbo-admin-2.0.0.war`
3. 将`dubbo-admin-2.0.0.war`复制到Tomcat的webapps目录下，并重命名为`dubbo-admin.war`
4. 修改WEB-INF下的dubbo.properties文件，配置zookeeper服务器和dubbo的管理后台的帐号密码
    1. 如果是多个zookeeper服务器，那服务器的值可设置为：zookeeper://127.0.0.1:2181?backup=127.0.0.2:2181
5. 重新启动tomcat服务器
6. 此时dubbo的管理后台就配置完了,可通过访问：`http://test.ufeng.top/dubbo-admin/`访问了