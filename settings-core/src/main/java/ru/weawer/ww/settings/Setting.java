/**
 * 
 */
package ru.weawer.ww.settings;

import ru.weawer.ww.struct.Struct;

/**
 * @author iweawer
 * @date 2016.07.12
 */
public interface Setting extends Struct {
	
	public static final String SYS_KEY_SEPARATOR = ".";
	
	String shortSettingName();
	String settingName();
	String sysKey();
	long updateTS();
}
