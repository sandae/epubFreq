#!/usr/bin/python
# -*- coding: utf-8 -*-
'''
     功能.  用字典文件中的释义，将目标文件中每个单词加上释义的超链接
     记事本，如果保存为utf8,第一行存放的编码
'''
import re
import os
#------------------主程序---------------

   

#------------------主要函数-------------
#两个参数：inFile,输入文件名，outFile 输出文件名
#返回类型string "success" 代表成功,否则返回错误原因
def DicReplace(inFile,outFile):
    "利用输入文件中的字典对目标html文件添加脚注"
    try:
        fIn=open(inFile)
        fOut=open(outFile)
        dictionary={}#字典对象
        dic={}
        for line in fIn:   #读入字典
            pos=line.find('\t')
            pos1=line.find('\t',pos+1)
            #print line
            if pos>-1:
                words=line[pos+1:pos1].strip()
                mealing=line[pos1+1:].strip()
                
                dictionary[words]=mealing
                #print words
                dic[words]=re.compile("\\b"+words+"\\b",2)
                
        fIn.close()
        if len(dictionary)==0:
            fOut.close()
            return "The dictionary file has no effictive words!"
        else:
            print "There has "+str(len(dictionary))+" words to replace."
        c=fOut.read()     #将目标文件分为body前body和body后分
        sep1='<body'       #分割目标文件，只对html文档的body部分的词进行替换
        sep2='</body>'
        pos1=c.find(sep1)
        pos2=c.find(sep2)
        if pos1<0 or pos2<0:
            return "The document didnt contain body"
        head=c[0:pos1+len(sep1)]
        body=c[pos1+len(sep1):pos2]#要进行替换的目标
        tail=c[pos2:]#添加脚注部分
        total=len(dictionary)
        tsum=0
        code={}
        num=0  #开始替换工作
        ttail=''
        for w_m in dictionary:
            if re.search(dic[w_m],body)!=None:
                
                num+=1
                rep='__&&@__'+str(num)+'__@&&__'
#               code[rep]=w_m+'<a style="color:#000; text-decoration:none;" epub:type="noteref" href="#footnote_'+str(num)+'">ⁿ</a>'
#               code[rep]=w_m+'<a epub:type="noteref" href="#footnote_'+str(num)+'">'+w_m+'</a>'
                code[rep]=' epub:type="noteref" href="#footnote_'+str(num)+'">'+w_m+'</a>'
#@$%                code[rep]='<a epub:type="noteref" href="#footnote_'+str(num)+'">'+w_m+'</a>'
                backnote='<aside epub:type="footnote" id="footnote_'+str(num)+'">'+dictionary[w_m]+'</aside>'
                ttail+=backnote
                body,a=re.subn(dic[w_m],rep,body);
                tsum+=a
#                print "The word "+w_m+" has replaced "+str(a)+"times"
#                print "There has "+str(total-num)+" words left to replace"
        tail=' <section epub:type="footnotes">'+ttail+'</section>'+tail
        for key in code:
            body=body.replace(key,code[key])
        html=head+body+tail
        #写入文件
        fOut.close()
        fOut=open(outFile,"w")
        fOut.write(html)
        fOut.close()
        print  "success,added "+str(num)+"notes,replaced "+str(tsum)+"words. "
    except IOError,e:
        print e
        print "文件操作错误"
#------------------遍历函数---------------------------
def DReplace(Dic,path):
    if os.path.exists(Dic):
        if os.path.exists(path):
            fset=[]
            for root,dirs,files in os.walk(path):
                for filespath in files:
                    if filespath.endswith((".html",".xhtml")):
                        fout=os.path.join(root,filespath)
                        print "Replacing "+fout
                        DicReplace(Dic,fout)
        else:
            return "the path didnt exists"
    else:
        return "the Dicfile didnt exists"                                  
#---------------主函数--------------------------
                                          
        
    
