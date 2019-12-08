title: Switch如何科学上网
author: winsky
tags:
  - 扶墙
categories:
  - 奇技淫巧
date: 2019-12-08 16:05:00
---
双十一前妹子从日本买了心心念的 Switch ，最近周末空了终于装好了想玩一玩。然鹅，由于某些不可描述的原因，上面的游戏下载始终在龟速，忍无可忍，于是便想着给 Switch 搞个梯子，一键起飞。

本文利用 ShadowsocksX-NG 提供的 HTTP 代理服务器来实现 Switch 翻墙。

这是现有条件下的被迫解决方案，需要一直开着笔记本。个人觉得最好的还是在家里的路由器上直接架上梯子，这样局域网内所有的设备都可以自由起飞，美滋滋。

<!-- more -->

# 为什么 Switch 要翻墙
一是使用 Switch 所支持的社交账号 Twitter （另一个是 Facebook），二是某些游戏的下载需要借助梯子来实现更快的访问速度。

# Switch 翻墙所需条件
- Switch 一台（硬指标）
- WiFi
- 梯子服务
> 国外VPS，强推 [搬瓦工](https://su.winsky.wang/bwh44)，价格和线路质量都没得说，
> 如果你不会使用国外的VPS搭建梯子的话，也可以直接使用现成的服务 [一键起飞](https://su.winsky.wang/sock2)


# Switch 如何翻墙
## 准备代理服务器
如果你已经有一台能够自由飞翔的 HTTP 代理服务器，可以直接跳过本小节。

若你和我一样在 macOS 上使用 ShadowsocksX-NG 翻墙，那么你完全可以按照我的做法达到 Switch 翻墙的目的。

若不是，方法类似。

## 配置 HTTP 代理服务器
打开 ShadowsocksX-NG Preferences 窗口，选择 HTTP 标签页，填上你的局域网 IP 和端口(保持默认1087即可)，并开启 HTTP Proxy Enable 选项。

然后关闭 Preferences 窗口就准备好代理服务器了。

## Switch 连接 WiFi 并设置代理
首先，到 Switch System Settings 里选择 Internet > Internet Settings 并确定(A)，连接你的 WiFi。

然后，在 Internet Settings 里选择刚连接的 WiFi，并确定(A)。在出现的界面中选择 Change Settings 并确定(A)。

接着，在出现的界面中选择 Proxy Settings 并确定(A)，并在出现的界面中选择 On 并确定(A)。

最后，在 Proxy Settings 下面填上上一节所设置的代理服务器的 IP 地址(Server)、端口(Port)以及授权信息并保存(根据实际情况填写，本教程中的代理服务器无授权信息就不用填了。)。

## 测试代理是否设置成功
到 System Settings > Internet > Internet Settings 里选择 Test Connection 并确定开始测试。

若测试结果显示成功则表示你的 Switch 已经可以穿越到异世界了，恭喜！

> 注：测试成功时，Global IP Address 显示的是你的真正的代理服务器的 IP 地址。(我这里显示的是 ShadowsocksX-NG 所使用的翻墙服务器的IP地址)