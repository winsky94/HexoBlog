---
title: Python基本语法
date: 2018-04-30 19:40:14
updated: 2018-04-30 19:40:14
tags:
  - Python
categories: 
  - Python
---

本文在菜鸟教程的基础上，介绍了Python的基本语法，主要是做个记录，以备后续的查阅。

<!-- more -->

# 基础语法
## py文件头
- 第一行表示Python的执行器
- 第二行表示Python文件的编码
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
```

## 注释
- 多行注释 '''或"""
- 单行注释 #

## 标识符
- python中的标识符是区分大小写的
- 以下划线开头的标识符是有特殊意义的
    - 以单下划线开头（_foo）的代表不能直接访问的类属性，需通过类提供的接口进行访问，不能用`from xxx import *`而导入
    - 以双下划线开头的（__foo）代表类的私有成员；以双下划线开头和结尾的`(__foo__)`代表python里特殊方法专用的标识，如`__init__()`代表类的构造函数

# 变量类型
- Python中的变量赋值不需要申明类型
- 每个变量在使用前都必须被赋值，变量赋值以后该变量才会被创建
- 同时为多个变量赋值
    - 创建一个整型对象，值为1，三个变量被分配到相同的内存空间上
        ```python
        a = b = c = 1
        ```
    - 也可以为对个对象指定多个变量变量
        ```python
        a, b, c = 1, 2, "john"
        ```
## 标准数据类型
- Python有五个标准的数据类型
    - Numbers：数字
    - String：字符串
    - List：列表
    - Tuple：元祖
    - Dictionary：字典
### Python数字
- 支持四种不同的数字类型
    - int：有符号整型
    - long：长整型
        - Python使用"L"来显示长整型
    - float：浮点型
    - complex：复数
        -  复数由实数部分和虚数部分构成
        - 可以用a + bj,或者complex(a,b)表示
        -  复数的实部a和虚部b都是浮点型
### Python字符串
- 字符串两种取值顺序
    - 从左到右索引默认0开始的，最大范围是字符串长度少1
    - 从右到左索引默认-1开始的，最大范围是字符串开头
- 从字符串中截取子串
    - 可以使用变量 [头下标:尾下标]，包含下边界，不包含上边界
    - 下标是从 0 开始算起，可以是正数或负数
    - 下标可以为空表示取到头或尾
- 加号（+）是字符串连接运算符，星号（*）是重复操作
```python
print str * 2       # 输出字符串两次
print str + "TEST"  # 输出连接的字符串
```

- **Python三引号**
    - python中三引号可以将复杂的字符串进行复制
    - Python三引号允许一个字符串跨多行，字符串中可以包含换行符、制表符以及其他特殊字符
    - 典型的用例场景：
        - 当一个标识符需要用来表示一段HTML或者SQL的时候，如果用字符串的组合，特殊字符的转义会非常繁琐
        - 使用三引号就可以非常方便的表达
        ```python
        errHTML = '''
        <HTML><HEAD><TITLE>
        Friends CGI Demo</TITLE></HEAD>
        <BODY><H3>ERROR</H3>
        <B>%s</B><P>
        <FORM><INPUT TYPE=button VALUE=Back
        ONCLICK="window.history.back()"></FORM>
        </BODY></HTML>
        '''
        cursor.execute('''
        CREATE TABLE users (  
        login VARCHAR(8), 
        uid INTEGER,
        prid INTEGER)
        ''')
        ```
    
### Python列表
- 列表中值分隔也可以用变量[头下标：尾下标]来截取相应的列表
- 从左到右索引默认0开始的
- 从右到左索引默认-1开始
- 下标可以为空表示取到头或尾
- 加号（+）是列表连接运算符，星号（*）是重复操作
- 创建二维列表
 ```
# 将需要的参数写入cols和rows即可，0表示列表元素的默认值
list_2d = [[0 for col in range(cols)] for row in range(rows)]
```

### Python元组
- 类似于List
- 元组用"()"标识
- 内部元素用逗号隔开
- 元组不能二次赋值，相当于只读列表
- 元组中只包含一个元素时，需要在元素后面添加逗号
`tup1 = (50,);`
- 任意无符号的对象，以逗号隔开，默认为元组

### Python字典
- 列表是有序的对象集合，字典是无序的对象集合
- 二者的区别：
    - 字典中的元素是通过键来取值的，而不是通过偏移存取
- 字典用"{}"标识
- 每个键值(key=>value)对用冒号(:)分割，每个对之间用逗号(,)分割
- 字典由索引key和他对应的value组成
- 访问字典里的值：把相应的键放入熟悉的方括弧
- 字典的键必须是不可变的，所以可以是用数字、字符串或者元组来充当，但是不可以是列表
 ```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
dict = {}
dict['one'] = "This is one"
dict[2] = "This is two"
 
tinydict = {'name': 'john','code':6734, 'dept': 'sales'}
 
print dict['one']          # 输出键为'one' 的值
print dict[2]              # 输出键为 2 的值
print tinydict             # 输出完整的字典
print tinydict.keys()      # 输出所有键
print tinydict.values()    # 输出所有值
```
## Python数据类型转换
- 数据类型的转换，只要将数据类型作为函数名即可
- 内置的数据类型转换函数
    函数 | 描述
    ---|---
    int(x [,base]) | 将x转换为一个整数
    long(x [,base] ) | 将x转换为一个长整数
    complex(real [,imag]) | 创建一个复数
    str(x) | 将对象 x 转换为字符串
    repr(x) | 将对象 x 转换为表达式字符串
    eval(str) | 用来计算在字符串中的有效Python表达式,并返回一个对象
    tuple(s) | 将序列 s 转换为一个元组
    list(s) | 将序列 s 转换为一个列表
    set(s) | 转换为可变集合
    dict(d) | 创建一个字典。d 必须是一个序列 (key,value)元组。
    frozenset(s) | 转换为不可变集合
    chr(x) | 将一个整数转换为一个字符
    unichr(x) | 将一个整数转换为Unicode字符
    ord(x) | 将一个字符转换为它的整数值
    hex(x) | 将一个整数转换为一个十六进制字符串
    oct(x) | 将一个整数转换为一个八进制字符串

## 查看变量的数据类型
- 所有数据类型都是类,可以通过 type() 查看该变量的数据类型
```python
>>> n=1
>>> type(n)
<type 'int'>
>>> n="runoob"
>>> type(n)
<type 'str'>
```
- 还可以使用isinstance来判断
```python
a = 111
isinstance(a, int)
True
```
- type和isinstance的区别
    -  type()不会认为子类是一种父类类型
    -  isinstance()会认为子类是一种父类类型
# 运算符
- Python语言支持一下的运算符
    - 算数运算符
    - 比较运算符
    - 赋值运算符
    - 逻辑运算符
    - 位运算符
    - 成员运算符
    - 身份运算符
## 算数运算符
运算符 | 描述
---|---
/ | 除
% | 取模
** | 幂 返回x的y次幂
// | 取整除 返回商的整数部分

## 位运算符
运算符 | 描述
---|---
& | 按位与运算符：参与运算的两个值,如果两个相应位都为1,则该位的结果为1,否则为0
\| | 按位或运算符：只要对应的二个二进位有一个为1时，结果位就为1。
^ | 按位异或运算符：当两对应的二进位相异时，结果为1
~ | 按位取反运算符：对数据的每个二进制位取反,即把1变为0,把0变为1
<< | 左移动运算符：运算数的各二进位全部左移若干位，由"<<"右边的数指定移动的位数，高位丢弃，低位补0。	
>> | 右移动运算符：把">>"左边的运算数的各二进位全部右移若干位，">>"右边的数指定移动的位数

##  成员运算符
运算符 | 描述
--- | ---
in | 	如果在指定的序列中找到值返回 True，否则返回 False
not in | 如果在指定的序列中没有找到值返回 True，否则返回 False

## 身份运算符
- 用于比较两个对象的存储单元

运算符 | 描述
--- | ---
is | is判断两个标识符是不是引用自一个对象
is not | is not是判断两个标识符是不是引用自不同对象
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-

a = 20
b = 20

if ( a is b ):
   print "1 - a 和 b 有相同的标识"
else:
   print "1 - a 和 b 没有相同的标识"

# 结果：1 - a 和 b 有相同的标识

if ( id(a) is not id(b) ):
   print "2 - a 和 b 有相同的标识"
else:
   print "2 - a 和 b 没有相同的标识"

# 结果：2 - a 和 b 有相同的标识

# 修改变量 b 的值
b = 30
if ( a is b ):
   print "3 - a 和 b 有相同的标识"
else:
   print "3 - a 和 b 没有相同的标识"

结果：3 - a 和 b 没有相同的标识

if ( a is not b ):
   print "4 - a 和 b 没有相同的标识"
else:
   print "4 - a 和 b 有相同的标识"

结果：4 - a 和 b 没有相同的标识  

```
## 运算符优先级
- 以下表格列出了从最高到最低优先级的所有 运算符

运算符 | 描述
--- | ---
** | 指数（最高优先级）
~ + - | 按位翻转，一元加号和减号
* / % // | 乘，除，取模，取整除
+ - | 加法，减法
>> << | 右移，左移
& | 与运算
^ | 位运算
<= < > >= |　比较运算符
<> == !=　| 等于运算符
= %= /= //= -= += *= **= | 赋值运算符
is is not | 身份运算符
in not in | 成员运算符
not or and | 逻辑运算符

# 条件语句
- 指定任何非0和非空（null）值为true，0 或者 null为false
- "判断条件"成立时（非零），则执行后面的语句，而执行内容可以多行，以缩进来区分表示同一范围
- 判断条件为多个值时：
```python
if 判断条件1:
    执行语句1……
elif 判断条件2:
    执行语句2……
elif 判断条件3:
    执行语句3……
else:
    执行语句4……
```
- Python不支持switch，所以多个条件的判断只能使用elif来实现

# 循环语句
## while循环语句
- 循环中使用else语句
- while … else 在循环条件为 false 时执行 else 语句块
```python
#!/usr/bin/python

count = 0
while count < 5:
   print count, " is  less than 5"
   count = count + 1
else:
   print count, " is not less than 5"
```

## for循环语句
- for循环可以遍历任何序列的项目，如一个列表或者一个字符串
- for循环的几种写法
    - 常见写法：
    ```python
    #!/usr/bin/python
    # -*- coding: UTF-8 -*-
     
    for letter in 'Python':     # 第一个实例
       print '当前字母 :', letter
     
    fruits = ['banana', 'apple',  'mango']
    for fruit in fruits:        # 第二个实例
       print '当前水果 :', fruit
     
    print "Good bye!"
    ```
    - 通过序列索引迭代
    ```python
    #!/usr/bin/python
    # -*- coding: UTF-8 -*-
     
    fruits = ['banana', 'apple',  'mango']
    for index in range(len(fruits)):
       print '当前水果 :', fruits[index]
     
    print "Good bye!"
    ```
    - 使用内置 enumerate 函数进行遍历
    ```python
    for index, item in enumerate(sequence):
        process(index, item)
    ```
- for循环使用else语句
    - for中的语句和普通的语句没有区别，else中的语句会在循环正常执行完的情况下执行
    - **for不是通过break来跳出循环的情况下才会执行else语句**，while-else也一样
## pass语句
- pass语句是空语句，是为了保持程序结构的完整性
- pass不做任何事情，一般用作占位语句
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*- 

# 输出 Python 的每个字母
for letter in 'Python':
   if letter == 'h':
      pass
      print '这是 pass 块'
   print '当前字母 :', letter

print "Good bye!"

"""
输出结果：
当前字母 : P
当前字母 : y
当前字母 : t
这是 pass 块
当前字母 : h
当前字母 : o
当前字母 : n
Good bye!
"""
```

# Python随机函数
函数 | 描述
--- | ---
choice(seq) | 从序列的元素中随机挑选一个元素，比如random.choice(range(10))，从0到9中随机挑选一个整数
randrange([start,]stop[,step]) | 从指定范围内，按执行基数递增的集合中获取一个随机数，基数step缺省值为1
random() | 随机生成下一个示数，在[0,1)范围内
seed([x]) | 改变随机数生成器的种子seed
shuffle(list) | 将序列的所有元素随机排序
uniform(x, y) | 随机生成下一个实数，它在[x,y]范围内

# Python日期和时间
- Python 提供了一个 time 和 calendar 模块可以用于格式化日期和时间
- 时间间隔是以秒为单位的浮点小数
- Python 的 time 模块下有很多函数可以转换常见日期格式
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-

import time;  # 引入time模块

ticks = time.time()
print "当前时间戳为:", ticks #当前时间戳为: 1459994552.51
```
- Python中经常用一个元组装起来的9组数字来处理时间，即struct_time元组，结构属性如下：

序号 | 属性 | 值
--- | --- | ---
0 | tm_year | 2017
1 | tm_mon | 1到12
2 | tm_mday | 1到31
3 | tm_hour | 0到23
4 | tm_min | 0到59
5 | tm_sec | 0到61（60,61是闰秒）
6 | tm_ wday | 0到6（0是周一）
7 | tm_yday | 1到366
8 | tm_isdst | -1,0,1是决定是否是夏令时的旗帜

## 获取当前时间
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-

import time

localtime = time.localtime(time.time())
print "本地时间为 :", localtime

"""
本地时间为 : time.struct_time(tm_year=2016, tm_mon=4, tm_mday=7, tm_hour=10, tm_min=3, tm_sec=27, tm_wday=3, tm_yday=98, tm_isdst=0)
"""
```

## 格式化时间
使用 time 模块的 strftime 方法
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-

import time

# 格式化成2016-03-20 11:45:39形式
print time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()) 

# 格式化成Sat Mar 28 22:24:24 2016形式
print time.strftime("%a %b %d %H:%M:%S %Y", time.localtime()) 
  
# 将格式字符串转换为时间戳
a = "Sat Mar 28 22:24:24 2016"
print time.mktime(time.strptime(a,"%a %b %d %H:%M:%S %Y"))
```

# Python函数
- 定义函数的规则
    - 函数代码块以 def 关键词开头，后接函数标识符名称和圆括号()
    - 任何传入参数和自变量必须放在圆括号中间。圆括号之间可以用于定义参数
    - 函数的第一行语句可以选择性地使用文档字符串—用于存放函数说明
    - 函数内容以冒号起始，并且缩进
    - return [表达式] 结束函数，选择性地返回一个值给调用方。不带表达式的return相当于返回 None
- 默认情况下，参数值和参数名称是按函数声明中定义的的顺序匹配起来的

## 关键字参数
- 使用关键字参数允许函数调用时参数的顺序与声明时不一致，因为Python解释器能够用参数名匹配参数值
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
#可写函数说明
def printinfo( name, age ):
   "打印任何传入的字符串"
   print "Name: ", name;
   print "Age ", age;
   return;
 
#调用printinfo函数
printinfo( age=50, name="miki" ); #能正确调用
```

## 缺省参数
- 调用函数时，缺省参数的值如果没有传入，则被认为是默认值
```
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
#可写函数说明
def printinfo( name, age = 35 ): # 参数age设置了缺省值
   "打印任何传入的字符串"
   print "Name: ", name;
   print "Age ", age;
   return;
 
#调用printinfo函数
printinfo( age=50, name="miki" );
printinfo( name="miki" );
```

## lambda函数
- python 使用 lambda 来创建匿名函数
- lambda函数拥有自己的命名空间，且不能访问自有参数列表之外或全局命名空间里的参数
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
# 可写函数说明
sum = lambda arg1, arg2: arg1 + arg2;
 
# 调用sum函数
print "相加后的值为 : ", sum( 10, 20 )
print "相加后的值为 : ", sum( 20, 20 )
```

# Python中的不可变对象
- 变量赋值 a=5 后再赋值 a=10，这里实际是新生成一个 int 值对象 10，再让 a 指向它，而 5 被丢弃，不是改变a的值，相当于新生成了a
- python 函数的参数传递：
    - **不可变类型**：类似 c++ 的值传递，如整数、字符串、元组。如fun（a），传递的只是a的值，没有影响a对象本身。比如在 fun（a）内部修改 a 的值，只是修改另一个复制的对象，不会影响 a 本身。
    - **可变类型**：类似 c++ 的引用传递，如 列表，字典。如 fun（la），则是将 la 真正的传过去，修改后fun外部的la也会受影响
- 实例：
```python
#!/usr/bin/python
# -*- coding: UTF-8 -*-
 
def ChangeInt( a ):
    a = 10

b = 2
ChangeInt(b)
print b # 结果是 2
```

# Python模块
- 模块能定义函数，类和变量，模块里也能包含可执行的代码
## 模块的引入import
- 模块定义好后，我们可以使用 import 语句来引入模块
```python
import module1[, module2[,... moduleN]
```
- 调用模块中的函数时，必须使用`模块名.函数名`来进行调用
- 不管执行多少次import，一个模块只会被导入一次

## from……import 语句
- from语句可以从模块中导入一个指定的部分到当前命名空间中
```python
from modname import name1[, name2[, ... nameN]]
```

## from…import* 语句
- 把一个模块的所有内容全部导入到当前的命名空间
```python
from modname import *
```

## 搜索路径
- 当导入一个模块时，Python解释器对模块位置的搜索顺序是：
    1. 当前目录
    2. 如果不在当前目录，则去搜索在shell变量PYTHONPATH下的每个目录
    3. 如果都找不到，Python会察看默认路径。UNIX下，默认路径一般为/usr/local/lib/python/
- 模块搜索路径存储在 system 模块的 sys.path 变量中。变量里包含当前目录，PYTHONPATH和由安装过程决定的默认目录

## 命名空间和作用域
- 如果要在一个函数里给一个全局变量赋值，必须使用global语句
- global VarName 的表达式会告诉 Python， VarName 是一个全局变量，这样 Python 就不会在局部命名空间里寻找这个变量了

### dir函数
- dir()函数是一个排好序的字符串列表，内容是一个模块里定义过的名字
- 返回的列表容纳了在一个模块里定义的所有模块、变量和函数

### globals和locals函数
- 根据调用的地方的不同，globals() 和 locals() 函数可被用来返回全局和局部命名空间里的名字
- 如果在函数内部调用 locals()，返回的是所有能在该函数里访问的命名
- 如果在函数内部调用 globals()，返回的是所有在该函数里能访问的全局名字
- 两个函数的返回类型都是字典。所以名字们能用 keys() 函数摘取

### reload函数
- 当一个模块被导入到一个脚本，模块顶层部分的 代码只会被执行一次
- 如果你想重新执行模块里顶层部分的代码，可以用 reload() 函数
- 该函数会重导之前导入过的模块
- module_name要直接放模块的名字，而不是一个字符串形式
```python
reload(module_name)
```

## Python中的包
- 简单来说，包就是文件夹，但该文件夹下必须存在 __init__.py 文件, 该文件的内容可以为空
- __int__.py用于标识当前文件夹是一个包

# Python文件IO
## 读取键盘输入
- Python提供了两个内置函数从标准输入读入一行文本，默认的标准输入是键盘
    - raw_input
        - `raw_input([prompt])` 函数从标准输入读取一个行，并返回一个字符串（去掉结尾的换行符）
    - input
        - `input([prompt])`函数和`raw_input([prompt])`函数基本类似，但是 input 可以接收一个Python表达式作为输入，并将运算结果返回
        ```python
        #!/usr/bin/python
        # -*- coding: UTF-8 -*- 
         
        str = input("请输入：");
        print "你输入的内容是: ", str
        
        """
        请输入：[x*5 for x in range(2,10,2)]
        你输入的内容是:  [10, 20, 30, 40]
        """
        ```
## 打开和关闭文件
### open函数
- 先用Python内置的open()函数打开一个文件，创建一个file对象，相关的方法才可以调用它进行读写
- 语法`file object = open(file_name [, access_mode][, buffering])`
- 各个参数细节如下：
    - file_name：file_name变量是一个包含了你要访问的文件名称的字符串值
    - access_mode：access_mode决定了打开文件的模式：只读，写入，追加等。这个参数是非强制的，默认文件访问模式为只读(r)
    - buffering:如果buffering的值被设为0，就不会有寄存。如果buffering的值取1，访问文件时会寄存行。如果将buffering的值设为大于1的整数，表明了这就是寄存区的缓冲大小。如果取负值，寄存区的缓冲大小则为系统默认

### File对象的属性
属性 | 描述
--- | ---
file.closed | 返回true如果文件已被关闭，否则返回false
file.mode | 返回被打开文件的访问模式
file.name | 返回文件的名称
file.softspace | 如果用print输出后，必须跟一个空格符，则返回false。否则返回true
### close() 方法
- 刷新缓冲区里任何还没有写入的信息，并关闭该文件，这之后便不能再进行写入

## 读写文件
### write()方法
- write()方法可将任何字符串写入一个打开的文件
- 需要重点注意的是，Python字符串可以是二进制数据，而不是仅仅是文字
- write()方法不会在字符串的结尾添加换行符('\n')

### read()方法
- 从一个打开的文件中读取一个字符串
- 需要重点注意的是，Python字符串可以是二进制数据，而不是仅仅是文字

## 文件定位
- tell()方法告诉你文件内的当前位置
    - 换句话说，下一次的读写会发生在文件开头这么多字节之后
- seek（offset [,from]）方法改变当前文件的位置
    - Offset变量表示要移动的字节数
    - From变量指定开始移动字节的参考位置
        - 如果from被设为0，这意味着将文件的开头作为移动字节的参考位置
        - 如果设为1，则使用当前的位置作为参考位置
        - 如果它被设为2，那么该文件的末尾将作为参考位置

# Python异常处理
- BaseException 所有异常的基类
- 捕捉异常可以使用try/except语句
- try/except语句用来检测try语句块中的错误，从而让except语句捕获异常信息并处理
- 如果你不想在异常发生时结束你的程序，只需在try里捕获它
```python
try:
<语句>        #运行别的代码
except <名字>：
<语句>        #如果在try部份引发了'name'异常
except <名字>，<数据>:
<语句>        #如果引发了'name'异常，获得附加的数据
else:
<语句>        #如果没有异常发生
```
- 如果except后不带具体异常名称，那么会捕获发生的所有的异常
- try-finally 语句无论是否发生异常都将执行最后的代码
- 异常的参数
```python
try:
    正常的操作
   ......................
except ExceptionType, Argument:
    你可以在这输出 Argument 的值...
```
- 可以使用raise语句自己触发异常
- 触发异常后，后面的代码就不会被执行