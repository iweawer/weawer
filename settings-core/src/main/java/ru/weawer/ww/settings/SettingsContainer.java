package ru.weawer.ww.settings;

import java.util.Map;
import java.util.Set;

import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;

public class SettingsContainer {

	private final ImmutableMap<String, Class<? extends Setting>> supportedSettings;
	private final Map<String, Map<String, ? extends Setting>> settings = Maps.newHashMap();
	
	public SettingsContainer(Set<Class<? extends Setting>> supportedSettings) {
		Preconditions.checkArgument(supportedSettings != null, "You must provide supportedSettings");
		ImmutableMap.Builder<String, Class<? extends Setting>> builder = ImmutableMap.builder();
		supportedSettings.forEach((Class<? extends Setting> c) -> {
			builder.put(c.getName(), c);
		});
		this.supportedSettings = builder.build();
	}
}
