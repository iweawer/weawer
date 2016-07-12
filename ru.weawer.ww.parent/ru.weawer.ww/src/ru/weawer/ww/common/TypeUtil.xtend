package ru.weawer.ww.common

import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.Map
import ru.weawer.ww.wwDsl.SimpleType

import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type
import ru.weawer.ww.wwDsl.EnumType

public class TypeUtil {
	
	def public static boolean isSimple(Type type) {
		return type.simple != null
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
	
	def public static String toJavaType(SimpleType type) {
		switch(type.getName) {
			case "boolean": return "boolean"
			case "byte": return "byte"
			case "char": return "char"
			case "short": return "short"
			case "int": return "int"
			case "long": return "long"
			case "float": return "float"
			case "double": return "double"
			case "string": return "String"
			case "date": return "LocalDate"
			case "time": return "LocalTime"
			case "datetime": return "LocalDateTime"
			case "timestamp": return "long"
			case "guid": return "java.util.UUID"
		}
	}
	
	def public static String toJavaObjectType(SimpleType type) {
		switch(type.getName) {
			case "boolean": return "Boolean"
			case "byte": return "Byte"
			case "char": return "Character"
			case "short": return "Short"
			case "int": return "Integer"
			case "long": return "Long"
			case "float": return "Float"
			case "double": return "Double"
			case "string": return "String"
			case "date": return "LocalDate"
			case "time": return "LocalTime"
			case "datetime": return "LocalDateTime"
			case "timestamp": return "Long"
			case "guid": return "java.util.UUID"
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
			toJavaType(type.simple)
		} else if(isEnum(type)) {
			return Util.getFullname(type.ref as EnumType)
		} else if(isMap(type)) {
			return "Map<" + toJavaObjectType(type.map.key) + ", " + toJavaObjectType(type.map.value) + ">"
		} else if(type instanceof List) {
			return "List<" + toJavaObjectType(type.elem) + ">"
		} else if(type instanceof Struct) {
			return Util.getFullname(type)
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
		} else if(type instanceof Map) {
			return "map<" + getTypeName(type.map.key) + ", " + getTypeName(type.map.value) + ">"
		} else if(type instanceof List) {
			return "list<" + toJavaObjectType(type.elem) + ">"
		} else if(type instanceof Struct) {
			return Util.getFullname(type)
		}
		return null;
	}
	
	def public static String javaToJson(Type type, String name) {
		return javaToJson(type, name, 0);
	}
	
	def private static String javaToJson(Type type, String name, int count) {
		if(isSimple(type)) {
			return '''"\"" + String.valueOf(«name») + "\""''';
		} else if(isEnum(type)) {
			return '''"\"" + «name».name() + "\""''';
		} else if(isMap(type)) {
			return '''"{" + «name».entrySet().stream().map(e«count» -> «javaToJson(type.map.key, "e"+count + ".getKey()", count+1)» + ":" + «javaToJson(type.map.value, "e"+count+".getValue()", count+1)»).collect(Collectors.joining(",")) + "}"'''
		} else if(isList(type)) {
			return '''"[" + «name».stream().map(e«count» -> «javaToJson(type.list.elem, "e"+count, count+1)»).collect(Collectors.joining(",")) + "]"'''
		} else if(isStruct(type)) {
			return '''JSONStructSerializer.toJson(«name»)'''
		}
		return null;
	}
}
