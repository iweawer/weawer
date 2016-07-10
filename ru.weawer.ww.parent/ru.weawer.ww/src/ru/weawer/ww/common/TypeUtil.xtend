package ru.weawer.ww.common

import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.Map
import ru.weawer.ww.wwDsl.SimpleType
import ru.weawer.ww.wwDsl.SimpleTypeAndEnum
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type

public class TypeUtil {
	
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
			return toJavaObjectType((type as SimpleTypeAndEnum).s);
		}
		return toJavaType(type)
	}
	
	def public static String toJavaType(Type type) {
		if(type instanceof SimpleTypeAndEnum) {
			if(type.e != null) {
				return Util.getFullname(type.e)
			} else {
				return toJavaType(type.s)
			}
		} else if(type instanceof Map) {
			return "Map<" + toJavaObjectType(type.key) + ", " + toJavaObjectType(type.value) + ">"
		} else if(type instanceof List) {
			return "List<" + toJavaObjectType(type.elem) + ">"
		} else if(type instanceof Struct) {
			return Util.getFullname(type)
		}
		return null;
	}
	
	def public static boolean isJavaSimpleType(Type type) {
		if(type instanceof SimpleTypeAndEnum) {
			if(type.e != null) {
				return false
			} else {
				return isJavaSimpleType(type.s)
			}
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
		if(type instanceof SimpleTypeAndEnum) {
			if(type.e != null) {
				return Util.getFullname(type.e)
			} else {
				return type.s.getName
			}
		} else if(type instanceof Map) {
			return "map<" + getTypeName(type.key) + ", " + getTypeName(type.value) + ">"
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
		if(type instanceof SimpleTypeAndEnum) {
			if(type.e != null) {
				return '''"\"" + «name».name() + "\""''';
			} else {
				return '''"\"" + String.valueOf(«name») + "\""''';
			}
		} else if(type instanceof Map) {
			return '''"{" + «name».entrySet().stream().map(e«count» -> «javaToJson(type.key, "e"+count + ".getKey()", count+1)» + ":" + «javaToJson(type.value, "e"+count+".getValue()", count+1)»).collect(Collectors.joining(",")) + "}"'''
		} else if(type instanceof List) {
			return '''"[" + «name».stream().map(e«count» -> «javaToJson(type.elem, "e"+count, count+1)»).collect(Collectors.joining(",")) + "]"'''
		} else if(type instanceof Struct) {
			return '''«name».toJson()'''
		}
		return null;
	}
	
	def public static String pythonToJson(Type type, String name) {
		return pythonToJson(type, name, 0);
	}
	
	def private static String pythonToJson(Type type, String name, int count) {
		if(type instanceof SimpleTypeAndEnum) {
			if(type.e != null) {
				return '''"\"" + «name».name() + "\""'''
			} else {
				return '''"\"" + str(«name») + "\""'''
			}
		} else if(type instanceof Map) {
			return '''"{" + ", ".join(['"' + str(e«count») + '": "' + str(«name»[e«count»]) + '"' for e«count» in «name».keys()]) + "}"'''
		} else if(type instanceof List) {
			return '''"[" + ", ".join([«pythonToJson(type.elem, "e"+count, count+1)» for e«count» in «name»]) + "]"'''
		} else if(type instanceof Struct) {
			return '''«name».toJson()'''
		}
		return null;
	}
}
