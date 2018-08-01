#!/bin/bash
regexp=\"(btrfs|ext2|ext3|ext4|jfs|reiser|xfs|ffs|ufs|jfs|jfs2|vxfs|hfs|ntfs|fat32|zfs)\"
tmpfile=\"/tmp/mounts.tmp\"  
# 过滤所有已挂载的文件系统
egrep \"\$regexp\" /proc/mounts > \"\$tmpfile\" 
num=\$(cat \"\$tmpfile\"|wc -l)
printf {n
printf t"data":[ 
while read line;do
# 磁盘分区名称
    DEV_NAME=\$(echo \$line|awk {print $1})
# 文件系统名称，即磁盘分区的挂载点
    FS_NAME=\$(echo \$line|awk {print $2})
# blockdev命令获取扇区大小，用于计算磁盘读写速率
    SEC_SIZE=\$(/sbin/blockdev --getss \$DEV_NAME 2>/dev/null)
    printf ntt{
    printf \"\\"{#DEV_NAME}\\":\\"\${DEV_NAME}\\",\"
    printf \"\\"{#FS_NAME}\\":\\"\${FS_NAME}\\",\"
    printf \"\\"{#SEC_SIZE}\\":\\"\${SEC_SIZE}\\"}\"
    ((num--))
    [ \"\$num\" == 0 ] && break
    printf \",\"
done < \"\$tmpfile\"
printf nt]n
printf }n 
