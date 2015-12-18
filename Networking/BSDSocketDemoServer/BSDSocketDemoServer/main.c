//
//  main.c
//  BSDSocketDemoServer
//
//  Created by Tarena on 13-11-19.
//  Copyright (c) 2013年 Tarena. All rights reserved.
//

#include <stdio.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>

#define IP "127.0.0.1"
#define PORT 10222
int startServer()
{
    //创建Socket
    int serversocket = socket(AF_INET, SOCK_STREAM, 0);
    if(serversocket==-1) {
        perror("创建Socket失败");
        return -1;
    }
    //准备地址
    struct sockaddr_in addr = {};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = inet_addr(IP);
    addr.sin_port = htons(PORT);
    addr.sin_len = sizeof(struct sockaddr_in);
    //绑定socket
    int res = bind(serversocket, (struct sockaddr*)&addr, sizeof(addr));
    if(res==-1){
        perror("绑定失败");
        return -1;
    }
    printf("绑定成功\n");
    //监听
    if(listen(serversocket, 10)==-1){
        perror("监听失败");
        return -1;
    }
    printf("监听服务启动\n");
    //等待客户端连接
    while (1) {
        struct sockaddr_in fromaddr = {};
        socklen_t addr_len;
        int client_socket = accept(serversocket, (struct sockaddr*)&fromaddr, &addr_len);
        if (client_socket==-1) {
            perror("客户端连接出现问题");
            return -1;
        }
        printf("客户端连接成功\n");
        
        //接收客户端数据
        char recv_msg[1024] = {};
        if(recv(client_socket, recv_msg, sizeof(recv_msg), 0)<0){
            perror("接收客户端数据出错");
            return -1;
        }
        printf("成功接收到客户端发来的数据\n");
        printf("客户端消息:%s\n", recv_msg);
        
        char send_msg[1024] = {};
        sprintf(send_msg, "您刚才说:%s", recv_msg);
        if(send(client_socket, send_msg, strlen(send_msg)+1, 0)<0){
            perror("给客户端发消息失败");
            close(client_socket);
            continue;
        }
        printf("成功地给客户端发送了一条消息\n");
        close(client_socket);
    }
    return 0;
}


int main()
{
    startServer();
    return 0;
}
