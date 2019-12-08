echo "提交内容： $msg"

# 本地编译
cd /home/blogSrc/
echo '开始部署'
hexo clean && hexo generate && hexo deploy 
echo '部署完毕'

# 提交到GitHub
git add . 
git commit -m $1
git push origin dev

echo '成功推送到GitHub'
