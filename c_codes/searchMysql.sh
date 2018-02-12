#!/bin/bash
### 和modify.sh配合使用，用来修改产品时间为6个月内的随机时间
ADDR='192.168.0.130'
USER='root'

#输入产品名称和修改的表名
KEYSTR=""
PRODUCT=$1
TABLE=$2

if [ "$TABLE" == "qis_value" ]
then
KEYSTR="KeyPrivate"
else
KEYSTR="KeyPublic"
fi

echo "Modify "$PRODUCT" From "$TABLE" Begin ...">> modify.log

FLAG=0
REGTIME=0
KEYPRIVATE=''

#获取qis_product中的关联变量和时间
STR='SELECT qis_product.'$KEYSTR',UNIX_TIMESTAMP(qis_product.RegTime) FROM qis_product WHERE Products = "'$PRODUCT'";'
QUERY=$(mysql -h$ADDR -u$USER <<EOF
use qis;
$STR
EOF
)

for KEY in $QUERY
do
if [ "$KEY" != "$KEYSTR" -a "$KEY" != "UNIX_TIMESTAMP(qis_product.RegTime)" ] 
then

if [ "$FLAG" -eq "0" ]
then
    FLAG=1
    KEYPRIVATE=$KEY
else
    FLAG=0
    REGTIME=$KEY
fi

if [ "$FLAG" -eq "0" ]
then

#根据关联变量更新qis_value或者qis_public的时间为qis_product中相关联的时间
Str='UPDATE '$TABLE' SET RegTime = FROM_UNIXTIME('$REGTIME') WHERE '$TABLE'.'$KEYSTR' = "'$KEYPRIVATE'";'

$(mysql -h$ADDR -u$USER <<EOF
use qis;
$Str
EOF
)

fi

fi     
done

echo "Modify "$PRODUCT" From "$TABLE" Complete ...">> modify.log
