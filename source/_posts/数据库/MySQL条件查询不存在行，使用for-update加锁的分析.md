title: MySQL条件查询不存在行，使用for update加锁的分析
author: winsky
tags:
  - MySQL
categories: []
date: 2020-04-06 21:11:00
---
先说结论：

- MySQL `for update`加的是独占锁，而且如果对应的索引是唯一索引加的是行锁，一个事务加锁了，另一个事务应该被阻塞了。
- 但是如果该查询条件对应的记录不存在，则加了gap锁。
- 同时如果并发执行insert语句，需要insert意向锁，和gap锁是冲突的，容易产生死锁

<!-- more -->
有如下的表：
```
CREATE TABLE `test` (
  `id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
```

表中数据如下：
```

mysql> SELECT * FROM test;
+----+------+
| id | name |
+----+------+
|  1 | 1    |
|  6 | 6    |
| 11 | 11   |
| 16 | 16   |
| 21 | 21   |
| 26 | 26   |
| 31 | 31   |
| 36 | 36   |
+----+------+
8 rows in set (0.00 sec)
```

有两个并发的事务执行相同的SQL：
```
START TRANSACTION;
SELECT * FROM test WHERE id = 13 FOR UPDATE;
INSERT INTO test VALUES (13, '13');
COMMIT;
```

第二个事务会出现死锁，退出后随即第一个事务insert执行成功。
```
mysql> START TRANSACTION;
Query OK, 0 rows affected (0.00 sec)
 
mysql> SELECT * FROM test_2 WHERE id = 13 FOR UPDATE;
Empty set (0.00 sec)
 
mysql> INSERT INTO test VALUES (13, '13');
ERROR 1213 (40001): Deadlock found when trying to get lock; try restarting transaction
mysql> 
```

该例子和幻读挺类似的。但是for update应该加的是独占锁，而且如果对应的索引是唯一索引加的是行锁，一个事务加锁了，另一个事务应该被阻塞了。但是如果该查询条件对应的记录不存在，加的则是gap锁，该例子中锁的范围是(11,16)，不包括11，16，gap是互相兼容的，另一个事务不会阻塞。执行insert语句时，需要insert意向锁，和gap锁是冲突的，所以产生了死锁。
