package ru.weawer.ww.struct;

import java.nio.ByteBuffer;

public interface Struct {

	public String toJson();
	
	public void toByteArray(ByteBuffer buf);

}
