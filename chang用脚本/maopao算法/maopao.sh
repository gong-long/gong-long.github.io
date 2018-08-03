#!/bin/bash

a=`awk -F ' ' '{print $2}' /script/gitlab/git/counts_$(date +%F).log`
arrs=($(echo $a))

echo "please input a number list"
read -a arrs

for((i=0;i<${#arrs[@]};i++)){
   for((j=0;j<${#arrs[@]}-1;j++)){
     if (( ${arrs[j]} <= ${arrs[j+1]} ));then
          tmp=${arrs[j]}
          arrs[j]=${arrs[j+1]}
          arrs[j+1]=$tmp
      fi
}
}

echo ${arrs[@]}
