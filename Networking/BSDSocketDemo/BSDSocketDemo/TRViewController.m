//
//  TRViewController.m
//  BSDSocketDemo
//
//  Created by Tarena on 13-11-19.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#import "TRViewController.h"
#import "sys/socket.h"
#import "netinet/in.h"
#import "arpa/inet.h"


#define IP "127.0.0.1"
#define PORT 10222

@interface TRViewController ()
@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet UITextField *sendMessage;
@property (nonatomic) int clientsocket;
@end

@implementation TRViewController
- (IBAction)connectServer
{
    //创建Socket
    self.clientsocket = socket(AF_INET, SOCK_STREAM, 0);
    //准备地址
    struct sockaddr_in addr = {};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(IP);
    addr.sin_port = htons(PORT);
    addr.sin_len = sizeof(struct sockaddr_in);
    //连接
    int res = connect(self.clientsocket, (struct sockaddr*)&addr, sizeof(addr));
    if(res==-1){
        NSLog(@"连接服务器失败");
        self.messageView.text = [self.messageView.text stringByAppendingString:@"连接服务器失败\n"];
        return;
    }
    NSLog(@"连接服务器成功");
    self.messageView.text = [self.messageView.text stringByAppendingString:@"连接服务器成功\n"];
}

- (IBAction)sendMyMessage
{
    const char* msg = [self.sendMessage.text cStringUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%s", msg);
    if(send(self.clientsocket, msg, strlen(msg)+1, 0)<0){
        NSLog(@"发送消息失败");
        self.messageView.text = [self.messageView.text stringByAppendingString:@"发送消息失败\n"];
        return;
    }
    send(self.clientsocket, "\n\n", 2, 0);
    NSLog(@"成功发送一条消息");
    self.messageView.text = [self.messageView.text stringByAppendingString:@"成功发送一条消息\n"];
    //接收消息
    char buf[1024] = {};
    if(recv(self.clientsocket, buf, sizeof(buf), 0)<0) {
        NSLog(@"接收消息错误");
        self.messageView.text = [self.messageView.text stringByAppendingString:@"接收消息错误\n"];
    }else{
        NSLog(@"成功收到一条消息");
        NSString* recvMsg = [NSString stringWithCString:buf encoding:NSUTF8StringEncoding];
        self.messageView.text = [[self.messageView.text stringByAppendingString:@"服务器回复:"]stringByAppendingString:recvMsg];
    }
}

@end
