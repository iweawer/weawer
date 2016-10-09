package ru.weawer.ww.struct;

import java.nio.ByteBuffer;

public interface Struct {

	public String toJson();
	public void toByteArray(ByteBuffer buf);
	public byte [] toByteArray();
	public int getByteSize();
	
	public static byte[] byteArrayFromString(String s) {
		s = s.trim();
		if(s.startsWith("[") && s.endsWith("]")) {
			s = s.substring(1, s.length() - 1);
			String [] bs = s.split(",");
			byte [] b = new byte[bs.length];
			for(int i = 0; i < bs.length; i++) {
				b[i] = Byte.parseByte(bs[i].trim());
			}
			return b;
		}
		throw new RuntimeException("Invalid format for byte array: " + s);
	}

}
