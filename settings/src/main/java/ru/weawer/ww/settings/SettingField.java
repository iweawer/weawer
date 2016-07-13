package ru.weawer.ww.settings;

import com.google.common.base.Preconditions;

/**
 * 
 * @author iweawer
 * @date 2016.07.12
 */
public class SettingField {

	private final String settingName;
	private final String sysKey;
	private final String fieldName;
	private String strVal;
	private Double val;
	
	private SettingField(String settingName, String sysKey, String fieldName) {
		Preconditions.checkArgument(settingName != null, "settingName is null");
		Preconditions.checkArgument(sysKey != null, "sysKey is null");
		Preconditions.checkArgument(fieldName != null, "fieldName is null");
		this.settingName = settingName;
		this.sysKey = sysKey;
		this.fieldName = fieldName;
	}
	
	public SettingField(String settingName, String sysKey, String fieldName, String strVal) {
		this(settingName, sysKey, fieldName);
		Preconditions.checkArgument(strVal != null, "Value is null");
		this.strVal = strVal;
		this.val = null;
	}
	
	public SettingField(String settingName, String sysKey, String fieldName, double val) {
		this(settingName, sysKey, fieldName);
		this.strVal = null;
		this.val = val;
	}
	
	public String settingName() {
		return settingName;
	}
	
	public String sysKey() {
		return sysKey;
	}
	
	public String fieldName() {
		return fieldName;
	}
	
	public double val() {
		if(val == null) {
			throw new RuntimeException("Invalid value requested. " + fieldName + " is string type");
		}
		return val;
	};
	
	public String strVal() {
		if(strVal == null) {
			throw new RuntimeException("Invalid value requested. " + fieldName + " is double type");
		}
		return strVal;
	}
}
