---
title: Spring ConcurrentReferenceHashMap简单测试
date: 2018-07-22 15:15:14
updated: 2018-07-22 15:15:14
tags:
  - Spring
categories: 
  - Spring
---

这周在写代码的时候，由于配置了IDE的快捷提示，一不留神使用了`ConcurrentReferenceHashMap`这个新奇的类，虽然不会引发什么bug，但是还是在CR的时候被师兄发现了。

本文就来探讨一下`ConcurrentReferenceHashMap`这个map具体是什么类。


<!-- more -->

ConcurrentReferenceHashMap是自spring3.2后增加的一个同步的软(虚)引用Map。关于软引用(SoftRefrence)和虚引用(WeakRefrence可以参见[Java四种引用类型[1]。废话不多说直接上测试代码:


[1]: "Java四种引用类型"