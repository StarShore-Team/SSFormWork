package com.starshore.cx;

import java.io.*;
import java.net.Socket;

public class SSNetClient implements ISSNetClient {
    private Socket socket;

    @Override
    public boolean connect(String host, int port) {
        if (host == null) return false;
        try {
            socket = new Socket(host, port);
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        }
        return true;
    }

    @Override
    public boolean close() {
        if (socket != null) {
            try {
                socket.close();
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
        return true;
    }

    @Override
    public int send(byte[] buffer) {
        if (buffer == null) return -1;
        try {
            OutputStream stream = socket.getOutputStream();
            stream.write(buffer);
            socket.shutdownOutput();
        } catch (IOException e) {
            e.printStackTrace();
            return -1;
        }
        return 0;
    }

    @Override
    public RecvMessage recv() {
        RecvMessage recvMessage = new RecvMessage();
        recvMessage.recv = null;
        if (socket == null) {
            recvMessage.error = -1;
            return recvMessage;
        }
        try {
            InputStream stream = socket.getInputStream();
            byte[] bytes = new byte[Protocol.TOTAL_LENGTH];
            BufferedInputStream bis = new BufferedInputStream(stream);
            int len = bis.read(bytes);
            byte[] bytes1 = new byte[len - Protocol.TOTAL_PROTOCOL_LENGTH];
            System.arraycopy(bytes, Protocol.TOTAL_PROTOCOL_LENGTH, bytes1, 0, bytes1.length);
            recvMessage.recv = bytes1;
        } catch (IOException e) {
            e.printStackTrace();
            recvMessage.error = -1;
            return recvMessage;
        }
        recvMessage.error = 0;
        return recvMessage;
    }

    @Override
    public void apply_protocol(int prot) {

    }

    @Override
    public void apply_version(int ver) {

    }

    static class RecvMessage {
        byte[] recv;
        int error;
    }

}
