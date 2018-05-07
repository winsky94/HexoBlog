---
title: 多应用共享session
date: 2018-03-14 20:14:14
updated: 2018-03-14 20:14:14
tags:
  - Tomcat
  - 共享Session
categories: 
  - web开发
---

在Java web开发中，我们经常使用Tomcat来作为Java web应用的容器。关于web开发中web容器的作用，可以参考[这篇文章][1]

特别情况下，我们可能需要部署在Tomcat中的多个应用共享session，以方便在不同的应用中共享存储在session中的内容。本文介绍了如何基于Tomcat实现多应用共享session。

<!-- more -->


# tomcat 配置
## 修改Tomcat/conf/server.xml文件
把 
```XML
<Host appBase="webapps" autoDeploy="true" name="localhost" unpackWARs="true" xmlNamespaceAware="false" x mlValidation="false"></Host>
``` 
修改为
```XML
<Host appBase="webapps" autoDeploy="true" name="localhost" unpackWARs="true" xmlNamespaceAware="false" x mlValidation="false">
<Context path="/project_a" reloadable="false" crossContext="true"></Context>
<Context path="/project_b" reloadable="false" crossContext="true"></Context>
</Host>
```
注意 **crossContext** 属性：设置为true，说明你可以调用另外一个WEB应用程序，通过ServletContext.getContext() 获得ServletContext 然后再调用其getAttribute() 得到你要的对象。

# 编写项目代码
## project_a项目
```Java
PrintWriter out = response.getWriter();

HttpSession session = request.getSession();
session.setAttribute("name", "user");
session.setMaxInactiveInterval(1800);

ServletContext ContextA = request.getSession().getServletContext();
ContextA.setAttribute("session", session);

//测试
out.println("in session put name : " + session.getAttribute("name"));
```

## project_b项目
```Java
PrintWriter out = response.getWriter();

HttpSession session = request.getSession();
ServletContext contextB = session.getServletContext();

// 这里面传递的是 Project_A 的虚拟路径
ServletContext context = contextB.getContext("/project_a");
HttpSession sessionA= (HttpSession) context.getAttribute("session");

//测试
out.println("in session put name : " + sessionA.getAttribute("name"));
```
# 进阶：共享socket套接字
## project_a项目
```Java
PrintWriter out = response.getWriter();

HttpSession session = request.getSession();
session.setAttribute("name", "user");
session.setMaxInactiveInterval(1800);

ServletContext ContextA = request.getSession().getServletContext();
ContextA.setAttribute("session", session);

Socket socket = new Socket("127.0.0.1", 8889);
ContextA.setAttribute("socket", socket);

PrintWriter printWriter = new PrintWriter(socket.getOutputStream(), true);
ContextA.setAttribute("printWriter", printWriter);

//测试
out.println("in session put name : " + session.getAttribute("name"));
```
## project_b项目
```Java
PrintWriter out = response.getWriter();

HttpSession session = request.getSession();
ServletContext contextB = session.getServletContext();

// 这里面传递的是 Project_A 的虚拟路径
ServletContext context = contextB.getContext("/project_a");
HttpSession sessionA= (HttpSession) context.getAttribute("session");
PrintWriter printWriter = (PrintWriter) context.getAttribute("printWriter");

String ipRequest = "B:" + System.currentTimeMillis();
printWriter.println(ipRequest);
printWriter.flush();

//测试
out.println("in session put name : " + sessionA.getAttribute("name"));
```

## socket服务端
```Java
public static void main(String[] args) {
   try {
       ServerSocket ss = new ServerSocket(8889);
       while (true) {
            Socket socket = ss.accept();
            receive(socket);
        }
    } catch (IOException e) {
        e.printStackTrace();
    }
}

public static void receive(final Socket socket){
   new Thread(){
       public void run(){
           while(true){
                try {
                    BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                    String line = in.readLine();
                    System.out.println("收到消息:" + line);
                    //返回处理信息
                    PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
                    out.println("发送信息:" + System.currentTimeMillis());
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }.start();
}
```

> [同一Tomcat下不同Web应用之间共享Session会话](http://blog.csdn.net/vacblog/article/details/45044709)

[1]: https://blog.winsky.wang/web开发/web开发中web容器的作用(如tomcat)/ "web开发中web容器的作用"



