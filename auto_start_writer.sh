source /etc/profile

cd /home/blogSrc

hexo server -d &
nohup hexo server -d > server.log 2>&1 &
