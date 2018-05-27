---
title: Tair入门教程(2)：Tair环境搭建
date: 2018-05-27 17:54:14
updated: 2018-05-27 17:54:14
tags:
  - 中间件
  - tair
categories: 
  - 中间件
  - tair
---

上一篇文章[Tair入门教程(1)：Tair介绍][1]我们介绍了Tair的主要功能和使用场景，以及其架构和各部分组件的作用。

本文以CentOS为例，介绍如何搭建一个Tair环境，采用Zookeeper作为注册中心。

> 基于阿里云学生机CentOS 7.3系统

<!-- more -->

# 安装
参照官方开源的[GitHub](https://github.com/alibaba/tair/)中的方法，我们采用编译源码的方式来安装tair。

## 安装步骤
```
# clone 代码到本地
git clone https://github.com/alibaba/tair.git

# 安装必要依赖
sudo yum install -y openssl-devel libcurl-devel

# 编译依赖
./bootstrap.sh

# 检测和生成 Makefile (默认安装位置是 ~/tair_bin, 修改使用 --prefix=目标目录)
./configure

# 编译和安装到目标目录
make -j && make install
```

## 遇到的问题
上面安装步骤都很简单，看上去是分分钟就能安装完，但是在安装的时候还是会有各种各样的问题。这里记录一下我遇到的一个问题。
```
g++: internal compiler error: Killed (program cc1plus)

Please submit a full bug report,
```

经过谷歌，最终发现主要原因是内存不足，g++编译时需要大量内存，临时使用交换分区来解决吧
```
sudo dd if=/dev/zero of=/swapfile bs=64M count=16

sudo mkswap /swapfile

sudo swapon /swapfile
```

上面三行命令临时挂载了一个64M的Swap内存。这样操作之后我就顺利编译完成了。

当然，编译完成后如果想卸载Swap内存，可以使用如下的命令
```
sudo swapoff /swapfile

sudo rm /swapfile
```

# 启动
## 部署配置
tair的运行, 至少需要一个 config server 和一个 data server。推荐使用两个config server 多个data server的方式。两个config server有主备之分。

tair有三个配置文件，分别是对config server、data server及group信息的配置，在tair_bin安装目录下的etc目录下有这三个配置文件的样例，我们将其复制一下，成为我们需要的配置文件。
```
cp configserver.conf.default configserver.conf
cp dataserver.conf.default dataserver.conf
cp group.conf.default group.conf
```

> [配置文件详解](https://github.com/alibaba/tair/wiki/配置文件详解)

在配置之前，请查阅官网给出的配置文件字段详解，下面直接贴出我自己的配置并加以简单的说明。

### 配置ConfigServer
```
#
# tair 2.3 --- configserver config
#

[public]
config_server=172.17.68.153:5198
config_server=172.17.68.153:5198

[configserver]
port=5198
log_file=/root/tair_bin/logs/config.log
pid_file=/root/tair_bin/logs/config.pid
log_level=warn
group_file=/root/tair_bin/etc/group.conf
data_dir=/root/tair_bin/data/data
dev_name=eth0
```

- 首先需要配置config server的服务器地址和端口号，端口号可以默认，服务器地址改成自己的，有一主一备两台configserver，这里仅为测试使用就设置为一台了。
- `log_file/pid_file`等的路径设置最好用绝对路径，默认的是相对路径，而且是不正确的相对路径（没有返回上级目录），因此这里需要修改。注意data文件和log文件非常重要，data文件不可缺少，而log文件是部署出错后能给你详细的出错原因。
- dev_name很重要，需要设置为你自己当前网络接口的名称，默认为eth0。

### 配置data server
```
#
#  tair 2.3 --- tairserver config
#

[public]
config_server=172.17.68.153:5198
config_server=172.17.68.153:5198

[tairserver]
#
#storage_engine:
#
# mdb
# ldb
#
storage_engine=mdb
local_mode=0
#
#mdb_type:
# mdb
# mdb_shm
#
mdb_type=mdb_shm

# shm file prefix, located in /dev/shm/, the leading '/' is must
mdb_shm_path=/mdb_shm_inst
# (1<<mdb_inst_shift) would be the instance count
mdb_inst_shift=3
# (1<<mdb_hash_bucket_shift) would be the overall bucket count of hashtable
# (1<<mdb_hash_bucket_shift) * 8 bytes memory would be allocated as hashtable
mdb_hash_bucket_shift=24
# milliseconds, time of one round of the checking in mdb lasts before having a break
mdb_check_granularity=15
# increase this factor when the check thread of mdb incurs heavy load
# cpu load would be around 1/(1+mdb_check_granularity_factor)
mdb_check_granularity_factor=10

#tairserver listen port
port=5191

supported_admin=0
process_thread_num=12
io_thread_num=12
dup_io_thread_num=1
#
#mdb size in MB
#
slab_mem_size=4096
log_file=/root/tair_bin/logs/server.log
pid_file=/root/tair_bin/logs/server.pid

is_namespace_load=1
is_flowcontrol_load=1
tair_admin_file = /root/tair_bin/etc/admin.conf

put_remove_expired=0
# set same number means to disable the memory merge, like 5-5
mem_merge_hour_range=5-5
# 1ms copy 300 items
mem_merge_move_count=300

log_level=warn
dev_name=eth0
ulog_dir=/root/tair_bin/data/ulog
ulog_file_number=3
ulog_file_size=64
check_expired_hour_range=2-4
check_slab_hour_range=5-7
dup_sync=1
dup_timeout=500

do_rsync=0

rsync_io_thread_num=1
rsync_task_thread_num=4

rsync_listen=1
# 0 mean old version
# 1 mean new version
rsync_version=0
rsync_config_service=http://localhost:8080/hangzhou/group_1
rsync_config_update_interval=60

# much resemble json format
# one local cluster config and one or multi remote cluster config.
# {local:[master_cs_addr,slave_cs_addr,group_name,timeout_ms,queue_limit],remote:[...],remote:[...]}
# rsync_conf={local:[10.0.0.1:5198,10.0.0.2:5198,group_local,2000,1000],remote:[10.0.1.1:5198,10.0.1.2:5198,group_remote,2000,800]}
# if same data can be updated in local and remote cluster, then we need care modify time to
# reserve latest update when do rsync to each other.
rsync_mtime_care=0
# rsync data directory(retry_log/fail_log..)
rsync_data_dir=./data/remote
# max log file size to record failed rsync data, rotate to a new file when over the limit
rsync_fail_log_size=30000000
# when doing retry,  size limit of retry log's memory use
rsync_retry_log_mem_size=100000000

# depot duplicate update when one server down
do_dup_depot=0
dup_depot_dir=./data/dupdepot

[flow_control]
# default flow control setting
default_net_upper = 30000000
default_net_lower = 15000000
default_ops_upper = 30000
default_ops_lower = 20000
default_total_net_upper = 75000000
default_total_net_lower = 65000000
default_total_ops_upper = 50000
default_total_ops_lower = 40000

[ldb]
#### ldb manager config
## data dir prefix, db path will be data/ldbxx, "xx" means db instance index.
## so if ldb_db_instance_count = 2, then leveldb will init in
## /data/ldb1/ldb/, /data/ldb2/ldb/. We can mount each disk to
## data/ldb1, data/ldb2, so we can init each instance on each disk.
data_dir=data/ldb
## leveldb instance count, buckets will be well-distributed to instances
ldb_db_instance_count=1
## whether load backup version when startup.
## backup version may be created to maintain some db data of specifid version.
ldb_load_backup_version=0
## whether support version strategy.
## if yes, put will do get operation to update existed items's meta info(version .etc),
## get unexist item is expensive for leveldb. set 0 to disable if nobody even care version stuff.
ldb_db_version_care=1
## time range to compact for gc, 1-1 means do no compaction at all
ldb_compact_gc_range = 3-6
## backgroud task check compact interval (s)
ldb_check_compact_interval = 120
## use cache count, 0 means NOT use cache,`ldb_use_cache_count should NOT be larger
## than `ldb_db_instance_count, and better to be a factor of `ldb_db_instance_count.
## each cache mdb's config depends on mdb's config item(mdb_type, slab_mem_size, etc)
ldb_use_cache_count=1
## cache stat can't report configserver, record stat locally, stat file size.
## file will be rotate when file size is over this.
ldb_cache_stat_file_size=20971520
## migrate item batch size one time (1M)
ldb_migrate_batch_size = 3145728
## migrate item batch count.
## real batch migrate items depends on the smaller size/count
ldb_migrate_batch_count = 5000
## comparator_type bitcmp by default
# ldb_comparator_type=numeric
## numeric comparator: special compare method for user_key sorting in order to reducing compact
## parameters for numeric compare. format: [meta][prefix][delimiter][number][suffix]
## skip meta size in compare
# ldb_userkey_skip_meta_size=2
## delimiter between prefix and number
# ldb_userkey_num_delimiter=:
####
## use blommfilter
ldb_use_bloomfilter=1
## use mmap to speed up random acess file(sstable),may cost much memory
ldb_use_mmap_random_access=0
## how many highest levels to limit compaction
ldb_limit_compact_level_count=0
## limit compaction ratio: allow doing one compaction every ldb_limit_compact_interval
## 0 means limit all compaction
ldb_limit_compact_count_interval=0
## limit compaction time interval
## 0 means limit all compaction
ldb_limit_compact_time_interval=0
## limit compaction time range, start == end means doing limit the whole day.
ldb_limit_compact_time_range=6-1
## limit delete obsolete files when finishing one compaction
ldb_limit_delete_obsolete_file_interval=5
## whether trigger compaction by seek
ldb_do_seek_compaction=0
## whether split mmt when compaction with user-define logic(bucket range, eg)
ldb_do_split_mmt_compaction=0

## do specify compact
## time range 24 hours
ldb_specify_compact_time_range=0-6
ldb_specify_compact_max_threshold=10000
## score threshold default = 1
ldb_specify_compact_score_threshold=1

#### following config effects on FastDump ####
## when ldb_db_instance_count > 1, bucket will be sharded to instance base on config strategy.
## current supported:
##  hash : just do integer hash to bucket number then module to instance, instance's balance may be
##         not perfect in small buckets set. same bucket will be sharded to same instance
##         all the time, so data will be reused even if buckets owned by server changed(maybe cluster has changed),
##  map  : handle to get better balance among all instances. same bucket may be sharded to different instance based
##         on different buckets set(data will be migrated among instances).
ldb_bucket_index_to_instance_strategy=map
## bucket index can be updated. this is useful if the cluster wouldn't change once started
## even server down/up accidently.
ldb_bucket_index_can_update=1
## strategy map will save bucket index statistics into file, this is the file's directory
ldb_bucket_index_file_dir=./data/bindex
## memory usage for memtable sharded by bucket when batch-put(especially for FastDump)
ldb_max_mem_usage_for_memtable=3221225472
####

#### leveldb config (Warning: you should know what you're doing.)
## one leveldb instance max open files(actually table_cache_ capacity, consider as working set, see `ldb_table_cache_size)
ldb_max_open_files=65535
## whether return fail when occure fail when init/load db, and
## if true, read data when compactiong will verify checksum
ldb_paranoid_check=0
## memtable size
ldb_write_buffer_size=67108864
## sstable size
ldb_target_file_size=8388608
## max file size in each level. level-n (n > 0): (n - 1) * 10 * ldb_base_level_size
ldb_base_level_size=134217728
## sstable's block size
# ldb_block_size=4096
## sstable cache size (override `ldb_max_open_files)
ldb_table_cache_size=1073741824
##block cache size
ldb_block_cache_size=16777216
## arena used by memtable, arena block size
#ldb_arenablock_size=4096
## key is prefix-compressed period in block,
## this is period length(how many keys will be prefix-compressed period)
# ldb_block_restart_interval=16
## specifid compression method (snappy only now)
# ldb_compression=1
## compact when sstables count in level-0 is over this trigger
ldb_l0_compaction_trigger=1
## whether limit write with l0's filecount, if false
ldb_l0_limit_write_with_count=0
## write will slow down when sstables count in level-0 is over this trigger
## or sstables' filesize in level-0 is over trigger * ldb_write_buffer_size if ldb_l0_limit_write_with_count=0
ldb_l0_slowdown_write_trigger=32
## write will stop(wait until trigger down)
ldb_l0_stop_write_trigger=64
## when write memtable, max level to below maybe
ldb_max_memcompact_level=3
## read verify checksum
ldb_read_verify_checksums=0
## write sync log. (one write will sync log once, expensive)
ldb_write_sync=0
## bits per key when use bloom filter
#ldb_bloomfilter_bits_per_key=10
## filter data base logarithm. filterbasesize=1<<ldb_filter_base_logarithm
#ldb_filter_base_logarithm=12

[extras]
######## RT-related ########
#rt_oplist=1,2
# Threashold of latency beyond which would let the request be dumped out.
rt_threshold=8000
# Enable RT Module at startup
rt_auto_enable=0
# How many requests would be subject to RT Module
rt_percent=100
# Interval to reset the latency statistics, by seconds
rt_reset_interval=10

######## HotKey-related ########
hotk_oplist=2
# Sample count
hotk_sample_max=50000
# Reap count
hotk_reap_max=32
# Whether to send client feedback response
hotk_need_feedback=0
# Whether to dump out packets, caches or hot keys
hotk_need_dump=0
# Whether to just Do Hot one round
hotk_one_shot=0
# Whether having hot key depends on: sigma >= (average * hotk_hot_factor)
hotk_hot_factor=0.8
```
- config_server的配置与之前必须完全相同。
- 这里面的port和heartbeat_port是data server的端口号和心跳端口号，必须确保系统能给你使用这些端口号。一般默认的即可
- data文件、log文件等很重要，与前一样，最好用绝对路径

### 配置group信息
```
#group name
[group_1]
# data move is 1 means when some data serve down, the migrating will be start.
# default value is 0
_data_move=0
#_min_data_server_count: when data servers left in a group less than this value, config server will stop serve for this group
#default value is copy count.
_min_data_server_count=1
#_plugIns_list=libStaticPlugIn.so
_build_strategy=1 #1 normal 2 rack
_build_diff_ratio=0.6 #how much difference is allowd between different rack
# diff_ratio =  |data_sever_count_in_rack1 - data_server_count_in_rack2| / max (data_sever_count_in_rack1, data_server_count_in_rack2)
# diff_ration must less than _build_diff_ratio
_pos_mask=65535  # 65535 is 0xffff  this will be used to gernerate rack info. 64 bit serverId & _pos_mask is the rack info,
_copy_count=1
_bucket_number=1023
# accept ds strategy. 1 means accept ds automatically
_accept_strategy=1
_allow_failover_server=0

# data center A
_server_list=172.17.68.153:5191
#_server_list=192.168.1.2:5191
#_server_list=192.168.1.3:5191
#_server_list=192.168.1.4:5191

# data center B
#_server_list=192.168.2.1:5191
#_server_list=192.168.2.2:5191
#_server_list=192.168.2.3:5191
#_server_list=192.168.2.4:5191

#quota info
_areaCapacity_list=0,1124000;
```
这个文件我只配置了data server列表，我只有一个dataserver，因此只需配置一个。

# 启动集群
在完成安装配置之后, 可以启动集群了.  启动的时候需要先启动data server 然后再启动cofnig server.

进入tair_bin目录后，按顺序启动：
```bash
sudo sbin/tair_server -f etc/dataserver.conf     # 在dataserver端启动
sudo sbin/tair_cfg_svr -f etc/configserver.conf   # 在config server端启动
```

执行启动命令后，在两端通过`ps aux | grep tair`查看是否启动了，这里启动起来只是第一步，还需要测试看是否真的启动成功，通过下面命令测试：
```
sudo sbin/tairclient -c 172.17.68.153:5198 -g group_1
TAIR> put k1 v1       
put: success
TAIR> put k2 v2
put: success
TAIR> get k2
KEY: k2, LEN: 2
```

其中172.17.68.153:5198是config server IP:PORT，group_1是group name，在group.conf里配置的。

# 遗留问题
按照上面的步骤，可以配置一个可用的Tair测试环境。但是，经过我的测试，这个集群只是在这台机器上可用，不能远程访问。参照网上的教程，把ip换成公网ip或者公网ip和私有ip混合的模式，都不行，不能远程访问。只能把程序发送到机器上去执行。

[1]: https://blog.winsky.wang/中间件/tair/Tair入门教程(1)：Tair介绍/ "Tair入门教程(1)：Tair介绍"