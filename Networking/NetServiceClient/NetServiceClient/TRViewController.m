//
//  TRViewController.m
//  NetServiceClient
//
//  Created by Tarena on 13-11-21.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#import "TRViewController.h"
#import "NetServiceClient.h"

@interface TRViewController () <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UILabel *message;
@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;
@property (strong, nonatomic) NetServiceClient *client;

-(void)openStream;
-(void)closeStream;
@end

@implementation TRViewController
{
    int flag;
}

-(NetServiceClient*)client
{
    if(!_client) _client = [[NetServiceClient alloc]init];
    return _client;
}
- (IBAction)sendMessage:(id)sender
{
    flag = 0;
    [self openStream];
}
- (IBAction)recvMessage:(id)sender
{
    flag = 1;
    [self openStream];
}

-(void)openStream
{
    NSLog(@"openStream client services: %u", [self.client.services count]);
    for (NSNetService *service in self.client.services) {
        if( [@"daniel" isEqualToString:service.name]) {
            if (![service getInputStream:&_inputStream outputStream:&_outputStream]) {
                NSLog(@"连接服务器失败");
                return;
            }
            break;
        }
    }
    
    self.outputStream.delegate = self;
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
    
    self.inputStream.delegate = self;
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
}

-(void)closeStream
{
    [self.outputStream close];
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.outputStream.delegate = nil;
    [self.inputStream close];
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    self.inputStream.delegate = nil;
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
            [self closeStream];
            break;
        case NSStreamEventEndEncountered:
            event = @"NSStreamEventEndEncounterd";
            break;
        default:
            [self closeStream];
            event = @"Unknown";
            break;
    }
    NSLog(@"event------------ %@", event);
}




@end
