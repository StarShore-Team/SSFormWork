//
//  NSDataUtil.swift
//  SSNSDK
//
//  Created by 阿杰 on 2018/5/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//

import Foundation

class NSDataUtil: NSObject {
    static public func createDataByFile(filePath:String) -> Data {
        
        let data = try? Data (contentsOf: URL.init(string: filePath)!)
        return data!
    }
    
    static public func createDataByPNG(image:UIImage) -> Data {
        let data = UIImagePNGRepresentation(image)
        return data!
    }
    
    static public func createDataByJPG(image:UIImage) -> Data {
        let data = UIImageJPEGRepresentation(image, 1)
        return data!
    }
    static public func createDataByString(string:String) -> Data {
        let data = string.data(using: String.Encoding.utf8)
        return data!
    }
    static public func createDataByInt32(number:Int32) -> Data {
        var a = number;
        let data = Data.init(bytes: &a, count: 4)
        return data
    }
    static public func getInt32ByData(data:Data) -> Int32 {
        let bytes:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.init(bitPattern: 0)!
        data.copyBytes(to: bytes , count: 4)
        var a:Int32 = Int32(0x00000000|bytes[0])
        a = a<<6;
        var b:Int32 = Int32(0x00000000|bytes[1])
        b = b << 4
        var c:Int32 = Int32(0x00000000|bytes[2])
        c = c << 2
        let d:Int32 = Int32(0x00000000|bytes[3])
        let e:Int32 = a|b|c|d
        return e
    }
}
