import time
time_start=time.time()#生成开始时间
#需要加密的文件路径
fildPath=r"/Users/caolei/packshop_all/flash.bin"
picRead=open(fildPath,mode="rb")
#读取二进制文件
picData=picRead.read()
picLen=len(picData)
#需要写出的文件路径
f_write = open(r"/Users/caolei/packshop_all/flash.rar","wb")
#提供密码的txt文件
#读取二进制密钥文件
keyData="xxxx".encode()
keyLen=keyData.__len__()
#获取Key
key=picLen//keyLen*keyData+keyData[:picLen%keyLen]
#进行循环加密
for i in range(len(key)):
    newByte=key[i]^picData[i]
    #写出二进制文件
    f_write.write(bytes([newByte]))
f_write.close()
picRead.close()


time_end=time.time()#生成结束时间
print('time cost',time_end-time_start,'s')#打印运行时间

