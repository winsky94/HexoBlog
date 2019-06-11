---
title: Gitlab日常备份及迁移
date: 2019-06-11 20:26:14
updated: 2018-06-11 20:26:14
tags:
  - Gitlab
categories: 
  - Git
  - gitlab
---

[Gitlab安装体验](/Git/gitlab/Gitlab安装体验/)一文介绍了如何在阿里云上安装Gitlab，安装是很简单方便，但是出于数据安全的考虑，我们需要做一些备份，以防万一。

本文重点介绍Gitlab的日常备份及迁移恢复


<!-- more -->

# Gitlab创建备份

使用Gitlab一键安装包安装Gitlab非常简单, 同样的备份恢复与迁移也非常简单. 使用一条命令即可创建完整的Gitlab备份:

```shell
gitlab-rake gitlab:backup:create
```

使用以上命令会在`/var/opt/gitlab/backups`目录下创建一个名称类似为`1393513186_gitlab_backup.tar`的压缩包, 这个压缩包就是Gitlab整个的完整部分, 其中开头的`1393513186`是备份创建的日期。

# Gitlab修改备份文件默认目录
你也可以通过修改`/etc/gitlab/gitlab.rb`来修改默认存放备份文件的目录

```shell
gitlab_rails['backup_path'] = '/mnt/backups'
```

`/mnt/backups`修改为你想存放备份的目录即可，修改完成之后使用`gitlab-ctl reconfigure`命令重载配置文件即可。

# Gitlab恢复备份

同样, Gitlab的从备份恢复也非常简单

```shell
# 停止相关数据连接服务
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq

# 从1393513186编号备份中恢复
gitlab-rake gitlab:backup:restore BACKUP=1393513186_gitlab_backup

# 启动Gitlab
sudo gitlab-ctl start
```

# Gitlab迁移

迁移如同备份与恢复的步骤一样，只需要将老服务器`/var/opt/gitlab/backups`目录下的备份文件拷贝到新服务器上的`/var/opt/gitlab/backups`即可(如果你没修改过默认备份目录的话)。

但是需要注意的是新服务器上的Gitlab的版本必须与创建备份时的Gitlab版本号相同。

比如新服务器安装的是最新的7.60版本的Gitlab，那么迁移之前，最好将老服务器的Gitlab升级为7.60在进行备份。

# Gitlab定时自动异地备份

由于Gitlab部署在了阿里云上，把Gitlab再备份在本地意义不是特别大，所以这里利用了家里的NAS做了一个简单的异地备份。

## 服务器备份脚本
在阿里云服务器上创建如下脚本，存储在`/home/scripts/gitlab_backup.sh`文件中

```shell
#!/bin/bash

# Gitlab自动备份脚本


#Gitlab 备份地址
LocalBackDir=/var/opt/gitlab/backups

#备份日志文件
LogFile=$LocalBackDir/remote_backup.log

#新建备份日志文件
touch $LogFile

echo "-------------------------------------------------------------------------" >> $LogFile

#记录本地生成gitlab备份日志
echo "Gitlab auto backup at local server, start at $(date +"%Y-%m-%d %H:%M:%S")" >>  $LogFile

#执行gitlab本地备份
gitlab-rake gitlab:backup:create >> $LogFile 2>&1

# $?符号显示上一条命令的返回值，如果为0则代表执行成功，其他表示失败
if [ $? -eq 0 ];then
   #追加日志到日志文件
   echo "Gitlab auto backup at local server successed at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile
else
   #追加日志到日志文件
   echo "Gitlab auto backup at local server failed at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile
fi

#查找本地备份目录修改时间为10分钟以内且后缀为.tar的Gitlab备份文件
Backfile_Send_To_Remote=`find $LocalBackDir -type f  -mmin -10 -name '*.tar' | tail -1` >> $LogFile 2>&1

echo $Backfile_Send_To_Remote
```

## NAS免密登录阿里云

异地备份思路需要在NAS上登录到阿里云服务器上执行对应的备份命令并下载文件，所以需要让NAS可以免密登录阿里云服务器，以定时自动执行这个任务。

免密登录的配置，可以参考[SSH免密登录配置](/Linux/SSH免密登录配置/(

## NAS服务器脚本

SSH进入NAS，然后创建脚本，自动在服务器上执行备份，并下载到NAS本地来。脚本存储在`/volume1/homes/gitlab_back/scripts/gitlab_backup_download.sh`文件中。

```shell
#!/bin/bash

# 远程登录gitlab服务器，执行自动备份脚本，然后传输至本地

#Gitlab服务器
RemoteServer=git.ufeng.top
RemoteServerUser=root

#Gitlab服务器备份地址
RemoteBackDir=/var/opt/gitlab/backups

#NAS本地备份地址
LocalBackDir=/volume1/homes/gitlab_back

#备份日志文件
LogFile=$LocalBackDir/remote_backup.log

#新建备份日志文件
touch $LogFile

echo "-------------------------------------------------------------------------" >> $LogFile
#记录NAS下载gitlab备份日志
echo "Gitlab backup auto download at NAS, start at $(date +"%Y-%m-%d %H:%M:%S")" >>  $LogFile

#远程登录gitlab服务器并执行备份脚本，获取备份文件的名字
result=`ssh $RemoteServerUser@$RemoteServer "sh /home/scripts/gitlab_backup.sh"`

#远程下载备份文件到本地
scp $RemoteServerUser@$RemoteServer:$result $LocalBackDir

echo "Gitlab remote backup file is ${result}" >> $LogFile

# 备份结果追加到备份日志
if [ $? -eq 0 ];then
	echo ""
	echo "$(date +"%Y-%m-%d %H:%M:%S") Gitlab Remote download Succeed!" >> $LogFile
else
	echo "$(date +"%Y-%m-%d %H:%M:%S") Gitlab Remote download Failed!" >> $LogFile
fi
```


然后配置群晖的定时任务，每天自动执行。

![群晖计划任务.png](https://pic.winsky.wang/images/2019/06/11/62bc4f425938329c.png)

## 自动清理历史备份文件

由于阿里云的存储空间有限，所以对Gitlab的历史备份文件需要定期删除，释放磁盘空间。

同样在`/home/scripts/gitlab_auto_del_backup.sh`文件中存储自动清理历史备份的脚本内容。
```shell
#!/bin/bash

#清理多余的历史备份

#Gitlab 备份地址
LocalBackDir=/var/opt/gitlab/backups

#备份日志文件
LogFile=$LocalBackDir/remote_clean.log

#新建备份日志文件
touch $LogFile

echo "--------------------------------------------------------------------- " >> $LogFile
echo "Gitlab auto clean local backup, start at  $(date +"%Y-%m-%d %H:%M:%S")" >>  $LogFile

# 找到3*24*60分钟前，以tar结尾的文件并删除
find $LocalBackDir -type f -mmin +4320  -name "*.tar" -exec rm -rf {} \;

# $?符号显示上一条命令的返回值，如果为0则代表执行成功，其他表示失败
if [ $? -eq 0 ];then
   #追加日志到日志文件
   echo "Gitlab auto clean local backup success at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile
else
   #追加日志到日志文件
   echo "Gitlab auto clean local backup failed at $(date +"%Y-%m-%d %H:%M:%S")" >> $LogFile
fi

```

然后赋予执行权限
```shell
chmod u+x /home/scripts/gitlab_auto_del_backup.sh
```

配置定时任务
```shell
crontab -e

0 3 * * * /home/scripts/gitlab_auto_del_backup.sh
```



