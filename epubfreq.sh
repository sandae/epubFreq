#!/usr/bin/sh
#set -x

########### 全 局 变 量################## 
#-----------------------------------
#词典文件格式为：\tWORD\tMEANING
SOURCEDICT=dict
#如果Wordlist不存在则根据词典提取出来
SOURCELIST=wordlist
if [  ! -f wordlist ];then
   cat $(eval echo "$SOURCEDICT") \
   | head -n 38000 \
   | awk '{FS="\t"}{print $2}' > wordlist
fi
#-------------------------------------

#定义脚本参数（如未使用参数则转换当前目录所有epub文件）
EPUB_FILES=$1
if  [ ! -n "$1" ]; then
 EPUB_FILES=`ls *.epub`
fi

WORKSPACE=epub
DATE=`date "+%d%H%M"`
echo $DICT_COUNT
rm -rf epub
rm  *.zip
mkdir -p $WORKSPACE


#词频等级数量（实际数量为NO-1） 
NO=6

#Word分频等级界限 LEVEL

#Junior
j1=1 j2=1500 j3=3500 j4=6500 j5=10000 j6=15000
#j1=20011 j2=2500 j3=3000 j4=3500 j5=4000 j6=4500
#j1=2000 j2=4500 j3=6500 j4=9000 j5=12000 j6=15000
#Middle
m1=4500 m2=6500 m3=10000 m4=15000 m5=20000 m6=28000
#Senior
s1=6000 s2=9000 s3=15000 s4=20000 s5=40000 s6=50000
#--------------------------------------------
#词频显示样式MODEL

# 角标 (MODEL b , 1为最高频)
b1='\1¹' b2='\1²' b3='\1³' b4='\1⁴' b5='\1⁵' b6='\1⁶'

# 彩色(MODEL d) 
#暗色
d1='<a style="color:DimGray; text-decoration:none;"\1'
d2='<a style="color:green; text-decoration:none;"\1'
d3='<a style="color:teal; text-decoration:none;"\1'
d4='<a style="color:olive; text-decoration:none;"\1'
d5='<a style="color:navy; text-decoration:none;"\1'
d6='<a style="color:maroon; text-decoration:none;"\1'

#亮色
#d1='<a style="color:LimeGreen; text-decoration:none;"\1'
#d2='<a style="color:DodgerBlue; text-decoration:none;"\1'
#d3='<a style="color:red; text-decoration:none;"\1'
#d4='<a style="color:orange; text-decoration:none;"\1'
#d5='<a style="color:fuchsia; text-decoration:none;"\1'
#d6='<a style="color:lime; text-decoration:none;"\1'

#彩色+无注释 (MODEL c)
c1='<font color=DimGray>\1</font>'
c2='<font color=green>\1</font>'
c3='<font color=teal>\1</font>'
c4='<font color=olive>\1</font>'
c5='<font color=purple>\1</font>'
c6='<font color=maroon>\1</font>'
############## 全 局 变 量 ###############



pre(){
##预处理epub文件######################
rename 's/[ ]+/_/g' $EPUB_FILES
#修改epub文件后缀为zip并解压到WORKSPACE目录下
for F in $EPUB_FILES
do
   cp $F ${F%.epub}.zip

done
#批量解压缩到WORKSPACE目录下
    for ZIP in *.zip
    do
        FILENAME=$(echo $ZIP|cut -d'.' -f1)
        unzip $ZIP -d $WORKSPACE/$FILENAME
    done

#---------------------------------------------
#函数 提取所有要处理的html或xhtml文件

#所有*html文件，包括小文件
html(){ 
for html in $(find epub -maxdepth 10 -type f -name "*.*html");do
#for i in 'epub/*/*/*.*html' 'epub/*/*.*html' ;do
    echo "$html"
done
}
HTML=$(html)
#--------------------------------------------

#过滤包含小于特定word数量的html文件
#查找html/xhtml文件
for COUNT in $(find epub -maxdepth 10 -type f -name "*.*ml")
do
#    H=$(ls -l $HTML | awk '{print $5}')
#删除<尖括号>部分内容
    H=$(sed -e "s/>/>\n/g" -e "s/</\n</g" $COUNT \
	| sed "/</d" | wc -w) 

#如果word数量小于1000则将文件改名
    if [ $H -lt 1000 ];then
        if [ "${COUNT##*.}" = "html" ]; then
        mv "$COUNT" "${COUNT%.html}.htmlB"
        elif [ "${COUNT##*.}" = "xhtml" ]; then
        mv "$COUNT" "${COUNT%.xhtml}.xhtmlB"
        fi
    fi
done
#--------------------------------------------

htmlbig(){ #经过字数筛选的*html文件
for htmlbig in $(find epub -maxdepth 10 -type f -name "*.*html");do
    echo "$htmlbig"
done
}
#--------------------------------------------
HTMLBIG=$(htmlbig)
}
echo "pre预处理完成"
##################预处理结束###############################


prefilter(){
################提取需要排除的word#####################
#每次转换从html文件提取代码文字（需剔除）
#尖括号换行|word换行|删非文字|删数字|删空行|去重
#列表单词收尾加@标记（@word@）
echo $HTML
FILTER=`sed -r -e "s/>/>\n/g" -e "s/</\n</g" $HTMLBIG \
      | sed -n "/</p" \
      | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
      | sed "/\W/d" \
      | tr -d 0-9 \
      | sed "/^$/d" \
      | awk '!x[$0]++'`

##Wordlist提取前2000单词（需剔除）
L2000=$(head -n 2000 $SOURCELIST)$'\n' #结尾回车
FILTERALL=$L2000$FILTER #合并前词典列表前2000和<code>文字作为剔除列表

#删除连续空格和空行|Word前后加@Word@|换行符改为分割符"|"|删除末尾"|"
FILTRATE=`echo "$FILTERALL" \
        | sed -r -e 's/\s+//g' -e '/^$/d' \
        | awk '{if($0 ~ "[a-zA-Z]+") \
               {print "@"$0"@"}else{print}}' \
        | tr '\n' '|' \
        | sed 's/|$//'`

#----------------------------------------------------
echo "pre过滤列表已生成"
echo "开始剔除........"

####根据以上生成的剔除列表从词典word列表中删除

#给词典word列表加@标记@ | 剔除FILTRATE中的word
WORDLIST=`cat $(eval echo "$SOURCELIST") \
        | sed -e 's/^/@/g' -e 's/$/@/g' \
        | sed -r "s#($FILTRATE)#\1AAAA#g" \
        | sed 's/@//g' | sed '/AAAA/d'`

echo "$WORDLIST"

###根据以上生成的剔除列表从词典文件中删除相应条目
#词典添加\t@\t标记 | 把FILTRATE从词典中剔除 | 删除标记
FOOTDICT=`cat $(eval echo "$SOURCEDICT") \
        | sed -r 's/\t/@\t@/g' \
        | sed -r "s#($FILTRATE)#\1\tAAAA#g" \
        | sed '/AAAA/d' | sed "/^$/d"`
echo "$FOOTDICT"
echo "prefilter预过滤完成"
echo "开始转换..........."
}
#################### 过 滤 与 剔 除 完 成 ###########################


#######################  主  函  数  ###############################
convert_main(){
#!!函数的三个参数
LEVEL=$1 MODEL=$2 ADDNOTE=$3

#-----------------------------------------------------------------
#根据选定的Level等级提取相应等级的word范围

    #$NO为相应模式的等级数量
    for n in $( eval echo {$(($NO-1))..1});do
    #LISTN为相应等级的word列表 head -n j6 | tail -n j5
    LISTN=$(echo "$WORDLIST" \
        | head - -n$(eval echo \$$LEVEL$[ n+1 ]) \
        | tail -n$[ $(eval echo \$$LEVEL$[ n+1 ]) \
        - $(eval echo \$$LEVEL$n) ])

#---------------------------------------------------------------
#逐级预处理
    #添加边界符\bword\b| | 删除连续空格和空行 | 删除末尾“|”
    EXP=`echo "$LISTN" \
      | sed -r -e 's/\s+//g' -e '/^$/d' \
      | awk '{if($0 ~ "\\\w+"){print "\\\b"$0"\\\b"}else{print}}' \
      | tr '\n' '|' \
      | sed 's/|$//'`


#核心步骤 给html添加词频标记（i忽略大小写）
sed -r -i "s#($EXP)([\,\.\"]*)#$(eval echo \$$MODEL$n)#gi" $HTMLBIG

    done
echo "添加样式标记完成"
##################################################################


foot_insert(){
echo "开始添加注释......"
#添加footnote（词典释义）

#切换python脚本替换模式，不会python，无奈之举
if [ $MODEL = d ]&&[ $ADDNOTE = y ];then
    sed -r -i -e '61,62s/^/#/g' -e '63s/^#+//g' dic9.py
elif [ $MODEL = c ]&&[ $ADDNOTE = n ];then
    sed -r -i -e '61s/^/#/g' -e '63s/^/#/g' -e '62s/^#+//g' dic9.py
elif [ $MODEL = b -a $ADDNOTE = n ]|| \
     [ $MODEL = b -a $ADDNOTE = y ];then
    sed -r -i -e '61s/^#+//g' -e '62,63s/^/#/g' dic9.py
fi

#---------------------------------------
###插入释义
#根据过滤后的词典文件相应等级范围的条目逐级添加释义到html文件的<body>部分</body>
    echo "$FOOTDICT" | head - -n $(eval echo \$${LEVEL}6) \
    | tail -n $[ $(eval echo \$${LEVEL}6) - $(eval echo \$${LEVEL}1) ] \
    | sed 's/@//g' > dictlist
    python -c 'import dic9;print dic9.DReplace("dictlist","'$WORKSPACE'")'
}


#选择Model b且添加footnote时，最后转换 ⁿN为[⁰¹²³⁴⁵⁶⁷⁸⁹]
rep_sub(){
    sed -i "s/ⁿ<\/a>\([⁰¹²³⁴⁵⁶⁷⁸⁹]\+\)/\1<\/a>/g" $HTMLBIG
    sed -i "s/ⁿ<\/a>/<\/a>/g" $HTMLBIG
}

#------------------------------------------------------
#判断是否添加footnote并执行(仅在样式为black或color且addnote为y时添加释义)
    if [ $ADDNOTE = y ]&&[ $MODEL = b ];then
        foot_insert
        rep_sub
    elif [ $ADDNOTE = y ]&&[ $MODEL = d ];then
        foot_insert     
    fi

}

#by:convert,foot,sub,
#bn:convert sub
#cy:convert,foot,clean
#cn:convert

postzip(){
############## 打 包 复 原 ###############################
for HTML in $(find epub -maxdepth 10 -type f -name "*.*mlB")
do
        if [ "${HTML##*.}" = "htmlB" ]; then
        mv "$HTML" "${HTML%.htmlB}.html"
        elif [ "${HTML##*.}" = "xhtmlB" ]; then
        mv "$HTML" "${HTML%.xhtmlB}.xhtml"
        fi
done

mkdir -p Result && cd $WORKSPACE

#批量压缩单个epub电子书，不包含电子书目录本身
for i in `find ./* -type d`;do zip $i.zip `find $i \
| grep -v "$i$"`;done
rename 's/%#/ /g' *.zip 

#添加识别前缀
for F in *.zip ; do 
    mv -f "$F" ../Result/"$(echo $LEVEL$MODEL$ADDNOTE \
	| tr 'a-z' 'A-Z')$DATE-${F%.zip}.epub"
done

cd ../ && rename 's/%#/ /g' *.epub && rm *.zip 

echo "##############################################"
echo "#                 转换完成!                   #"
echo "###############################################"

}





################### 交 互 选 择 #########################
#输入/选择等级与样式
echo "############################################"
echo "#           CONVERT AND REPLACE            #"
echo "############################################"
    echo -n "[a]utomatic or [m]anual? (default=a):"
    read -t 30 AM
    AM=${AM:=a}
if [ $AM = a ];then
#    LEVEL=j MODEL=b ADDNOTE=y
    pre #预处理
    htmlbig #赋值给该变量（经过字数筛选的文件）
    prefilter #过滤与剔除
    convert_main j d y #自动模式默认组合
    postzip
elif [ $AM = m ];then
    echo "1 初级Junior(j) 2000/4500/6500/9000/12000/15000"
    echo "2 中级Middle(m)"
    echo "3 高级Senior(s)"
    echo "4 自定义User-defining(u)"
    echo -n "请选择难度等级 Level(j\m\s\u):"
    read -t 30 LEVEL
#    LEVEL=${LEVEL:=j}
    echo "1 单色Black(b)"
    echo "2 彩色Color(c)"
    echo "3 彩色+内置释义(d)"
    echo -n "请选择词频标记样式 Please select model(b\c\g)："
    read -t 30 MODEL
#    MODEL=${MODEL:=b}
    echo -n "是否添加释义？ Do you want add footnote?([y]es/[n]o):"
    read -t 30 ADDNOTE
#根据所选条件调用函数执行转换
    if [ $LEVEL = u ];then
        echo "自定义模式"
    echo "参考数据：科林斯词典选取最高频的35181词,分为五个词频等级"
    echo "每个等级分别为1342/1388/1831/3400/8228/20581(无星)"
    echo "请输入第一级词汇起始位置，注意：前2000高频词已剔除!"
    echo "请从1～$DICT_COUNT选择输入:"
    read u1
    echo -n "请输入第二级词汇开始位置 $u1-$DICT_COUNT:"
    read u2
    echo -n "请输入第三级词汇开始位置（$u2-$DICT_COUNT）:" 
    read u3
    echo -n "请输入第四级词汇开死位置（$u3-$DICT_COUNT）:"
    read u4
    echo -n "请输入第五级词汇开始位置（$u4-$DICT_COUNT）"
    read u5
    echo -n "请输入第六级词汇开始位置（$u5-$DICT_COUNT）"
    read u6
    echo "您选择的是$LEVEL,$MODEL,$ADDNOTE"
    echo "您选择的词频范围为: $u1/$u2/$u3/$u4/$u5/$u6"
    read -p "请回车确认或重新运行脚本选择：([y]es/[n]o default:y )"
    echo "开始以自定义模式转换........."
                pre #预处理
                htmlbig #赋值给该变量（经过字数筛选的文件）
                prefilter #过滤与剔除
                convert_main j d y #自动模式默认组合
                postzip

    elif [ $LEVEL != u ];then
        pre #预处理
        htmlbig #赋值给该变量（经过字数筛选的文件）
        prefilter #过滤与剔除
        convert_main $LEVEL $MODEL $ADDNOTE #自动模式默认组合
        postzip
    fi
       
fi
