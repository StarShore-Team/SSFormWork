//
//  NSSocketManager.m
//  Test
//
//  Created by 阿杰 on 2018/4/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//

#import "NSSocketManager.h"
static NSSocketManager *manager;

@implementation NSSocketManager{
    BOOL isConnectSuccess,canSendMesssage,isInputStreamOpenSuccess,isOutputStreamOpenSuccess;
}
+(NSSocketManager *)manager{
    if (!manager) {
        manager = [[NSSocketManager alloc]init];
    }
    return manager;
}

-(NSMutableArray *)chatMsgs{
    
    if(!_chatMsgs) {
        
        _chatMsgs =[NSMutableArray array];
        
    }
    
    return _chatMsgs;
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    NSLog(@"%@",[NSThread currentThread]);
    
    //NSStreamEventOpenCompleted = 1UL << 0,//输入输出流打开完成//NSStreamEventHasBytesAvailable = 1UL << 1,//有字节可读//NSStreamEventHasSpaceAvailable = 1UL << 2,//可以发放字节//NSStreamEventErrorOccurred = 1UL << 3,//连接出现错误//NSStreamEventEndEncountered = 1UL << 4//连接结束
    
    switch(eventCode) {
            
        case NSStreamEventOpenCompleted:
            if (aStream == self.inputStream) {
                isInputStreamOpenSuccess = YES;
            }else if (aStream == self.outputStream){
                isOutputStreamOpenSuccess = YES;
            }
            if (isInputStreamOpenSuccess && isOutputStreamOpenSuccess) {
                NSLog(@"输入输出流打开完成");
                isConnectSuccess = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketConnectWithResult:)]) {
                    [self.delegate onSocketConnectWithResult:YES];
                }
            }
            break;
        case NSStreamEventHasBytesAvailable:
            
            NSLog(@"有字节可读");
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketGetMessage:)]) {
                [self.delegate onSocketGetMessage:[self readData]];
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            
            NSLog(@"可以发送字节");
            canSendMesssage = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketCanSendMessage)]) {
                [self.delegate onSocketCanSendMessage];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            
            NSLog(@"连接出现错误");
            if (aStream == self.inputStream) {
                isInputStreamOpenSuccess = NO;
            }else if (aStream == self.outputStream){
                isOutputStreamOpenSuccess = NO;
            }
            isConnectSuccess = NO;
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketConnectWithResult:)]) {
                [self.delegate onSocketConnectWithResult:NO];
            }
            break;
            
        case NSStreamEventEndEncountered:
            
            NSLog(@"连接结束");
            isConnectSuccess = NO;
            canSendMesssage = NO;
            isInputStreamOpenSuccess = NO;
            isOutputStreamOpenSuccess = NO;
            //关闭输入输出流
            
            [self.inputStream close];
            
            [self.outputStream close];
            
            //从主运行循环移除
            
            [self.inputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            
            [self.outputStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketCloseConnect)]) {
                [self.delegate onSocketCloseConnect];
            }
            break;
            
        default:
            
            break;
            
    }
    
}


-(void)connectToHost:(NSString *)host andPort:(int)port{
    
    //定义C语言输入输出流
    
    CFReadStreamRef readStream;
    
    CFWriteStreamRef writeStream;
    
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)host, port, &readStream, &writeStream);
    //把C语言的输入输出流转化成OC对象
    
    self.inputStream = (__bridge NSInputStream *)(readStream);
    
    self.outputStream = (__bridge NSOutputStream *)(writeStream);
    
    //设置代理
    
    self.inputStream.delegate=self;
    
    self.outputStream.delegate=self;
    
    //把输入输入流添加到主运行循环
    
    //不添加主运行循环 代理有可能不工作
    
    [self.inputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.outputStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    //打开输入输出流
    
    [self.inputStream open];
    
    [self.outputStream open];
    
}

#pragma mark 读了服务器返回的数据

-(NSArray *)readData{
    
    //建立一个缓冲区 可以放1024个字节
    NSMutableArray * msgs = [NSMutableArray array];
    while ([self.inputStream hasBytesAvailable]) {
        uint8_t buf[1024];
        
        //返回实际装的字节数
        
        NSInteger len = [self.inputStream read:buf maxLength:sizeof(buf)];
        
        //把字节数组转化成字符串
        
        NSData *data =[NSData dataWithBytes:buf length:len];
        
        //从服务器接收到的数据
        
        NSString *recStr =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [msgs addObject:recStr];
    }
    return msgs;
}
-(void)sendMessage:(NSString *)msg{
    if (isConnectSuccess && canSendMesssage) {
        NSLog(@"%@",msg);
        //聊天信息
        //把Str转成NSData10
        NSData *data =[msg dataUsingEncoding:NSUTF8StringEncoding];
        
        [self.outputStream write:data.bytes maxLength:data.length];
    }else{
        NSLog(@"Error:Connect has not connected");
    }
    
}
@end
