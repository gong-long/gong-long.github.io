#!/usr/bin/python
# coding=utf-8
import sys
reload(sys)
sys.setdefaultencoding('utf8')
from xlsxwriter import Workbook
import os
###去除重复的SLOWSQL
outfile = open('/home/qmzb/nsql.txt', 'w') #新的文件
list_1=[]
for line in open('/home/qmzb/sql.txt'):  #老文件
    tmp = line.strip()
    if tmp not in list_1:
        list_1.append(tmp)
        outfile.write(line)
outfile.close()


def format_data():
    '''
    从全部数据中整理出需要的数据
    '''
    result = []
    data=[]
    with open('/home/qmzb/nsql.txt') as data_info:
        
        for line in data_info:
            dataname=line.split(':')[0]
            slowsql=line.split(':')[1]
            result.append(dataname)
            data.append(slowsql)
    #定义xlsx表格的路径
    filename = '/home/qmzb/mansql.xlsx'
    #生成xlsx表格
    test_book = Workbook(filename)
    #添加sheet
    worksheet = test_book.add_worksheet('SlowSql')
    # 设置字体加粗、字体大小
    format_title = test_book.add_format({'bold': True, 'font_size': 12})
    # 设置水平对齐、垂直对齐
    format_title.set_align('center')
    format_title.set_align('vcenter')
    # 定义表头
    title = (
        "库名",
        "慢SQL",
        "备注"
    )

    row = 0
    col = 0
    # 表头写入文件，引用样式
    for item in title:
        worksheet.write(row, col, item, format_title)
        col += 1
    row = 1
    col = 0
    for sqlname,sql in zip(result,data):
        worksheet.write(row,col,sqlname)
        worksheet.write(row,col+1,sql)
        row += 1
    test_book.close()


if __name__ ==  '__main__':
     format_data()
     os.system('echo "今天的SLOWSQL!!!!" |mail -s "SLOWSQL" -a /home/qmzb/mansql.xlsx group-1120675390@corp-32466167.groups.dingtalk.com')
