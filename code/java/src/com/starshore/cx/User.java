package com.starshore.cx;


public class User {

    public void test() {
        SSNetClient ssNetClient = new SSNetClient();
        boolean isConnect = ssNetClient.connect("192.168.1.17", 6688);
        System.out.println("连接是否成功" + isConnect);
        if (isConnect) {
            String s = "简单测试";
            byte[] bytes = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06};
            Protocol protocol = Protocol.getInstance();
            System.out.println("原始数据大小" + bytes.length);
            ssNetClient.send(ProtocolHelper.addProtocol(protocol, bytes));
            SSNetClient.RecvMessage recvMessage = ssNetClient.recv();
            System.out.print(recvMessage.error);
            if (recvMessage.recv != null) {
                for (byte b : recvMessage.recv) {
                    System.out.println(b);
                }
            }


        }


    }


    public static void main(String[] args) {
        User user = new User();
        user.test();
    }

}
