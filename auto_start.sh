source /etc/profile
source ~/bash_profile

cd /home/blog

# webhook服务启动
/sbin/runuser -l root -c "pm2 start /home/blog/webhooks.js"

# 启动博客
hexo s &
