/**
 * 
 */
package ru.weawer.ww.settings;

/**
 * @author iweawer
 * @date 2016.07.12
 */
public interface Setting {
	
	public static final String SYS_KEY_SEPARATOR = ".";
	
	String shortSettingName();
	String settingName();
	String sysKey();
	long updateTS();
}
