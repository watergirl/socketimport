//
//  CFSocketServer.c
//  TCPSocketServer
//
//  Created by Tarena on 13-11-20.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdio.h>
#include "CFSocketServer.h"

void AcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void* data, void* info) {
    CFShow(CFSTR("AcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void* data, void* info)"));
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    //如果回调类型是kCFSocketAcceptCallBack, data就是CFSocketNativeHandle类型的指针
    CFSocketNativeHandle sock = *(CFSocketNativeHandle*)data;
    //创建读写Socket流
    CFStreamCreatePairWithSocket(kCFAllocatorDefault, sock, &readStream, &writeStream);
    if(!readStream || !writeStream){
        perror("CFStreamCreatePairWithSocket失败");
        close(sock);
        return;
    }
    CFShow(CFSTR("Read Stream and Write Stream create successed!"));
    
    //注册读写回调函数
    CFStreamClientContext streamCtxt = {};
    CFReadStreamSetClient(readStream, kCFStreamEventHasBytesAvailable, ReadStreamClientCallBack, &streamCtxt);
    CFWriteStreamSetClient(writeStream, kCFStreamEventCanAcceptBytes, WriteStreamClientCallBack, &streamCtxt);
    
    //加入到循环
    CFReadStreamScheduleWithRunLoop(readStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(writeStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    
    //打开读写
    CFReadStreamOpen(readStream);
    CFWriteStreamOpen(writeStream);
}

void WriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType eventType, void* info) {
    CFShow(CFSTR("WriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType eventType, void* info)"));
    
    CFWriteStreamRef outputStream = stream;
    char buf[] = "Hello Client.";
    if(NULL != outputStream) {
        CFWriteStreamWrite(outputStream, (void*)buf, strlen(buf+1));
        CFWriteStreamClose(outputStream);
        CFWriteStreamUnscheduleFromRunLoop(outputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        outputStream = NULL;
    }
}
void ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void* info) {
    CFShow(CFSTR("ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void* info)"));
    UInt8 buf[255];
    CFReadStreamRef inputStream = stream;
    if (NULL != inputStream) {
        CFReadStreamRead(stream, buf, 255);
        printf("Reviced data: %s\n", buf);
        CFReadStreamClose(inputStream);
        CFReadStreamUnscheduleFromRunLoop(inputStream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
        inputStream = NULL;
    }
}

