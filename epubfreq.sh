#!/usr/bin/sh
#set -x
#```````````````` \e[0m

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
#词典文件格式为：\tWORD\tMEANING
source_dict=dict
source_list=dict_list
topn=1500 #剔除的top N高频词数量

#生成Word列表
#如果dict_list不存在则从dict中提取
echo "$source_list"
if [  ! -f $source_list ];then
   cat "$(eval echo "$source_dict")" \
   | head -n 38000 \
   | awk '{FS="\t"}{print $2}' > $source_list
fi

#-------------------------------------
workspace=epub
date=$(date "+%d%H%M")
dict_count=$(sed -n '$=' $source_dict)
echo "$dict_count"
rm -rf epub
rm -f ./*.zip
mkdir -p $workspace

#````````````````

####脚本参数$1，有参数（书名）时转换该书，否则转换所有epub
#如果没有参数，此处将所有epub文件名中的空格改为@标记

if  [ ! -n "$1" ]; then
rename 's/ /-/g' ./*.epub
epub_files=*.epub
else
for i in "$@";do #$@必须加引号，否则带空格文件名会被识别为多个字符串
#把循环中对单个变量计算的结果拼接成一个变量
epub_files="$epub_files "$(echo "$i" | sed 's/ /-/g')"" #如有参数，单独删除空格
rename 's/ /-/g' "$i" #必须加引号，否则带空格文件名会被识别为多个字符串
done
fi

#---------------------------------------------------
#搜索content.opf文件，以变添加html页面相应信息
content_opf=$(find ./"$workspace" -maxdepth 2 -type f -name "*.opf")

#要在content.opf文件添加的行，注意id的格式，很容易写错，id可随机，
#大于第一个页面的id号即可，2333为随机教大数，可改。manifest和spine两处都必须添加
add_manifest='<item href="freq_info.html" id="id2333" media-type="application/xhtml+xml"/>'
add_spine='<itemref idref="id2333"/>'
#------------------------------------------------------------------------------
#Word分频等级界限 level
#Elementary
e1=1 e2=1500 e3=3500 e4=8000 e5=16000 e6=24000 e7=30000
e8=30000 e9=38000 e10=46000 e11=54000 e12=62000 # 演示


#Intermediate (角标模式下使用i等级，依据collins3-5级，避免角标过多)
#collins每个等级分别为1342/1388/1831/3400/8228/20581(无星)
i1=1500 i2=3500 i3=4500 i4=6000 i5=9000 i6=12000 i7=15000

#Advance
#a1=7000 a2=13000 a3=21000 a4=29000 a5=36300 a6=50000 #演示
a1=4500 a2=6000 a3=14000 a4=22000 a5=30000 a6=36000 #自用

#------------------------------------------------------------------------------

#词频显示样式 model

# 角标 Subscript (1为最高频)
b1='\1¹' b2='\1²' b3='\1³' b4='\1⁴' b5='\1⁵' b6='\1⁶' b7='\1⁷'

# 彩色(如果新增颜色，需要添加到剔除列表:dict)
#暗色  
l1c=dimgray l2c=green l3c=teal l4c=olive l5c=maroon l6c=navy

#c1='<font color="dimgray">\1\2</font>'
c1="<font color=\""$l1c"\">\1\2</font>"
c2="<font color=\""$l2c"\">\1\2</font>"
c3="<font color=\""$l3c"\">\1\2</font>"
c4="<font color=\""$l4c"\">\1\2</font>"
c5="<font color=\""$l5c"\">\1\2</font>"
c6="<font color=\""$l6c"\">\1\2</font>"
c7="<font color=\""$l7c"\">\1\2</font>"
c8="<font color=\""$l8c"\">\1\2</font>"
c9="<font color=\""$l9c"\">\1\2</font>"
c10="<font color=\""$l10c"\">\1\2</font>"
c11="<font color=\""$l11c"\">\1\2</font>"
c12="<font color=\""$l12c"\">\1\2</font>"




#彩色+释义分段模式
d1="<a style=\"color:$l1c; text-decoration:none;\"\1\2"
d2="<a style=\"color:$l2c; text-decoration:none;\"\1\2"
d3="<a style=\"color:$l3c; text-decoration:none;\"\1\2"
d4="<a style=\"color:$l4c; text-decoration:none;\"\1\2"
d5="<a style=\"color:$l5c; text-decoration:none;\"\1\2"
#受sed argument长度限制，d6分割为三档 实际不需要这么多等级
d6="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
d7="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
d8="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
d9="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
d10="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
d11="<a style=\"color:$l6c; text-decoration:none;\"\1\2"

#词频释义分段模式第四级以后样式
#f1="<a style=\"color:olive; text-decoration:none;\"\1\2"
f1="<a style=\"color:$l4c; text-decoration:none;\"\1\2"
f2="<a style=\"color:$l5c; text-decoration:none;\"\1\2"
f3="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
f4="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
f5="<a style=\"color:$l6c; text-decoration:none;\"\1\2"
#------------------------------------------------------------------------------
#暗深红色	crimson
# 亮色 blue red fuchsia lime aqua yellow
# 暗色 navy maroon green teal  purple
# https://sobac.com/sobac/colors.htm
#http://www.shouce.ren/api/html/html4/appendix-color.html
################################# 全 局 变 量 结 束 #############################




echo "---------------------------------"
pre(){
################################ 预 处 理 epub 文件 ############################

#修改epub文件后缀为zip并解压到workspace目录下
for epub_file in $epub_files
do
   cp  "$epub_file" "${epub_file%.epub}".zip

done


#批量解压缩到workspace目录下
    for epub_zip in *.zip
    do
        FILENAME=$(echo ${epub_zip%\.*})
        unzip -q "$epub_zip" -d "$workspace"/"$FILENAME" 
#------------------------------------------------------------------------------

echo "统计字数"
echo "**********************"
echo "正在处理:$fn"
#统计字数
for fn in $(echo "$FILENAME");do 
htmlfile="$(find $workspace/$fn -maxdepth 10 -type f -name "*.*html")"



echo "提取所有html文字并列表"
for f in $htmlfile;do
text_count_pre=`sed -r -e "s/>/>\n/g" -e "s/</\n</g" $f \
      | sed -n "/</!p" \
      | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
      | sed "/\W/d" \
      | tr -d 0-9 \
      | sed "/^$/d" \
      | sort`
echo "$text_count_pre" >> $workspace/$fn/all_text
done

echo "html列表排序去重复写入文件"
html_list=`cat $workspace/$fn/all_text  \
      | sed -r 's/([A-Z])/\l\1/g' | sort | uniq -i`
#echo "$html_list" > textDEL44

toplist=$(head -n 1500 dict_wordlist)

echo "toplist预处理加标记"
    topexp=`echo "$toplist" \
      | sed -r -e 's/\s+//g' -e '/^$/d' \
      | awk '{if($0 ~ "\\\w+"){print "\\\b"$0"\\\b"}else{print}}' \
      | tr '\n' '|' \
      | sed 's/|$//'`
echo "toplist统计"
#给html文件中的top列表文字做标记@X|打印@X标记行|排列|去重|统计行数
word_topnu=$(echo "$html_list" | sed -r "s/($topexp)/\1@X/g" | sed -n '/@X/p' \
| sort | uniq -i | wc -l)

##文字总数 #词汇量 #不重复词汇数 写入相应目录wcount文件
cat $workspace/"$fn"/all_text | wc -l >> $workspace/"$fn"/wcount
cat $workspace/"$fn"/all_text |sort| uniq -i | wc -l >> $workspace/"$fn"/wcount
cat $workspace/"$fn"/all_text | sort | uniq -u | wc -l >> $workspace/"$fn"/wcount
echo "$word_topnu" >> $workspace/"$fn"/wcount

#--------------------------------------------------------------------
echo "生成html页面"
#生成html页面
html_add(){
if_note="(内置释义)"

cat >> $workspace/"$fn"/freq_info.html <<EOF
<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title>Ebook Word Frequency Tag</title>
</head>
  <body>
<p><font size="+1">Ebook Word Frequency Tag</font><br /><font size="-2">\
本书已添加词频标记和内置释义</font></p>

EOF

#插入piechart图片
echo "
<img src=\"piechart.png\" alt=\"count_info\" width=\"auto\" height=\"auto\">" \
>> $workspace/"$fn"/freq_info.html

cat >> $workspace/"$fn"/freq_info.html <<EOF
<p><font size="-1">* 本书已在Android版静读天下MoonReader\
(<a href=\"https://www.coolapk.com/apk/com.flyersoft.moonreaderp">酷市场\
</a>/<a href=\"https://play.google.com/store/apps/details?id=com.flyersoft.moonreader">\
Google Play</a>)、PC版<a href=\"https://calibre-ebook.com\">Calibre</a>、\
iOS的iBooks测试正常。<br \>&#160;&#160;&#160;由于各个阅读器对epub3.0标准兼容程度\
差异巨大，不同阅读器可能显示效果会有问题甚至无法正常阅读(已知<b>掌阅iReader</b>无法\
正常打开，提示书籍损坏,推荐使用兼容性好的主流阅读器<b>静读天下MoonReader</b></p>

<p><font size="-1">* 释义取自简明英汉词典,词频数据来自美国当代语料库COCA 6万词\
频列表,经过去重复等处理，共计3.9万词条。<br /> （参考数据：科林斯词典选取最高频的\
35181词,分为五个词频等级每个等级分别为1342/1388/1831/3400/8228/20581(无星),其\
中第1个等级1342词覆盖所有英语文本的75%，前5个等级共14600词覆盖所有英语文本的95%</font></p>
<p><font size="-1">* 由于网络上epub电子书可能存在排版格式混乱、网友转制等复杂情况，\
不排除可能存在样式或者文字异常情\况，可购买正版电子书或寻找排版良好的版本重新制作\
（见本页末尾）。</font></p>
EOF

echo "<p><font size="-1"></font></p>
<p><font size=\"-1\">本书使用epubFreq制作<br /> \
如需自定义词频等级和样式可联系作者协助制作，把要制作的epub电子书文件作为附件，\
并在邮件里注明：<br />
*在哪个网站获得你看到的这本书或这篇文章<br />
*大致英语水平（如高中，CET4/6,雅思）<br />
*词汇量（可以花5分钟时间在线测试：testyourvocab.com）<br />\
*希望标注的6个词频等级数量，例如1500/3500/7000/15000（可选前x个等级不加释义仅加标记）<br />\
Email:<a href=\"mailto:epubfreq@outlook.com\">epubfreq@outlook.com</a>\
</font></p>" >> $workspace/"$fn"/freq_info.html
echo "</body></html>" >> $workspace/"$fn"/freq_info.html
}

html_add

done
    done

echo "提取html文件"
#------------------------------------------------------------------------------
#函数 提取所有要处理的html或xhtml文件
#所有*html文件，包括小文件，仅做打包使用
html(){ 
for html in $(find $workspace -maxdepth 10 -type f -name "*.*html");do
#for i in 'epub/*/*/*.*html' 'epub/*/*.*html' ;do
        html_word=$(sed -e "s/>/>\n/g" -e "s/</\n</g" $html \
	| sed "/</d" | wc -w) 

####过滤包含小于特定word数量的html文件
####查找html/xhtml文件
#如果word数量小于1000则将文件改名
    if [ $html_word -lt 100 ];then
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
html_big=$(find $workspace -maxdepth 10 -type f -name "*.*html")
#echo "$html_big"
}
echo "pre结束"
################################# 预 处 理 结 束 ###################################


prefilter(){
echo "---------------------------------------"
echo "prefilter"
echo "提取html code"
################提取需要排除的word#####################
#每次转换从html文件提取代码文字（需剔除）
#尖括号换行|word换行|删非文字|删数字|删空行|去重|首字母小写
#列表单词收尾加@标记（@word@）
#echo $HTML
html_code=`sed -r -e "s/>/>\n/g" -e "s/</\n</g" $html_big \
      | sed -n "/</p" \
      | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
      | sed "/\W/d" \
      | tr -d 0-9 \
      | sed "/^$/d" \
      | awk '!x[$0]++' \
      | sed -r 's/([A-Z])/\l\1/g'`



##Wordlist提取前2000单词（需剔除）
top_list=$(head -n $topn $source_list)$'\n' #结尾回车
#合并前词典列表前2000和<code>文字作为剔除列表
filter_list=$top_list$html_code
echo "生成剔除列表预处理变量"
#删除连续空格和空行|Word前后加@Word@|换行符改为分割符"|"|删除末尾"|"
filtrate=`echo "$filter_list" \
        | sed -r -e 's/\s+//g' -e '/^$/d' \
        | awk '{if($0 ~ "[a-zA-Z]+") \
               {print "@"$0"@"}else{print}}' \
        | tr '\n' '|' \
        | sed 's/|$//'`

#----------------------------------------------------
echo "pre过滤列表已生成"
echo "剔除html标签和Top$topn高频词..."

####根据以上生成的剔除列表从词典word列表中删除
#给词典word列表加@标记@ | 剔除filtrate中的word
echo "从列表中删除剔除列表"
word_list=`cat $(eval echo "$source_list") \
        | sed -e 's/^/@/g' -e 's/$/@/g' \
        | sed -r "s#($filtrate)#\1AAAA#g" \
        | sed 's/@//g' | sed '/AAAA/d'`

#echo "$word_list" > word_list
echo "从字典中删除剔除列表"
###根据以上生成的剔除列表从词典文件中删除相应条目
#词典添加\t@\t标记 | 把filtrate从词典中剔除 | 删除标记
word_dict=`cat $(eval echo "$source_dict") \
        | sed -r 's/\t/@\t@/g' \
        | sed -r "s#($filtrate)#\1\tAAAA#g" \
        | sed '/AAAA/d' | sed "/^$/d"`
#echo "$word_dict" > word_dict
echo "添加词频标记..."
echo "---------------------------------------"
}
########################### 过 滤 与 剔 除 完 成 ##################################



postzip(){
############################### 打 包 复 原 #######################################
#htmlB文件名复原

for html_b in $(find $workspace -maxdepth 10 -type f -name "*.*mlB")
do

    if [ "${html_b##*.}" = "htmlB" ]; then
        mv "$html_b" "${html_b%.htmlB}.html"
    elif [ "${html_b##*.}" = "xhtmlB" ]; then
        mv "$html_b" "${html_b%.xhtmlB}.xhtml"
    fi
done


#向content.opf添加html页面

for content_opf in $(find $workspace -maxdepth 5 -type f -name "*.opf")
do
#cp  -v freq_info.html ${content_opf%/*}
sed -i "/<manifest>/a$add_manifest" $content_opf
sed -i "/<spine[^>]*>/a$add_spine" $content_opf
done

#如果没有epub namespace则添加namespace。
html=$(find $workspace -maxdepth 10 -type f -name "*.*html")

epub_namespace_str="xmlns:epub=\"http:\/\/www.idpf.org\/2007\/ops\">"
for html_file in $html
do
    find_epub_namespace=$(grep 'html.*xmlns:epub' $html_file)
    if [[ ! -n $find_epub_namespace ]];then
      sed -ri "s/(<html xmlns[^>]*)>/\1 $epub_namespace_str/g" $html_file
    fi
done
###############################################################################


mkdir -p Result
cd $workspace


#批量压缩单个epub电子书，不包含电子书目录本身
for i in $(find ./ -maxdepth 1 -type d | grep -v ./$)
do

echo "显示电子书根目录"
echo "$i"
echo "开始压缩"
rm -f "$i"/wcount "$i"/all_text "$i"/listcount
zip -q $i.zip $(find $i)
rename 's/%#/ /g' *.zip
#rename 's/@/ /g' *.zip
done



#添加识别前缀
for f in *.zip ; do 
    mv -f "$f" ../Result/"$(echo $level$model$add_note \
	| tr 'a-z' 'A-Z')$date-${f%.zip}.epub"
done
cd ../

#rename 's/%#/ /g' *.epub
#rename 's/@/ /g' *.epub
rm -f *.zip 
echo "制作完成，结果已保存到Result目录"
echo "##############################################"
echo "#                 制作完成!                   #"
echo "###############################################"
}


initial_tag(){ #给首字母大写word添加识别标记#%
sed -ri 's/(\b[A-Z])/#%\1/g' $html_big
}

##################################  主  函  数  ###############################

convert_main(){
echo "---------------------------------------"
echo "convert_main"
#函数的三个参数重新命名
level=$1 model=$2 add_note=$3
echo "您选择词频标记样式为$model，词频等级为$level,是否添加注释 $add_note"


#-----------------------------------------------------------------
#根据选定的Level等级提取相应等级的word范围
    #$level_num为相应模式的等级数量，此处生成循环,echo (6..1) > 6 5 4 3 2 1
#for fn in `echo "$FILENAME"`;do 
    # \$$level$[ n+1 ]获取顶部相应Level的分级，level_num=6则该函数值为e7
#    for n in $( eval echo {$(($level_num-1))..1});do
    for n in $( eval echo {1..$(($level_num-1))});do
    #list_N为相应等级的word列表 head -n j6 | tail -n j5，以此类推
    list_N=$(echo "$word_list" \
    | head - -n$(eval echo \$$level$[ n+1 ]) \
    | tail -n$[ $(eval echo \$$level$[ n+1 ]) - $(eval echo \$$level$n) ])
#---------------------------------------------------------------
#逐级预处理
echo "**********************"
echo "逐级预处理            Level$n"
    #添加边界符\bword\b| | 删除连续空格和空行 | 删除末尾“|”
    exp=`echo "$list_N" \
      | sed -r -e 's/\s+//g' -e '/^$/d' \
      | awk '{if($0 ~ "\\\w+"){print "\\\b"$0"\\\b"}else{print}}' \
      | tr '\n' '|' \
      | sed 's/|$//'`

#根据ListN和词频样式Model逐级为html文件添加标记，循环结束; i忽略大小写
echo "添加词频标记"
#==============================================================================
sed -r -i "s#($exp)([\,\.\"]+)*#$(eval echo \$$model$n)#gi" $html_big
#sed -r -i "s#($exp)([\,\.\"]+)*#$(eval echo \${$model[$(($n-1))]})#gi" $html_big
#==============================================================================

LNcount(){
echo "本级词汇数统计"
#====插入===利用分割出来的各等级列表预处理变量exp统计各等级词汇数====================
for fn in `ls "$workspace"`;do
listcount=$(cat $workspace/$fn/all_text | sed -r "s/($exp)/\1@X/g" \
| sed -n '/@X/p' | sort | uniq -i | wc -l)
echo "$listcount" >> $workspace/"$fn"/listcount
done
}
LNcount
#========================================================================

done #levelN循环


###############################################################################

foot_insert(){
echo "echo ---------------------------------------"
echo "添加注释......"
echo -e "\e[34m 由于需要大量遍历，添加注释耗时较长\e[0m"
echo -e "\e[34m 500KB左右的电子书添加注释需要约10分钟，不添加注释仅需少于1分钟\e[0m"
#添加footnote（词典释义）
#切换python脚本替换模式
if [ $add_note = y ]&&[ $model = d ]||[ $model = f ];then
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
#注意：分段模式中由于词频和注释两个操作中取词范围有差别（剔除的1500左右），所以
#     总词条数目应该减去1500,如词典3.8W，实际应按3.65W计算
echo "$word_dict" | head - -n $(eval echo \$${level}$level_num) \
| tail -n $[ $(eval echo \$${level}$level_num) - $(eval echo \$${level}1) ] \
| sed 's/@//g' > dictlist

python -c 'import dic9;print dic9.DReplace("dictlist","'$workspace'")'
}

#---------------------------------------------------
clear_tag(){
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
#---------------------------------------------------
clear_left(){
#此处匹配python替换过sed未替换的word，删除多余标签代码
epub_type_str="epub:type=\"n[^>]*>((\w+[ -]*){1,3})([.,:\"]*)(<\/a>)*"
sed -ri "s/([^\"]|[^;]\"|[^e]:\") $epub_type_str/\1\2\4/g" $html_big
color_str="<a style=\"color:\w+; text-decoration:none;\"([^ ]| [^e])"
sed -ri "s/$color_str/\1/g" $html_big
}

#---------------------------------------------------
rep_sub(){ #选择Model b且添加footnote时，最后转换 ⁿN 标记为[⁰¹²³⁴⁵⁶⁷⁸⁹]
    sed -i "s/ⁿ<\/a>\([⁰¹²³⁴⁵⁶⁷⁸⁹]\+\)/\1<\/a>/g" $html_big
    sed -i "s/ⁿ<\/a>/<\/a>/g" $html_big
}
#------------------------------------------------------
#判断是否添加footnote并执行。(仅在样式为black或color且addnote为y时添加释义)
    if [ $add_note = y ]&&[ $model = b ];then
        foot_insert
        rep_sub
#    elif [ $add_note = n ]&&[ $model = b ];then
#        foot_insert
#        rep_sub
    elif [ $add_note = n ]&&[ $model = b ];then
         echo "B model no footnote"
    elif [ $add_note = y ]&&[ $model = d ];then
        foot_insert
        clear_tag
        clear_left
    elif [ $add_note = y ]&&[ $model = f ];then
        foot_insert
        clear_tag
        clear_left
    fi

}
echo "convert_main函数结束"
########################################################################################


freqinfo(){
#!/usr/bin/sh
#set -x
echo "---------------------------------------"
echo "freqinfo"

#comment(){#按标记样式关键词统计分级数量，已被listN统计替代
for fn in `ls "$workspace"`;do


#--------------------根据以上数据生成piechart统计图标-----------------------------

#词频信息统计列表（无数据）的变量，作为gnuplot图例文字
if [ $select = 1 ];then
#分段模式中分别为第一部分无释义三个等级和第二部分四个等级分别设置等级标记H，T
#如果更改两个分段各自的等级数量需要注意调整
#在相应level等级上加了topN高频词数量
#style0="Level0 0-1500" #piechart添加0-1500效果不好，暂时废弃
style1="Level1 ($((($(eval echo \$${levelH}1)+$topn)))-\
$((($(eval echo \$${levelH}2)+$topn))))"
style2="Level2 ($((($(eval echo \$${levelH}2)+$topn)))-\
$((($(eval echo \$${levelH}3)+$topn))))"
style3="Level3 ($((($(eval echo \$${levelH}3)+$topn)))-\
$((($(eval echo \$${levelH}4)+$topn))))"

style4="Level4 ($((($(eval echo \$${levelT}1)+$topn)))-\
$((($(eval echo \$${levelT}2)+$topn))))"
style5="Level5 ($((($(eval echo \$${levelT}2)+$topn)))-\
$((($(eval echo \$${levelT}3)+$topn))))"
style6="Level6 ($((($(eval echo \$${levelT}3)+$topn)))-\
$((($(eval echo \$${levelT}4)+$topn))))"
else
#style0="Level0 0-1500"
style1="Level1 ($((($(eval echo \$${level}1)+$topn)))-\
$((($(eval echo \$${level}2)+$topn))))"
style2="Level2 ($((($(eval echo \$${level}2)+$topn)))-\
$((($(eval echo \$${level}3)+$topn))))"
style3="Level3 ($((($(eval echo \$${level}3)+$topn)))-\
$((($(eval echo \$${level}4)+$topn))))"
style4="Level4 ($((($(eval echo \$${level}4)+$topn)))-\
$((($(eval echo \$${level}5)+$topn))))"
style5="Level5 ($((($(eval echo \$${level}5)+$topn)))-\
$((($(eval echo \$${level}6)+$topn))))"
style6="Level6 ($((($(eval echo \$${level}6)+$topn)))-\
$((($(eval echo \$${level}$level_num)+$topn))))"
fi
#}#comment

echo -e "$style1\n$style2\n$style3\n$style4\n$style5\n$style6" > list


#------------------------------------------------------------------------------
#如果指定的level数量大于6，例如select=1或$number>6,则把分级统计数量中的第六行以后相加
#第六行以后相加保存到变量
cd "$workspace"/"$fn"
level_sum=$(awk 'NR>=6 {sum=sum+=$1};END {print sum;}' listcount)
#删除第六行及以后行
awk -v n=6 'NR >= n {next} {print > "listcount"}' listcount
#把第六行及之后的和写回第六行
echo "$level_sum" >> listcount
cd ../../
#------------------------------------------------------------------------------

#合并图标标签列表和列表数据两个文件的列
paste -d "," list $workspace/"$fn"/listcount > data.txt
#将文件倒序排列 #添加任意字符的titl
sed -i '1!G;h;$!d' data.txt
#向data.txt添加title，无意义，但必须，未解决
sed -i '1i\list,listcount' data.txt
#==============================================================================

top_count(){ #已用pre中的toplist统计函数替代
#统计包含top1500高频词的数量（非每个词的出现次数） 

toplist=$(head -n 1500 $source_list)
#top列表前后加分界符\b
    topexp=`echo "$toplist" \
      | sed -r -e 's/\s+//g' -e '/^$/d' \
      | awk '{if($0 ~ "\\\w+"){print "\\\b"$0"\\\b"}else{print}}' \
      | tr '\n' '|' \
      | sed 's/|$//'`
#预处理html文件文字为一列，剔除标签，去重复，排列
html_list=`sed -r -e "s/>/>\n/g" -e "s/</\n</g" $fn_html_big \
      | sed -n "/</!p" \
      | sed -e "s/\b/\n/g" -e "s/_/\n/g" \
      | sed "/\W/d" \
      | tr -d 0-9 \
      | sed "/^$/d" \
      | awk '!x[$0]++' \
      | sed -r 's/([A-Z])/\l\1/g' | sort | uniq -i`

#给html文件中的top列表文字做标记@X|打印@X标记行|排列|去重|统计行数
word_top=$(echo "$html_list" | sed -r "s/($topexp)/\1@X/g" | sed -n '/@X/p' \
| sort | uniq -i | wc -l)
#统计数据写入相应书目录下wcount(第四行)
echo "$word_topnu" >> $workspace/"$fn"/wcount
} #top_count
#------------------------------------------------------------------------------

print_count(){
#各等级统计词汇数量相加并从总词汇数中减去得到未标记数量（非常不准确）
listN_sum=$(awk '{sum += $1};END {print sum}' $workspace/"$fn"/listcount)
echo ""$(($(awk 'NR==2' $workspace/"$fn"/wcount)"-"$listN_sum"-"$word_topnu""))\
 >> $workspace/"$fn"/wcount

#从文件读取统计数据
word_total=$(head -n 1 $workspace/"$fn"/wcount)   #总字数（以下三项取自pre函数）
word_count=$(awk 'NR==2' $workspace/"$fn"/wcount) #词汇量，不包含topword
word_norep=$(sed -n '3p' $workspace/"$fn"/wcount) #不重复词汇数
word_notag=$(sed -n '5p' $workspace/"$fn"/wcount) #未标记
word_topnu=$(sed -n '4p' $workspace/"$fn"/wcount) #top数量

#屏幕打印统计信息
echo "本书:$fn"
echo "总字数：      $word_total"
echo "总词汇量：    $word_count"
echo "不重复字数：  $word_norep"
echo "前1500单词数：$word_topnu"
echo "未标记词汇数：$word_notag"
echo "*************************************"
} #print_count
print_count

#向图标制作程序piechart.plt添加统计数据|数据从相应wcount中提取|尾部加#count标记
sed -r -i "s/#count3/set label 4 \"未包含Level0 (1-1500)数量： "$word_topnu"\" \
at graph 0.35,0.02 left font \"Arial,13\"#count4/g" piechart2.2.plt 


sed -i -r -e "s/#count1/set label 5 \"总字数 "$word_total" | \
不重复词汇数 "$word_norep" | 词汇量 "$word_count"\" \
at graph 0,-0.04 left font \"Arial,16 #count2/g" piechart2.2.plt

#==============================================================================
gnuplot piechart2.2.plt

cp piechart.png $workspace/$fn
rm list piechart.png data.txt #listcount  freqcount

#复原注释标记
sed -i -r 's/.*(#count.)/\1/g' piechart2.2.plt
sed -i -r -e 's/count2/count1/g' -e 's/count4/count3/g' piechart2.2.plt

done

} #freqinfo




################### 交 互 选 择 #########################
#输入/选择等级与样式
custom(){ #顶部定义的epub文件（epub_files）作为本函数参数，末尾参数执行后不删除epub目录
#-------------------------------------------------------------------------------
mkdir -p $workspace
echo -e "\e[34m  _ _ _ _ _ _ _ _ _ _ _ _ _ _  _ _ _ _ _ _ _ _ \e[0m "
echo -e "\e[34m |                  _      __                 |\e[0m "
echo -e "\e[34m |  ___ _ __  _   _| |__  / _|_ __ ___  __ _  |\e[0m "
echo -e "\e[34m | / _ \ '_ \| | | | '_ \| |_| '__/ _ \/ _  | |\e[0m "
echo -e "\e[34m ||  __/ |_) | |_| | |_) |  _| | |  __/ (_| | |\e[0m "
echo -e "\e[34m | \___| .__/ \__,_|_.__/|_| |_|  \___|\__, | |\e[0m "
echo -e "\e[34m |     |_|                                |_| |\e[0m "
echo -e "\e[34m | _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _|\e[0m "
echo -e "\e[34m   \e[0m "
echo -e "\e[34m **本脚本用于为epub电子书添加词频标记和内置释义 \e[0m "
echo -e "\e[34m   可以选择多种模式，或在脚本内自定义 \e[0m "
echo -e "\e[34m **建议使用默认彩色字体词频标记+分段注释模式 \e[0m "
echo -e "\e[34m   前7000（可自定）单词只添加标记，方便用第三方词典查词和学习 \e[0m "
echo -e "\e[34m   7000以后单词添加内置释义，阅读时不需要查词典，更加便利 \e[0m "
echo -e "\e[34m **词频数据取自美国当代英语语料库COCA 6万词频数据，剔除重复 \e[0m "
echo -e "\e[34m   等部分，共计3.8万词条 可使用自定义词频数据，详见dict文件\e[0m "
echo -e "\e[34m **效果预览https://github.com/sandae/epubFreq \e[0m "
echo -e "\e[31m **本工具依赖python2.x，gnuplot5.2（绘制统计图），需手动安装\e[0m "
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
if [ "$select" = 2 ]||[ "$select" = 3 ]||\
[ "$select" = 4 ]||[ "$select" = 5 ];then
echo -e "\e[34m请输入词频等级数量，回车默认6 (建议5-8):\e[0m "
    read -t 20 number
    number=${number:=6}
    level_num=$(($number+1))
fi

#函数内全局预处理-----------
    pre
    prefilter
#-------------------------

if [ $select = 1 ];then
    number=3
    number_mem=$number
    level_num=$(($number+1))
    convert_main e c n
    levelH=e
    initial_tag
    number_note=4
    level_num=$(($number_note+1))
    convert_main a f y
    levelT=a
    freqinfo
    postzip
elif [ $select = 2 ];then
    initial_tag
    convert_main e d y #自动模式默认组合
elif [ $select = 3 ];then
    convert_main i b y
elif [ $select = 4 ];then
    convert_main e c n
elif [ $select = 5 ];then
    convert_main i b n

elif [ $select = 6 ];then
    echo "手动模式，可选择词频等级，词频标记样式，及组合（未充分测试）"
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
          convert_main $level $model $add_note
    elif [ $level != u ];then
echo -e "\e[34m请输入词频等级数量或回车(建议5-8,默认5):\e[0m "
    read -t 20 number
    number=${number:=6}
    level_num=$(($number+1))
    convert_main $level $model $add_note
    freqinfo
    postzip
    fi   

#
if [[ $i == "$_" ]];then
echo "最后一个参数（epub文件）"
break
fi
echo "删除workspace"
rm -r $workspace

fi

#函数内全局执行收尾
    freqinfo
    postzip
} #custom

custom "$epub_files"
