#!/usr/bin/sh
set -x
#````````````````
##################  简  介   ######################
#本脚本用于自动为epub电子书添加词频标记和注释（词典释义）
#标注样式分两种模式：彩色和数字角标（⁰¹²³⁴⁵）
#使用方法：运行脚本后自动转换当前目录下所有epub电子书
#         默认模式为初级词频等级/彩色标识/内置释义
#         可选择自定义词频等级模式和分级数量，样式，组合


########### 全 局 变 量################## 
#SOURCEDICT=100dict
#SOURCELIST=100list
SOURCEDICT=coca3w9dict
SOURCELIST=coca3w9dict
WORKSPACE=epub
DATE=`date "+%d%H%M"`
echo $DICT_COUNT
rm -rf epub
mkdir -p $WORKSPACE



#全局词频等级数量 
NO=6 
#----------------------------------------
#Word分频等级 LEVEL

#Junior
j1=2000 j2=4500 j3=6500 j4=9000 j5=12000 j6=15000
#j1=2001 j2=2500 j3=3000 j4=3500 j5=4000 j6=4500
#Middle
m1=4500 m2=6500 m3=10000 m4=15000 m5=20000 m6=28000
#Senior
s1=6000 s2=9000 s3=15000 s4=20000 s5=40000 s6=50000
#--------------------------------------------
#词频显示样式MODEL

#彩色
d1='<a style="color:DimGray; text-decoration:none;"\1'
d2='<a style="color:green; text-decoration:none;"\1'
d3='<a style="color:teal; text-decoration:none;"\1'
d4='<a style="color:olive; text-decoration:none;"\1'
d5='<a style="color:purple; text-decoration:none;"\1'
d6='<a style="color:maroon; text-decoration:none;"\1'

c1='<font color=DimGray>\1</font>'
c2='<font color=green>\1</font>'
c3='<font color=teal>\1</font>'
c4='<font color=olive>\1</font>'
c5='<font color=purple>\1</font>'
c6='<font color=maroon>\1</font>'

# 亮色搭配 blue red fuchsia lime aqua yellow
# 暗色搭配 navy maroon green teal  purple
# https://sobac.com/sobac/colors.htm

#角标 Subscript (1为最高频)
b1='\1¹' b2='\1²' b3='\1³' b4='\1⁴' b5='\1⁵' b6='\1⁶'
#b7='\1⁷'
############## 全 局 变 量 ###############



pre(){
##预处理epub文件######################

#脚本参数，有参数（书名）时转换该书，否则转换所有epub
EPUB_FILES=$1
if [ ! $EPUB_FILES ]; then
 echo "IS NULL"
 EPUB_FILES=./*.epub
  ls $EPUB_FILES
 echo "NOT NULL"
fi

rename 's/[ ]+/_/g' *.epub 
for EPUB_FILE in $EPUB_FILES
do 
    cp $EPUB_FILE ${EPUB_FILE%.epub}.zip
    for ZIP in *.zip
    do
        FILENAME=$(echo $ZIP|cut -d'.' -f1)
        unzip $ZIP -d $WORKSPACE/$FILENAME
    done
done

#---------------------------------------------
#提取统计处理html或xhtml文件
html(){ 
for html in $(find epub -maxdepth 10 -type f -name "*.*html");do
#for i in 'epub/*/*/*.*html' 'epub/*/*.*html' ;do
    echo "$html"
done
}
HTML=$(html)
#--------------------------------------------

#筛选字数小于1000的文件
for COUNT in $(find epub -maxdepth 10 -type f -name "*.*ml")
do
#    H=$(ls -l $HTML | awk '{print $5}')
#删除<尖括号>部分内容
    H=$(sed -e "s/>/>\n/g" -e "s/</\n</g" $COUNT \
	| sed "/</d" | wc -w) 

    if [ $H -lt 1000 ];then
        if [ "${COUNT##*.}" = "html" ]; then
        mv "$COUNT" "${COUNT%.html}.htmlB"
        elif [ "${COUNT##*.}" = "xhtml" ]; then
        mv "$COUNT" "${COUNT%.xhtml}.xhtmlB"
        fi
    fi
done
#--------------------------------------------

htmlbig(){ #筛选出来要转换的的*html文件
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
    | sed -n "/</p" | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
    | sed "/\W/d" | tr -d 0-9 | sed "/^$/d" \
    | awk '!x[$0]++'`

##Wordlist提取前2000单词（需剔除）
L2000=$(head -n 2000 $SOURCELIST)$'\n'
#合并前词典列表的前2000 word和<code>文字作为剔除列表
FILTERALL=$L2000$FILTER 

#删除连续空格和空行|Word前后加@Word@|换行符改为分割符"|"|删除末尾"|"
FILTRATE=`echo "$FILTERALL" | sed -r -e 's/\s+//g' -e '/^$/d' \
    | awk '{if($0 ~ "[a-zA-Z]+"){print "@"$0"@"}else{print}}' \
    | tr '\n' '|' | sed 's/|$//'`
#----------------------------------------------------
echo "************过滤结果 FILTRATE  ***************"
echo "$FILTRATE"

####根据以上生成的剔除列表从词典word列表中删除
#给词典word列表加@标记@ | 剔除FILTRATE中的word
WORDLIST=`cat $(eval echo "$SOURCELIST") \
    | sed -e 's/^/@/g' -e 's/$/@/g' \
    | sed -r "s#($FILTRATE)#\1AAAA#g" \
    | sed 's/@//g' | sed '/AAAA/d'`

###根据以上生成的剔除列表从词典文件中删除相应条目
#词典添加\t@\t标记 | 把FILTRATE从词典中剔除 | 删除标记
FOOTDICT=`cat $(eval echo "$SOURCEDICT") \
    | sed -r 's/\t/@\t@/g' \
    | sed -r "s#($FILTRATE)#\1\tAAAA#g" \
    | sed '/AAAA/d' \
    | sed "/^$/d"`
}
#################### 过 滤 与 剔 除 完 成 ###################


#######################  主  函  数  #######################
convert_main(){
LEVEL=$1 MODEL=$2 ADDNOTE=$3

#-----------------------------------------------------------------
#根据选定的Level等级提取相应等级的word范围
    #$NO为相应模式的等级数量
echo "XXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    # \$$LEVEL$[ n+1 ]获取顶部相应Level的分级
    for n in $( eval echo {$(($NO-1))..1});do
    #LISTN为相应等级的word列表
    LISTN=$(echo "$WORDLIST" | head - -n$(eval echo \$$LEVEL$[ n+1 ]) \
    | tail -n$[ $(eval echo \$$LEVEL$[ n+1 ]) - $(eval echo \$$LEVEL$n) ])
echo "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVv"

#---------------------------------------------------------------
##根据ListN和词频样式Model逐级为html文件添加标记
    #添加边界符\bword\b| | 删除连续空格和空行 | 删除末尾“|”
    EXP=`echo "$LISTN" | sed -r -e 's/\s+//g' -e '/^$/d' \
    | awk '{if($0 ~ "\\\w+"){print "\\\b"$0"\\\b"}else{print}}' \
    | tr '\n' '|' | sed 's/|$//'`
echo "$EXP"


### 核心步骤 根据整理好的wordlist批量添加词频样式（MODEL）
        sed -r -i "s#($EXP)#$(eval echo \$$MODEL$n)#g" $HTMLBIG
    done
#--------------------------------------------------------------


foot_insert(){
#添加footnote（词典释义）

#-----------------------------------------
#切换python脚本替换模式
if [ $MODEL = d ]&&[ $ADDNOTE = y ];then
    sed -r -i -e '61,62s/^/#/g' -e '63s/^#+//g' dic9.py
elif [ $MODEL = c ]&&[ $ADDNOTE = n ];then
    sed -r -i -e '61s/^/#/g' -e '63s/^/#/g' -e '62s/^#+//g' dic9.py
elif [ $MODEL = b -a $ADDNOTE = n ]||[ $MODEL = b -a $ADDNOTE = y ];then
    sed -r -i -e '61s/^#+//g' -e '62,63s/^/#/g' dic9.py
fi

#---------------------------------------
###插入释义（使用外部python脚本，此步骤需要重写。或整个脚本都需要用python重写）

#根据过滤后的词典文件相应等级范围的条目逐级添加释义到html文件的<body>部分</body>
	echo "$FOOTDICT" | head - -n $(eval echo \$${LEVEL}6) \
	| tail -n $[ $(eval echo \$${LEVEL}6) - $(eval echo \$${LEVEL}1) ] \
	| sed 's/@//g' > dictlist
    python -c 'import dic9;print dic9.DReplace("dictlist","'$WORKSPACE'")'
}


clean(){
##未成功添加词频样式只加入释义的情况下删除脚注代码-临时解决办法
sed -r -i 's/[^"] epub:type="noteref" href="footnote_[0-9]*">(\w+\s*)<\/a>/ \1/g' $HTMLBIG
sed -r -i 's/[^"] epub:type="noteref" href="#footnote_[0-9]*">(\w+)<\/a>/ \1/g' $HTMLBIG
#sed -r 's/<a style="color:\w+; text-decoration:none;([^ ])/\1/g' $HTMLBIG
sed -r -i 's/<a style="color:\w+; text-decoration:none;"([^ ])([^e])/\1\2/g' $HTMLBIG
}

#选择Model b 且添加footnote时，最后转换 ⁿN 标记为[⁰¹²³⁴⁵⁶⁷⁸⁹]
rep_sub(){
    sed -i "s/ⁿ<\/a>\([⁰¹²³⁴⁵⁶⁷⁸⁹]\+\)/\1<\/a>/g" $HTMLBIG
    sed -i "s/ⁿ<\/a>/<\/a>/g" $HTMLBIG
}
#------------------------------------------------------
#判断是否添加footnote并执行(仅在样式为black或color且addnote为y时添加释义)
    if [ $ADDNOTE = y ]&&[ $MODEL = b ];then
        foot_insert
        rep_sub
    elif [ $ADDNOTE = n ]&&[ $MODEL = b ];then
        rep_sub
    elif [ $ADDNOTE = y ]&&[ $MODEL = d ];then
        foot_insert
        clean        
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
for i in `find ./* -type d`;do zip $i.zip `find $i | grep -v "$i$"`;done
rename 's/%#/ /g' *.zip 

#添加识别前缀
for F in *.zip ; do 
    mv -f "$F" ../Result/"$(echo $LEVEL$MODEL$ADDNOTE \
	| tr 'a-z' 'A-Z')$DATE-${F%.zip}.epub"
done

cd ../ && rename 's/%#/ /g' *.epub && rm *.zip 

echo "##############################################"
echo "#                                            #"
echo "#                 DONE!                      #"
echo "#                                            #"
echo "###############################################"

}





################### 交 互 选 择 ###############################
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
    echo "1 初级Junior(j)2000/4500/6500/9000/12000/15000"
    echo "2 Middle(m)"
    echo "3 Senior(s)"
    echo "4 User-defining(u)"
    echo -n "please select level(j\m\s\u,default=j):"
    read -t 30 LEVEL
#    LEVEL=${LEVEL:=j}
    echo "1 Black(b)"
    echo "2 Color(c)"
    echo "3 Gamma(g)"
    echo -n "Please select model(b\c\g,default=b)："
    read -t 30 MODEL
#    MODEL=${MODEL:=b}
    echo -n "Do you want add footnote?([y]es or [n]o):"
    read -t 30 ADDNOTE
#根据所选条件调用函数执行转换
    if [ $LEVEL = u ];then
        echo "自定义模式"
#        echo $DICT_COUNT
    echo "参考数据：科林斯词典选取最高频的35181词,分为五个词频等级"
    echo "每个等级约为1500/1500/3000/8000/15000/25000（无星）"
    echo "请输入第一级开始位置 前2000高频词已剔除，请从1～$DICT_COUNT选择:" 
    echo -n "default: $j1  recommend:1~5000"
    read u1
    echo -n "请输入第二级开始位置 $u1-$DICT_COUNT:"
    echo -n "default: $j2 recommend:2000~8000"
    read u2
    echo -n "请输入第三级开始位置（$u2-$DICT_COUNT）:" 
    read u3
    echo -n "请输入第四级开始位置（$u3-$DICT_COUNT）:"
    read u4
    echo -n "请输入第五级开始位置（$u4-$DICT_COUNT）"
    read u5
    echo -n "请输入第六级词汇量（$u5-$DICT_COUNT）"
    read u6
    
        if [ MODEL = c ]&&[ ADDNOTE = y ];then
            echo "彩色+内置释义模式请回车确认"
            read MODEL
            LEVEL=${LEVEL:=j}
                pre #预处理
                htmlbig #赋值给该变量（经过字数筛选的文件）
                prefilter #过滤与剔除
                convert_main j d y #自动模式默认组合
                postzip
        else
                pre
                htmlbig
                prefilter
                convert_main $LEVEL $MODEL $ADDNOTE
                postzip
         fi
    elif [ $LEVEL != u ];then
        pre
        htmlbig
        prefilter
        convert_main $LEVEL $MODEL $ADDNOTE
        postzip
    fi
       
fi
 echo "转换完成"



