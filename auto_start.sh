source /etc/profile
source ~/bash_profile

cd /home/blog

/sbin/runuser -l root -c "/usr/bin/pm2 start /home/blog/webhooks.js"

hexo s &
