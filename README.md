# epubFreq


本脚本用于自动为epub电子书添加词频标记和注释（词典释义）
标注样式分两种模式：彩色和数字角标（⁰¹²³⁴⁵）


**使用方法：**

1、运行脚本

bash epubfreq.sh

自动转换当前目录下所有epub电子书

bash epubfreq.sh ebpufile.epub

转换当前目录下指定epub电子书。

2、默认模式（直接回车）为前7000高频词仅添加三个等级的彩色词频标记，方便高频词部分利用第三方词典深入查词和学习；7000以后单词添加4个等级的彩色词频标记+内置释义，

方便阅读时不中断阅读体验，单击即可显示简明汉译。

3、可选择自定义词频等级模式和分级数量，样式，组合


**新手习作，性能较差，且shell和python混合，希望帮助完善，或者用python/perl重写**


**依赖：**
python2.x




**效果演示**

PC版FBreader效果演示：
左边为暗色调样式（实际使用中暗色体验最好）， 右边为亮色，只做演示
![Aaron Swartz](https://github.com/sandae/epubFreq/blob/master/image/photo_2018-08-29_12-42-36.jpg)


角标模式演示：
![Aaron Swartz](https://github.com/sandae/epubFreq/blob/master/image/photo_2018-08-29_12-42-34.jpg)



手机阅读器效果演示：

![Aaron Swartz](https://github.com/sandae/epubFreq/blob/master/image/photo_2018-08-29_12-28-45.jpg)


![Aaron Swartz](https://github.com/sandae/epubFreq/blob/master/image/photo_2018-08-29_12-28-43.jpg)


