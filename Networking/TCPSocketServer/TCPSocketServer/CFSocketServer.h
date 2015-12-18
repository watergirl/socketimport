//
//  CFSocketServer.h
//  TCPSocketServer
//
//  Created by Tarena on 13-11-20.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#ifndef TCPSocketServer_CFSocketServer_h
#define TCPSocketServer_CFSocketServer_h
//客户端连接到服务器的回调函数
void AcceptCallBack(CFSocketRef, CFSocketCallBackType, CFDataRef, const void*, void*);
//客户端读取数据时的回调函数
void WriteStreamClientCallBack(CFWriteStreamRef, CFStreamEventType, void*);
//客户端写入数据时的回调函数
void ReadStreamClientCallBack(CFReadStreamRef, CFStreamEventType, void*);
#endif
