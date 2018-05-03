//
//  NSSocketManager.swift
//  SSNSDK
//
//  Created by 阿杰 on 2018/5/2.
//  Copyright © 2018年 阿杰. All rights reserved.
//

import Foundation
protocol NSSocketDelegate:NSObject{
    func onSocketConnectWithResult(isSuccess:Bool) -> Void
    func onSocketGetMessage(messages:Data) -> Void
    func onSocketCanSendMessage() -> Void
    func onSocketCloseConnect() -> Void
}

class NSSocketManager: NSObject,StreamDelegate {
    static let manager: NSSocketManager = {
        return NSSocketManager()
    }()
    static let version: Int32 = 0x01
    var isConnectSuccess:Bool = false,canSendMesssage:Bool = false,isInputStreamOpenSuccess:Bool = false,isOutputStreamOpenSuccess:Bool = false,logOpen:Bool = true;

    var inputStream: InputStream! {
        get {
            return self.inputStream
        }
        set {
            self.inputStream = newValue
        }
    }
    var outputStream: OutputStream! {
        get {
            return self.outputStream
        }
        set {
            self.outputStream = newValue
        }
    }
    var delegate: NSSocketDelegate!
    
    func connectToHost(host:String,port:UInt32) -> Void {
        //定义C语言输入输出流
    
        var readStream:Unmanaged<CFReadStream>?
    
        var writeStream:Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(nil, host as CFString, port, &readStream, &writeStream)
        //把C语言的输入输出流转化成OC对象
        if readStream != nil {
            self.inputStream = readStream!.takeRetainedValue()
        }
    
        if writeStream != nil {
            self.outputStream = writeStream!.takeRetainedValue()
        }
    
        //设置代理
    
        self.inputStream.delegate=self;
    
        self.outputStream.delegate=self;
    
        //把输入输入流添加到主运行循环
    
        //不添加主运行循环 代理有可能不工作
        self.inputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
    
        //打开输入输出流
    
        self.inputStream.open()
    
        self.outputStream.open()
    }
    func openLog(isopen:Bool) -> Void {
        logOpen = isopen
    }
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if (logOpen) {
            print(Thread.current)
        }
        
        switch eventCode {
        case Stream.Event.openCompleted:
            if (aStream == self.inputStream) {
                isInputStreamOpenSuccess = true;
            }else if (aStream == self.outputStream){
                isOutputStreamOpenSuccess = true;
            }
            if (isInputStreamOpenSuccess && isOutputStreamOpenSuccess) {
                if (logOpen) {
                    print("输入输出流打开完成");
                }
                
                isConnectSuccess = true;
                if (self.delegate != nil && self.delegate.responds(to: Selector.init(("onSocketConnectWithResult:")))) {
                    self.delegate.onSocketConnectWithResult(isSuccess: true)
                }
            }
            break
        case Stream.Event.hasBytesAvailable:
            if (logOpen) {
                print("有字节可读");
            }
            let data = self.readData()
            if (NSMessageHead.checkHeadByData(data: data)) {
                if (self.delegate != nil && self.delegate.responds(to: Selector.init(("onSocketGetMessage:")))) {
                self.delegate.onSocketGetMessage(messages:data.subdata(in: 8..<data.count - 8));
                }
            }
            break
        case Stream.Event.hasSpaceAvailable:
            if (logOpen) {
                print("可以发送字节");
            }
            
            canSendMesssage = true;
            if (self.delegate != nil && self.delegate.responds(to: Selector.init(("onSocketCanSendMessage"))))  {
                self.delegate.onSocketCanSendMessage()
            }
            break
        case Stream.Event.errorOccurred:
            if (logOpen) {
                print("连接出现错误");
            }
            if aStream == self.inputStream {
                isInputStreamOpenSuccess = false
            }else if aStream == self.outputStream {
                isOutputStreamOpenSuccess = false
            }
            isConnectSuccess = false
            if (self.delegate != nil && self.delegate.responds(to: Selector.init(("onSocketConnectWithResult:")))) {
                self.delegate.onSocketConnectWithResult(isSuccess: false)
            }
            break
        case Stream.Event.endEncountered:
            if logOpen {
                print("连接结束")
            }
            isConnectSuccess = false
            canSendMesssage = false
            isOutputStreamOpenSuccess = false
            isInputStreamOpenSuccess = false
            self.inputStream.close()
            self.outputStream.close()
            self.inputStream.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            self.outputStream.remove(from: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            if (self.delegate != nil && self.delegate.responds(to: Selector.init(("onSocketCloseConnect")))){
                self.delegate.onSocketCloseConnect()
            }
            break
        default:
            break
        }
    }


    func readData() -> Data {
        var data = Data.init()
        while self.inputStream.hasBytesAvailable {
            let bytes:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            let len = self.inputStream.read(bytes, maxLength:1024)
            let tmpData:Data = Data.init(bytes: bytes, count: len)
            data.append(tmpData)
        }
        return data
    }

    func sendMessage(msg:Data) -> Void {
        if (isConnectSuccess && canSendMesssage) {
            let head:NSMessageHead = NSMessageHead.init();
            head.length = Int32(msg.count) + 8;
            head.type = 0x01;
            head.version = NSSocketManager.version;
            var data:Data = Data.init();
            data.append(head.getHeadData())
            data.append(msg);
            let bytes:UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
            data.copyBytes(to: bytes, count: data.count)
            self.outputStream.write(bytes, maxLength: data.count)
        }else{
            if (logOpen) {
                print("Error:Connect has not connected")
            }
        }
    }
}
