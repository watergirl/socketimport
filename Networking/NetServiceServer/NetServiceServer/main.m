//
//  main.m
//  NetServiceServer
//
//  Created by Tarena on 13-11-21.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetServiceServer.h"


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        NetServiceServer* server = [[NetServiceServer alloc]init];
        CFRunLoopRun();
        server = nil;
        NSLog(@"Hello, World!");
    }
    return 0;
}

