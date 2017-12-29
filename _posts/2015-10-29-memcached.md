---
title: memcached 笔记
---



**一、memcached概述**

&emsp;memcached是一个高性能，分布式的内存对象缓存系统，通常是通过缓存降低数据库服务的负载来加速动态Web应用程序。memcache的分布是由客户端决定如何进行分布的，即依赖客户端。集中将后端的服务器的数据缓存到memcache服务器上。memcached缓存数据的上限是1M,超过1M的数据将不缓存，适合于小数据的缓存。LiveJournal旗下的Danga Interactive研发的产品。但是memcached无持久存储功能；使用内存空间来缓存数据，重启或关机，缓存项失效,失效后需要热身才能重新上线。缓存系统是hash后存储数据，是基于kv（键值）格式来存储数据是一种高效的方法

**二、概念介绍**

&emsp;缓存分两类

&emsp;&emsp;一是：bypass缓存：旁挂式缓存：仅提供缓存服务，强依赖于客户端的智能性，如缓存的内容，该信息是否可以被缓存，缓存的时间等信息都由客户端决定，即前端的客户端决定。这种客户端称为smart  client。客户端第一次发起请求时，向后端的服务器获取获取，得到服务器响应后，客户端会判断该响应数据是否可以被缓存，如果可以，就把响应信息也存一份到缓存服务器，第二次，客户端发起同样的请求，会先查看缓存服务器，如果缓存服务器此时有对应数据，直接响应，如果没有数据，则客户端会向后端服务器发起请求。mencache一半依赖于客户端，一半依赖于缓存和后端的原始存储。mencached是旁挂式缓存。


&emsp;&emsp;二是：代理式缓存：类似递归缓存的方式，如果本地没有缓存，需要自己去查找后端的服务器，得到数据

&emsp;memcached的特性:

> &emsp;&emsp;k/v cache：仅可存储可序列化（流式化）数据；存储项：k/v模式存储；智能性一半依赖于客户端（调用memcached的API开发程序），一半依赖于服务端；  
> &emsp;&emsp;分布式缓存：互不通信的分布式集群；  
> &emsp;&emsp;分布式系统请求路由方法：取模法，一致性哈希算法；  
> &emsp;&emsp;算法复杂度：O(1)  
> &emsp;&emsp;清理过期缓存项：  
> &emsp;&emsp;&emsp;&emsp;缓存耗尽：LRU ，最近最少使用算法  
> &emsp;&emsp;&emsp;&emsp;缓存项过期：惰性清理机制


**三、安装配置**

&emsp;监听的端口：11211/tcp, 11211/udp ：一般可以仅支持tcp，但是用tcp每次都需要三次握手，开销较大。

&emsp;memcached 软件集成在base仓库里，通过yum直接安装

> yum  -y  install  memcached 

&emsp;完成memcached服务器端的安装。客户端要驱动memcache，也要安装相应的包，有各种编程语言的客户端包，python,php,perl等，可以通过yum  list all *memcache*查看。

&emsp;&emsp;memcached通过命令行传递选项来启动。可以查看/usr/lib/systemd/system/memcached.service这个文件查看对应的启动命令。启动相关参数放在/etc/sysconfig/memcached文件里。可以通过memcached  -h 查看到更多选项。

&emsp;软件安装成功后，直接启动程序，不需要做其他设置。
> systemctl start memcached.service

> yum -y  install libmemcached

&emsp;libmemcached：基于C库的专用客户端工具来管理，连接到指定服务器上做设置。安装完后会生成很多mem相关的工具。如果不支持文本协议，只支持二进制，那么就一定要使用libmemcached这个专业工具进行管理，如果是支持文本协议，可以用telnet直接连接管理，连接方法是telnet 172.18.35.3 11211,不支持help帮助

> less /usr/share/doc/memcached-1.4.15/protocol.txt

&emsp;这个文档记录了关于memcache命令的介绍，记录了关于命令的格式，命令的使用方法。有三类命令：存储命令，获取数据的命令和其他命令三类

**配置文件**

> 主程序：/usr/bin/memcached  
> 配置文件：/etc/sysconfig/memcached  可调整配置  
> Unit File：memcached.service 

&emsp;按需存储，会造成内存碎片多
提前规划好缓存项，按一定步进规则来提前划分空间，切割大小的叫slab class

> 协议格式：memcached协议  
> 文本格式:效率低  
> 二进制格式：

**命令：**

> 统计类：stats, stats items, stats slabs, stats sizes 其中，stats显示所有的内键状态  
> 存储类：set, add, replace, append, prepend
命令格式：<command name> <key> <flags> <exptime> <bytes>  
<cas unique>  
> 检索类：get, delete, incr/decr  
> 清空：flush_all ，清空所有的缓存


memcached程序的常用选项：
```
            -m <num>：Use <num> MB memory max to use for object storage; the default is 64 megabytes.
			-c <num>：Use <num> max simultaneous connections; the default is 1024.
			-u <username>：以指定的用户身份来运行进程；
			-l <ip_addr>：监听的IP地址，默认为本机所有地址；
			-p <num>：监听的TCP端口， the default is port 11211.
			-U <num>：Listen on UDP port <num>, the default is port 11211, 0 is off.
			-M：内存耗尽时，不执行LRU清理缓存，而是拒绝存入新的缓存项，直到有多余的空间可用时为止；
			-f <factor>：增长因子；默认是1.25；
			-t <threads>：启动的用于响应用户请求的线程数；
			
		memcached默认没有认证机制，可借用于SASL进行认证；
			SASL：Simple Authentication Secure Layer
```

示例：（直接添加缓存值，到内存）

> telnet> add KEY <flags> <expiretime> <bytes> \r  
> telnet> VALUE
```
[root@CentOS ~]#telnet 127.0.0.1 11211       #连接memcached服务
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
help                            #不支持help命令，语法查看protocol.txt文档
ERROR
add mykey 1 600 15              #添加一条缓存，字节为15，缓存时长为10分钟 
hello memcached                 #写入缓存内容
STORED
get mykey                       #获取缓存内容
VALUE mykey 1 15
hello memcached
END
append mykey 1 600 7            #在mykey这个缓存后添加7个字节的内容
 system
STORED
get mykey                       #查看是否插入成功
VALUE mykey 1 22
hello memcached system
END
prepend mykey 1 600 4           #在mykey这个缓存键的内容前添加4字节的内容
new 
STORED
get mykey                       #查看是否插入成功
VALUE mykey 1 26
new hello memcached system
END
add count 1 600 1               #添加一个自增键，缓存10分钟
0
STORED
incr count 1                    #定义第一个内容
1
get count
VALUE count 1 1
1
END
incr count 3                    #内容增加3
4
get count                       #查看内容
VALUE count 1 1
4
END
decr count 2                    #内容减2
2
get count                       #查看内容
VALUE count 1 1
2
END
delete count                    #删除这个键
DELETED
get count                       #再获取count键已经没有了
END

stats                           #查看缓存状态
STAT pid 2350
STAT uptime 2903
STAT time 1511695533
STAT version 1.4.15
STAT libevent 2.0.21-stable
STAT pointer_size 64
STAT rusage_user 0.040151
STAT rusage_system 0.085321
STAT curr_connections 10
STAT total_connections 14
STAT connection_structures 11
STAT reserved_fds 20
STAT cmd_get 7
STAT cmd_set 4
STAT cmd_flush 0
STAT cmd_touch 0
STAT get_hits 6
STAT get_misses 1
STAT delete_misses 0
STAT delete_hits 1
STAT incr_misses 0
STAT incr_hits 2
STAT decr_misses 0
STAT decr_hits 1
STAT cas_misses 0
STAT cas_hits 0
STAT cas_badval 0
STAT touch_hits 0
STAT touch_misses 0
STAT auth_cmds 0
STAT auth_errors 0
STAT bytes_read 314
STAT bytes_written 331
STAT limit_maxbytes 67108864
STAT accepting_conns 1
STAT listen_disabled_num 0
STAT threads 4
STAT conn_yields 0
STAT hash_power_level 16
STAT hash_bytes 524288
STAT hash_is_expanding 0
STAT bytes 97
STAT curr_items 1
STAT total_items 7
STAT expired_unfetched 0
STAT evicted_unfetched 0
STAT evictions 0
STAT reclaimed 0
END
flush_all                       #清空所有内容
OK
quit
Connection closed by foreign host.
[root@CentOS ~]#
```
    




