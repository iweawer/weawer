package ru.weawer.ww.settings;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.Sets;

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
		assertNotNull(settingsContainer);
	}

}
