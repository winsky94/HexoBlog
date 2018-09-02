---
title: 锁等待超时与information_schema的三个表
date: 2018-09-02 14:35:16
updated: 2018-09-02 14:35:16
tags:
  - MySQL
  - 锁
categories: 
  - 数据库
---

在高并发的环境下，我们经常会遇到并发处理的问题。在数据库的处理过程中，曾经碰到这样一个错误：
```
ERROR 1205 (HY000): Lock wait timeout exceeded; 
try restarting transaction
```

翻译过来就是`锁等待超时，尝试重启事务`。

那，这种是如何出现的呢？以及我们在开发中应该如何排查呢？

<!-- more -->

# information_schema的三个表
information_schema中的三个表记录了事务和锁的相关的记录，三张表的具体字段描述如下：

## innodb_trx
当前运行的所有事务
| Field | Type | Null | Key | Default | Extra |
| :--------:| :--------: | :--: | :--: | :--------: | :--------: |
| trx_id | varchar(18) | NO | | | 事务ID |
| trx_state | varchar(13) | NO | | | 事务状态 |
| trx_started | datetime | NO | | 0000-00-00 00:00:00 | 事务开始时间 |
| trx_requested_lock_id | varchar(81) | YES |  | NULL | innodb_locks.lock_id |
| trx_wait_started | datetime | YES |  | NULL | 事务开始等待的时间 |
| trx_weight | bigint(21) unsigned | NO |  | 0 | 事务权重 |
| trx_mysql_thread_id | bigint(21) unsigned | NO |  | 0 | 事务线程ID |
| trx_query | varchar(1024) | YES |  | NULL | 具体SQL语句 |
| trx_operation_state | varchar(64) | YES |  | NULL | 事务当前操作状态 |
| trx_tables_in_use | bigint(21) unsigned | NO |  | 0 | 事务中有多少个表被使用 |
| trx_tables_locked | (21) unsigned | NO |  | 0 | 事务拥有多少个锁 |
| trx_lock_structs | bigint(21) unsigned | NO |  | 0 |  |
| trx_lock_memory_bytes | bigint(21) unsigned | NO |  | 0 | 事务锁住的内存大小（B） |
| trx_rows_locked | bigint(21) unsigned | NO |  | 0 | 事务锁住的行数 |
| trx_rows_modified | bigint(21) unsigned | NO |  | 0 | 事务更改的行数 |
| trx_concurrency_tickets | bigint(21) unsigned | NO |  | 0 | 事务并发票数 |
| trx_isolation_level | varchar(16) | NO |  |  | 事务隔离级别 |
| trx_unique_checks | int(1) | NO |  | 0 | 是否唯一性检查 |
| trx_foreign_key_checks | int(1) | NO |  | 0 | 是否外键检查 |
| trx_last_foreign_key_error | varchar(256) | YES |  | NULL | 最后的外键错误 |
| trx_adaptive_hash_latched | int(1) | NO |  | 0 |  |
| trx_adaptive_hash_timeout | bigint(21) unsigned | NO |  | 0 |  |

## innodb_locks
当前出现的锁
| Field	| Type | Null | Key | Default | Extra |
| :----: | :----: | :--: | :--: | :----: | :----: |
| lock_id | varchar(81) | NO | | | 锁id
| lock_trx_id | varchar(18) | NO | | | 拥有锁的事务id
| lock_mode | varchar(32) | NO | | | 锁模式
| lock_type | varchar(32) | NO | | | 锁类型
| lock_table | varchar(1024) | NO | | | 被锁的表
| lock_index | varchar(1024) | YES | | NULL | 被锁的索引
| lock_space | bigint(21) unsigned | YES | | NULL | 被锁的表空间号
| lock_page | bigint(21) unsigned | YES | | NULL | 被锁的页号
| lock_rec | bigint(21) unsigned | YES | | NULL | 被锁的记录号
| lock_data | varchar(8192) | YES | | NULL | 被锁的数据

## innodb_lock_waits
锁等待的对应关系
| Field				| Type			| Null 	| Key 	| Default	| Extra				|
| -- | --	| -- | -- | -- | -- |
| requesting_trx_id	| varchar(18) 	| NO 	|		|			| 请求锁的事务ID 		|
| requested_lock_id	| varchar(81) 	| NO 	|		|			| 请求锁的锁ID 		|
| blocking_trx_id 	| varchar(18) 	| NO 	|		|			| 当前拥有锁的事务ID 	|
| blocking_lock_id	| varchar(81) 	| NO 	|		|			| 当前拥有锁的锁ID 	|

# 案例演示
** 第一步，创建测试表，并插入测试数据 **
```SQL
create table tx1(id int primary key ,c1 varchar(20),c2 varchar(30),c3 datetime) engine=innodb default charset = utf8 ;

insert into tx1 values
(1,'aaaa','aaaaa2',NOW()),
(2,'bbbb','bbbbb2',NOW()),
(3,'cccc','ccccc2',NOW());
```

** 第二步，手动开启事务，并查询三个表数据 **
```SQL
start transaction;

update tx1 set c1='heyf',c2='heyf',c3=NOW() where id =3 ;

select * from information_schema.innodb_trx\G;

select * from information_schema.INNODB_LOCKS\G;

select * from information_schema.INNODB_LOCK_WAITS\G;
```
此时没有锁，锁等待关系，只有`innodb_trx`表中有数据
```
mysql> select * from information_schema.innodb_trx\G;
*************************** 1. row ***************************
                    trx_id: 805646
                 trx_state: RUNNING
               trx_started: 2018-09-02 14:29:58
     trx_requested_lock_id: NULL
          trx_wait_started: NULL
                trx_weight: 3
       trx_mysql_thread_id: 3
                 trx_query: select * from information_schema.innodb_trx
       trx_operation_state: NULL
         trx_tables_in_use: 0
         trx_tables_locked: 1
          trx_lock_structs: 2
     trx_lock_memory_bytes: 1136
           trx_rows_locked: 1
         trx_rows_modified: 1
   trx_concurrency_tickets: 0
       trx_isolation_level: REPEATABLE READ
         trx_unique_checks: 1
    trx_foreign_key_checks: 1
trx_last_foreign_key_error: NULL
 trx_adaptive_hash_latched: 0
 trx_adaptive_hash_timeout: 0
          trx_is_read_only: 0
trx_autocommit_non_locking: 0
1 row in set (0.00 sec)
```

** 第三步，在另一个会话中更新该记录，产生锁等待 **
```SQL
start transaction;

update tx1 set c1='heyfffff',c2='heyffffff',c3=NOW() where id =3 ;
```
查看`innodb_trx`表数据
```
mysql> select * from information_schema.innodb_trx\G;
*************************** 1. row ***************************
                    trx_id: 805649
                 trx_state: LOCK WAIT
               trx_started: 2018-09-02 15:08:55
     trx_requested_lock_id: 805649:153:3:4
          trx_wait_started: 2018-09-02 15:08:55
                trx_weight: 2
       trx_mysql_thread_id: 4
                 trx_query: update tx1 set c1='heyfffff',c2='heyffffff',c3=NOW() where id =3
       trx_operation_state: starting index read
         trx_tables_in_use: 1
         trx_tables_locked: 1
          trx_lock_structs: 2
     trx_lock_memory_bytes: 1136
           trx_rows_locked: 1
         trx_rows_modified: 0
   trx_concurrency_tickets: 0
       trx_isolation_level: REPEATABLE READ
         trx_unique_checks: 1
    trx_foreign_key_checks: 1
trx_last_foreign_key_error: NULL
 trx_adaptive_hash_latched: 0
 trx_adaptive_hash_timeout: 0
          trx_is_read_only: 0
trx_autocommit_non_locking: 0
*************************** 2. row ***************************
                    trx_id: 805646
                 trx_state: RUNNING
               trx_started: 2018-09-02 14:29:58
     trx_requested_lock_id: NULL
          trx_wait_started: NULL
                trx_weight: 3
       trx_mysql_thread_id: 3
                 trx_query: select * from information_schema.innodb_trx
       trx_operation_state: NULL
         trx_tables_in_use: 0
         trx_tables_locked: 1
          trx_lock_structs: 2
     trx_lock_memory_bytes: 1136
           trx_rows_locked: 1
         trx_rows_modified: 1
   trx_concurrency_tickets: 0
       trx_isolation_level: REPEATABLE READ
         trx_unique_checks: 1
    trx_foreign_key_checks: 1
trx_last_foreign_key_error: NULL
 trx_adaptive_hash_latched: 0
 trx_adaptive_hash_timeout: 0
          trx_is_read_only: 0
trx_autocommit_non_locking: 0
2 rows in set (0.00 sec)
```

查看`innodb_locks`表数据
```
mysql>  select * from information_schema.INNODB_LOCKS\G;
*************************** 1. row ***************************
    lock_id: 805649:153:3:4
lock_trx_id: 805649
  lock_mode: X
  lock_type: RECORD
 lock_table: `test`.`tx1`
 lock_index: PRIMARY
 lock_space: 153
  lock_page: 3
   lock_rec: 4
  lock_data: 3
*************************** 2. row ***************************
    lock_id: 805646:153:3:4
lock_trx_id: 805646
  lock_mode: X
  lock_type: RECORD
 lock_table: `test`.`tx1`
 lock_index: PRIMARY
 lock_space: 153
  lock_page: 3
   lock_rec: 4
  lock_data: 3
2 rows in set, 1 warning (0.00 sec)
```

查案`innodb_lock_waits`表数据
```
mysql> select * from information_schema.INNODB_LOCK_WAITS;\G
+-------------------+-------------------+-----------------+------------------+
| requesting_trx_id | requested_lock_id | blocking_trx_id | blocking_lock_id |
+-------------------+-------------------+-----------------+------------------+
| 805649            | 805649:153:3:4    | 805646          | 805646:153:3:4   |
+-------------------+-------------------+-----------------+------------------+
1 row in set, 1 warning (0.00 sec)
```

在执行第二个update的时候，由于第一个update事务还未提交，故而第二个update在等待，其事务状态为LOCK WAIT ，等待时间超过innodb_lock_wait_timeout值(默认是50)时，则会报ERROR 1205 (HY000): `Lock wait timeout exceeded; try restarting transaction`异常。

在第二个update锁等待超时之后，对第一个update手动提交事务，则第一个update语句成功更新数据库中数据表。

** 锁等待递进 **
如果是多个锁等待，比如有三个update，update同一行记录，则锁等待关系会层级递进，第二个第三个update都保留对第一个update的锁等待且第三个update保留对第二个update的锁等待，如下：
```
mysql> select * from information_schema.INNODB_LOCK_WAITS;\G
+-------------------+-------------------+-----------------+------------------+
| requesting_trx_id | requested_lock_id | blocking_trx_id | blocking_lock_id |
+-------------------+-------------------+-----------------+------------------+
| 805653            | 805653:153:3:4    | 805652          | 805652:153:3:4   |
| 805653            | 805653:153:3:4    | 805651          | 805651:153:3:4   |
| 805652            | 805652:153:3:4    | 805651          | 805651:153:3:4   |
+-------------------+-------------------+-----------------+------------------+
3 rows in set, 1 warning (0.00 sec)
```

# 解决办法
** 1、查看并修改变量值 **
```SQL
show GLOBAL VARIABLES like '%innodb_lock_wait_timeout%';

set GLOBAL innodb_lock_wait_timeout=100; -- 设置大小值看系统情况
```

** 2、找到一直未提交事务导致后来进程死锁等待的进程，并杀掉 **
根据锁等待表中的拥有锁的事务id(blocking_trx_id)，从innodb_trx表中找到trx_mysql_thread_id值，kill掉。

如 这里杀掉 进程235：
```SQL
select trx_mysql_thread_id from information_schema.innodb_trx it 
JOIN information_schema.INNODB_LOCK_WAITS ilw 
on ilw.blocking_trx_id = it.trx_id;

-- trx_mysql_thread_id: 235

kill 235
```

** 3、优化SQL，优化数据库，优化项目 **
第一个update未执行完，第二个update就来了，超过等待时间就会报锁等待超时异常。在数据并发项目遇到这种情况概率比较大，这时候就要从项目、数据库、执行SQL多方面入手了。