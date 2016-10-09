package ru.weawer.ww.common;

import static org.junit.Assert.*;

import java.util.Set;

import org.junit.After;
import org.junit.BeforeClass;
import org.junit.Test;

import com.google.common.collect.Sets;

import ru.weawer.ww.wwDsl.Struct;
import ru.weawer.ww.wwDsl.Tag;

public class TestModelProvider {

	private static ModelProvider modelProvider;
	
	@BeforeClass
	public static void setUp() throws Exception {
		modelProvider = ModelProvider.instance();
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void testGetSettingsByAnyTag() {
		Set<Struct> settings = modelProvider.getSettingsByAnyTag(Sets.newHashSet("Complex", "Simple"));
		assertEquals(settings.size(), 2);
		assertTrue(settings.stream().filter(s -> s.getName().equals("ComplexTypes")).findFirst().isPresent());
		assertTrue(settings.stream().filter(s -> s.getName().equals("SimpleTypes")).findFirst().isPresent());
		
		settings = modelProvider.getSettingsByAnyTag(Sets.newHashSet());
		assertEquals(settings.size(), 0);
	}
	
	@Test
	public void testGetSettingsByAllTags() {
		Set<Struct> settings = modelProvider.getSettingsByAllTags(Sets.newHashSet("Complex", "Simple"));
		assertEquals(0, settings.size());
		
		settings = modelProvider.getSettingsByAllTags(Sets.newHashSet("TDEV", "TTAG"));
		assertEquals(1, settings.size());
		
		settings = modelProvider.getSettingsByAllTags(Sets.newHashSet("TPROD", "TTAG", "Simple"));
		assertEquals(1, settings.size());
		
		settings = modelProvider.getSettingsByAllTags(Sets.newHashSet("TDEV", "TPROD"));
		assertEquals(0, settings.size());
	}

	@Test
	public void testGetElementsByAnyTag() {
		Set<Tag> elements = modelProvider.getElementsByAnyTag(Tag.class, Sets.newHashSet("TENV"));
		assertEquals(elements.size(), 2);
		assertTrue(elements.stream().filter(s -> s.getName().equals("TPROD")).findFirst().isPresent());
		assertTrue(elements.stream().filter(s -> s.getName().equals("TDEV")).findFirst().isPresent());
		
		elements = modelProvider.getElementsByAnyTag(Tag.class, Sets.newHashSet());
		assertEquals(elements.size(), 0);
		
		elements = modelProvider.getElementsByAnyTag(Tag.class, Sets.newHashSet("Str"));
		assertEquals(elements.size(), 0);
		
		Set<Struct> structElements = modelProvider.getElementsByAnyTag(Struct.class, Sets.newHashSet("Str"));
		assertEquals(structElements.size(), 2);
		assertTrue(structElements.stream().filter(s -> s.getName().equals("MyStr1")).findFirst().isPresent());
		assertTrue(structElements.stream().filter(s -> s.getName().equals("MyStr2")).findFirst().isPresent());
	}
	
	@Test
	public void testGetElementsByAllTags() {
		Set<Struct> settings = modelProvider.getElementsByAllTags(Struct.class, Sets.newHashSet("Complex", "Simple"));
		assertEquals(0, settings.size());
		
		settings = modelProvider.getElementsByAllTags(Struct.class, Sets.newHashSet("TDEV", "TTAG"));
		assertEquals(1, settings.size());
		
		settings = modelProvider.getElementsByAllTags(Struct.class, Sets.newHashSet("TPROD", "TTAG", "Simple"));
		assertEquals(1, settings.size());
		
		settings = modelProvider.getElementsByAllTags(Struct.class, Sets.newHashSet("TDEV", "TPROD"));
		assertEquals(0, settings.size());
	}

}
