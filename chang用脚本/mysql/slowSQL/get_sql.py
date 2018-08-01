#!/usr/bin/env python
#coding=utf-8

import time
import json
from aliyunsdkcore import client
from aliyunsdkrds.request.v20140815 import DescribeSlowLogRecordsRequest

clt = client.AcsClient('LTAIhW7ZgLwPtjCS','zHIYQ8cTLswCWLyekQI53Z4Hrjcs54','cn-hangzhou')
dblist =  ['rr-2zeyvcbluukv1qiwn', 'rm-2zek28989p9k1179v', 'rr-2zeo3es975ai399y', 'rr-2ze0s71v12o8qdtuh', 'rr-2ze9wz8bb610cx7', 'rr-2ze6hc62pa61dx0p4', 'rr-2zela73o7mh0s2p8o', 'rr-2ze6t3cl58ad3w62', 'rr-2ze1t8s3l254v9qqv', 'rr-2ze66z8t4fpd0x51h', 'rm-2zeg270l9534v1a5m', 'rm-2ze6239209hgvuvgq', 'rm-2zey971kf9t3ublde', 'rm-2ze15vy3vb88cp426', 'rm-2zezohz4xdu54263k', 'rm-2ze85u60ll2iw7x46', 'rm-2ze29k1wb187v1796', 'rm-2ze2yq4xg2mz3a5p', 'rr-2ze5ufm1idmn4bn01', 'rr-2ze4ka78ef56b70fq', 'rr-2ze79e35ia84d2dpq', 'rm-2ze509kn6k6177uf5']

starttime = time.strftime('%Y-%m-%d')+"T00:00Z"
endtime = time.strftime('%Y-%m-%dT%H:%m')+'Z'

request = DescribeSlowLogRecordsRequest.DescribeSlowLogRecordsRequest()
request.set_accept_format('json')

def exc_sql(db):
    request.add_query_param('DBInstanceId', db)
    request.add_query_param('StartTime', starttime)
    request.add_query_param('EndTime', endtime)
    request.add_query_param('PageSize', 100)
    request.add_query_param('PageNumber', 1)
    response = clt.do_action(request)
    return json.loads(response)

if __name__ == "__main__":
    for db in dblist:
        try:
            if len(exc_sql(db)['Items']['SQLSlowRecord']) > 1:
                for i in exc_sql(db)['Items']['SQLSlowRecord']:
                    print i['DBName']
                    print i['SQLText']+"\n"
            print exc_sql(db)['Items']['SQLSlowRecord'][0]['DBName']
            print exc_sql(db)['Items']['SQLSlowRecord'][0]['SQLText']+"\n"
        except:
            pass


