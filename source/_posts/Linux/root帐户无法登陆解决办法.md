---
title: root账户无法登录解决办法
date: 2018-03-27 23:47:14
updated: 2018-03-27 23:47:14
tags:
  - Linux
categories: 
  - Linux
---

今天遇到的一个看上去很奇怪的问题（其实是自己蠢，具体经过感兴趣的可以参照[一次特殊的root密码错误经历][1]）。本文主要记录`Linux`系统下，root账户无法登录的解决办法。

<!-- more -->

1. `/etc/securetty`中规定了root可以从哪个tty设备登录，如果`root`登录不了，可以检查`/etc/securetty`文件，看看是否禁用了什么设备。如果发现被修改，可以将文件改回原来的样子。并且注意，如果修改了该文件，要保证该文件的权限模式为`600`，才能正常生效。

	正常的`/etc/securetty`文件内容：
	```
	console
	vc/1
	vc/2
	vc/3
	vc/4
	vc/5
	vc/6
	vc/7
	vc/8
	vc/9
	vc/10
	vc/11
	tty1
	tty2
	tty3
	tty4
	tty5
	tty6
	tty7
	tty8
	tty9
	tty10
	tty11
	```

2. `/etc/ssh/sshd_config`文件中禁用root登录。如果`sshd_config`文件中有`PermitRootLogin no`这行，`root`就无法通过`ssh`登录。请改成`PermitRootLogin yes`，然后重启`ssd`：`/etc/init.d/sshd restart`

3. 使用了`pam`认证，`pam`配置中限制了`root`账号的登录。这种情况的可能性比较多，需要仔细检查`/etc/pam.d/`下以及`/etc/security/`下的配置文件是否有禁止`root`的设置。

4. `/etc/passwd`文件被修改。检查`passwd`文件中，`root`的`uid`是否为0，`root`的`shell`路径是否真实存在，总之`root`这行的每个设置要完全正常才行。

	我就遇到过一种特殊情况，`passwd`文件的换行符变成了`DOS`格式，结果`linux`系统认为`shell`路径是`/bin/bash^M`，返回路径不存在错误，导致了`root`无法登录。所以还要保证`passwd`文件的换行符是`unix`格式。


[1] "一次特殊的root密码错误经历"