---
title: Junit测试延伸——私有方法测试
date: 2018-07-21 16:03:43
updated: 2018-07-21 16:03:43
tags:
  - Junit测试
categories: 
  - 测试
---

之前上软件测试课的时候，曾经听闻某些同学在考试的时候使用黑科技，直接通过反射的方式直接调用private方法，提高测试用例覆盖率。当时只是觉得这个好高大上，但是也没在意去学习一下。因为类私有方法只允许被本类访问，而其他类无权调用，我只要通过给其他public的方法写好测试用例就行了。

然鹅，前几天公司的研发流程中需要变更行覆盖率达到一定程度，可是由于逻辑太复杂的，导致部分private方法很难被覆盖到。时间不多了，只能出绝招了——通过Junit测试私有方法。

<!-- more -->
Talk is easy. Show me the code. 我们举个栗子来学习如何通过Junit测试私有方法。

我们先定义一个Dog类
```Java
/**
 * author: winsky
 * date: 2018/7/21
 * description:
 */
public class Dog {
    private String bark(String name) {
        return name + " 汪汪汪";
    }
}
```

OK，现在我们来写上面这个私有方法的测试类：
```Java
/**
 * author: winsky
 * date: 2018/7/21
 * description:
 */
public class DogTest {
    private Dog dog = new Dog();

    @Test
    public void testBark() throws Exception {
        Class<Dog> clazz = Dog.class;
        Method declaredMethod = clazz.getDeclaredMethod("bark", String.class);
        declaredMethod.setAccessible(true);
        Object invoke = declaredMethod.invoke(dog, "妞妞");
        declaredMethod.setAccessible(false);
        Assert.assertEquals("妞妞 汪汪汪", invoke);

    }
}
```

我们运行上面的测试，来看下Junit绿条情况。测试通过，没问题。
![image](https://pic.winsky.wang/images/2018/07/21/testprivate.jpg)
