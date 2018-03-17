package com.starshore.cx;

public interface ISSNetClient {
    // 与服务端建立连接
    public boolean connect(String host, int port);

    // 与服务器断开连接
    public boolean close();

    // 同步发送
    public int send(byte[] buffer);

    // 同步接受
    public SSNetClient.RecvMessage recv();

    // 设置默认协议号
    public void apply_protocol(int prot);

    // 设置默认版本号
    public void apply_version(int ver);
}



