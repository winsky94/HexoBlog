---
title: 自动将更新部署到VPS
date: 2018-02-10 11:55:23
updated: 2018-02-10 11:55:23
tags:
	- HEXO
  	- 博客
  	- 部署
categories: 
	- Hexo博客
---

博客雏形搭建好了之后，又浪了几天没有折腾。昨天晚上自己买了个域名，想着是时候好好把博客完善起来了。下面继续开始折腾...

前面我们介绍了如何在[搬瓦工VPS][1]上[快速搭建自己的个人博客][2]，做了相关的[主题美化][3]，同时也进行了简单的[SEO优化][4]。

在这个过程中，每次需要更新，我都是直接手动将文件拖到VPS上的。作为一个“懒人”，这个过程还是太烦了。今天我们就来学习一下如何自动将博客部署到VPS上。

<!-- more -->
这篇文章重点介绍如何通过git webhooks实现远程vps的自动部署

具体流程：先在本机搭建好hexo环境，push到git仓库，再部署到服务器上

# 本地安配置hexo环境
在本地用hexo搭建一个个人博客很简单，分分钟可以搞定。如果以前没有接触过，可以参考我前面的博文：[个人博客Hexo搭建][2]

## 提交到远程仓库
首先需要一个在线的仓库，可以选择[github](https://github.com/)或者[Coding.net](https://coding.net/)。这里我选择了常用的[github](https://github.com/)

先在`github`上创建一个项目`HexoBlog`，并拷贝仓库`ssh`地址（使用`ssh`需要配置`ssh`公钥和私钥，如果不会配可以`google`一下或使用`http`地址）。注意，如果需要通过webhooks实现服务器自动化部署，推荐使用ssh会更方便一些

然后在本地`hexo`目录初始化本地仓库并提交到`github`
```
git init
git add .
git commit -m "first commit"
git remote add origin git@github.com:winsky94/HexoBlog.git
git push -u origin master
```

注意，如果以前没有配置`github`的`SSH`提交，可以参考这篇博文[GitHub的SSH提交配置][5]

# VPS配置
我使用的是[搬瓦工VPS][1]。服务器上安装好了`nodejs,git,nginx`，具体不会的可以谷歌一下
### 将代码从`github`上拉取下来
同样，这里也需要在服务器上配置`github`的`SSH`登录。参考[GitHub的SSH提交配置][5]
```
mkdir /home/blog
git init
git remote add origin git@github.com:winsky94/HexoBlog.git
git pull origin master
```

## 安装hexo模块
```
cd /home/blog
npm install hexo-cli -g
npm install
```

## hexo静态编译
```
hexo g
```
这一步会在`/home/blog`目录下生成一个`public`目录，这里面就是编译后的静态文件目录，其实这时候直接访问里面的html文件即可看到完整的效果了，只不过还需要一个服务来运行它

## 配置nginx
进入nginx服务配置文件目录`/usr/local/nginx/conf/vhost`，新建一个配置文件`blog.conf`，内容为
```
server
{
	listen 80;
    server_name blog.winsky.wang ;

	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   	proxy_pass http://localhost:4000/;
  }
}
```
重载nginx，使配置生效`nginx -s reload`。然后就可以通过[http://blog.winsky.wang](http://blog.winsky.wang)来访问博客了

# Git WebHooks 自动化部署
是不是觉得每次写完文章还要登录服务器去执行一次`git pull`很麻烦？最起码对我这个“懒人”来说，这样很耗时啊

幸运的是，`git`有很多钩子，可以在仓库发生变化的时候触发，类似`js`中的事件。`WebHooks`就是在你本地执行`git push`的时候，远程仓库会检测到仓库的变化，并发送一个请求到我们配置好的`WebHooks`


实现WebHooks自动化部署的推荐条件：
- 服务器端配置`ssh`认证
- 服务器端配置`nodejs`服务，接收`github`发来的请求

## 服务器webhook配置
由于`hexo`是基于`NodeJS`的，所以这里用`NodeJS`来接收`github`的`push`事件。
安装依赖库`github-webhook-handler`：
```
npm install github-webhook-handler
```
安装完成之后配置`webhooks.js`
```
var http = require('http')
var createHandler = require('github-webhook-handler')
var handler = createHandler({ path: '/webhooks_push', secret: 'winsky_nju' })
// 上面的 secret 保持和 GitHub 后台设置的一致
function run_cmd(cmd, args, callback) {
  var spawn = require('child_process').spawn;
  var child = spawn(cmd, args);
  var resp = "";
  child.stdout.on('data', function(buffer) { resp += buffer.toString(); });
  child.stdout.on('end', function() { callback (resp) });
}
handler.on('error', function (err) {
  console.error('Error:', err.message)
})
handler.on('push', function (event) {
  console.log('Received a push event for %s to %s',
    event.payload.repository.name,
    event.payload.ref);
    run_cmd('sh', ['./deploy.sh'], function(text){ console.log(text) });
})
try {
  http.createServer(function (req, res) {
    handler(req, res, function (err) {
      res.statusCode = 404
      res.end('no such location')
    })
  }).listen(6666)
}catch(err){
  console.error('Error:', err.message)
}
```
其中`secret`要和`github`仓库中`webhooks`设置的一致，`6666`是监听端口可以随便改，不要冲突就行，`./deploy.sh`是接收到`push`事件时需要执行的`shell`脚本，与`webhooks.js`都存放在博客目录下；`path: '/webhooks_push'`是`github`通知服务器的地址

因为我们的服务器上使用了`Nginx`，所以这里我们也需要使用`Nginx`来转发6666端口。在`Nginx`配置文件目录下新建一个`webhooks.conf`，内容如下：
```
server
{
    listen 80;
    server_name git.winsky.wang ;

	location / {
		proxy_set_header HOST $host;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:6666/;
    }
}
```
然后配置`git.winsky.wang`的域名解析

最后git上配置的地址是：`http://git.winsky.wang/webhooks_push`

## 配置`./deploy.sh`
```
cd /home/blog/
git reset --hard
git pull origin master  
hexo generate
```

然后运行`node webhooks.js`，就可以实现本地更新`push`到`github`，服务器会自动更新部署博客。

最后要将进程加入守护，通过`pm2`来实现
```
npm install pm2 --global
```
然后通过`pm2`启动`webhooks.js`
```
pm2 start /home/blog/webhooks.js 
```

## 自启动
参考[服务器重启后自动运行hexo服务][]


> [快速搭建Hexo博客+webhook自动部署+全站HTTPS](http://www.gaoshilei.com/2017/10/30/hexo-init/)

> [给你的项目增加Webhooks，自动进行部署](https://excaliburhan.com/post/add-webhooks-to-your-project.html)

> [使用Github的webhooks进行网站自动化部署](https://aotu.io/notes/2016/01/07/auto-deploy-website-by-webhooks-of-github/index.html)


[1]: https://bwh1.net/aff.php?aff=29080 "搬瓦工VPS"
[2]: https://blog.winsky.wang/2018/02/03/%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A2Hexo%E6%90%AD%E5%BB%BA/ "快速搭建自己的个人博客"
[3]: https://blog.winsky.wang/2018/02/04/Hexo%E5%8D%9A%E5%AE%A2Next%E4%B8%BB%E9%A2%98%E9%85%8D%E7%BD%AE/ "主题美化"
[4]: https://blog.winsky.wang/2018/02/06/%E5%A6%82%E4%BD%95%E8%AE%A9%E8%B0%B7%E6%AD%8C%E5%92%8C%E7%99%BE%E5%BA%A6%E6%90%9C%E7%B4%A2%E5%88%B0%E8%87%AA%E5%B7%B1%E7%9A%84%E5%8D%9A%E5%AE%A2/ "SEO优化"
[5]: http://blog.csdn.net/oDeviloo/article/details/52654590 "GitHub的SSH提交配置"