source /etc/profile
source ~/bash_profile

cd /home/blog

# webhook服务启动
/sbin/runuser -l root -c "pm2 start /home/blog/blog_webhooks.js"


# 改为静态部署之后，不需要在自启动脚本中启动

# 生成静态内容
# hexo generate && gulp

# 启动博客
# hexo s &
