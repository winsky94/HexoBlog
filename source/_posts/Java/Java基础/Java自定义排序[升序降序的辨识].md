---
title: Java自定义排序[升序降序的辨识]
date: 2018-03-11 19:52:14
updated: 2018-03-11 19:52:14
tags:
  - 数据结构
categories: 
  - Java
  - Java基础
---

一直以来，对`Java`中自定义排序中是如何判断升序还是降序没有任何概念，每次遇到都是线程调试一把看看结果。

今天来介绍一种如何辨识自定义排序中是升序还是降序的方法

<!-- more -->

我的辨识方法：

顺序主要看返回-1的情况，-1决定了是否需要调整顺序。

```Java
if(o1.compareTo(o2) < 0 ){
    return ?;
}
```

这里o1表示位于前面的字符，o2表示后面的字符

上面的条件是，o1比o2小，这个时候，我们需要需要调整它们的顺序

**如果你想升序，那么o1比o2小就是我想要的；所以返回-1，类比成false；表示我不想调整顺序**

**如果你想降序，那么o1比o2小不是我想要的；所以返回1，类比成true；表示我想调整顺序**

如下例子就是对数组进行升序排列。因为在`o1 < o2`的时候，返回了-1，表名不需要调整顺序

```Java
Character[] s = {'c', 'b', 'a'};
Arrays.sort(s, new Comparator<Character>() {
    @Override
    public int compare(Character o1, Character o2) {
        if (o1 > o2) return 1;
        if (o1 < o2) return -1;
        else return 0;
    }
});
```
