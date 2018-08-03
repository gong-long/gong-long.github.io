#!/bin/bash
#统计git提交代码量
rm /script/gitlab/git/count_`date +%F`.log
for dir in qmzb qmzb-android h5 im-server push-server qmzb-api-docs qmzb-ios web-live web-login web-money web-shake lua qmzb-web-login web-apollo;do
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
/script/gitlab/gitstat.sh  --since=""$years"/"$mons"/"$days" 0:00" --until=""$year"/"$mon"/"$day" 0:00" -p /script/gitlab/$dir >> /script/gitlab/git/count_`date +%F`.log
done

sed -i '/DESKTOP-FK5DD12lxw/d' /script/gitlab/git/count_`date +%F`.log
sed -i '/^Author/d' /script/gitlab/git/count_`date +%F`.log
cp /script/gitlab/git/count_`date +%F`.log /script/gitlab/git/aliyun.log

rm /script/gitlab/git/counts_$(date +%F).log
#echo -e "Author\tAdd\tDelete\tCommit" > /script/gitlab/git/counts_$(date +%F).log
awk -F ' ' '{print $1}' /script/gitlab/git/count_`date +%F`.log |sort |uniq |while read name;do
	sum1=`grep $name /script/gitlab/git/count_$(date +%F).log |awk -F ' ' '{print $2}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
	sum2=`grep $name /script/gitlab/git/count_$(date +%F).log |awk -F ' ' '{print $3}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
	sum3=`grep $name /script/gitlab/git/count_$(date +%F).log |awk -F ' ' '{print $4}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
	echo -e "$name\t$sum1\t$sum2\t$sum3" >> /script/gitlab/git/counts_$(date +%F).log
done


a=`awk -F ' ' '{print $2}' /script/gitlab/git/counts_$(date +%F).log`
arrs=($(echo $a))

for((i=0;i<${#arrs[@]};i++)){
   for((j=0;j<${#arrs[@]}-1;j++)){
     if (( ${arrs[j]} <= ${arrs[j+1]} ));then
          tmp=${arrs[j]}
          arrs[j]=${arrs[j+1]}
          arrs[j+1]=$tmp
      fi
}
}

rm /script/gitlab/git/allcount_$(date +%F).log
for((m=0;m<${#arrs[@]};m++));do
        sed -n "/^[a-zA-Z]\+\.\?[a-zA-Z]\+	${arrs[m]}\>/p" /script/gitlab/git/counts_$(date +%F).log >> /script/gitlab/git/allcount_$(date +%F).log
done
        #sed -n "/^[a-zA-Z]\+\.\?[a-zA-Z]\+      ${arrs[m]}/p" /script/gitlab/git/counts_$(date +%F).log >> /script/gitlab/git/allcounts_$(date +%F).log

#如果有重复行，删除重复的行
q=`cat /script/gitlab/git/allcount_$(date +%F).log|wc -l`
for v in `seq $q`;do
	var1=`sed -n ""$v"p" /script/gitlab/git/allcount_$(date +%F).log|awk -F ' ' '{print $1}'`
        for ((w=$(($v+1));$w<$q;w++));do
        var2=`sed -n ""$w"p" /script/gitlab/git/allcount_$(date +%F).log|awk -F ' ' '{print $1}'`
        #echo $var2
                if [ $var1 = $var2 ] ;then
                        sed -i ""$w"d" /script/gitlab/git/allcount_$(date +%F).log
                fi
        done
done	

#替换Author为用户名
#git_name=("zhoukeke2448" "xiang.ou" "hanlongfei3650" "15333038192" "spd2904" "2759455183" "210813289" "zdq7318" "ouxiang5154" "weijinpeng9928" "zwx1851" "gaojian1131" "zhaoshuguang" "wei815559417" "decheng7747" "cfq0050")
git_name=("huaihkiss" "tiancongying" "wuruifeng" "ruifeng.wu" "tangKing" "xiaoyan.li" "zhoukeke" "hanlongfei" "hailong.wang" "wuqianhui" "JackChen" "liuxiangwei" "zhaojach" "ox" "ouxiang" "weiweijinpeng" "zhangwenxiang" "EntityGJ" "zhaoshuguang" "aijun.wei" "yudecheng" "mahui")
#real_name=("周珂珂" "欧翔" "韩龙飞" "王海龙" "武倩辉" "陈文富" "刘香苇" "赵建超" "欧翔" "魏金鹏" "张文祥" "高健" "赵曙光" "魏爱军" "余德成" "马辉")
real_name=("余德成" "田聪颖" "吴锐锋" "吴锐锋"  "唐勇" "李晓燕" "周珂珂" "韩龙飞" "王海龙" "武倩辉" "陈文富" "刘香苇" "赵建超" "欧翔" "欧翔" "魏金鹏" "张文祥" "高健" "赵曙光" "魏爱军" "余德成" "马辉")

#处理文件
awk -F ' ' '{print $1}' /script/gitlab/git/allcount_$(date +%F).log|sort |uniq |while read names;do
#sed -n '1p' count_$(date +%F).log >> /script/gitlab/git/all_count_`date +%F`.log
if [ ${#git_name[@]} == ${#real_name[@]} ];then
for (( s=0;s<${#git_name[@]};s++)) do
	if [ "$names" == ${git_name[s]} ] ;then
		sed -i "s/$names/${real_name[s]}/g" /script/gitlab/git/allcount_$(date +%F).log
	fi
done
else
	echo "Git脚本新增人员添加错误，请重新添加。" > /script/gitlab/git/allcount_`date +%F`.log
fi
done

txt=`grep -v Author /script/gitlab/git/allcount_$(date +%F).log`
echo -e "Author\tAdd\tDelete\tCommit" > /script/gitlab/git/allcount_$(date +%F).log
echo "$txt" >> /script/gitlab/git/allcount_$(date +%F).log

#上传到阿里ECS
txt1=`grep -v "Author" /script/gitlab/git/aliyun.log`
echo "$txt1" > /script/gitlab/git/aliyun.log
scp -P 12138 /script/gitlab/git/aliyun.log qmzb@39.105.26.12:/home/qmzb/Git_count
rm /script/gitlab/git/aliyun.log

find -mtime +7 -exec rm {} \;
