//
//  NSMessageHead.h
//  Test
//
//  Created by 阿杰 on 2018/5/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMessageHead : NSObject
@property (nonatomic,assign) int32_t magic;
@property (nonatomic,assign) int16_t length;
@property (nonatomic,assign) int8_t type;
@property (nonatomic,assign) int8_t version;
+(BOOL)checkHeadByData:(NSData *)data;
-(instancetype)initWithData:(NSData *)data;
-(NSData *)getHeadData;
@end
