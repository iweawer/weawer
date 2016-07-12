/**
 * 
 */
package ru.weawer.ww.settings;

import java.util.Map;

/**
 * @author iweawer
 * @date 2016.07.12
 */
public interface Setting {

	public Object fieldValue(String fieldName);
	
	public Object [] fieldValues();
	
	public Map<String, Object> fieldValuesAsMap();
	
	public String settingName();
	
	public String fullSettingName();
	
	public Iterable<SettingField> fields();

	public String sysKey();
	
	public long updateTS();
}
