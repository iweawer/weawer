package ru.weawer.ww.settings;

import static org.junit.Assert.*;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestSettingsContainer {

	private SettingsContainer settingsContainer;
	
	@Before
	public void setUp() throws Exception {
		settingsContainer = new SettingsContainer();
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void test() {
		assertNotNull(settingsContainer);
	}

}
