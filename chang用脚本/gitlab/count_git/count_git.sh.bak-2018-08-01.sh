#!/bin/bash
#统计git提交代码量

for dir in qmzb qmzb-android h5 im-server push-server qmzb-api-docs qmzb-ios web-live web-login web-money web-shake lua qmzb-web-login;do
#for dir in qmzb qmzb-android im-server;do
	rm /script/gitlab/git/"$dir"_`date +%F`.txt
	echo -e "\n项目名:$dir" >> /script/gitlab/git/count_`date +%F`.log
#进入分支，统计分支数量
	cd /script/gitlab/$dir
	git branch -a |grep origin|awk -F '/' '{print $NF}' > /script/gitlab/git/branch.txt
	sed -i '/^$/d' /script/gitlab/git/branch.txt
#到每个分支下面去统计所有的代码量
	while read lines;do
	git checkout $lines &> /dev/null
	git pull &> /dev/null
	txt=`git log --format='%aN' | sort -u | while read name; do echo -en "$name\t"; git log --author="$name" --all --no-merges --pretty=tformat: --numstat | awk '{ add += $1; subs += $2; loc += $1 - $2 } END { printf "added lines: %s, removed lines: %s, total lines: %s\n", add, subs, loc }' -; done`
	#commit=`git log --author=aijun.wei --since="2014-07-01" --no-merges | grep -e 'commit [a-zA-Z0-9]*'|wc -l`
	echo  "$txt" >> /script/gitlab/git/"$dir"_`date +%F`.txt
	sed -i '/^$/d' /script/gitlab/git/"$dir"_`date +%F`.txt
	done < /script/gitlab/git/branch.txt
#去重每个人
	awk -F ' ' '{print $1}' /script/gitlab/git/"$dir"_`date +%F`.txt |sort|uniq > /script/gitlab/git/members.txt
	sed -i '/^$/d' /script/gitlab/git/members.txt
#每个人的代码相加
	while read mem;do
	#统计每行进入的量
		sum1=`grep $mem /script/gitlab/git/"$dir"_$(date +%F).txt |awk -F ' ' '{print $4}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
		sum2=`grep $mem /script/gitlab/git/"$dir"_$(date +%F).txt |awk -F ' ' '{print $7}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
		sum3=`grep $mem /script/gitlab/git/"$dir"_$(date +%F).txt |awk -F ' ' '{print $NF}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
#	echo "统计数 $sum1 $sum2 $sum3"
	#把总数据统计出来，输入到文件
		echo -e "$mem\tadd lines: $sum1\tremove lines: $sum2\ttotal lines: $sum3" >> /script/gitlab/git/count_"$dir"_`date +%F`.txt
		sed -i '/^$/d' /script/gitlab/git/count_"$dir"_`date +%F`.txt
	done < /script/gitlab/git/members.txt

#	mv /script/gitlab/git/"$dir"_`date +%F`.txt /script/gitlab/git/yesday
#done
	count=`cat /script/gitlab/git/members.txt |wc -l`
#	if [ $count == 0 ];then	
		for i in `seq $count`;do
	#today_cat
			name=`sed -n ''$i'p' /script/gitlab/git/members.txt`
	#判断此人是否是在职人员
		git_names=("aijun.wei" "hailong.wang" "ruifeng.wu" "yudecheng" "zhangwenxiang" "wuqianhui" "mahui" "hanlongfei" "zhaoshuguang" "zhoukeke" "weiweijinpeng" "liuxiangwei" "tiancongying" "chenwenfu" "tangKing" "gaojian" "ouxiang")
		real_names=("魏爱军" "王海龙" "吴锐锋" "余德成" "张文祥" "武倩辉" "马辉" "韩龙飞" "赵曙光" "周珂珂" "魏金鹏" "刘香苇" "田聪颖" "陈文富" "唐勇" "高健" "欧翔")
	if [ ${#git_names[@]} == ${#git_names[@]} ];then
		#git_names=("aijun.wei" "hailong.wang")
		for (( s=0;s<${#git_names[@]};s++)) do
			if [ $name == ${git_names[s]} ] ;then

		#	grep "$name" /script/gitlab/git/count_"$dir"_`date +%F`.txt  > /script/gitlab/git/line
        	#add
                	today=`grep ^"$name" /script/gitlab/git/count_"$dir"_$(date +%F).txt|awk -F' ' '{print $4}'|grep -o "[0-9]\+"`
		#remove
                	today1=`grep ^"$name" /script/gitlab/git/count_"$dir"_$(date +%F).txt|awk -F' ' '{print $7}'|grep -o "[0-9]\+"`

	#yesday_cat
		#	grep "$name" /script/gitlab/git/yesday/count_"$dir".txt > /script/gitlab/git/line1
		#add
                	yesday=`grep ^"$name" /script/gitlab/git/yesday/count_"$dir".txt|awk -F' ' '{print $4}'|grep -o "[0-9]\+"`
		#remove
                	yesday1=`grep ^"$name" /script/gitlab/git/yesday/count_"$dir".txt|awk -F' ' '{print $7}'|grep -o "[0-9]\+"`

        	        add=`expr $today - $yesday`
			remove=`expr $today1 - $yesday1`
			total=`grep ^"$name" /script/gitlab/git/count_"$dir"_$(date +%F).txt |awk -F ' ' '{print $NF}'`
			echo -e "name: ${real_names[s]}\tadd: $add\tremove: $remove\ttotal: $total" >> /script/gitlab/git/count_`date +%F`.log
			echo -e "${real_names[s]}\t$add\t$remove\t$total" >> /script/gitlab/git/all_count_`date +%F`.log
			echo -e "$dir\t$name\t$add\t$remove" >> /script/gitlab/git/aliyun.log
			fi
		done
	else
		echo "添加在职人员映射错误，请重新检查..." > /script/gitlab/git/count_`date +%F`.log
	fi
		done

		totals=`awk -F ' ' '{print $NF}' /script/gitlab/git/count_"$dir"_$(date +%F).txt|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
		echo "项目代码量: $totals" >> /script/gitlab/git/count_`date +%F`.log
#	else
#		echo "昨天增加用户到git" > /script/gitlab/git/count_`date +%F`.log
#	fi
		mv /script/gitlab/git/count_"$dir"_`date +%F`.txt /script/gitlab/git/yesday/count_"$dir".txt
done

#统计所有项目的所有人的添加和删除

awk -F ' ' '{print $1}' /script/gitlab/git/all_count_`date +%F`.log|sort|uniq > /script/gitlab/git/members.txt
while read members;do
	count1=`grep ^"$members" /script/gitlab/git/all_count_$(date +%F).log |awk -F ' ' '{print $2}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
	count2=`grep ^"$members" /script/gitlab/git/all_count_$(date +%F).log |awk -F ' ' '{print $3}'|awk 'BEGIN {sum=0} {sum+=$0} END{print sum}'`
	count3=`expr $count1 + $count2`
	echo -e "name: $members\tadd: $count1\tremove: $count2\ttotal: $count3" >> /script/gitlab/git/all_`date +%F`.log
done < /script/gitlab/git/members.txt


#发送到钉钉
sed -i '1d' /script/gitlab/git/count_`date +%F`.log
#MSG=$(cat /script/gitlab/git/count_`date +%F`.log)

#curl 'https://oapi.dingtalk.com/robot/send?access_token=fc77e095fc33e69647e9086b852eb1b2b3616312628e175cafb2484cd3fdbe4b'    -H 'Content-Type: application/json'    -d "{
#curl 'https://oapi.dingtalk.com/robot/send?access_token=c66a2d3e1eaf029d19ab98100388a6bff0037c18c9d95a0639e417a741693709'    -H 'Content-Type: application/json'    -d "{
#\"msgtype\":\"text\", 
#\"text\":{ 
#\"content\":\"$MSG\" 
#} 
#}"

# 发送到阿里云ECS
#scp -P 12138 /script/gitlab/git/aliyun.log qmzb@39.105.26.12:/home/qmzb/Git_count
rm /script/gitlab/git/aliyun.log
        find /script/gitlab/git/ -mtime +3 -exec rm {} \;
