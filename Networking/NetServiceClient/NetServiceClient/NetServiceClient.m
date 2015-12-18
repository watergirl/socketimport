//
//  NetServiceClient.m
//  NetServiceClient
//
//  Created by Tarena on 13-11-21.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#import "NetServiceClient.h"
@interface NetServiceClient () <NSNetServiceDelegate>
@property (nonatomic, strong, readwrite) NSMutableArray *services;
@property (nonatomic, strong) NSNetService *service;
@end

@implementation NetServiceClient
-(id)init
{
    if (self = [super init]) {
        _service = [[NSNetService alloc]initWithDomain:@"local." type:@"_danielipp._tcp." name:@"daniel"];
        _service.delegate = self;
        //设置解析地址超时时间
        [_service resolveWithTimeout:1.0];
        _services = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)netServiceDidResolveAddress:(NSNetService *)netService
{
    NSLog(@"netServiceDidResolveAddress");
    [self.services addObject:netService];
}
-(void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    
}
@end
