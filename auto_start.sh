source /etc/profile
source ~/bash_profile

cd /home/blog

/sbin/runuser -l root -c "pm2 start /home/blog/webhooks.js"

hexo s &
