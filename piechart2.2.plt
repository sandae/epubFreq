#!/usr/bin/gnuplot -persist 
reset 

dataname = 'data.txt' 
set datafile separator ',' 

# Get STATS_sum (sum of column 2) and STATS_records 
stats dataname u 2 noout 

# Define angles and percentages 
ang(x)=x*360.0/STATS_sum  # get angle (grades) 
perc(x)=x*100.0/STATS_sum  # get percentage 

# Set Output 
set terminal png transparent
set output "piechart.png" 
set size nosquare 
#set size ratio 0.5

set term pngcairo size 680,550 #可调节高度

# Print the Title of the Chart 
set title "\n" 
set label 1 "词频统计信息与词频标记样式" at graph 0.1,0.49 left 
                                     #标题位置 大右小左，大上小下
set label 1 "词频统计信息与词频标记样式" font "Arial,20"
#set label 1 "Word Frequency count" font "Arial,20"
#set label 2 "（本数据未包括Top1500高频词）" at graph 0.39,0.43 left 
#set label 2 "（本数据未包括Top1500高频词）" font "Arial,12" 
#set label 3 "本书词汇总数量共计5000）" at graph 0.43,0.06 left 
#set label 3 "本书词汇总数量共计5000" font "Arial,15" 

#set label 4 "未包含Top1500数量 Level0:1000" at graph 0.35,0.02 left font "Arial,15" 
#set label 4 "未包含Top1500数量 Level0:1000" font "Arial,15" 

#锚点：
#count1
#count3



#set label 5 "总字数 5360 | 不重复词汇数 1124 | 词汇量 1576 (不包括Top1500)" at graph 0,-0.04 left font "Arial,15"
#set label 5 "总字数 5360 | 不重复词汇数 1124 | 词汇量 1576 (不包括Top1500)" font "Arial,15"
#set label 6 "Created by Gnuplot" at graph 0.58,-0.08 left #右下角
set label 6 "Created by Gnuplot" at graph 0.52,0.49 left
set label 6 "Created by Gnuplot" font "Arial,11"
set border
#set size ratio 1.8
set size square 1.4,2
          #小左大右  小下大上
#set size 1,1
#位置

#set terminal wxt 
unset key 
set key off 
set xrange [-1:3.5] 
set yrange [-1.2:4.2] 
#set y [:小上大下]
#原始：-1.5:1.5 
set style fill solid 1 


unset border 
unset tics 
unset colorbox 

# some parameters 
Ai = 5.0;      # Initial angle 
mid = 4.0;     # Mid angle 

# This defines the colors yellow~FFC90E, and blue~1729A8 
#set palette defined (1 '#696969', 2 '#008000', 3 '#008080', 4 '#808000', 5 '#800000', 6 '#000080') #dimgray-navy正序
set palette defined (1 '#000080', 2 '#800000', 3 '#808000', 4 '#008080', 5 '#008000', 6 '#696969' ) #navy-dimgray 倒序
#set palette defined (1 '#000080', 2 '#800000', 3 '#808000', 4 '#008080', 5 '#008000', 6 '#696969', 7 '#FFC0CB' ) #navy-dimgray倒 7个等级
#set palette defined (1 1 0.888 0.055, 2 0.156 0.455 0.651) # format R G B (scaled to [0,1]) 
#set palette defined (1 0.588 0.588 0.588, 2 1 0.498 1, 3 1 0.498 0.498, 4 0.498 0.498 1, 5 0.498 1 1, 6 1 1 0.498) # format R G B (scaled to [0,1]) 


#备份
#plot for [i=1:STATS_records] dataname u (0):(0):(1):(Ai):(Ai=Ai+ang($2)):(i) every ::i::i with circle linecolor #palette,dataname u (mid=Ai+ang($2), Ai=2*mid-Ai, mid=mid*pi/360.0, -0.5*cos(mid)):(-0.5*sin(mid)):(sprintf('%.0f', $2, #perc($2))) every ::1 w labels center font ',12',for [i=1:STATS_records]dataname u (1.25):(i*0.11):1 every ::i::i with labels #left font 'Arial,12',for [i=1:STATS_records] '+' u (1.15):(i*0.11):(i) pt 5 ps 4 lc palette 
#备份图标最佳间隔和大小高度
#labels left font 'Arial,12',for [i=1:STATS_records] '+' u (1.15):(i*0.17)-0.6:(i) pt 5 ps 4 lc palette 

plot for [i=1:STATS_records] dataname u (0):(0):(1):(Ai):(Ai=Ai+ang($2)):(i) every ::i::i with circle linecolor palette,dataname u (mid=Ai+ang($2), Ai=2*mid-Ai, mid=mid*pi/360.0, -0.5*cos(mid)):(-0.5*sin(mid)):(sprintf('%.0f', $2, perc($2))) every ::1 w labels center font ',12',for [i=1:STATS_records]dataname u (1.25):(i*0.23)-0.8:1 every ::i::i with labels left font 'Arial,14',for [i=1:STATS_records] '+' u (1.15):(i*0.23)-0.8:(i) pt 5 ps 4 lc palette 

#图例高度需要同时改-0.8此处:1 every和(i*0.23)-0.8此处:(i) pt 5 | 
#6级：0.8 
#7级：0.9 
#8级：1 
#9级：1.1 

# 倒数第二 for [i=1:STATS_records]dataname u (1.25图例文字水平位置):(i*0.11图例文字行距)-0.4文字高度:1 every ::i::i
# 最后一行 u (1.3图例图标水平位置，小左大右):(i*0.10图例图标图块高度，间隔 小低大高 默认1.4)-0.4图标高度，可跨中点（i） pt 5图例图标样式 ps 4图标宽度

#图例正常 https://stackoverflow.com/questions/36968063/gnuplot-pie-chart-placing-labels-on-left-cant-see-them-all
#plot for [i=1:STATS_records] '2008-2015procent_pie.csv' u (0):(0):(1):(Ai):(Ai=Ai+ang($2)):(i) every ::i::i with circle #linecolor palette,\
#     '2008-2015procent_pie.csv' u (mid=(Ai+ang($2)), Ai=2*mid-Ai, mid=mid*pi/360.0, -0.5*cos(mid)):(-0.5*sin(mid)):#(sprintf('%.1f\%', $2, perc($2))) every ::1 w labels center font ',10',\
  #   for [i=1:STATS_records] '2008-2015procent_pie.csv' u (1.45):(i*0.25)-1.9:1 every ::i::i with labels left,\
  #   for [i=1:STATS_records] '+' u (1.3):(i*0.25)-1.9:(i) pt 5 ps 4 lc palette






# plot for [i=1:STATS_records] dataname u (0):(0):(1):(Ai):(Ai=Ai+ang($2)):(i) every ::i::i with circle linecolor palette,dataname u (mid=(Ai+ang($2)), Ai=2*mid-Ai, mid=mid*pi/360.0, -0.5*cos(mid)):(-0.5*sin(mid)):(sprintf('%.2f\%', $2, perc($2))) w labels center font ',16',for [i=1:STATS_records]dataname u (1.45):(i*0.15):1 every ::i::i with labels left font 'Arial-Bold,10',for [i=1:STATS_records] '+' u (1.3):(i*0.14):(i) pt 5 ps 4 linecolor palette 


# https://stackoverflow.com/questions/31896718/generation-of-pie-chart-using-gnuplot
#Ai = 0.0; Bi = 0.0;             # init angle
#mid = 0.0;                      # mid angle
#i = 0; j = 0;                   # color
#yi  = 0.0; yi2 = 0.0;           # label position

#plot 'data.txt' u (0):(0):(1):(Ai):(Ai=Ai+ang($2)):(i=i+1) with circle linecolor var,\
#     'data.txt' u (1.5):(yi=yi+0.5/STATS_records):($1) w labels,\
#     'data.txt' u (1.3):(yi2=yi2+0.5/STATS_records):(j=j+1) w p pt 5 ps 2 linecolor var,\
#     'data.txt' u (mid=Bi+ang($2)*pi/360.0, Bi=2.0*mid-Bi, 0.5*cos(mid)):(0.5*sin(mid)):(sprintf('%.0f (%.1f\%)', $2, #perc($2))) w labels


#plot 'myfile.csv' u (mid=Ai+ang($2), Ai=2*mid-Ai, mid=mid*pi/360.0, -0.5*cos(mid)):(-0.5*sin(mid)):(sprintf('%.2f\%', $2, perc($2))) every ::1 w labels center font ',10'



# *************************************************** +--------------------   shape code= 
#  for [i=1:STATS_records] '+' u (1.3):(i*0.25):(i) pt 8 ps 4 linecolor palette   # empty triangle 
#  for [i=1:STATS_records] '+' u (1.3):(i*0.25):(i) pt 9 ps 4 linecolor palette   # solid triangle 
#  for [i=1:STATS_records] '+' u (1.3):(i*0.25):(i) pt 7 ps 4 linecolor palette   # solid circle 
#  for [i=1:STATS_records] '+' u (1.3):(i*0.25):(i) pt 6 ps 4 linecolor palette   # empty circle 



# first line plot semicircles: (x):(y):(radius):(init angle):(final angle):(color) 
# second line places percentages: (x):(y):(percentage) 
# third line places the color labels 
# fourth line places the color symbols 



#简单的柱状图
#echo "
#set terminal png truecolor
#set output \"my.png\"
#set grid
#set style data histograms
#set style fill solid 1.00 border -1
#set xlabel \"Level\"
#set ylabel \"Number\"
#plot \"data.txt\" using 2:xtic(1) title \"my data\"
#" | gnuplot

