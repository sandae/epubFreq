#!/usr/bin/sh
#set -x
#```````````````` 
# 脚本介绍：
# 1. 本脚本用来为epub电子书添加词频标记和内置释义,可以选择多种模式，
#    或在脚本内自定义 "
# 2. 建议使用默认的彩色字体词频标记+分段注释模式 "
#    前8000（可自定）单词只添加标记，方便用第三方词典查词和学习
#    8000以后单词添加内置释义，阅读时不需要查词典，更加便利
# 3. 词频数据取自美国当代英语语料库COCA 6万词频数据，剔除重复
#    等部分，共计3.8万词条 可使用自定义词频数据，详见dict文件
#    效果预览https://github.com/sandae/epubFreq





########### 全 局 变 量################## 
#-----------------------------------
#词典文件格式为：\tWORD\tMEANING
source_dict=dict
source_list=dict_wordlist

#生成Wordlist列表
if [  ! -f dict_wordlist ];then
   cat $(eval echo "$source_dict") \
   | head -n 38000 \
   | awk '{FS="\t"}{print $2}' > dict_wordlist
fi

#-------------------------------------
workspace=epub
date=`date "+%d%H%M"`
dict_count=`sed -n '$=' $source_dict`
echo $dict_count
rm -rf epub
rm -f *.zip
mkdir -p $workspace


####脚本参数$1，有参数（书名）时转换该书，否则转换所有epub
#文件名中的空格改为@标记
if  [ ! -n "$1" ]; then
rename 's/ /@/g' *.epub
epub_files=*.epub
echo $epub_files
else
epub_files=`echo $1 | sed 's/ /@/g'`
mv "$1" "$epub_files"
fi
#---------------------------------------------------

#Word分频等级界限 level

#Elementary
e1=1 e2=1500 e3=3500 e4=7000 e5=10000 e6=14000 e7=22000
e8=30000 e9=38000 e10=46000 e11=54000 e12=62000
#e1=20011 e2=2500 e3=3000 e4=3500 e5=4000 e6=4500
#e1=2000 e2=4500 e3=6500 e4=9000 e5=12000 e6=15000

#Intermediate (角标模式下使用i等级，依据collins3-5级，避免角标过多)
i1=1500 i2=3500 i3=5000 i4=15000 i5=22000 i6=30000
echo "collins每个等级分别为1342/1388/1831/3400/8228/20581(无星)"

#Upper Intermediate
#Advance
a1=7000 a2=15000 a3=23000 a4=31000 a5=36300 a6=50000
#--------------------------------------------

#######词频显示样式model
# 角标 Subscript (1为最高频)
b1='\1¹' b2='\1²' b3='\1³' b4='\1⁴' b5='\1⁵' b6='\1⁶'

# 彩色(如果新增颜色，需要添加到剔除列表，也就是dict)
#暗色  

#d1='<a style="color:DimGray; text-decoration:none;"\1\2'
#d2='<a style="color:green; text-decoration:none;"\1\2'
#d3='<a style="color:teal; text-decoration:none;"\1\2'
#d4='<a style="color:olive; text-decoration:none;"\1\2'
#d5='<a style="color:maroon; text-decoration:none;"\1\2'
##受sed argument长度限制，d6分割为三档
#d6='<a style="color:navy; text-decoration:none;"\1\2'
#d7='<a style="color:navy; text-decoration:none;"\1\2'
#d8='<a style="color:navy; text-decoration:none;"\1\2'


d1='<a style="color:olive; text-decoration:none;"\1\2'
d2='<a style="color:maroon; text-decoration:none;"\1\2'
d3='<a style="color:navy; text-decoration:none;"\1\2'
d4='<a style="color:navy; text-decoration:none;"\1\2'
d5='<a style="color:navy; text-decoration:none;"\1\2'
#受sed argument长度限制，d6分割为多档，均为同一样式标记
d6='<a style="color:navy; text-decoration:none;"\1\2'
d7='<a style="color:navy; text-decoration:none;"\1\2'
d8='<a style="color:navy; text-decoration:none;"\1\2'
d9='<a style="color:navy; text-decoration:none;"\1\2'
d10='<a style="color:navy; text-decoration:none;"\1\2'
d11='<a style="color:navy; text-decoration:none;"\1\2'

#d1='<a style="color:navy; text-decoration:none;"\1'
#d2='<a style="color:maroon; text-decoration:none;"\1'
#d3='<a style="color:green; text-decoration:none;"\1'
#d4='<a style="color:orange; text-decoration:none;"\1'
#d5='<a style="color:purple; text-decoration:none;"\1'
#d6='<a style="color:lime; text-decoration:none;"\1'

#c1='<font color=LimeGreen>\1\2</font>'
#c2='<font color=DodgerBlue>\1\2</font>'
#c3='<font color=red>\1\2</font>'
#c4='<font color=orange>\1\2</font>'
#c5='<font color=fuchsia>\1\2</font>'
#c6='<font color=navy>\1\2</font>'
#c7='<font color=navy>\1\2</font>'
#c8='<font color=navy>\1\2</font>'


c1='<font color="dimgray">\1\2</font>'
c2='<font color="green">\1\2</font>'
c3='<font color="teal">\1\2</font>'
c4='<font color="olive">\1\2</font>'
c5='<font color="maroon">\1\2</font>'
c6='<font color="navy">\1\2</font>'
c7='<font color="navy">\1\2</font>'
c8='<font color="navy">\1\2</font>'
c9='<font color="navy">\1\2</font>'
c10='<font color="navy">\1\2</font>'
c11='<font color="navy">\1\2</font>'
c12='<font color="navy">\1\2</font>'


#亮色 LimeGreen DodgerBlue red orange fuchsia lime
# 暗色 navy maroon green teal  purple
#颜色搭配参考：
# https://sobac.com/sobac/colors.htm
#http://www.shouce.ren/api/html/html4/appendix-color.html
############## 全 局 变 量 ###############



#以上变量部分可单独一个文件，用source读取     
#source var.sh



pre(){
##预处理epub文件######################

#修改epub文件后缀为zip并解压到workspace目录下
for epub_file in $epub_files
do
   cp  $epub_file ${epub_file%.epub}.zip
done

    for epub_zip in *.zip
    do
        FILENAME=$(echo $epub_zip|cut -d'.' -f1)
        unzip -q $epub_zip -d $workspace/$FILENAME
    done


#---------------------------------------------
#提取所有要处理的html或xhtml文件


html(){ 
for html in $(find epub -maxdepth 10 -type f -name "*.*html");do
#for i in 'epub/*/*/*.*html' 'epub/*/*.*html' ;do
        html_word=$(sed -e "s/>/>\n/g" -e "s/</\n</g" $html \
	| sed "/</d" | wc -w) 

####过滤包含小于特定word数量的html文件

    if [ $html_word -lt 1000 ];then
        if [ "${html##*.}" = "html" ]; then
        mv "$html" "${html%.html}.htmlB"
        elif [ "${html##*.}" = "xhtml" ]; then
        mv "$html" "${html%.xhtml}.xhtmlB"
        fi
    fi
done
}
HTML=$(html)

#--------------------------------------------

htmlbig(){ #经过字数筛选的*html文件
for htmlbig in $(find epub -maxdepth 10 -type f -name "*.*html");do
    echo "$htmlbig"
done
}
#--------------------------------------------
html_big=$(htmlbig)
}
##################预处理结束###############################


prefilter(){
################提取需要排除的word#####################
#每次转换从html文件提取<标签内>文字（用来后边从dict中剔除不添加标记）
filter_html_code=`sed -r -e "s/>/>\n/g" -e "s/</\n</g" $html_big \
      | sed -n "/</p" \
      | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
      | sed "/\W/d" \
      | tr -d 0-9 \
      | sed "/^$/d" \
      | awk '!x[$0]++'`

#Wordlist提取前2000高频单词（需剔除）
list2000=$(head -n 1500 $source_list)$'\n' #结尾回车
#合并前词典列表前2000和<code>文字作为剔除列表
filter_list=$list2000$filter_html_code 

#删除连续空格和空行|Word前后加@Word@|换行符改为分割符"|"|删除末尾"|"
filtrate=`echo "$filter_list" \
        | sed -r -e 's/\s+//g' -e '/^$/d' \
        | awk '{if($0 ~ "[a-zA-Z]+") \
               {print "@"$0"@"}else{print}}' \
        | tr '\n' '|' \
        | sed 's/|$//'`

#----------------------------------------------------
echo "pre过滤列表已生成"
echo "开始剔除html标签内词汇和前2000高频词........"

####根据以上生成的剔除列表从词典word列表中删除
#给词典word列表加@标记@ | 剔除filtrate中的word
word_list=`cat $(eval echo "$source_list") \
        | sed -e 's/^/@/g' -e 's/$/@/g' \
        | sed -r "s#($filtrate)#\1AAAA#g" \
        | sed 's/@//g' | sed '/AAAA/d'`

###根据以上生成的剔除列表从词典文件中删除相应条目
#词典添加\t@\t标记 | 把filtrate从词典中剔除 | 删除标记
word_dict=`cat $(eval echo "$source_dict") \
        | sed -r 's/\t/@\t@/g' \
        | sed -r "s#($filtrate)#\1\tAAAA#g" \
        | sed '/AAAA/d' | sed "/^$/d"`
echo "开始添加词频标记........"
}
#################### 过 滤 与 剔 除 完 成 ##########################


postzip(){
############## 打 包 复 原 ###############################
for html_b in $(find epub -maxdepth 10 -type f -name "*.*mlB")
do
        if [ "${html_b##*.}" = "htmlB" ]; then
        mv "$html_b" "${html_b%.htmlB}.html"
        elif [ "${html_b##*.}" = "xhtmlB" ]; then
        mv "$html_b" "${html_b%.xhtmlB}.xhtml"
        fi
done

mkdir -p Result && cd $workspace

#批量压缩单个epub电子书
for i in `find ./* -type d`;do zip -q $i.zip `find $i \
| grep -v "$i$"`;done
rename 's/%#/ /g' *.zip 
rename 's/@/ /g' *.zip

#添加识别前缀
for f in *.zip ; do 
    mv -f "$f" ../Result/"$(echo $level$model$add_note \
	| tr 'a-z' 'A-Z')$date-${f%.zip}.epub"
done

cd ../
rename 's/%#/ /g' *.epub
rename 's/@/ /g' *.epub
rm -f *.zip 

echo "##############################################"
echo "#                 转换完成!                   #"
echo "###############################################"

}



initial_tag(){
#给首字母大写word添加识别标记#%
sed -ri 's/(\b[A-Z])/#%\1/g' $html_big
}

#######################  主  函  数  ###############################
convert_main(){

#convert_main函数的三个参数
level=$1 model=$2 add_note=$3

#-----------------------------------------------------------------
#根据选定的Level等级提取相应等级的word范围
    #$level_num为相应模式的等级数量

    # \$$level$[ n+1 ]获取顶部相应Level的分级，如level_num=6则此处值为e7
    for n in $( eval echo {$(($level_num-1))..1});do
    #list_N为相应等级的word列表 head -n j6 | tail -n j5，以此类推
    list_N=$(echo "$word_list" \
        | head - -n$(eval echo \$$level$[ n+1 ]) \
        | tail -n$[ $(eval echo \$$level$[ n+1 ]) - $(eval echo \$$level$n) ])

#---------------------------------------------------------------
#逐级预处理
    #添加边界符\bword\b| | 删除连续空格和空行 | 删除末尾“|”
    exp=`echo "$list_N" \
      | sed -r -e 's/\s+//g' -e '/^$/d' \
      | awk '{if($0 ~ "\\\w+"){print "\\\b"$0"\\\b"}else{print}}' \
      | tr '\n' '|' \
      | sed 's/|$//'`

#根据ListN和词频样式Model逐级为html文件添加标记，循环结束; i忽略大小写
sed -r -i "s#($exp)([\,\.\"]+)*#$(eval echo \$$model$n)#gi" $html_big


    done
echo "添加词频标记完成，开始添加脚注前检索匹配"
##################################################################


foot_insert(){
echo "开始添加注释......"
echo -e "\e[34m 由于需要大量遍历，添加注释耗时较长\e[0m"
echo -e "\e[34m 500KB左右的电子书添加注释需要约10分钟，不添加注释只需1分钟\e[0m"
#添加footnote（词典释义）

#切换python脚本替换模式，临时解决办法，最好本脚本能用python重写
if [ $model = d ]&&[ $add_note = y ];then
     sed -ri -e '61,62s/^[^#]/#/g' -e '63s/^#+/ /g' dic9.py
elif [ $model = c ]&&[ $add_note = n ];then
    sed -ri -e '61s/^[^#]/#/g' -e '63s/^[^#]/#/g' -e '62s/^#+/ /g' dic9.py
elif [ $model = b -a $add_note = n ]|| \
     [ $model = b -a $add_note = y ];then
    sed -r -i -e '61s/^#+/ /g' -e '62,63s/^[^#]/#/g' dic9.py
fi


#---------------------------------------
###插入释义
#根据过滤后的词典文件相应等级范围的条目逐级添加释义到html文件的<body>部分</body>
    echo "$word_dict" | head - -n $(eval echo \$${level}$level_num) \
    | tail -n $[ $(eval echo \$${level}$level_num) - $(eval echo \$${level}1) ] \
    | sed 's/@//g' > dictlist

    python -c 'import dic9;print dic9.DReplace("dictlist","'$workspace'")'



}

clear_tag(){
#添加footnote的python部分会将首字母大写替换为词典中的小写，
#故此处需要通过额外标记复原大写，额外增加了计算量

#添加脚注被误改的首字母恢复大写
#sed -ri 's/#%(<[^>]*>)([a-z])/\1\u\2/g' $html_big
sed -ri 's/#%(<[^>]*>)*(\b[a-z])/\1\u\2/g' $html_big
#清除#%word标记并恢复首字母大写
sed -ri 's/#%(\w)/\u\1/g' $html_big
#清除其余#%标记
sed -ri 's/#%//g' $html_big
#sed -r 's/@%#%([a-zA-Z]+)/\U\1/g' $html_big
#恢复全大写WORD失败
#sed -ri 's/@%(\w+)/\U\1/g' $html_big

}

clear_left(){
#此处匹配python替换过sed未替换的word，删除多余标签代码
sed -ri 's/([^"]|[^;]"|[^e]:") epub[^>]*>((\w+[ -]*){1,3})([.,:"]*)(<\/a>)*/\1\2\4/g' $html_big
#sed -ri 's/<a style="color:\w+; text-decoration:none;"([^ ])/\1/g' $html_big
sed -ri 's/<a style="color:\w+; text-decoration:none;"([^ ]| [^e])/\1/g' $html_big
}


rep_sub(){ #选择Model b且添加footnote时，最后转换 ⁿN 标记为[⁰¹²³⁴⁵⁶⁷⁸⁹]
    sed -i "s/ⁿ<\/a>\([⁰¹²³⁴⁵⁶⁷⁸⁹]\+\)/\1<\/a>/g" $html_big
    sed -i "s/ⁿ<\/a>/<\/a>/g" $html_big
}
#------------------------------------------------------
#判断是否添加footnote并执行。(仅在样式为black或color且addnote为y时添加释义)
    if [ $add_note = y ]&&[ $model = b ];then
        foot_insert
        rep_sub
    elif [ $add_note = y ]&&[ $model = d ];then
echo "test"
        foot_insert
        clear_tag
        clear_left
    fi

#打包收尾

}



#by:convert,foot,sub,
#bn:convert sub
#cy:convert,foot,clean
#cn:convert



################### 交 互 选 择 #########################
#输入/选择等级与样式
echo -e "\e[34m  _ _ _ _ _ _ _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _ \e[0m "
echo -e "\e[34m |                  _      __                 |\e[0m "
echo -e "\e[34m |  ___ _ __  _   _| |__  / _|_ __ ___  __ _  |\e[0m "
echo -e "\e[34m | / _ \ '_ \| | | | '_ \| |_| '__/ _ \/ _  | |\e[0m "
echo -e "\e[34m ||  __/ |_) | |_| | |_) |  _| | |  __/ (_| | |\e[0m "
echo -e "\e[34m | \___| .__/ \__,_|_.__/|_| |_|  \___|\__, | |\e[0m "
echo -e "\e[34m |     |_|                                |_| |\e[0m "
echo -e "\e[34m | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _|\e[0m "
echo -e "\e[34m   \e[0m "
echo -e "\e[34m * 本脚本用来为epub电子书添加词频标记和内置释义 \e[0m "
echo -e "\e[34m   可以选择多种模式，或在脚本内自定义 \e[0m "
echo -e "\e[34m * 建议使用默认的彩色字体词频标记+分段注释模式 \e[0m "
echo -e "\e[34m   前8000（可自定）单词只添加标记，方便用第三方词典查词和学习 \e[0m "
echo -e "\e[34m   8000以后单词添加内置释义，阅读时不需要查词典，更加便利 \e[0m "
echo -e "\e[34m * 词频数据取自美国当代英语语料库COCA 6万词频数据，剔除重复 \e[0m "
echo -e "\e[34m   等部分，共计3.8万词条 可使用自定义词频数据，详见dict文件\e[0m "
echo -e "\e[34m * 效果预览https://github.com/sandae/epubFreq \e[0m "
echo -e "\e[34m   \e[0m "
echo -e "\e[34m   \e[0m "
    echo -e "\e[34m请选择词频标记样式\e[0m "
    echo -e "\e[34m 1 高频纯彩色字体标记+低频标记+释义（默认）\e[0m "
    echo -e "\e[34m 2 彩色字体标记+释义\e[0m "
    echo -e "\e[34m 3 角标¹²³⁴⁵标记+释义\e[0m "
    echo -e "\e[34m 4 彩色字体标记\e[0m "
    echo -e "\e[34m 5 角标¹²³⁴⁵标记\e[0m "
    echo -e "\e[34m 6 自定义模式\e[0m "
    echo -e "\e[34m   \e[0m "
    echo -n "请输入编号1～6.（Default:1）"
    read -t 60 select 
#   echo "[a]utomatic or [m]anual? (default=a):"
    select=${select:=1}

#选择2345模式时选择词频等级数量
if [ "$select" = 2 ]||[ "$select" = 3 ]||[ "$select" = 4 ]||[ "$select" = 5 ];then
echo -e "\e[34m请输入词频等级数量或回车(建议5-8,默认5):\e[0m "
    read -t 20 number
    number=${number:=5}
    level_num=$(($number+1))
fi

if [ $select = 1 ];then
    pre
    htmlbig
    prefilter
    level_num=4
    convert_main e c n
    initial_tag
    level_num=5
    convert_main a d y
    postzip
elif [ $select = 2 ];then
    pre
    htmlbig
    prefilter
    initial_tag
    convert_main e d y #自动模式默认组合
    postzip
elif [ $select = 3 ];then
    pre
    htmlbig
    prefilter
    convert_main i b y
    postzip
elif [ $select = 4 ];then
    pre
    htmlbig
    prefilter
    convert_main e c n
    postzip
elif [ $select = 5 ];then
    pre
    htmlbig
    prefilter
    convert_main i b n
    postzip
elif [ $select = 6 ];then
    echo "手动模式，可选择词频等级，词频标记样式，及组合"
    echo "词频等级："
    echo -e "\e[34m 1 初级Elementary(e) $e1/$e2/$e3/$e4/$e5/$e6\e[0m"
    echo -e "\e[34m 2 中级Intermediate(i) $i1/$i2/$i3/$i4/$i5/$i6\e[0m"
    echo -e "\e[34m 3 高级Advance(a) $a1/$a2/$a3/$a4/$a5/$a6\e[0m"
    echo -e "\e[34m 4 词频范围自定义User(u)\e[0m"
    echo -n "请选择难度等级 Level(e\i\a\u):"
    read -t 30 level
#    level=${level:=e}
    echo " * * * * * * * * * "
    echo -e "\e[34m  1 角标/单色Black(b)\e[0m"
    echo -e "\e[34m  2 彩色Color(c)\e[0m"
    echo -e "\e[34m  3 彩色+内置释义(d)\e[0m"
    echo -n "请选择词频标记样式 Please select model(b\c\g)："
    read -t 30 model
#    model=${model:=b}
    echo " * * * * * * * * * "
    echo -n "是否添加释义？ Do you want add footnote?([y]es/[n]o):"
    read -t 30 add_note
    echo " * * * * * * * * * "
#根据所选条件调用函数执行转换
    if [ $level = u ];then
        echo "词频自定义模式"
    echo "# 全局默认词频等级为5个级别，如需自定义等级数量需修改脚本。"
    echo "# 参考数据：科林斯词典选取最高频的35181词,分为五个词频等级"
    echo "  每个等级分别为1342/1388/1831/3400/8228/20581(无星)"
    echo "  请输入第一级词汇起始位置，注意：前2000高频词已剔除!"
    echo "请从1～$dict_count选择输入:"
        #该循环用于自定义输入词频等级分界
        for i in {1..11}
        do
            if [[ $i -gt 5 ]];then
        echo "是否继续添加等级,按回车继续，输入[n]o终止:"
        read yn
                if [[ $yn = n ]];then
                level_num=$i
                echo "$level_num"
                    break
                fi
            fi
        echo "请输入第$i级词汇开始位置:"
        read "u$i"
        done
    echo "您选择的是$level,$model,$add_note"
#    echo "您选择的词频范围为: $u1/$u2/$u3/$u4/$u5/$u6"
    read -p "请回车确认或重新运行脚本选择：([y]es/[n]o default:y )"
    echo "开始以自定义模式转换........."
          pre
          htmlbig
          prefilter
          convert_main $level $model $add_note
          postzip
    elif [ $level != u ];then
echo -e "\e[34m请输入词频等级数量或回车(建议5-8,默认5):\e[0m "
    read -t 20 number
    number=${number:=5}
    level_num=$(($number+1))
        pre
        htmlbig
        prefilter
        convert_main $level $model $add_note
        postzip


    fi
       
fi
