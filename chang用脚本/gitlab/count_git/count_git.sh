#!/bin/bash
#统计git提交代码量

for dir in qmzb qmzb-android h5 im-server push-server qmzb-api-docs qmzb-ios web-live web-login web-money web-shake lua qmzb-web-login;do
#yestaerday-time
years=`date -d "yesterday" +%Y`
mons=`date -d "yesterday" +%m`
days=`date -d "yesterday" +%d`
hears=`date -d "yesterday" +%H`
#today-time
year=`date +%Y`
mon=`date +%m`
day=`date +%d`
hear=`date +%H`
#
cd /script/gitlab/$dir
git pull &> /dev/null
/script/gitlab/gitstat.sh  --since="$years"/"$mons"/"$days" --until="$year"/"$mon"/"$day" -p /script/gitlab/$dir >> /script/gitlab/git/count_`date +%F`.log
done

cp /script/gitlab/git/count_`date +%F`.log /script/gitlab/git/aliyun.log
git_name=("zhoukeke2448" "xiang.ou" "hanlongfei3650" "15333038192" "spd2904" "2759455183" "210813289" "zdq7318" "ouxiang5154" "weijinpeng9928" "zwx1851" "gaojian1131" "zhaoshuguang" "wei815559417" "decheng7747" "cfq0050")
real_name=("周珂珂" "欧翔" "韩龙飞" "王海龙" "武倩辉" "陈文富" "刘香苇" "赵建超" "欧翔" "魏金鹏" "张文祥" "高健" "赵曙光" "魏爱军" "余德成" "马辉")

#处理文件
grep -v Author /script/gitlab/git/count_$(date +%F).log |awk -F ' ' '{print $1}' |sort |uniq |while read names;do
#sed -n '1p' count_$(date +%F).log >> /script/gitlab/git/all_count_`date +%F`.log
if [ ${#git_name[@]} == ${#real_name[@]} ];then
for (( s=0;s<${#git_name[@]};s++)) do
	if [ "$names" == ${git_name[s]} ] ;then
		sed -i "s/$names/${real_name[s]}/g" /script/gitlab/git/count_$(date +%F).log
	fi
done
else
	echo "Git脚本新增人员添加错误，请重新添加。" > /script/gitlab/git/count_`date +%F`.log
fi
done
#sed -i '/^Author*/d' /script/gitlab/git/count_$(date +%F).log
txt=`grep -v Author /script/gitlab/git/count_$(date +%F).log`
echo -e "Author\tAdd\tDelete\tCommit\tProject" > /script/gitlab/git/count_$(date +%F).log
echo "$txt" >> /script/gitlab/git/count_$(date +%F).log

#上传到阿里ECS
txt1=`grep -v "Author" /script/gitlab/git/aliyun.log`
echo "$txt1" > /script/gitlab/git/aliyun.log
scp -P 12138 /script/gitlab/git/aliyun.log qmzb@39.105.26.12:/home/qmzb/Git_count
#rm /script/gitlab/git/aliyun.log

