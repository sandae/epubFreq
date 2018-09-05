#!/usr/bin/sh
set -x
#````````````````
########### 全 局 变 量################## 
#-----------------------------------
#词典文件格式为：\tWORD\tMEANING
SOURCEDICT=coca3w9dict
SOURCELIST=coca3w9list


#生成Word列表
if [  ! -f coca3w9list ];then
   cat $(eval echo "$SOURCEDICT") \
   | head -n 38000 \
   | awk '{FS="\t"}{print $2}' > coca3w9list
fi
#-------------------------------------
WORKSPACE=epub
DATE=`date "+%d%H%M"`
echo $DICT_COUNT
rm -rf epub
rm -f *.zip
mkdir -p $WORKSPACE

#````````````````

if  [ ! -n "$1" ]; then

rename 's/ /@/g' *.epub
EPUB_FILES=*.epub
echo $EPUB_FILES

else
EPUB_FILES=`echo $1 | sed 's/ /@/g'`
mv "$1" "$EPUB_FILES"
fi



#词频等级数量（实际数量为NO-1） 
NO=6
#Word分频等级界限 LEVEL
#Junior
echo "collins每个等级分别为1342/1388/1831/3400/8228/20581(无星)"
e1=1 e2=2000 e3=4000 e4=6500 e5=10000 e6=18000 e7=26000
#e1=20011 e2=2500 e3=3000 e4=3500 e5=4000 e6=4500
#e1=2000 e2=4500 e3=6500 e4=9000 e5=12000 e6=15000
#Middle
i1=4500 i2=6500 i3=10000 i4=15000 i5=20000 i6=28000
#Senior
a1=6000 a2=9000 a3=15000 a4=20000 a5=40000 a6=50000
#--------------------------------------------
#词频显示样式MODEL
# （1/2） 角标 Subscript (1为最高频)
b1='\1¹' b2='\1²' b3='\1³' b4='\1⁴' b5='\1⁵' b6='\1⁶'

# （2/2） 彩色
#暗色

d1='<a style="color:Gray; text-decoration:none;"\1\2'
d2='<a style="color:green; text-decoration:none;"\1\2'
d3='<a style="color:teal; text-decoration:none;"\1\2'
d4='<a style="color:olive; text-decoration:none;"\1\2'
d5='<a style="color:maroon; text-decoration:none;"\1\2'
d6='<a style="color:maroon; text-decoration:none;"\1\2'

#亮色
#d1='<a style="color:LimeGreen; text-decoration:none;"\1'
#d2='<a style="color:DodgerBlue; text-decoration:none;"\1'
#d3='<a style="color:red; text-decoration:none;"\1'
#d4='<a style="color:orange; text-decoration:none;"\1'
#d5='<a style="color:fuchsia; text-decoration:none;"\1'
#d6='<a style="color:lime; text-decoration:none;"\1'

#d1='<a style="color:navy; text-decoration:none;"\1'
#d2='<a style="color:maroon; text-decoration:none;"\1'
#d3='<a style="color:green; text-decoration:none;"\1'
#d4='<a style="color:orange; text-decoration:none;"\1'
#d5='<a style="color:purple; text-decoration:none;"\1'
#d6='<a style="color:lime; text-decoration:none;"\1'

c1='<font color=DimGray>\1</font>'
c2='<font color=green>\1</font>'
c3='<font color=teal>\1</font>'
c4='<font color=olive>\1</font>'
c5='<font color=purple>\1</font>'
c6='<font color=maroon>\1</font>'

#暗深红色	crimson

# 亮色 blue red fuchsia lime aqua yellow
# 暗色 navy maroon green teal  purple
# https://sobac.com/sobac/colors.htm
#http://www.shouce.ren/api/html/html4/appendix-color.html


############## 全 局 变 量 ###############



pre(){
##预处理epub文件######################

####脚本参数，有参数（书名）时转换该书，否则转换所有epub
###EPUB_FILES=$1
###if  [ ! -n "$1" ]; then
### echo "IS NULL"
### EPUB_FILES=`*.epub`
#### echo "$EPUB_FILES"

###   else
###  echo "NOT NULL"
###     EPUB_FILES=$1
###     echo "$EPUB_FILES"
###fi
### echo "$EPUB_FILES"
###exit 0

##rename 's/ /@/g' *.epub #删除文件名中的空格
###修改epub文件后缀为zip并解压到WORKSPACE目录下
##for F in *.epub
##do
##   cp $F ${F%.epub}.zip


##done
###批量解压缩到WORKSPACE目录下
##    for ZIP in *.zip
##    do
##        FILENAME=$(echo $ZIP|cut -d'.' -f1)
##        unzip -q $ZIP -d $WORKSPACE/$FILENAME
##    done


#$$$%%%^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^



#rename 's/[ ]+/_/g' $1 #删除文件名中的空格
#修改epub文件后缀为zip并解压到WORKSPACE目录下
for F in $EPUB_FILES
do
   cp $F ${F%.epub}.zip

echo "$EPUB_FILES"

done
#批量解压缩到WORKSPACE目录下
    for ZIP in *.zip
    do
        FILENAME=$(echo $ZIP|cut -d'.' -f1)
        unzip $ZIP -d $WORKSPACE/$FILENAME
    done


#&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

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
#echo $HTML
FILTER=`sed -r -e "s/>/>\n/g" -e "s/</\n</g" $HTMLBIG \
      | sed -n "/</p" \
      | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
      | sed "/\W/d" \
      | tr -d 0-9 \
      | sed "/^$/d" \
      | awk '!x[$0]++'`

##Wordlist提取前2000单词（需剔除）
L2000=$(head -n 1500 $SOURCELIST)$'\n' #结尾回车
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
#记录：echo或cat等打印方式是否换行，会影响sed的执行
#     如果不换行，sed会当作一行来处理（废话），换行的话正常，
#     即使sed在执行中还是是当成一行来处理的。 对文件如此，对传递的变量呢？
#     对变量来说，需要“正确执行”，如cat $(eval echo "$SOURCELIST") 
#     相当与直接cat 文件
#     2、var=$() 和var=''测试效果相同，区别未知

WORDLIST=`cat $(eval echo "$SOURCELIST") \
        | sed -e 's/^/@/g' -e 's/$/@/g' \
        | sed -r "s#($FILTRATE)#\1AAAA#g" \
        | sed 's/@//g' | sed '/AAAA/d'`

#echo "$WORDLIST"

###根据以上生成的剔除列表从词典文件中删除相应条目
#词典添加\t@\t标记 | 把FILTRATE从词典中剔除 | 删除标记
FOOTDICT=`cat $(eval echo "$SOURCEDICT") \
        | sed -r 's/\t/@\t@/g' \
        | sed -r "s#($FILTRATE)#\1\tAAAA#g" \
        | sed '/AAAA/d' | sed "/^$/d"`
#echo "$FOOTDICT" > FOOTDICT
echo "prefilter预过滤完成"
echo "开始转换..........."
}
#################### 过 滤 与 剔 除 完 成 ############################


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
for i in `find ./* -type d`;do zip -q $i.zip `find $i \
| grep -v "$i$"`;done
rename 's/%#/ /g' *.zip 
rename 's/@/ /g' *.zip

#添加识别前缀
for F in *.zip ; do 
    mv -f "$F" ../Result/"$(echo $LEVEL$MODEL$ADDNOTE \
	| tr 'a-z' 'A-Z')$DATE-${F%.zip}.epub"
done

cd ../
rename 's/%#/ /g' *.epub
rename 's/@/ /g' *.epub
rm -f *.zip 

echo "##############################################"
echo "#                 转换完成!                   #"
echo "###############################################"

}


#######################  主  函  数  ###############################
convert_main(){
    pre
    htmlbig
    prefilter

#函数的三个参数,functrion a b c
LEVEL=$1 MODEL=$2 ADDNOTE=$3

#-----------------------------------------------------------------
#根据选定的Level等级提取相应等级的word范围
    #$NO为相应模式的等级数量，此处生成循环,echo (6..1) > 6 5 4 3 2 1

    # \$$LEVEL$[ n+1 ]获取顶部相应Level的分级，NO=6则该函数值为e7
    for n in $( eval echo {$(($NO-1))..1});do
    #LISTN为相应等级的word列表 head -n j6 | tail -n j5，以此类推
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

#根据ListN和词频样式Model逐级为html文件添加标记，循环结束
#i忽略大小写

sed -r -i "s#($EXP)([\,\.\"]+)*#$(eval echo \$$MODEL$n)#gi" $HTMLBIG
#sed -r -i "s#($EXP)#$(eval echo \$$MODEL$n)#g" $HTMLBIG

    done
echo "添加样式标记完成"
##################################################################


foot_insert(){
echo "开始添加注释......"
echo -e "\e[34m 由于遍历次数多，添加注释耗时较长\e[0m"
echo -e "\e[34m 500KB左右的epub电子书添加注释需要约10分钟，请耐心等待\e[0m"
#添加footnote（词典释义）
#切换python脚本替换模式
if [ $MODEL = d ]&&[ $ADDNOTE = y ];then
     sed -ri -e '61,62s/^[^#]/#/g' -e '63s/^#+/ /g' dic9.py
elif [ $MODEL = c ]&&[ $ADDNOTE = n ];then
    sed -ri -e '61s/^[^#]/#/g' -e '63s/^[^#]/#/g' -e '62s/^#+/ /g' dic9.py
elif [ $MODEL = b -a $ADDNOTE = n ]|| \
     [ $MODEL = b -a $ADDNOTE = y ];then
    sed -r -i -e '61s/^#+/ /g' -e '62,63s/^[^#]/#/g' dic9.py
fi


#---------------------------------------
###插入释义
#根据过滤后的词典文件相应等级范围的条目逐级添加释义到html文件的<body>部分</body>
    echo "$FOOTDICT" | head - -n $(eval echo \$${LEVEL}6) \
    | tail -n $[ $(eval echo \$${LEVEL}6) - $(eval echo \$${LEVEL}1) ] \
    | sed 's/@//g' > dictlist
    python -c 'import dic9;print dic9.DReplace("dictlist","'$WORKSPACE'")'

#解决python无法保留替换对象小写的问题：sed区分大小写，大写不替换
#此处匹配python替换过sed未替换的word，将首字母恢复大写，并删除多余标签代码

#    sed -ri 's/(\w+)<a epub:type="noteref" href="#footnote_[0-9]*"><\/a>/\u\1/g' $HTMLBIG

}

#未成功添加词频样式只加入释义的情况下删除脚注代码并回复首字母大写-临时解决办法
clear_left(){
    sed -ri -e 's/([^"]) epub.*?\>(\w+)<\/a>/\1 \u\2/g' $HTMLBIG
#    sed -ri -e 's/([^:])" epub.*?\>(\w+)<\/a>/\1 \u\2/g' $HTMLBIG
sed -ri -e 's/([^"])\s+epub:type="noteref" href="#footnote_[0-9]+">(\w+)<\/a>/\1 \u\2/g' $HTMLBIG
#sed -ri -e 's/([^:])"\s+epub:type="noteref" href="#footnote_[0-9]+">(\w+)<\/a>/\1 \u\2/g' $HTMLBIG
sed -ri -e 's/[^"] epub:type="noteref" href="#footnote_[0-9]*">(\w+ \w+)<\/a>/ \u\1/g' $HTMLBIG
sed -ri -e 's/[^"] epub:type="noteref" href="#footnote_[0-9]*">(\w+ \w+ \w+)<\/a>/ \u\1/g' $HTMLBIG
}

clean(){
##未成功添加词频样式只加入释义的情况下删除脚注代码-临时解决办法
sed -ri 's/[^"] epub:type="noteref" href="footnote_[0-9]*">(\w+\s*)<\/a>/ \1/g' $HTMLBIG
sed -ri 's/[^"] epub:type="noteref" href="#footnote_[0-9]*">(\w+)<\/a>/ \1/g' $HTMLBIG
sed -ri 's/<a style="color:\w+; text-decoration:none;"([^ ])([^e])/\1\2/g' $HTMLBIG
}
#选择Model b且添加footnote时，最后转换 ⁿN 标记为[⁰¹²³⁴⁵⁶⁷⁸⁹]
rep_sub(){
    sed -i "s/ⁿ<\/a>\([⁰¹²³⁴⁵⁶⁷⁸⁹]\+\)/\1<\/a>/g" $HTMLBIG
    sed -i "s/ⁿ<\/a>/<\/a>/g" $HTMLBIG
}
#------------------------------------------------------
#判断是否添加footnote并执行。(仅在样式为black或color且addnote为y时添加释义)
    if [ $ADDNOTE = y ]&&[ $MODEL = b ];then
        foot_insert
        rep_sub
    elif [ $ADDNOTE = y ]&&[ $MODEL = d ];then
        foot_insert
        clear_left
    fi

#打包收尾
    postzip
}

#by:convert,foot,sub,
#bn:convert sub
#cy:convert,foot,clean
#cn:convert



################### 交 互 选 择 #########################
#输入/选择等级与样式
echo "     _ _ _ _ _ _ _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _ "
echo -e " |                  _      __                 |"
echo -e " |  ___ _ __  _   _| |__  / _|_ __ ___  __ _  |"
echo -e " | / _ \ '_ \| | | | '_ \| |_| '__/ _ \/ _  | |"
echo -e " ||  __/ |_) | |_| | |_) |  _| | |  __/ (_| | |"
echo -e " | \___| .__/ \__,_|_.__/|_| |_|  \___|\__, | |"
echo -e " |     |_|                                |_| |"
echo "    | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _  |"

    echo "请选择词频标记样式"
#    echo "1 彩色字体标记+内置释义"
    echo -e "\e[34m 1 彩色字体标记+内置释义\e[0m "
#    echo "2 角标标记+内置释义"
    echo -e "\e[34m 2 角标¹²³⁴⁵标记+内置释义\e[0m "
    echo -e "\e[34m 3 彩色字体标记\e[0m "
    echo -e "\e[34m 4 角标¹²³⁴⁵标记\e[0m "
#    echo "3 自定义模式"
    echo -e "\e[34m 5 自定义模式\e[0m "
    echo -n "请输入编号1/2/3.（Default:1）"
    read -t 30 AM 
#   echo "[a]utomatic or [m]anual? (default=a):"
    AM=${AM:=1}
if [ $AM = 1 ];then
    convert_main e d y #自动模式默认组合
elif [ $AM = 2 ];then
    convert_main e b y
elif [ $AM = 3 ];then
    convert_main e c n
elif [ $AM = 4 ];then
    convert_main e b n
elif [ $AM = 5 ];then
    echo "手动模式，可选择词频等级，词频标记样式，及组合"
    echo "词频等级："
    echo -e "\e[34m 1 初级Elementary(e) $e1/$e2/$e3/$e4/$e5/$e6\e[0m"
    echo -e "\e[34m 2 中级Intermediate(i) $i1/$i2/$i3/$i4/$i5/$i6\e[0m"
    echo -e "\e[34m 3 高级Advance(a) $a1/$a2/$a3/$a4/$a5/$a6\e[0m"
    echo -e "\e[34m 4 词频范围自定义User(u)\e[0m"
    echo -n "请选择难度等级 Level(e\i\a\u):"
    read -t 30 LEVEL
#    LEVEL=${LEVEL:=e}
    echo " * * * * * * * * * "
    echo -e "\e[34m  1 角标/单色Black(b)\e[0m"
    echo -e "\e[34m  2 彩色Color(c)\e[0m"
    echo -e "\e[34m  3 彩色+内置释义(d)\e[0m"
    echo -n "请选择词频标记样式 Please select model(b\c\g)："
    read -t 30 MODEL
#    MODEL=${MODEL:=b}
    echo " * * * * * * * * * "
    echo -n "是否添加释义？ Do you want add footnote?([y]es/[n]o):"
    read -t 30 ADDNOTE
    echo " * * * * * * * * * "
#根据所选条件调用函数执行转换
    if [ $LEVEL = u ];then
        echo "词频自定义模式"
    echo "# 全局默认词频等级为5个级别，如需自定义等级数量需修改脚本。"
    echo "# 参考数据：科林斯词典选取最高频的35181词,分为五个词频等级"
    echo "  每个等级分别为1342/1388/1831/3400/8228/20581(无星)"
    echo "  请输入第一级词汇起始位置，注意：前2000高频词已剔除!"
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
          convert_main e d y
    elif [ $LEVEL != u ];then
        convert_main $LEVEL $MODEL $ADDNOTE

    fi
       
fi
