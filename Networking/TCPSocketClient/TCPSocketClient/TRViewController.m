//
//  TRViewController.m
//  TCPSocketClient
//
//  Created by Tarena on 13-11-20.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#import "TRViewController.h"

@interface TRViewController () <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@end

@implementation TRViewController
{
    int flag;
}
-(void)initNetWorkCommunication
{
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (CFStringRef)@IP, PORT, &readStream, &writeStream);
    _inputStream = (__bridge_transfer NSInputStream *)(readStream);
    _outputStream = (__bridge_transfer NSOutputStream *)writeStream;
    self.inputStream.delegate = self;
    self.outputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    [self.outputStream open];
    
}

- (IBAction)sendMessage:(id)sender
{
    flag = 0;
    [self initNetWorkCommunication];
}
- (IBAction)recvMessage:(id)sender
{
    flag = 1;
    [self initNetWorkCommunication];
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    NSString* event;
    switch (eventCode) {
        case NSStreamEventNone:
            event = @"NSStreamEventNone";
            break;
        case NSStreamEventOpenCompleted:
            event = @"NSStreamEventOpenCompleted";
            break;
        case NSStreamEventHasBytesAvailable:
            event = @"NSStreamEventHasBytesAvailable";
            if(flag==1 && aStream == self.inputStream) {
                NSMutableData *input = [[NSMutableData alloc]init];
                uint8_t buffer[1024];
                NSInteger len;
                while ([self.inputStream hasBytesAvailable]) {
                    len = [self.inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len>0) {
                        [input appendBytes:buffer length:len];
                    }
                }
                
                NSString *resultString = [[NSString alloc]initWithData:input encoding:NSUTF8StringEncoding];
                NSLog(@"接收：%@", resultString);
                self.message.text = resultString;
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            event = @"NSStreamEventHasSpaceAvailable";
            if(flag==0 && aStream==self.outputStream) {
                UInt8 buffer[] = "Hello Server";
                [self.outputStream write:buffer maxLength:strlen((const char*)buffer)+1];
                [self.outputStream close];
            }
            break;
        case NSStreamEventErrorOccurred:
            event = @"NSStreamEventErrorOccurred";
            [self close];
            break;
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncounterd";
            NSLog(@"Error: %ld: %@", [[aStream streamError]code], [[aStream streamError]localizedDescription]);
            break;
        default:
            [self close];
            event = @"Unknown";
            break;
    }
    NSLog(@"event------------ %@", event);
}

-(void) close
{
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream.delegate = nil;
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream.delegate = nil;
}

#include "IPAddress.h"

- (IBAction)getLocalIP
{
    GetIPAddresses();
    char* ip = ip_names[1];
    if(ip){
        NSString *ipString = [NSString stringWithCString:ip encoding:NSUTF8StringEncoding];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"本机IP地相" message:ipString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

#include <ifaddrs.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

- (IBAction)getLocalIP2
{
    struct ifaddrs *ifaHead;
    if(getifaddrs(&ifaHead)<0) return;
    struct ifaddrs *ifap = ifaHead;
    while (ifap) {
        if(ifap->ifa_addr->sa_family == AF_INET && strcmp(ifap->ifa_name, "en0") == 0) {
            const char* ip = inet_ntoa(((struct sockaddr_in*)ifap->ifa_addr)->sin_addr);
            if(ip){
                NSString *ipString = [NSString stringWithCString:ip encoding:NSUTF8StringEncoding];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"本机IP地相" message:ipString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            return;
        }
        ifap = ifap->ifa_next;
    }
}

@end
