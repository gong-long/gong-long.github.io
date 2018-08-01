#!/bin/bash
#get slow_sql_log

mailsubject="慢SQL统计-`date +%F`"
/usr/bin/python /script/get_slowSQL.py > /data/SQL.txt
cat /data/SQL.txt |mail -s "$mailsubject" gonglong6155@dingtalk.com

