msg=$1

while [ ! -n "$msg" ]
do
    read -p "请先输入更新内容:" msg
done

echo "提交内容： $msg"

cd /Users/winsky/Documents/project/blog/
echo '开始部署'
hexo clean && hexo generate && hexo deploy 
echo '部署完毕'
./push.sh $msg
