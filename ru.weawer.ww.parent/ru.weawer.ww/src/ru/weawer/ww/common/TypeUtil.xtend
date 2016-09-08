package ru.weawer.ww.common

import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.Map
import ru.weawer.ww.wwDsl.SimpleType
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type
import ru.weawer.ww.wwDsl.Interface

public class TypeUtil {
	
	def public static boolean isSimple(Type type) {
		return type.simple != null && type.ref == null && type.map == null && type.list == null
	}
	
	def public static boolean isEnum(Type type) {
		return type.ref != null && type.ref instanceof EnumType
	}
	
	def public static boolean isMap(Type type) {
		return type.map != null
	}
	
	def public static boolean isList(Type type) {
		return type.list != null
	}
	
	def public static boolean isStruct(Type type) {
		return type.ref != null && type.ref instanceof Struct
	}
	
	def public static boolean isInterface(Type type) {
		return type.ref != null && type.ref instanceof Interface
	}
	
	def public static String toJavaType(SimpleType type) {
		switch(type) {
			case SimpleType.BOOLEAN: return "boolean"
			case SimpleType.BYTE: return "byte"
			case SimpleType.CHAR: return "char"
			case SimpleType.SHORT: return "short"
			case SimpleType.INT: return "int"
			case SimpleType.LONG: return "long"
			case SimpleType.FLOAT: return "float"
			case SimpleType.DOUBLE: return "double"
			case SimpleType.STRING: return "String"
			case SimpleType.DATE: return "LocalDate"
			case SimpleType.TIME: return "LocalTime"
			case SimpleType.DATETIME: return "LocalDateTime"
			case SimpleType.TIMESTAMP: return "long"
			case SimpleType.GUID: return "java.util.UUID"
			case SimpleType.BYTEARRAY: return "byte[]"
		}
	}
	
	def public static String toJavaObjectType(SimpleType type) {
		switch(type) {
			case SimpleType.BOOLEAN: return "Boolean"
			case SimpleType.BYTE: return "Byte"
			case SimpleType.CHAR: return "Character"
			case SimpleType.SHORT: return "Short"
			case SimpleType.INT: return "Integer"
			case SimpleType.LONG: return "Long"
			case SimpleType.FLOAT: return "Float"
			case SimpleType.DOUBLE: return "Double"
			case SimpleType.STRING: return "String"
			case SimpleType.DATE: return "LocalDate"
			case SimpleType.TIME: return "LocalTime"
			case SimpleType.DATETIME: return "LocalDateTime"
			case SimpleType.TIMESTAMP: return "Long"
			case SimpleType.GUID: return "java.util.UUID"
			case SimpleType.BYTEARRAY: return "byte[]"
		}
	}
	
	def public static String toJavaObjectType(Type type) {
		if(type.isJavaSimpleType) {
			return toJavaObjectType(type.simple);
		}
		return toJavaType(type)
	}
	
	def public static String toJavaType(Type type) {
		if(isSimple(type)) {
			return toJavaType(type.simple)
		} else if(isEnum(type)) {
			return Util.getFullname(type.ref as EnumType)
		} else if(isMap(type)) {
			return toJavaType(type.map)
		} else if(isList(type)) {
			return toJavaType(type.list)
		} else if(isStruct(type)) {
			return Util.getFullname(type.ref as Struct)
		} else if(isInterface(type)) {
			return Util.getFullname(type.ref as Interface)
		}
		return null;
	}
	
	def public static String toJavaType(Map map) {
		return "Map<" + toJavaObjectType(map.key) + ", " + toJavaObjectType(map.value) + ">"
	}
	
	def public static String toJavaType(List list) {
		return "List<" + toJavaObjectType(list.elem) + ">"
	}
	
	def public static String toName(Map map) {
		return "Map" + map.key.toName + map.value.toName
	}
	
	def public static String toName(List list) {
		return "List" + list.elem.toName
	}
	
	def public static String toName(Type type) {
		if(isSimple(type)) {
			return type.simple.getName
		} else if(isEnum(type)) {
			return Util.getLongname(type.ref as EnumType)
		} else if(isMap(type)) {
			return toName(type.map)
		} else if(isList(type)) {
			return toName(type.list)
		} else if(isStruct(type)) {
			return Util.getLongname(type.ref as Struct)
		}
		return null;
	}
	
	def public static boolean isJavaSimpleType(Type type) {
		if(isSimple(type)) {
			return isJavaSimpleType(type.simple)
		}
		return false
	}
	
	
	
	def public static boolean isJavaSimpleType(SimpleType type) {
		switch(type) {
			case SimpleType.BOOLEAN: return true
			case SimpleType.BYTE: return true
			case SimpleType.CHAR: return true
			case SimpleType.SHORT: return true
			case SimpleType.INT: return true
			case SimpleType.LONG: return true
			case SimpleType.FLOAT: return true
			case SimpleType.DOUBLE: return true
			case SimpleType.STRING: return false
			case SimpleType.DATE: return false
			case SimpleType.TIME: return false
			case SimpleType.DATETIME: return false
			case SimpleType.TIMESTAMP: return true
			case SimpleType.GUID: return false
			default: return false
		}
	}
	
	def public static String getTypeName(Type type) {
		if(isSimple(type)) {
			return type.simple.getName
		} else if(isEnum(type)) {
			return Util.getFullname(type.ref as EnumType)
		} else if(isMap(type)) {
			return "map<" + getTypeName(type.map.key) + ", " + getTypeName(type.map.value) + ">"
		} else if(isList(type)) {
			return "list<" + toJavaObjectType(type.list.elem) + ">"
		} else if(isStruct(type)) {
			return Util.getFullname(type.ref as Struct)
		}
		return null;
	}
	
	def public static String javaToJson(Type type, String name) {
		return javaToJson(type, name, 0);
	}
	
	def private static String javaToJson(Type type, String name, int count) {
		if(isSimple(type)) {
			return simpleTypeToJson(type, name);
		} else if(isEnum(type)) {
			return '''"\"" + «name».name() + "\""''';
		} else if(isMap(type)) {
			return '''"{" + «name».entrySet().stream().map(e«count» -> «javaToJson(type.map.key, "e"+count + ".getKey()", count+1)» + ":" + «javaToJson(type.map.value, "e"+count+".getValue()", count+1)»).collect(Collectors.joining(",")) + "}"'''
		} else if(isList(type)) {
			return '''"[" + «name».stream().map(e«count» -> «javaToJson(type.list.elem, "e"+count, count+1)»).collect(Collectors.joining(",")) + "]"'''
		} else if(isStruct(type) || isInterface(type)) {
			return '''JSONStructSerializer.toJson(«name»)'''
		}
		return null;
	}
	
	def private static String simpleTypeToJson(Type type, String name) {
		switch(type.simple) {
			case SimpleType.BOOLEAN: return name
			case SimpleType.BYTE: return name
			case SimpleType.CHAR: return '''"\"" + String.valueOf(«name») + "\""'''
			case SimpleType.SHORT: return name
			case SimpleType.INT: return name
			case SimpleType.LONG: return name
			case SimpleType.FLOAT: return name
			case SimpleType.DOUBLE: return name
			case SimpleType.STRING: return '''"\"" + «name» + "\""'''
			case SimpleType.DATE: return '''"\"" + String.valueOf(«name») + "\""'''
			case SimpleType.TIME: return '''"\"" + String.valueOf(«name») + "\""'''
			case SimpleType.DATETIME: return '''"\"" + String.valueOf(«name») + "\""'''
			case SimpleType.TIMESTAMP: return name
			case SimpleType.GUID: return '''"\"" + String.valueOf(«name») + "\""'''
			case SimpleType.BYTEARRAY: return '''"\"" + Arrays.toString(«name») + "\""'''
		}
	}
	
	def public static String hashCode(Type type, String name) {
		switch(type.simple) {
			case SimpleType.BOOLEAN: return "(" + name + " ? 1 : 0)"
			case SimpleType.BYTE: return name
			case SimpleType.CHAR: return "(int) " + name
			case SimpleType.SHORT: return name
			case SimpleType.INT: return name
			case SimpleType.LONG: return "(int) " + name
			case SimpleType.FLOAT: return "(int) " + name
			case SimpleType.DOUBLE: return "(int) " + name
			case SimpleType.STRING: return name + ".hashCode()"
			case SimpleType.DATE: return name + ".hashCode()"
			case SimpleType.TIME: return name + ".hashCode()"
			case SimpleType.DATETIME: return name + ".hashCode()"
			case SimpleType.TIMESTAMP: return "(int) " + name
			case SimpleType.GUID: return name + ".hashCode()"
			case SimpleType.BYTEARRAY: return "Arrays.toString(" + name + ").hashCode()"
		}
	}
	
	def public static String equals(Type type, String name) {
		switch(type.simple) {
			case SimpleType.BOOLEAN: '''this.«name»() == that.«name»()'''
			case SimpleType.BYTE: return '''this.«name»() == that.«name»()'''
			case SimpleType.CHAR: return '''this.«name»() == that.«name»()'''
			case SimpleType.SHORT: return '''this.«name»() == that.«name»()'''
			case SimpleType.INT: return '''this.«name»() == that.«name»()'''
			case SimpleType.LONG: return '''this.«name»() == that.«name»()'''
			case SimpleType.FLOAT: return '''this.«name»() == that.«name»()'''
			case SimpleType.DOUBLE: return '''this.«name»() == that.«name»()'''
			case SimpleType.STRING: return '''this.«name»().equals(that.«name»())'''
			case SimpleType.DATE: return '''this.«name»().equals(that.«name»())'''
			case SimpleType.TIME: return '''this.«name»().equals(that.«name»())'''
			case SimpleType.DATETIME: return '''this.«name»().equals(that.«name»())'''
			case SimpleType.TIMESTAMP: return '''this.«name»() == that.«name»()'''
			case SimpleType.GUID: return '''this.«name»().equals(that.«name»())'''
			case SimpleType.BYTEARRAY: return '''Arrays.equals(this.«name»(), that.«name»())'''
		}
	}
	
	def public static print(Type t) {
		println("Type: " + t)
		println("TypeName: " + t.typeName)
		println("isSimple: " + isSimple(t))
		println("isEnum: " + isEnum(t))
		println("isMap: " + isMap(t))
		println("isList: " + isList(t))
		println("isStruct: " + isStruct(t))
		println("javaObjectType: " + toJavaObjectType(t))		
	}
}
