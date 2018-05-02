//
//  NSSocketManager.m
//  Test
//
//  Created by 阿杰 on 2018/4/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//
#import "NSMessageHead.h"
#import "NSSocketManager.h"
static NSSocketManager *manager;
static NSInteger version;
@implementation NSSocketManager{
    BOOL isConnectSuccess,canSendMesssage,isInputStreamOpenSuccess,isOutputStreamOpenSuccess,logOpen;
}
+(NSSocketManager *)manager{
    if (!manager) {
        manager = [[NSSocketManager alloc]init];
        version = 0x01;
    }
    return manager;
}

-(void)openLog:(BOOL)isopen{
    logOpen = isopen;
}

-(NSMutableArray *)chatMsgs{
    
    if(!_chatMsgs) {
        
        _chatMsgs =[NSMutableArray array];
        
    }
    
    return _chatMsgs;
}

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    if (logOpen) {
        NSLog(@"%@",[NSThread currentThread]);
    }
   
    
    //NSStreamEventOpenCompleted = 1UL << 0,//输入输出流打开完成//NSStreamEventHasBytesAvailable = 1UL << 1,//有字节可读//NSStreamEventHasSpaceAvailable = 1UL << 2,//可以发放字节//NSStreamEventErrorOccurred = 1UL << 3,//连接出现错误//NSStreamEventEndEncountered = 1UL << 4//连接结束
    
    switch(eventCode) {
            
        case NSStreamEventOpenCompleted:
            if (aStream == self.inputStream) {
                isInputStreamOpenSuccess = YES;
            }else if (aStream == self.outputStream){
                isOutputStreamOpenSuccess = YES;
            }
            if (isInputStreamOpenSuccess && isOutputStreamOpenSuccess) {
                if (logOpen) {
                    NSLog(@"输入输出流打开完成");
                }
                
                isConnectSuccess = YES;
                if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketConnectWithResult:)]) {
                    [self.delegate onSocketConnectWithResult:YES];
                }
            }
            break;
        case NSStreamEventHasBytesAvailable:
            {if (logOpen) {
                NSLog(@"有字节可读");
            }
            NSData * data =[self readData];
            if ([NSMessageHead checkHeadByData:data]) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketGetMessage:)]) {
                    [self.delegate onSocketGetMessage:[data subdataWithRange:NSMakeRange(8, data.length - 8)]];
                }
            }
            break;}
            
        case NSStreamEventHasSpaceAvailable:
            if (logOpen) {
                NSLog(@"可以发送字节");
            }
            
            canSendMesssage = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(onSocketCanSendMessage)]) {
                [self.delegate onSocketCanSendMessage];
            }
            break;
            
        case NSStreamEventErrorOccurred:
            if (logOpen) {
                NSLog(@"连接出现错误");
            }
            
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
            if (logOpen) {
                NSLog(@"连接结束");
            }
            
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

-(NSData *)readData{
    
    //建立一个缓冲区 可以放1024个字节
    NSMutableData * msgs = [NSMutableData data];
    while ([self.inputStream hasBytesAvailable]) {
        uint8_t buf[1024];
        
        //返回实际装的字节数
        
        NSInteger len = [self.inputStream read:buf maxLength:sizeof(buf)];
        
        //把字节数组转化成字符串
        
        NSData *data =[NSData dataWithBytes:buf length:len];
        
        //从服务器接收到的数据
        [msgs appendData:data];
    }
    return msgs;
}
-(void)sendMessage:(NSData *)msg{
    if (msg && isConnectSuccess && canSendMesssage) {
        NSMessageHead * head = [[NSMessageHead alloc]init];
        head.length = msg.length + 8;
        head.type = 0x01;
        head.version = version;
        NSMutableData * data = [NSMutableData dataWithData:[head getHeadData]];
        [data appendData:msg];
        [self.outputStream write:data.bytes maxLength:data.length];
    }else{
        if (logOpen) {
            NSLog(@"Error:Connect has not connected");
        }
    }
    
}
@end
