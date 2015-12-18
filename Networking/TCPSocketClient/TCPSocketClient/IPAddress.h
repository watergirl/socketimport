//
//  IPAddress.h
//  TCPSocketServer
//
//  Created by Tarena on 14-3-24.
//  Copyright (c) 2014年 Tarena. All rights reserved.
//

#ifndef IPADDRESS_H
#define IPADDRESS_H

#define MAXADDRS    32

extern char *if_names[MAXADDRS];
extern char *ip_names[MAXADDRS];
extern char *hw_addrs[MAXADDRS];
extern unsigned long ip_addrs[MAXADDRS];

// Function prototypes

void InitAddresses();
void FreeAddresses();
void GetIPAddresses();
void GetHWAddresses();

#endif
