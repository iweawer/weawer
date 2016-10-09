package ru.weawer.ww.settings;

import java.util.Set;

import org.junit.After;
import org.junit.BeforeClass;
import org.junit.Test;

import com.google.common.collect.Lists;
import com.google.common.collect.Sets;

import ru.weawer.ww.common.ModelProvider;
import ru.weawer.ww.sett.AnotherSetting;
import ru.weawer.ww.sett.ComplexTypes;
import ru.weawer.ww.sett.SimpleTypes;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static ru.weawer.ww.settings.TestStructUtils.*;

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
	public void testSupportedSettings() {
		Set<Class<Setting>> supportedSettings = ModelProvider.toClasses(modelProvider.getSettingsByAnyTag(Sets.newHashSet("TTAG")));
		SettingsContainer c = new SettingsContainer(supportedSettings);
		Listener l = new Listener();
		c.addListener(l);
		c.updateSettings("testuser", Sets.newHashSet(getSimpleTypes(), getComplexTypes(), 
				AnotherSetting.builder().id("id42").build()), "Create setting");
		
		
		
		assertEquals(2, Sets.newHashSet(l.changed).size());
		assertNull(l.deletedCategory);
		assertNull(l.deletedKeys);

		SimpleTypes st = c.getSetting(SimpleTypes.class.getName(), "true." + Integer.MAX_VALUE, SimpleTypes.class);
		assertTrue(getSimpleTypes().equals(st));

		ComplexTypes ct = c.getSingleSetting(ComplexTypes.class.getName(), ComplexTypes.class);
		assertTrue(getComplexTypes().equals(ct));
		
		assertNull(c.getSettings(AnotherSetting.class.getName()));
	}
	
	@Test
	public void testUnsupportedSettings() {
		Set<Class<Setting>> supportedSettings = ModelProvider.toClasses(modelProvider.getSettingsByAnyTag(Sets.newHashSet("TTAG")));
		SettingsContainer c = new SettingsContainer(supportedSettings);
		Listener l = new Listener();
		c.addListener(l);
		c.updateSettings("testuser", Sets.newHashSet(AnotherSetting.builder().id("id42").build()), "Create setting");

		assertNull(l.changed);
		assertNull(l.deletedCategory);
		assertNull(l.deletedKeys);
	}

	
	@Test
	public void testUpdateSettings() {
		Set<Class<Setting>> supportedSettings = ModelProvider.toClasses(modelProvider.getSettingsByAnyTag(Sets.newHashSet("TTAG")));
		SettingsContainer c = new SettingsContainer(supportedSettings);
		Listener l = new Listener();
		c.addListener(l);
		assertEquals(0, c.getSettings(SimpleTypes.class.getName()).size());
		assertEquals(0, c.getSettings(ComplexTypes.class.getName()).size());
		SimpleTypes t = getSimpleTypes();
		c.updateSettings("testuser", Sets.newHashSet(t), "Create setting");
		assertEquals(1, c.getSettings(SimpleTypes.class.getName()).size());
		
		c.updateSettings("testuser", Sets.newHashSet(t.copy().c('5').build()), "Create setting");
		assertEquals(1, c.getSettings(SimpleTypes.class.getName()).size());
		SimpleTypes st = c.getSetting(SimpleTypes.class.getName(), "true." + Integer.MAX_VALUE, SimpleTypes.class);
		assertEquals(st.c(), '5');
		
		assertEquals(1, Sets.newHashSet(l.changed).size());
		assertNull(l.deletedCategory);
		assertNull(l.deletedKeys);
		
		c.updateSettings("testuser", Sets.newHashSet(t.copy().b(false).build()), "Create setting");
		assertEquals(2, c.getSettings(SimpleTypes.class.getName()).size());
		assertEquals(1, Sets.newHashSet(l.changed).size());
		assertNull(l.deletedCategory);
		assertNull(l.deletedKeys);
	}
	
	@Test
	public void testDeleteSettings() {
		Set<Class<Setting>> supportedSettings = ModelProvider.toClasses(modelProvider.getSettingsByAnyTag(Sets.newHashSet("TTAG")));
		SettingsContainer c = new SettingsContainer(supportedSettings);
		Listener l = new Listener();
		c.addListener(l);
		assertEquals(0, c.getSettings(SimpleTypes.class.getName()).size());
		assertEquals(0, c.getSettings(ComplexTypes.class.getName()).size());
		SimpleTypes t = getSimpleTypes();
		c.updateSettings("testuser", Sets.newHashSet(t), "Create setting");
		
		assertEquals(1, c.getSettings(SimpleTypes.class.getName()).size());
		
		c.deleteSettings("testuser", t.settingName(), Sets.newHashSet(t.sysKey()), "detete setting");
		assertEquals(0, c.getSettings(t.settingName()).size());
		assertEquals(l.deletedCategory, t.settingName());
		assertEquals(Lists.newArrayList(l.deletedKeys).get(0), t.sysKey());
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

}
