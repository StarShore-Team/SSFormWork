//
//  NSMessageHead.m
//  Test
//
//  Created by 阿杰 on 2018/5/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//

#import "NSMessageHead.h"
#import "NSDataUtil.h"
@implementation NSMessageHead

+(BOOL)checkHeadByData:(NSData *)data{
    if (data.length < 8) {
        return NO;
    }
    int32_t magic;
    int16_t length;
    int8_t type,version;
    magic = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(0, 4)]];
    length = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(4, 2)]];
    type = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(6, 1)]];
    version = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(7, 1)]];
    if (magic != 0x0133ED55) {
        return NO;
    }
    return YES;
}

-(NSData *)getHeadData{
    NSMutableData *data = [NSMutableData dataWithData:[NSDataUtil createDataByInt32:self.magic]];
    [data appendData:[NSDataUtil createDataByInt32:self.length]];
    [data appendData:[NSDataUtil createDataByInt32:self.type]];
    [data appendData:[NSDataUtil createDataByInt32:self.version]];
    return data;
}

- (instancetype)initWithData:(NSData *)data{
    if (data.length < 8) {
        return nil;
    }
    int32_t magic;
    int16_t length;
    int8_t type,version;
    magic = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(0, 4)]];
    length = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(4, 2)]];
    type = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(6, 1)]];
    version = [NSDataUtil getInt32ByData:[data subdataWithRange:NSMakeRange(7, 1)]];
    if (magic != 0x0133ED55) {
        return nil;
    }
    self = [super init];
    if (self) {
        self.magic = magic;
        self.length = length;
        self.type = type;
        self.version = version;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.magic = 0x0133ED55;
        self.length =  0x0008;
        self.type = 0x00;
        self.version = 0x01;
    }
    return self;
}
@end
