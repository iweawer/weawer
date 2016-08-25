/**
 * 
 */
package ru.weawer.ww.settings;

/**
 * @author iweawer
 * @date 2016.07.12
 */
public interface Setting {
	
	String shortSettingName();
	String settingName();
	String sysKey();
	long updateTS();
}
