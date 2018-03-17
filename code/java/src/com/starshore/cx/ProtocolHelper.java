package com.starshore.cx;

public class ProtocolHelper {

    public static byte[] addProtocol(Protocol protocol,byte[] buffer) {
        if (buffer == null||protocol==null) throw new NullPointerException();
        if (buffer.length > Protocol.TOTAL_MESSAGE_LENGTH) throw new ArrayIndexOutOfBoundsException();
        protocol.setLength(Protocol.TOTAL_PROTOCOL_LENGTH+buffer.length);
        byte[] protocolBuff = protocol.getProtocolBuff(Protocol.TYPE_BIG_ENDIN);
        byte[]res=new byte[protocol.getLength()];
        System.arraycopy(protocolBuff,0,res,0,protocolBuff.length);
        System.arraycopy(buffer, 0, res, Protocol.TOTAL_PROTOCOL_LENGTH, buffer.length);
        return res;
    }


}