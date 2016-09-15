package ru.weawer.ww.settings;

import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Joiner;
import com.google.common.base.Preconditions;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

public class SettingsContainer implements SettingsClient {

	private static final Logger logger = LoggerFactory.getLogger(SettingsContainer.class);
	
	private final ImmutableMap<String, Class<Setting>> supportedSettings;
	private final Map<String, Map<String, Setting>> settings = Maps.newHashMap();
	
	private final Set<SettingsListener> listeners = Sets.newHashSet();
	
	public SettingsContainer(Set<Class<Setting>> supportedSettings) {
		Preconditions.checkArgument(supportedSettings != null, "You must provide supportedSettings");
		ImmutableMap.Builder<String, Class<Setting>> builder = ImmutableMap.builder();
		supportedSettings.forEach((Class<Setting> c) -> {
			builder.put(c.getName(), c);
			settings.put(c.getName(), Maps.newConcurrentMap());
		});
		this.supportedSettings = builder.build();
	}
	
	public synchronized void addListener(SettingsListener settingsListener) {
		listeners.add(settingsListener);
	}
	
	public synchronized void removeListener(SettingsListener settingsListener) {
		listeners.remove(settingsListener);
	}

	@Override
	public synchronized void updateSettings(String user, Iterable<Setting> sett, String comment) {
		Set<Setting> settingsToUpdate = Sets.newHashSet();
		for(Setting s : sett) {
			if(supportedSettings.containsKey(s.settingName())) {
				if(logger.isDebugEnabled()) {
					logger.debug("updateSettings: " + s.toJson());
				}
				Map<String, Setting> map = this.settings.get(s.settingName());
				map.put(s.sysKey(), s);
				settingsToUpdate.add(s);
			}
		}
		if(settingsToUpdate.size() > 0) {
			listeners.forEach(listener -> listener.settingsChanged(settingsToUpdate));
		}
	}

	@Override
	public synchronized void deleteSettings(String user, String category, Iterable<String> keys, String comment) {
		if(!supportedSettings.containsKey(category)) return;
		if(logger.isDebugEnabled()) {
			logger.debug("deleteSettings: user={}, category={}, keys={}, comment={}", user, category, Joiner.on(",").join(keys), comment);
		}
		Map<String, Setting> map = settings.get(category);
		if(map != null) {
			keys.forEach(k -> map.remove(k));
		}
		if(keys.iterator().hasNext()) {
			listeners.forEach(listener -> listener.settingsDeleted(category, keys));
		}
	}
	
	public <T extends Setting> Map<String, T> getSettings(String category, Class<T> clazz) {
		return (Map<String, T>) settings.get(category);
	}
	
	public Map<String, Setting> getSettings(String category) {
		return settings.get(category);
	}
	
	public <T extends Setting> T getSetting(String category, String key, Class<T> clazz) {
		return (T) settings.get(category).get(key);
	}
	
	public <T extends Setting> T getSingleSetting(String category, Class<T> clazz) {
		if(isSupported(category)) {
			return (T) settings.get(category).get(category);
		}
		return null;
	}
	
	public Setting getSingleSetting(String category) {
		if(isSupported(category)) {
			return settings.get(category).get(category);
		}
		return null;
	}
	
	public boolean isSupported(String category) {
		return supportedSettings.containsKey(category);
	}
	
	public boolean isSupported(Class<? extends Setting> clazz) {
		return supportedSettings.containsValue(clazz);
	}
}
