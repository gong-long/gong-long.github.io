#!/usr/bin/env python
#coding=utf-8
#在阿里云的msyql上调用mysql的API接口来查找慢SQL
#需要阿里云的模块库，aliyunsdkecs，xlsxwriter，#termcolor

import time
import json
import datetime
from aliyunsdkcore import client
from aliyunsdkrds.request.v20140815 import DescribeSlowLogRecordsRequest
#设置访问凭证

clt = client.AcsClient('LTAIhW7ZgLwPtjCS','zHIYQ8cTLswCWLyekQI53Z4Hrjcs54','cn-hangzhou')

#数据库清单

dblist =  ['rr-2zeyvcbluukv1qiwn', 'rm-2zek28989p9k1179v', 'rr-2zeo3es975ai399y', 'rr-2ze0s71v12o8qdtuh', 'rr-2ze9wz8bb610cx7', 'rr-2ze6hc62pa61dx0p4', 'rr-2zela73o7mh0s2p8o', 'rr-2ze6t3cl58ad3w62', 'rr-2ze1t8s3l254v9qqv', 'rr-2ze66z8t4fpd0x51h', 'rm-2zeg270l9534v1a5m', 'rm-2ze6239209hgvuvgq', 'rm-2zey971kf9t3ublde', 'rm-2ze15vy3vb88cp426', 'rm-2zezohz4xdu54263k', 'rm-2ze85u60ll2iw7x46', 'rm-2ze29k1wb187v1796', 'rm-2ze2yq4xg2mz3a5p', 'rr-2ze5ufm1idmn4bn01', 'rr-2ze4ka78ef56b70fq', 'rr-2ze79e35ia84d2dpq', 'rm-2ze509kn6k6177uf5']

#起始时间的定义

now_time = datetime.datetime.now()
yes_time = now_time + datetime.timedelta(days=-1)
starttime = yes_time.strftime('%Y-%m-%d')+"T11:00Z"
print starttime
#starttime = time.strftime('%Y-%m-%d')+"T00:00Z"
endtime = time.strftime('%Y-%m-%d')+"T11:00Z"
print endtime

#查询
##设置参数
request = DescribeSlowLogRecordsRequest.DescribeSlowLogRecordsRequest()
request.set_accept_format('json')


def exc_sql(db):
    request.add_query_param('DBInstanceId', db)
    request.add_query_param('StartTime', starttime)
    request.add_query_param('EndTime', endtime)
    request.add_query_param('PageSize', 100)
    request.add_query_param('PageNumber', 1)
    #发起请求
    response = clt.do_action(request)
    #处理
    return json.loads(response)

if __name__ == "__main__":
    for db in dblist:
        try:
                for i in exc_sql(db)['Items']['SQLSlowRecord']:
                    print i['DBName']+":"+i['SQLText']
        except:
                pass
