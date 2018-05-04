//
//  NSDataUtil.m
//  Test
//
//  Created by 阿杰 on 2018/4/4.


//  Copyright © 2018年 阿杰. All rights reserved.
//

#import "NSDataUtil.h"

@implementation NSDataUtil
+ (NSData *)createDataByFile:(NSString *)filePath{
    if (!filePath) {
        return nil;
    }
    NSData * data = [NSData dataWithContentsOfFile:filePath];
    return data;
}
+ (NSData *)createDataByPNG:(UIImage *)image{
    if (!image) {
        return nil;
    }
    NSData * data = UIImagePNGRepresentation(image);
    return data;
}
+ (NSData *)createDataByJPG:(UIImage *)image{
    if (!image) {
        return nil;
    }
    NSData * data = UIImageJPEGRepresentation(image, 1);
    return data;
}
+ (NSData *)createDataByString:(NSString *)string{
    if (!string) {
        return nil;
    }
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}
+ (NSData *)createDataByString:(NSString *)string andLength:(NSInteger)len{
    if (string == nil) {
        Byte * bytes = alloca(sizeof(Byte) * len);
        for (int i = 0; i<len; i++) {
            bytes[i] = 0;
        }
        return [NSData dataWithBytes:bytes length:len];
    }
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length >len) {
        return [NSData dataWithBytes:[data subdataWithRange:NSMakeRange(0, len)].bytes length:len];
    }else{
        NSMutableData * tmpData = [NSMutableData dataWithData:data];
        Byte * bytes = alloca(sizeof(Byte) * len);
        for (int i = 0; i<len; i++) {
            bytes[i] = 0;
        }
        [tmpData appendData:[NSData dataWithBytes:bytes length:len - data.length]];
        return [NSData dataWithData:tmpData];
    }
}
+ (NSData *)createDataByInt32:(int32_t)number{
    return [NSData dataWithBytes:&number length:sizeof(number)];
}
+(int32_t)getInt32ByData:(NSData *)data{
    int32_t bytes;
    [data getBytes:&bytes length:sizeof(bytes)];
    return bytes;
}

+(NSString *)getStringByData:(NSData *)data{
    Byte * bytes = alloca(sizeof(Byte) * data.length);
    [data getBytes:bytes length:data.length];
    NSInteger i = data.length - 1;
    for (; i >= 0; i--) {
        if (bytes[i] != 0) {
            break;
        }
    }
    if (i == -1) {
        return nil;
    }
    return [[NSString alloc]initWithBytes:bytes length:i + 1 encoding:NSUTF8StringEncoding];
}
@end
