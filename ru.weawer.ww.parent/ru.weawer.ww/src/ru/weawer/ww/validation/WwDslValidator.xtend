/*
 * generated by Xtext 2.10.0
 */
package ru.weawer.ww.validation

import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeParseException
import java.util.UUID
import java.util.regex.Pattern

import org.eclipse.xtext.validation.Check
import ru.weawer.ww.wwDsl.EnumField
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.Field
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.StructField
import ru.weawer.ww.wwDsl.TagWithValue
import ru.weawer.ww.wwDsl.TaggableElement
import ru.weawer.ww.wwDsl.WwDslPackage

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*


/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class WwDslValidator extends AbstractWwDslValidator {
	
//	public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					WwWwDslPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}

	@Check
	def void checkTagValue(TagWithValue v) {
		if(v.tag.hasValue && v.value == null) {
			error("Tag " + v.tag.name + " must have value", WwDslPackage.Literals.TAG_WITH_VALUE__TAG)
			return;
		}
		if(!v.tag.hasValue && v.value != null) {
			error("Tag " + v.tag.name + " must not have value", WwDslPackage.Literals.TAG_WITH_VALUE__TAG)
			return;
		}
	}
	
	@Check
	def void checkFieldDefaultValue(Field f) {
		if(f.^default != null) {
			if(f.type.list != null) {
				error("default is not supported for field of type List", WwDslPackage.Literals.FIELD__DEFAULT)
				return;
			} 
			if(f.type.map != null) {
				error("default is not supported for field of type Map", WwDslPackage.Literals.FIELD__DEFAULT)
				return;
			}
			if(f.type.ref != null) {
				if(f.type.ref  instanceof Struct) {
					error("default is not supported for field of type Struct", WwDslPackage.Literals.FIELD__DEFAULT)
					return;
				}
				if(f.type.ref instanceof EnumType) {
					val en = f.type.ref as EnumType
					if(f.^default.e == null) {
						error("default must be of enum type " + en.name, WwDslPackage.Literals.FIELD__DEFAULT)
						return;
					}
					val EnumField ef = f.^default.e;
					if(ef.eContainer != f.type.ref || !en.fields.contains(ef)) {
						error("Enum type mismatch", WwDslPackage.Literals.FIELD__DEFAULT)
						return;
					}
					return;
				} else {
					if(f.^default.e != null) {
						error("default can't be of enum type", WwDslPackage.Literals.FIELD__DEFAULT)
						return;
					}
				}
			}
			if(f.type.simple != null) {
				val t = f.^default.s;
				switch(f.type.simple) {
					case BOOLEAN: {
						if(!"true".equals(t) && !"false".equals(t)) {
							error("Invalid type: boolean is expected", WwDslPackage.Literals.FIELD__DEFAULT)
							return;
						}
					}
					case BYTE: {
						try {
							Byte.parseByte(t);
						} catch(NumberFormatException e) {
							error("Invalid type: byte is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case CHAR: {
						if(!Pattern.matches("'\\\\?.{1,1}'", t)) {
							error("Invalid type: char is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
						
					}
					case DATE: {
						try {
							LocalDate.parse(t);
						} catch(DateTimeParseException e) {
							error("Invalid type: date is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case DATETIME: {
						try {
							LocalDateTime.parse(t);
						} catch(DateTimeParseException e) {
							error("Invalid type: datetime is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case DOUBLE: {
						try {
							
							Double.parseDouble(t);
						} catch(NumberFormatException  e) {
							error("Invalid type: double is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case FLOAT: {
						try {
							Float.parseFloat(t);
						} catch(NumberFormatException  e) {
							error("Invalid type: float is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return; 
					}
					case GUID: {
						try {
							UUID.fromString(t);
						} catch(IllegalArgumentException  e) {
							error("Invalid type: UUID is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case INT: {
						try {
							Integer.parseInt(t);
						} catch(NumberFormatException  e) {
							error("Invalid type: int is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case LONG: {
						try {
							Long.parseLong(t)
						} catch(NumberFormatException  e) {
							error("Invalid type: long is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case SHORT: {
						try {
							Short.parseShort(t);
						} catch(NumberFormatException  e) {
							error("Invalid type: short is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case STRING: {
						if(!Pattern.matches("\".*\"", t)) {
							error("Invalid type: string is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case TIME: {
						try {
							LocalTime.parse(t);
						} catch(DateTimeParseException  e) {
							error("Invalid type: time is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case TIMESTAMP: {
						try {
							Long.parseLong(t);
						} catch(NumberFormatException  e) {
							error("Invalid type: long is expected", WwDslPackage.Literals.FIELD__DEFAULT)
						}
						return;
					}
					case BYTEARRAY: {
						error("default value for byte array not supported", WwDslPackage.Literals.FIELD__DEFAULT)
					}
					
				}
			}
		}
	}
		
	@Check
	def void checkStruct(Struct struct) {
		if(struct.fieldsExpr != null) {
			struct.fieldsExpr.forEach[{
				if(elemType != 'fields') {
					error("Only 'fields' allowed here in expression", WwDslPackage.Literals.STRUCT__FIELDS_EXPR)
				}
			}]
		}
	}
	
//	@Check
//	def void checkSetting(Struct setting) {
//		if(setting.ref != null && setting.ref.type != 'setting') {
//			error("Setting reference only allowed here", WwDslPackage.Literals.SETTING__REF)
//		}
//		if(setting.field != null && setting.field.type != 'setting') {
//			error("Setting only allowed here", WwDslPackage.Literals.SETTING__FIELD)
//		}
//	}
//	
//	@Check
//	def void checkSettingsContainer(SettingsContainer settingsContainer) { 
//		if(settingsContainer.fieldsExpr != null) {
//			settingsContainer.fieldsExpr.forEach[{
//				if(!'settings'.equals(elemType)) {
//					error("Only settings accepted", WwDslPackage.Literals.FILTER_EXPRESSION__ELEM_TYPE)
//				}
//			}]
//		}
//	}
	
	@Check
	def void checkEnumValues(EnumType e) {
		val allZeros = e.fields.map[^val].filter[it != 0].size == 0
		if(!allZeros) {
			if(e.arrayIndex) {
				error("Custom values are not allowed with 'ArrayIndex'", WwDslPackage.Literals.ENUM_TYPE__ARRAY_INDEX)
			}
		}
	}
	
	@Check
	def void checkEnumField(EnumField f) {
		val t = f.eContainer as EnumType;
		if(t.fields.filter[it != f].filter[name.equals(f.name)].size > 0) {
			error("Duplicate name", WwDslPackage.Literals.ENUM_FIELD__NAME)
		}
		val allZeros = t.fields.map[^val].filter[it != 0].size == 0
		if(!allZeros) {
			if(t.fields.filter[name != f.name].filter[^val == f.^val].size > 0) {
				error("Duplicate field value", WwDslPackage.Literals.ENUM_FIELD__VAL)
			}
		}
	}
	
//	@Check 
//	def public void checkSingleVsKeyedOnStruct(Struct s) {
//		if(!s.single) {
//			for(Field f : s.keys) {
//				if(!s.structFields.map[fullname].contains(f.fullname)) {
//					error("Key is missing in fields. Either add field or remove this key", WwDslPackage.Literals.STRUCT__KEYS)
//				}
//			}
//		}
//	}
	
	@Check
	def public void checkStructField(StructField f) {
		// TODO tkacigo: add validation
//		val t = f.eContainer as EnumType;
//		if(t.fields.filter[it != f].filter[name.equals(f.name)].size > 0) {
//			error("Duplicate name", WwDslPackage.Literals.ENUM_FIELD__NAME)
//		}
//		if(t.fields.filter[name != f.name].filter[^val == f.^val].size > 0) {
//			error("Duplicate field value", WwDslPackage.Literals.ENUM_FIELD__VAL)
//		}
	}
	
	@Check
	def public void checkTagUniqueness(TaggableElement e) {
		if(e.tags == null) return;
		for(var i = 0; i < e.tags.size; i++) {
			for(var j = 0; j < e.tags.size; j++) {
				if(i != j) {
					if(e.tags.get(i).tag.name == e.tags.get(j).tag.name) {
						if(e.tags.get(i).value == null && e.tags.get(j).value == null) {
							error("Duplicated tags", WwDslPackage.Literals.TAGGABLE_ELEMENT__TAGS)
						} else if(e.tags.get(i).value == e.tags.get(j).value) {
							error("Duplicated values", WwDslPackage.Literals.TAGGABLE_ELEMENT__TAGS)
						}
					}
				} 
			}
		}
	}
	
//	@Check
//	def public void checkDuplicates(Struct s) {
//		val fields = s.structFields
//		for(var i = 0; i < fields.size; i++) {
//			for(var j = i + 1; j < fields.size; j++) {
//				if(fields.get(i).name.equals(fields.get(j).name)) {
//					error("Duplicated name", WwDslPackage.Literals.STRUCT__FIELDS)
//				}
//			}
//		}
//	}
//	
//	@Check
//	def public void checkDuplicates(EnumType s) {
//		for(var i = 0; i < s.fields.size; i++) {
//			for(var j = i + 1; j < s.fields.size; j++) {
//				if(s.fields.get(i).name.equals(s.fields.get(j).name)) {
//					error("Duplicated name", WwDslPackage.Literals.ENUM_TYPE__FIELDS)
//				}
//			}
//		}
//	}
	
}
