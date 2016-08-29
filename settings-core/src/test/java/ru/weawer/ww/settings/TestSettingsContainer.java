package ru.weawer.ww.settings;

import static org.junit.Assert.*;

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

}
