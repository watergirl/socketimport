//
//  main.c
//  TCPSocketServer
//
//  Created by Tarena on 13-11-20.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#include <CoreFoundation/CoreFoundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include "CFSocketServer.h"
#include "IPAddress.h"

#define PORT 10222

int main(int argc, const char * argv[])
{
    
    GetIPAddresses();
    printf("%s\n", (ip_names[1]));
    GetHWAddresses();
    printf("%s\n", hw_addrs[1]);
    //定义Server Socket引用（是个指针）
    CFSocketRef sserver;
    //创建Socket上下文
    CFSocketContext CTX = {};
    //创建Socket, 设置回调函数
    sserver = CFSocketCreate(NULL, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)AcceptCallBack, &CTX);
    if(sserver == NULL) {
        perror("Create Socket Failed!");
        return -1;
    }
    CFShow(CFSTR("Create Socket Successed!"));
    
    //设置Socket属性  SOL_SOCKET允许设置属性， SO_REUSEADDR 可重新绑定
    int yes = 1;//是否重新绑定标志
    setsockopt(CFSocketGetNative(sserver), SOL_SOCKET, SO_REUSEADDR, (void*)&yes, sizeof(yes));
    //定义地址
    struct sockaddr_in addr = {};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);//内核分配，本机地址
    addr.sin_port = htons(PORT);
    addr.sin_len = sizeof(addr);
    
    //从字节序列中复制一个不可变的CFData对象
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8*)&addr, sizeof(addr));
    //绑定Socket
    if(CFSocketSetAddress(sserver, address) != kCFSocketSuccess) {
        perror("Bind Failed!");
        return -1;
    }
    CFShow(CFSTR("Bind Successed!"));
    
    //创建Run Loop Socket源
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, sserver, 0);
    //将socket源加入到Run Loop中
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
    CFStringRef str = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("Socket Listening on port %d\n"), PORT);
    CFShow(str);
    
    //运行Loop
    CFRunLoopRun();
    
    return 0;
}
