---
title: Python高级教程
date: 2018-04-30 19:43:14
updated: 2018-04-30 19:43:14
tags:
  - Python
categories: 
  - Python
---

本文在菜鸟教程的基础上，介绍了Python的高级语法，主要是做个记录，以备后续的查阅。

<!-- more -->

# Python面向对象
## 创建第一个对象
```python
class Employee:
    '所有员工的基类'
    empCount = 0
    
    def __init__(self, name, salary):
        self.name = name
        self.salary = salary
        Employee.empCount += 1
   
   def displayCount(self):
        print "Total Employee %d" % Employee.empCount
 
   def displayEmployee(self):
        print "Name : ", self.name,  ", Salary: ", self.salary
```
- `empCount` 变量是一个类变量，它的值将在这个类的所有实例之间共享。你可以在内部类或外部类使用 Employee.empCount 访问。
    - 注：就相当于类的静态变量 
- 第一种方法`__init__()`方法是一种特殊的方法，被称为类的构造函数或初始化方法，当创建了这个类的实例时就会调用该方法
- self 代表类的实例，self 在定义类的方法时是必须有的，虽然在调用时不必传入相应的参数。

## Python内置内属性
- `__dict__` : 类的属性（包含一个字典，由类的数据属性组成）
- `__doc__` :类的文档字符串
- `__name__`: 类名
- `__module__`: 类定义所在的模块（类的全名是`__main__.className`，如果类位于一个导入模块mymod中，那么`className.__module__` 等于 mymod）
- `__bases__` : 类的所有父类构成元素（包含了一个由所有父类组成的元组）

## Python对象销毁（垃圾回收）
- Python使用了引用计数这一简单技术来跟踪和回收垃圾
- 在 Python 内部记录着所有使用中的对象各有多少引用。
- 一个内部跟踪变量，称为一个引用计数器。
- 当对象被创建时， 就创建了一个引用计数， 当这个对象不再需要时， 也就是说， 这个对象的引用计数变为0 时， 它被垃圾回收。但是回收不是"立即"的， 由解释器在适当的时机，将垃圾对象占用的内存空间回收。
```python
a = 40      # 创建对象  <40>
b = a       # 增加引用， <40> 的计数
c = [b]     # 增加引用.  <40> 的计数

del a       # 减少引用 <40> 的计数
b = 100     # 减少引用 <40> 的计数
c[0] = -1   # 减少引用 <40> 的计数
```
- Python的垃圾回收机制不仅针对引用计数为0的对象，同样也可以处理循环引用的情况
- 循环引用是指，两个对象互相引用，但是没有其他变量引用他们。这种情况下仅仅使用引用计数是不够的
- Python的垃圾收集器实际上是一个引用计数器和一个循环垃圾收集器。
- 作为引用计数器的补充，垃圾收集器也会留意被分配的总量很大（及未通过引用计数销毁的那些）对象。在这种情况下，解释器会暂停下来，试图清理所有未引用的循环

## 析构函数 `__del__`
- 析构函数在对象销毁的时候被调用
```python
class Point:
   def __init__( self, x=0, y=0):
        self.x = x
        self.y = y
   def __del__(self):
        class_name = self.__class__.__name__
        print class_name, "销毁"
 
pt1 = Point()
pt2 = pt1
pt3 = pt1
print id(pt1), id(pt2), id(pt3) # 打印对象的id
del pt1
del pt2
del pt3
```

## 类的继承
- 继承语法：class 派生类名(基类名):// ... 基类名写在括号里，基本类是在类定义的时候，在元组中指明的
- Python中继承的一些特点：
    - 在继承中基类的构造（`__init__()`方法）不会被自动调用，他需要在其派生类的构造中亲自专门调用
    - 在调用基类的方法时，需要加上基类的类名前缀，且需要带上self参数变量。区别在于，类中调用普通函数时并需要带上self参数
    - Python总是首先查找对应类型的方法，如果他不能在派生类中找到对应的方法，他才开始到基类中逐个查找
- 如果在继承元组中列了一个以上的类，那就被称为“多重继承”
```python
class Parent:        # 定义父类
    parentAttr = 100
    def __init__(self):
        print "调用父类构造函数"
        
    def parentMethod(self):
        print '调用父类方法'
 
    def setAttr(self, attr):
        Parent.parentAttr = attr
 
    def getAttr(self):
        print "父类属性 :", Parent.parentAttr
 
class Child(Parent): # 定义子类
    def __init__(self):
        print "调用子类构造方法"
 
    def childMethod(self):
        print '调用子类方法 child method'
 
c = Child()          # 实例化子类
c.childMethod()      # 调用子类的方法
c.parentMethod()     # 调用父类方法
c.setAttr(200)       # 再次调用父类的方法
c.getAttr()          # 再次调用父类的方法

"""
调用子类构造方法
调用子类方法 child method
调用父类方法
父类属性 : 200
"""
```
- 可以使用`issubclass()`和`isinstance()`方法来检测
    - `issubclass()`：布尔函数判断一个类是另一个类的子类或者子孙类，语法：`issubclass(sub,sup)`
    - `isinstance(obj,Class)`：布尔函数，如果obj是Class类的实例对象或者一个Class子类的实例对象则返回true

## 方法重写
- 如果父类方法的功能不能满足需求，子类可以重写父类的方法
- 在调用时，根据前面提到的原则，Python会优先查找对应类型中的方法，如果不能在派生类中找到对应的方法，才会逐个查找基类中的方法。所以会优先调用子类中重写后的方法
- 基础的重载方法：

序号 | 方法，描述&简单的调用
---|---
1 | `__init__(self[,args...])`，构造函数，简单的调用方法：obj=className(args)
2 | `__del__(self)`，析构函数，删除一个对象，简单的调用方法：del obj
3 | `__repr__(self)`，转换为供解释器读取的形式，简单的调用方法：repr(obj)
4 | `__str__(self)`，用于将值转为适于人阅读的形式，简单的调用方法：str(obj)
5 | `__cmp__(self,x)`，对象比较，简单的调用方法：cmp(obj,x)

## 运算符重载
- Python同样支持运算符重载，实例如下：
```
class Vector:
    def __init__(self, a, b):
        self.a = a
        self.b = b
 
    def __str__(self):
        return 'Vector (%d, %d)' % (self.a, self.b)
   
    def __add__(self,other):
        return Vector(self.a + other.a, self.b + other.b)
 
v1 = Vector(2,10)
v2 = Vector(5,-2)
print v1 + v2
```

## 类属性与方法
### 类的私有属性
- `__private_attrs`:两个下划线开头，生命该属性为私有，不能在类的外部被使用或者直接访问。在类内部的方法中使用时`self.__private_attrs`

### 类的方法
- 在类的内部，使用def关键字可以为类定义一个方法，与一般函数定义不同，类方法必须包含参数self，且为第一个参数
- 类的私有方法：
    - `__private_methond`:两个下划线开头，声明该方法为私有方法，不能在类的外部调用。在类的内部调用`self.__private_method`
    - Python不允许实例化的类访问私有数据，但是可以使用`object._className__attrName`访问属性

## 单下划线、双下划线、头尾双下划线说明：
- `__foo__`：定义的是特别方法，类似`__init__()`方法
- `_foo`：以单划线开头的表示protected类型的变量，即保护类型只能允许其本身与子类进行访问，不用用于`from module import *`
- `__foo`：双下划线表示的是私有类型的变量，只能允许类本身进行访问

# Python正则表达式
- re模块提供Perl风格的正则表达式模式
- re模块使得Python语言拥有全部的正则表达式功能
- compile函数根据一个模式字符串和可选的标志参数生成一个正则表达式对象。该对象拥有一些列方法用于正则表达式的匹配和替换
- re模块也提供了与这些方法功能完全一致的函数，这些函数使用一个模式字符串作为第一个参数

## re.match函数
- `re.match`函数尝试从字符串的起始位置匹配一个模式，如果不是起始位置匹配成功的话，就返回一个None
- 函数语法：`re.match(pattern, string, flags=0)`
- 参数说明：
    参数 | 描述
    ---|---
    pattern | 匹配的正则表达式
    string | 要匹配的字符串
    flags | 标志位，用于控制正则表达式的匹配方式，如是否区分大小写，多行匹配等
- 匹配成功的`re.match`方法返回一个匹配的对象，否则返回None
- 可以使用`group(num)`或者`groups`匹配对象函数来获取匹配表达式
    匹配对象方法 | 描述
    --- | ---
    group(num=0) | 匹配的整个表达式的字符串，group()可以一次输入多个组号，在这种情况下它将返回一个包含那些组对应值的元组
    groups() | 返回一个包含所有小组字符串的元祖，从1到所含的小组号

## re.search方法
- `re.search`扫描整个字符串并返回第一个成功的匹配
- 函数语法：`re.search(pattern, string, flags=0)`
- 参数说明：
    参数 | 描述
    ---|---
    pattern | 匹配的正则表达式
    string | 要匹配的字符串
    flags | 标志位，用于控制正则表达式的匹配方式，如是否区分大小写，多行匹配等
- 匹配成功的`re.search`方法返回一个匹配的对象，否则返回None
- 可以使用`group(num)`或者`groups`匹配对象函数来获取匹配表达式
    匹配对象方法 | 描述
    --- | ---
    group(num=0) | 匹配的整个表达式的字符串，group()可以一次输入多个组号，在这种情况下它将返回一个包含那些组对应值的元组
    groups() | 返回一个包含所有小组字符串的元祖，从1到所含的小组号

## re.match和re.search的区别
- `re.match`只匹配字符串的开始，如果字符串的开始不符合正则表达式，则匹配失败，函数返回None
- `re.search`匹配整个字符串，直到找到一个匹配

## 检索和替换
- Python的re模块提供了`re.sub`用于替换字符串中的匹配项
- 语法：`re.sub(pattern, repl, string, count=0, flags=0)`
- 参数：
    参数 | 描述
    --- | ---
    pattern | 正则中的模式字符串
    repl | 替换的字符串，也可为一个函数
    string | 要被查找替换的字符串
    count | 模式匹配后替换的最大次数，默认0表示替换所有的匹配

## 正则表达式的修饰符
- 正则表达式可以包含一些可选标志修饰符来控制匹配的模式
- 修饰符被指定为一个可选的标志
- 多个标志可以通过按位OR(|)它们来指定

修饰符 | 描述
--- | ---
re.I | 使匹配对大小写不敏感
re.L | 做本地化识别(locale-aware)匹配
re.M | 多行匹配，影响^和$
re.S | 使.匹配包括换行在内的所有字符
re.U | 根据Unicode字符串集解析字符，这个标志位影响\w,\W,\b,\B
re.X | 该标志通过给予更加灵活的形式以便将正则表达式写得更易于理解

# Python多线程
## 线程的使用方式
### 函数式
- 调用thread模块中的`start_new_thread()`函数来产生新线程
- `thread.start_new_thread ( function, args[, kwargs] )`
    - function - 线程函数
    - args - 传递给线程函数的参数,他必须是个tuple类型
    - kwargs - 可选参数
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import thread
import time
 
# 为线程定义一个函数
def print_time( threadName, delay):
   count = 0
   while count < 5:
      time.sleep(delay)
      count += 1
      print "%s: %s" % ( threadName, time.ctime(time.time()) )
 
# 创建两个线程
try:
   thread.start_new_thread( print_time, ("Thread-1", 2, ) )
   thread.start_new_thread( print_time, ("Thread-2", 4, ) )
except:
   print "Error: unable to start thread"
 
while 1:
   pass
```
- 上面的示例，输出
```
Thread-1: Thu Jan 22 15:42:17 2009
Thread-1: Thu Jan 22 15:42:19 2009
Thread-2: Thu Jan 22 15:42:19 2009
Thread-1: Thu Jan 22 15:42:21 2009
Thread-2: Thu Jan 22 15:42:23 2009
Thread-1: Thu Jan 22 15:42:23 2009
Thread-1: Thu Jan 22 15:42:25 2009
Thread-2: Thu Jan 22 15:42:27 2009
Thread-2: Thu Jan 22 15:42:31 2009
Thread-2: Thu Jan 22 15:42:35 2009
```
- 线程的结束一般依靠线程函数的自然结束
- 也可以在线程函数中调用thread.exit()，他抛出SystemExit exception，达到退出线程的目的

### 用类来包装线程对象
#### 线程模块
- Python通过两个标准库`thread`和`threading`提供对线程的支持
- thread提供了低级别的、原始的线程以及一个简单的锁
- `thread`模块提供的其他方法
    - `threading.currentThread()`: 返回当前的线程变量
    - `threading.enumerate()`: 返回一个包含正在运行的线程的list。正在运行指线程启动后、结束前，不包括启动前和终止后的线程
    - `threading.activeCount()`: 返回正在运行的线程数量，与len(threading.enumerate())有相同的结果
- 除了使用方法外，线程模块同样提供了`Thread`类来处理线程，`Thread`类提供了以下方法:
    - `run()`: 用以表示线程活动的方法
    - `start()`:启动线程活动
    - `join([time])`: 等待至线程中止。这阻塞调用线程直至线程的join() 方法被调用中止-正常退出或者抛出未处理的异常-或者是可选的超时发生
    `isAlive()`: 返回线程是否活动的
    - `getName()`: 返回线程名
    - `setName()`: 设置线程名

#### 使用Threading模块创建线程
- 使用`Threading`模块创建线程，直接从`threading.Thread`继承，然后重写`__init__`方法和`run`方法
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import threading
import time
 
exitFlag = 0
 
class myThread (threading.Thread):   #继承父类threading.Thread
    def __init__(self, threadID, name, counter):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.counter = counter
    def run(self):                   #把要执行的代码写到run函数里面 线程在创建后会直接运行run函数 
        print "Starting " + self.name
        print_time(self.name, self.counter, 5)
        print "Exiting " + self.name
 
def print_time(threadName, delay, counter):
    while counter:
        if exitFlag:
            threading.Thread.exit()
        time.sleep(delay)
        print "%s: %s" % (threadName, time.ctime(time.time()))
        counter -= 1
 
# 创建新线程
thread1 = myThread(1, "Thread-1", 1)
thread2 = myThread(2, "Thread-2", 2)
 
# 开启线程
thread1.start()
thread2.start()
 
print "Exiting Main Thread"
```
- 上面的示例，输出
```
Starting Thread-1
Starting Thread-2
Exiting Main Thread
Thread-1: Thu Mar 21 09:10:03 2013
Thread-1: Thu Mar 21 09:10:04 2013
Thread-2: Thu Mar 21 09:10:04 2013
Thread-1: Thu Mar 21 09:10:05 2013
Thread-1: Thu Mar 21 09:10:06 2013
Thread-2: Thu Mar 21 09:10:06 2013
Thread-1: Thu Mar 21 09:10:07 2013
Exiting Thread-1
Thread-2: Thu Mar 21 09:10:08 2013
Thread-2: Thu Mar 21 09:10:10 2013
Thread-2: Thu Mar 21 09:10:12 2013
Exiting Thread-2
```
## 线程同步
- 如果多个线程共同对某个数据修改，则可能出现不可预料的结果，为了保证数据的正确性，需要对多个线程进行同步
- 使用`Thread`对象的`Lock`和`Rlock`可以实现简单的线程同步，这两个对象都有`acquire`方法和`release`方法，对于那些需要每次只允许一个线程操作的数据，可以将其操作放到`acquire`和`release`方法之间
- 多线程的优势在于可以同时运行多个任务（至少感觉起来是这样）
- 但是当线程需要共享数据时，可能存在数据不同步的问题
- 考虑这样一种情况：一个列表里所有元素都是0，线程"set"从后向前把所有元素改成1，而线程"print"负责从前往后读取列表并打印
    - 那么，可能线程"set"开始改的时候，线程"print"便来打印列表了，输出就成了一半0一半1，这就是数据的不同步
    - 为了避免这种情况，引入了锁的概念
- 锁有两种状态：锁定和未锁定。
    - 每当一个线程比如"set"要访问共享数据时，必须先获得锁定；
    - 如果已经有别的线程比如"print"获得锁定了，那么就让线程"set"暂停，也就是同步阻塞；
    - 等到线程"print"访问完毕，释放锁以后，再让线程"set"继续。
    - 经过这样的处理，打印列表时要么全部输出0，要么全部输出1，不会再出现一半0一半1的尴尬场面
```Python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import threading
import time
 
class myThread (threading.Thread):
    def __init__(self, threadID, name, counter):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.counter = counter
    def run(self):
        print "Starting " + self.name
       # 获得锁，成功获得锁定后返回True
       # 可选的timeout参数不填时将一直阻塞直到获得锁定
       # 否则超时后将返回False
        threadLock.acquire()
        print_time(self.name, self.counter, 3)
        # 释放锁
        threadLock.release()
 
def print_time(threadName, delay, counter):
    while counter:
        time.sleep(delay)
        print "%s: %s" % (threadName, time.ctime(time.time()))
        counter -= 1
 
threadLock = threading.Lock()
threads = []
 
# 创建新线程
thread1 = myThread(1, "Thread-1", 1)
thread2 = myThread(2, "Thread-2", 2)
 
# 开启新线程
thread1.start()
thread2.start()
 
# 添加线程到线程列表
threads.append(thread1)
threads.append(thread2)
 
# 等待所有线程完成
for t in threads:
    t.join()
print "Exiting Main Thread"
```

## 线程优先级队列（ Queue）
- Python的`Queue`模块中提供了同步的、线程安全的队列类
    - `FIFO（先入先出)队列Queue`
    - `LIFO（后入先出）队列LifoQueue`
    - `优先级队列PriorityQueue`
- 这些队列都实现了锁原语，能够在多线程中直接使用
- 可以使用队列来实现线程间的同步
- Queue模块中的常用方法:
    - `Queue.qsize()` 返回队列的大小
    - `Queue.empty()` 如果队列为空，返回True,反之False
    - `Queue.full()` 如果队列满了，返回True,反之False
    - `Queue.full` 与 `maxsize` 大小对应
    - `Queue.get([block[, timeout]])`获取队列，`timeout`等待时间
    - `Queue.get_nowait()` 相当`Queue.get(False)`
    - `Queue.put(item)` 写入队列，`timeout`等待时间
    - `Queue.put_nowait(item)` 相当`Queue.put(item, False)`
    - `Queue.task_done()` 在完成一项工作之后，`Queue.task_done()`函数向任务已经完成的队列发送一个信号
    - `Queue.join()` 实际上意味着等到队列为空，再执行别的操作
```Python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
import Queue
import threading
import time
 
exitFlag = 0
 
class myThread (threading.Thread):
    def __init__(self, threadID, name, q):
        threading.Thread.__init__(self)
        self.threadID = threadID
        self.name = name
        self.q = q
    def run(self):
        print "Starting " + self.name
        process_data(self.name, self.q)
        print "Exiting " + self.name
 
def process_data(threadName, q):
    while not exitFlag:
        queueLock.acquire()
        if not workQueue.empty():
            data = q.get()
            queueLock.release()
            print "%s processing %s" % (threadName, data)
        else:
            queueLock.release()
        time.sleep(1)
 
threadList = ["Thread-1", "Thread-2", "Thread-3"]
nameList = ["One", "Two", "Three", "Four", "Five"]
queueLock = threading.Lock()
workQueue = Queue.Queue(10)
threads = []
threadID = 1
 
# 创建新线程
for tName in threadList:
    thread = myThread(threadID, tName, workQueue)
    thread.start()
    threads.append(thread)
    threadID += 1
 
# 填充队列
queueLock.acquire()
for word in nameList:
    workQueue.put(word)
queueLock.release()
 
# 等待队列清空
while not workQueue.empty():
    pass
 
# 通知线程是时候退出
exitFlag = 1
 
# 等待所有线程完成
for t in threads:
    t.join()
print "Exiting Main Thread"
```
- 以上示例，执行结果
```
Starting Thread-1
Starting Thread-2
Starting Thread-3
Thread-1 processing One
Thread-2 processing Two
Thread-3 processing Three
Thread-1 processing Four
Thread-2 processing Five
Exiting Thread-3
Exiting Thread-1
Exiting Thread-2
Exiting Main Thread
```