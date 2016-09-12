package ru.weawer.ww.settings;

public interface SettingsListener {

	void settingsChanged(Iterable<Setting> settings);
	void settingsDeleted(String category, Iterable<String> keys);
}
