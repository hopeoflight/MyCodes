#!/bin/bash
## 提取数据库中产品的数据记录，并且生成标准模板文件
HOST='127.0.0.1'
USER='root'
PASSWD='HuaHui@111111'
echo -e "PRODUCTS:\c"
read PRODUCT
echo -e "OUTPUT FILENAME:\c"
read FILE
FILENAME=$FILE".csv"

function Querymine
{
return=$(mysql -h$HOSTMINE -u$USER -p$PASSWD<<EOF
use qis;
$1
EOF
)
echo $return
}

function Query
{
return=$(mysql -h$HOST -u$USER <<EOF
use qis;
$1
EOF
)
echo $return
}

getLimitStr="SELECT Freq,Max,Min FROM qis_public WHERE Products='$PRODUCT' LIMIT 1;"
ret=($(Query "$getLimitStr"))
Freq=$(echo ${ret[3]} | sed -r "s/\[|\]|\"//g")
Max=$(echo ${ret[4]} | sed -r "s/\[|\]|\"//g")
Min=$(echo ${ret[5]} | sed -r "s/\[|\]|\"//g")
totalNum=$(($(echo $Freq| grep -o ',' | wc -l) + 6))
for((i=0;i<$totalNum;++i))
do
    if [ $i -eq 0 ]
    then
        HEAD1="VNA1 J71S_WF1-J71S_WF2-J71S_WF3-J71S_WF5,"
        HEAD2="Limit Line:,"
        HEAD3="Serial Number,"
        HEAD4="Upper Limits----->,"
        HEAD5="Lower Limits----->,"
        HEAD6="Measurement Unit----->,"
    elif [ $i -lt 6 ]
    then
        HEAD1=$HEAD1","
        HEAD2=$HEAD2","
        HEAD4=$HEAD4","
        HEAD5=$HEAD5","
        HEAD6=$HEAD6","
        if [ $i -eq 1 ]
        then
            HEAD3=$HEAD3"Test Start Time,"
        elif [ $i -eq 2 ]
        then
            HEAD3=$HEAD3"Test Stop Time,"
        elif [ $i -eq 3 ]
        then
            HEAD3=$HEAD3"SubStation ID,"
        elif [ $i -eq 4 ]
        then
            HEAD3=$HEAD3"Overall Result,"
        elif [ $i -eq 5 ]
        then
            HEAD3=$HEAD3"Failing Bands,"
        fi
    elif [ $i -eq 6 ]
    then
        HEAD1=$HEAD1","
        HEAD2=$HEAD2","
        HEAD3=$HEAD3$Freq
        HEAD4=$HEAD4$Max 
        HEAD5=$HEAD5$Min
        HEAD6=$HEAD6","
    else
        HEAD1=$HEAD1","
        HEAD2=$HEAD2","
        HEAD6=$HEAD6","
    fi
done
echo $HEAD1 >> $FILENAME
echo $HEAD2 >> $FILENAME
echo $HEAD3 >> $FILENAME
echo $HEAD4 >> $FILENAME
echo $HEAD5 >> $FILENAME
echo $HEAD6 >> $FILENAME

getStr="SELECT qis_product.SN,qis_product.StartTime,qis_product.StopTime,qis_product.Result,qis_value.Value FROM qis_product,qis_value WHERE qis_value.KeyPrivate=qis_product.KeyPrivate AND qis_product.Products='$PRODUCT';"
ret=($(Query "$getStr"))

flag=0
count=0
SN=""
StartTime=""
StopTime=""
Result=""
Value="" 
for val in ${ret[@]}
do
    if [ $flag -gt 4 ]
    then
        if [ $(($count % 7)) -eq 0 ]
        then
            SN=$val
        elif [ $(($count % 7)) -eq 1 ]
        then
            StartTime=$val
        elif [ $(($count % 7)) -eq 2 ]
        then
            StartTime=$StartTime"+"$val
        elif [ $(($count % 7)) -eq 3 ]
        then
            StopTime=$val
        elif [ $(($count % 7)) -eq 4 ]
        then
            StopTime=$StopTime"+"$val
        elif [ $(($count % 7)) -eq 5 ]
        then
            if [ $val -eq 0 ]
            then
                Result="Fail"
            else
                Result="Pass"
            fi
        elif [ $(($count % 7)) -eq 6 ]
        then
            Value=$(echo $val | sed -r "s/\[|\]|\"//g")
            ValueStr=$SN","$StartTime","$StopTime",1,"$Result",*,"$Value
            echo $ValueStr >> $FILENAME
        fi
        count=$(($count + 1))
    else
        flag=$(($flag + 1))
    fi
done

