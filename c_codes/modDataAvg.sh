#!/bin/bash
####
# 修改产品RegTime为最近6个月，每天的产品数量使用总记录数除以总天数计算得到
####
HOST='192.168.0.133'
USER='root'
#echo -e "Product:\c"
#read PRODUCT
#PRODUCT=$1
END=$(date  +%s)
Diff=180

function Query
{
return=$(mysql -h$HOST -u$USER <<EOF
use qis;
$1
EOF
)
echo $return
}

function DataDiff
{
startDate=$1
endDate=$2
stampDiff=$(($endDate - $startDate))
dayDiff=$(($stampDiff / 86400 + 1))
echo $dayDiff
}

function UpdateData
{
UpdateDataStr="UPDATE qis_product SET RegTime='$1' WHERE Id='$2';"
return=$(Query "$UpdateDataStr")
}

SelectProduct="SELECT Products FROM qis_product GROUP BY Products;"
res=($(Query "$SelectProduct"))
for PRODUCT in ${res[@]}
do
    if [ $PRODUCT != "Products" ]
    then
{
echo "Modify "$PRODUCT" From qis_product Begin ..." >> modify.log

SelectId="SELECT Id FROM qis_product WHERE Products='$PRODUCT' ORDER BY Id;"
Id=($(Query "$SelectId"))

SelectCount="SELECT COUNT(SN) FROM qis_product WHERE Products='$PRODUCT';"
Count=($(Query "$SelectCount"))
Avg=$((${Count[1]} / $Diff))

if [ $Avg -eq 0 ]
then
    Avg=1
fi

RegTime=$END
tmpNum=1
for((i=1;i<=${Count[1]};++i)) 
do
    tmpNum=$(($i % 60))
    if [ $(($i % $Avg)) -eq 0 ]
    then
        RegTime=$(($RegTime - 86400 + $tmpNum))
    else
        RegTime=$(($RegTime + $tmpNum))
    fi
    tmp=$(date -d @"$RegTime" +"%Y-%m-%d %H:%M:%S")
    res=$(UpdateData "$tmp" "${Id[$i]}")
#    if [ $i -lt 20 ]
#    then
#        echo $res
#    else
#        exit
#    fi
done

echo "Modify "$PRODUCT" From qis_product Complete ...">> modify.log

wait

{
echo "Modify "$PRODUCT" From qis_value Begin ..." >> modify.log

str="UPDATE qis_value,qis_product SET qis_value.RegTime=qis_product.RegTime WHERE qis_value.KeyPrivate=qis_product.KeyPrivate;";
res=$(Query "$str")

echo "Modify "$PRODUCT" From qis_value End ..." >> modify.log
}&

{
echo "Modify "$PRODUCT" From qis_public Begin ..." >> modify.log

str="UPDATE qis_public,qis_product SET qis_public.RegTime=qis_product.RegTime WHERE qis_public.KeyPublic=qis_product.KeyPublic;";
res=$(Query "$str")

echo "Modify "$PRODUCT" From qis_public End ..." >> modify.log
}&

}&



    fi
done


