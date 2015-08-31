#!/bin/bash

insts=localhost:3306

db_prefix=test_db
table_prefix=test_table

db_num=2
table_num=2

user_name=test_user
password=test_password

build_db() {
  inst=$1
  inst_arr=(${inst//:/ })

  host=${inst_arr[0]}
  port=${inst_arr[1]}

  db=$2
  db_no=$3

  for ((j=0;j<$table_num;j++)); do
    ((table_no=$table_num*$db_no+$j))
    
    #reg="s/\$index/$table_no/g"
    #echo $reg
    
    sql_command="sed 's/"'$index''/'$table_no"/g' ./table.sql | tr -t '\n' '\0'"
    sql=`eval "$sql_command"`
    
    mysql -uroot -pyouarebest -e "$sql" $db
     
  done  
}

build_inst() {
  inst=$1
  inst_arr=(${inst//:/ })

  host=${inst_arr[0]}
  port=${inst_arr[1]}

  inst_no=$2

  #mysql -uroot -pyouarebest -e "create user '$user_name'@'%' identified by '$password'"
  
  for ((i=0;i<$db_num;i++)); do
    ((db_no=$db_num*$inst_no+$i)) 
    mysql -uroot -pyouarebest -e "create database ${db_prefix}_${db_no}"

    mysql -uroot -pyouarebest -e "grant all privileges on ${db_prefix}_${db_no}.* to '$user_name'@'%' identified by '$password'"
    mysql -uroot -pyouarebest -e "flush privileges"    

    build_db $inst ${db_prefix}_${db_no} $db_no
  done   

echo $host$post
}

insts_arr=(${insts//,/ })  
insts_num=${#insts_arr[@]} 

for ((i=0;i<$insts_num;i++)); do 
  build_inst ${insts_arr[$i]} $i
done


