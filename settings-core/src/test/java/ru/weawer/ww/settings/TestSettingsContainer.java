package ru.weawer.ww.settings;

import static org.junit.Assert.*;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.stream.IntStream;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.Sets;

import ru.weawer.ww.struct.Struct;

public class TestSettingsContainer {

	private SettingsContainer settingsContainer;
	
	@Before
	public void setUp() throws Exception {
		settingsContainer = new SettingsContainer(Sets.newHashSet());
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		byte [] b = new byte[]{0x00, 0x01, 0x7F};
		System.out.println(Arrays.toString(b));
		
		byte [] b1 = Struct.byteArrayFromString(Arrays.toString(b));
		System.out.println(Arrays.toString(b1));
	}
	
	public static void main(String[] args) {
		byte [] b = new byte[10];
		ByteBuffer buf = ByteBuffer.wrap(b);
		buf.putInt(100);
		buf.putInt(200);
		buf.putChar('a');
		buf.flip();
		int pos = buf.position();
		int i1 = buf.getInt();
		buf.position(pos);
		i1 = buf.getInt();
		int i2 = buf.getInt();
		char c = buf.getChar();
		buf.rewind();
		
	}

}
