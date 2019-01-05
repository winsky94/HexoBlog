cd /Users/winsky/Documents/project/blog/

echo '开始部署'

hexo clean && hexo generate && hexo deploy 

echo '部署完毕'

sh ./push.sh