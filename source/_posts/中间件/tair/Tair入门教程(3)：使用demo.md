---
title: Tair入门教程(3)：使用demo
date: 2018-05-27 23:54:14
updated: 2018-05-27 23:54:14
tags:
  - 中间件
  - tair
categories: 
  - 中间件
  - tair
---

在[Tair入门教程(1)：Tair介绍][1]我们介绍了Tair的主要功能和使用场景，以及其架构和各部分组件的作用。

在[Tair入门教程(2):Tair环境搭建][2]中我们搭建好了Tair的服务器环境。

接下来就是编写实际的应用代码了。本文给出了一个小demo，以供学习。详细的项目可以参见[github源代码][3]。

<!-- more -->

# 构建maven项目
首先构建MAVEN项目，导入所需要的jar包依赖

需要导入的有tair-client等jar包。

## 编写客户端程序
直接给我示例demo，很容易理解
```Java
package com.winsky;

import com.taobao.tair.DataEntry;
import com.taobao.tair.Result;
import com.taobao.tair.ResultCode;
import com.taobao.tair.impl.DefaultTairManager;

import java.util.ArrayList;
import java.util.List;

/**
 * author: winsky
 * date: 2018/5/16
 * description:
 */
public class TairClientTest {
    public static void main(String[] args) {
        // 创建config server列表
        List<String> confServers = new ArrayList<>();
        confServers.add("172.17.68.153:5198");
        //  confServers.add("10.10.7.144:51980"); // 可选

        // 创建客户端实例
        DefaultTairManager tairManager = new DefaultTairManager();
        tairManager.setConfigServerList(confServers);

        // 设置组名
        tairManager.setGroupName("group_1");
        // 初始化客户端
        tairManager.init();

        // put 10 items
        for (int i = 0; i < 10; i++) {
            // 第一个参数是namespace，第二个是key，第三是value，第四个是版本，第五个是有效时间
            ResultCode result = tairManager.put(0, "k" + i, "v" + i, 0, 10);
            System.out.println("put k" + i + ":" + result.isSuccess());
            System.out.println(result.getMessage());
            if (!result.isSuccess())
                break;
        }

        // get one
        // 第一个参数是namespce，第二个是key
        Result<DataEntry> result = tairManager.get(0, "k3");
        System.out.println("get:" + result.isSuccess());
        if (result.isSuccess()) {
            DataEntry entry = result.getValue();
            if (entry != null) {
                // 数据存在
                System.out.println("value is " + entry.getValue().toString());
            } else {
                // 数据不存在
                System.out.println("this key doesn't exist.");
            }
        } else {
            // 异常处理
            System.out.println(result.getRc().getMessage());
        }
    }
}
```

运行结果
```
log4j:WARN No appenders could be found for logger (com.taobao.tair.impl.ConfigServer).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
put k0:true
put k1:true
put k2:true
put k3:true
put k4:true
put k5:true
put k6:true
put k7:true
put k8:true
put k9:true
get:true
value is v3
```

注意事项：测试如果不是在config server或data server上进行，那么一定要确保测试端系统与config server和data server能互相通信，即ping通。否则有可能会报下面这样的错误：
```
Exception in thread "main" java.lang.RuntimeException: init config failed
 at com.taobao.tair.impl.DefaultTairManager.init(DefaultTairManager.java:80)
 at tair.client.TairClientTest.main(TairClientTest.java:27)
```

[1]: https://blog.winsky.wang/中间件/tair/Tair入门教程(1)：Tair介绍/ "Tair入门教程(1)：Tair介绍"
[2]: https://blog.winsky.wang/中间件/tair/Tair入门教程(2)：Tair环境搭建/ "Tair入门教程(2):Tair环境搭建"
[3]: https://github.com/winsky94/tair_demo "github源代码"