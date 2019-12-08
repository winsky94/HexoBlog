msg=$1

echo "提交内容： $msg"

# 提交到GitHub
cd /home/blogSrc/
git add . 
git commit -m $msg
git push origin dev

echo '成功推送到GitHub'
