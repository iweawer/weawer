package ru.weawer.ww.settings;

public interface SettingsClient {

	void updateSettings(String user, Iterable<Setting> settings, String comment);
	void deleteSettings(String user, String category, Iterable<String> keys, String comment);
}
