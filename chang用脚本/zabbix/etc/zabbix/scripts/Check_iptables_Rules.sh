#!/bin/bash
# check iptables rule change status
function check_iptables_rule() {
    if [ -f /tmp/iptables_rules_md5 ];then
        old_md5=`cat /tmp/iptables_rules_md5`
        new_md5=`iptables -L -n | md5sum | awk {print }`
        if [ "$old_md5" = "$new_md5" ];then
            echo 0
        else
            echo 1
            iptables -L -n | md5sum | awk {print } > /tmp/iptables_rules_md5
        fi
    else
      iptables -L -n | md5sum | awk {print } > /tmp/iptables_rules_md5
    fi
}
# check iptables status
if [ -f /var/lock/subsys/iptables ];then
    check_iptables_rule
else
    echo 2
fi
