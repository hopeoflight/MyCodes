#!/bin/bash
#连接数据库并且分别修改 WF1，WF2，WF3，WF5的RegTime为最近6个月的时间
HOST='192.168.0.130'
USER='root'
echo -e "Product:\c"
read PRODUCT

{
#首先修改qis_product时间为最近6个月
echo "Modify "$PRODUCT" From qis_product Begin ..." >> modify.log
STR='UPDATE qis_product SET RegTime=(NOW() - INTERVAL FLOOR(0 + (RAND()*180)) DAY) WHERE Products = "'$PRODUCT'";'
MODPRODWF1=`mysql -h$HOST -u$USER  <<EOF
use qis;
$STR
EOF`
echo "Modify "$PRODUCT" From qis_product Complete ...">> modify.log

#等待qis_product修改完成之后，调用外部脚本修改qis_value和qis_public的时间和相应的qis_product的时间相同
wait

{
exec "./searchMysql.sh" $PRODUCT "qis_value"
}&

{
exec "./searchMysql.sh" $PRODUCT "qis_public"
}&

}&



