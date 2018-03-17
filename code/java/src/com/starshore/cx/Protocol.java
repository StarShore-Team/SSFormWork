package com.starshore.cx;


public class Protocol {
    private int magicNumber;//魔数
    private int length;//报文长度
    private byte type;//消息类别号
    private byte version;//消息版本号
    public static final int TOTAL_LENGTH = 64;//单位字节
    public static final int TOTAL_PROTOCOL_LENGTH = 8;//单位字节
    public static final int TOTAL_MESSAGE_LENGTH = 56;//单位字节
    public static final int TYPE_LITTLE_ENDIAN = 1;
    public static final int TYPE_BIG_ENDIN = 2;

    public void setLength(int length) {
        this.length = length;
    }

    public int getLength() {
        return length;
    }

    private Protocol() {
        this.magicNumber = 0x133ED55;
        this.length = TOTAL_PROTOCOL_LENGTH;

        this.type = 0x00;
        this.version = 0x01;
    }


    public byte[] getProtocolBuff(int type) {
        if (type == TYPE_BIG_ENDIN) {
            return getBigEndian();
        } else if (type == TYPE_LITTLE_ENDIAN) {
            return getLittleEndian();
        } else return null;
    }

    private byte[] getBigEndian() {
        byte[] bytes = new byte[Protocol.TOTAL_PROTOCOL_LENGTH];
        bytes[0] = (byte) ((magicNumber >>> 24) & 0xff);
        bytes[1] = (byte) ((magicNumber >>> 16) & 0xff);
        bytes[2] = (byte) ((magicNumber >>> 8) & 0xff);
        bytes[3] = (byte) ((magicNumber) & 0xff);
        bytes[4] = (byte) ((length >>> 8) & 0xff);
        bytes[5] = (byte) ((length) & 0xff);
        bytes[6] = type;
        bytes[7] = version;
        return bytes;
    }

    private byte[] getLittleEndian() {
        byte[] bytes = new byte[Protocol.TOTAL_PROTOCOL_LENGTH];
        bytes[0] = (byte) ((magicNumber) & 0xff);
        bytes[1] = (byte) ((magicNumber >>> 8) & 0xff);
        bytes[2] = (byte) ((magicNumber >>> 16) & 0xff);
        bytes[3] = (byte) ((magicNumber >>> 24) & 0xff);
        bytes[4] = (byte) ((length) & 0xff);
        bytes[5] = (byte) ((length >>> 8) & 0xff);
        bytes[6] = type;
        bytes[7] = version;
        return bytes;

    }

    public static Protocol getInstance() {
        return SingleHolder.instance;
    }


    private static class SingleHolder {
        private static final Protocol instance = new Protocol();
    }


}
