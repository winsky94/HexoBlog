---
title: forward和sendRedirect区别
date: 2018-05-07 17:33:14
updated: 2018-05-07 17:33:14
tags:
  - web开发
  - 页面跳转
categories: 
  - web开发
---

之前知道forward后地址栏地址不变，redirect后地址了那会发生变化

但是今天遇到一个问题，forward和redirect后，其后的代码段还会继续执行吗？

<!-- more -->

# redirect
- redirect 后，确认了要跳转的页面的 url，继续执行 redirect 下面的代码
- 执行完后，断开当前的与用户所发出的请求连接，即断开 request 的引用指向
- request 里存放的信息也会丢失
- 然后再与用户建立新的请求连接，即创建新的 request 对象，地址栏地址变成新的页面的地址

# forward
- forward后，确认了要跳转的页面的 url，停止继续执行后面的代码
- 先执行要跳转url里的代码
- 执行完毕后，再回来继续执行当前页面的代码
- 这期间二者共享一个 request 和 response 对象
- 这个过程，最后还是执行的原来的servlet，所以地址栏的地址不会变化

# 以登陆为例

### 页面
```html
  <form action="CheckUser" method="post">
        username:<input type="text" name="username" /><br>
        password:<input type="password" name="password" /><br>
        <input type="submit" value="submit" />
        <input type="reset" value="reset" />
  </form>
```

### check的servlet
```java
String username = request.getParameter("username");
String password = request.getParameter("password");
 
request.setAttribute("user", username);
 
if (username.equals(password)) {
      getServletContext().getRequestDispatcher("/success").forward(request, response);
      System.out.println("-----this is forward end-----");
} else {
       response.sendRedirect("false");
       System.out.println("---this is redirect end---");
}
```

### success的servlet
```java
PrintWriter out = response.getWriter();

String username = (String) request.getAttribute("user");

out.println("");
out.println("");
out.println("Welcome you " + username);
out.println("");
out.println("");
System.out.println("---- this is success servlet end ----");
```

### false的servlet
```java
PrintWriter out = response.getWriter();
 
String username = (String) request.getAttribute("user");
 
out.println("");
out.println("");
out.println(username + "  password ERROR!");
out.println("");
out.println("");
System.out.println("---- this is false servlet end ----");
```

### 运行结果
```
---- this is success servlet end ----
---- this is forward end-----
---- this is redirect end---
---- this is false servlet end ----
```