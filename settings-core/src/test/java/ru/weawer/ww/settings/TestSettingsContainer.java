package ru.weawer.ww.settings;

import static org.junit.Assert.*;

import java.nio.ByteBuffer;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

import com.google.common.collect.Sets;

import ru.weawer.ww.common.ModelProvider;
import ru.weawer.ww.common.TypeUtil;
import ru.weawer.ww.common.Util;
import ru.weawer.ww.sett.En1;
import ru.weawer.ww.sett.SimpleTypes;
import ru.weawer.ww.struct.Struct;

public class TestSettingsContainer {

private static ModelProvider modelProvider;
	
	@BeforeClass
	public static void setUp() throws Exception {
		modelProvider = ModelProvider.instance();
	}
	
	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		Set<Class<Setting>> supportedSettings = ModelProvider.toClasses(modelProvider.getSettingsByAnyTag(Sets.newHashSet("TTAG")));
		SettingsContainer c = new SettingsContainer(supportedSettings);
		Listener l = new Listener();
		c.addListener(l);
		
	}
	
	private class Listener implements SettingsListener {

		Iterable<Setting> changed;
		String deletedCategory;
		Iterable<String> deletedKeys;
		
		@Override
		public void settingsChanged(Iterable<Setting> settings) {
			changed = settings;
		}

		@Override
		public void settingsDeleted(String category, Iterable<String> keys) {
			deletedCategory = category;
			deletedKeys = keys;
		}
		
		public void clear() {
			changed = null;
			deletedCategory = null;
			deletedKeys = null;
		}
		
	}
	
	private SimpleTypes getSimpleTypes() {
		LocalDate d = LocalDate.now();
		LocalTime t = LocalTime.now();
		LocalDateTime dt = LocalDateTime.now();
		long ts = System.currentTimeMillis();
		UUID uuid = UUID.randomUUID();
		
		return SimpleTypes.builder()
				.en(En1.ONE)
				.b(true)
				.bt((byte) 0x02)
				.c('f')
				.s((short) -12)
				.i(Integer.MAX_VALUE)
				.l(-200000)
				.f(23.23f)
				.dds(1.1e-18)
				.str("Hello, world!")
				.d(d)
				.t(t)
				.dt(dt)
				.ts(ts)
				.g(uuid)
				.ba(new byte[] { 0x12, 0x13 })
				.build();
	}

}
