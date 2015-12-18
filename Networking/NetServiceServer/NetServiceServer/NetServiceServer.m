//
//  NetServiceServer.m
//  NetServiceServer
//
//  Created by Tarena on 13-11-21.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#import "NetServiceServer.h"
#import "CFSocketServer.h"
#import <netinet/in.h>
#import <sys/socket.h>

@interface NetServiceServer() <NSNetServiceDelegate, NSStreamDelegate>
@property (nonatomic, strong) NSNetService *service;
//@property (nonatomic, strong) NSInputStream *inputStream;
//@property (nonatomic, strong) NSOutputStream *outputStream;

@property (nonatomic) int port;

//启动服务器
-(BOOL)startServer;
//发布Bonjour
-(BOOL)publishService;

@end

@implementation NetServiceServer

-(id)init
{
    if(self = [super init]){
        BOOL successed = [self startServer];
        if(successed) successed = [self publishService];
        if(!successed) {
            self = nil;
            NSLog(@"服务器启动失败");
        }
    }
    NSLog(@"服务器已启动");
    return self;
}

-(BOOL)startServer
{
    //定义Server Socket引用（是个指针）
    CFSocketRef sserver;
    //创建Socket上下文
    CFSocketContext CTX = {};
    //创建Socket, 设置回调函数
    sserver = CFSocketCreate(NULL, AF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)AcceptCallBack, &CTX);
    if(sserver == NULL) {
        NSLog(@"Create Socket Failed!");
        return NO;
    }
    NSLog(@"Create Socket Successed!");
    
    //设置Socket属性  SOL_SOCKET允许设置属性， SO_REUSEADDR 可重新绑定
    int yes = 1;//是否重新绑定标志
    setsockopt(CFSocketGetNative(sserver), SOL_SOCKET, SO_REUSEADDR, (void*)&yes, sizeof(yes));
    //定义地址
    struct sockaddr_in addr = {};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);//内核分配，本机地址
    addr.sin_port = 0;//端口设置为0
    addr.sin_len = sizeof(addr);
    
    //从字节序列中复制一个不可变的CFData对象
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8*)&addr, sizeof(addr));
    //绑定Socket
    if(CFSocketSetAddress(sserver, address) != kCFSocketSuccess) {
        NSLog(@"Bind Failed!");
        return NO;
    }
    NSLog(@"Bind Successed!");
    
    //通过Bonjour广播服务器时使用
    NSData *socketAddressActualData = (__bridge NSData *)(CFSocketCopyAddress(sserver));
    //转换socket_in==>socketAddressActual
    struct sockaddr_in socketAddressActual;
    memcpy(&socketAddressActual, [socketAddressActualData bytes], [socketAddressActualData length]);
    self.port = ntohs(socketAddressActual.sin_port);
    NSLog(@"Socket Listening on port: %d\n", self.port);

    
    //创建Run Loop Socket源
    CFRunLoopSourceRef sourceRef = CFSocketCreateRunLoopSource(kCFAllocatorDefault, sserver, 0);
    //将socket源加入到Run Loop中
    CFRunLoopAddSource(CFRunLoopGetCurrent(), sourceRef, kCFRunLoopCommonModes);
    CFRelease(sourceRef);
    
    return YES;
}

-(NSNetService*)service
{
    //创建服务实例
    if(!_service)_service = [[NSNetService alloc]initWithDomain:@"local." type:@"_danielipp._tcp." name:@"daniel"  port:self.port];
    return _service;
}
-(BOOL)publishService
{
    //添加服务到当前的Run Loop
    [self.service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    //设置当前对象处理委托
    self.service.delegate = self;
    
    //发布服务
    [self.service publish];
    
    return YES;
}

-(void)netServiceDidPublish:(NSNetService *)netService
{
    NSLog(@"netServiceDidPublish.");
//    if([@"daniel" isEqualToString:netService.name]) {
//        if(![netService getInputStream:&_inputStream outputStream:&_outputStream]) {
//            NSLog(@"连接到服务器失败");
//            return;
//        }
//    }
}


@end
