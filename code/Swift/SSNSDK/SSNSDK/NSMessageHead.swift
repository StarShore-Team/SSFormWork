//
//  NSMessageHead.swift
//  SSNSDK
//
//  Created by 阿杰 on 2018/5/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//

import Foundation
class NSMessageHead: NSObject {
    public var magic:Int32 = 0
    public var length:Int32 = 0
    public var type:Int32 = 0
    public var version:Int32 = 0

    public static func checkHeadByData(data:Data) -> Bool {
        if (data.count < 8) {
            return false;
        }
        let magic = NSDataUtil.getInt32ByData(data:data.subdata(in:0..<4))
        if (magic != 0x0133ED55) {
            return false
        }
        return true
    }
    func getHeadData() -> Data {
        var data:Data = Data.init();
        data.append(NSDataUtil.createDataByInt32(number: self.magic))
        data.append(NSDataUtil.createDataByInt32(number: self.length))
        data.append(NSDataUtil.createDataByInt32(number: self.type))
        data.append(NSDataUtil.createDataByInt32(number: self.version))
        return data;
    }
    public override init() {
        super.init()
        self.magic = 0x0133ED55;
        self.length =  0x0008;
        self.type = 0x00;
        self.version = 0x01;
    }
    public init(data:Data) {
        super.init()
        if (data.count < 8) {
            return
        }
        let magic = NSDataUtil.getInt32ByData(data:data.subdata(in:0..<4))
        if (magic != 0x0133ED55) {
            return
        }
        self.magic = magic;
        self.length = NSDataUtil.getInt32ByData(data:data.subdata(in:4..<6))
        self.type = NSDataUtil.getInt32ByData(data:data.subdata(in:6..<7))
        self.version = NSDataUtil.getInt32ByData(data:data.subdata(in:7..<8))
    }
}
