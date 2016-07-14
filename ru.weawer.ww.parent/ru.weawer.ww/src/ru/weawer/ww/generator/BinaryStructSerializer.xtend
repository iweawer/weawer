package ru.weawer.ww.generator

import com.google.common.collect.Sets
import com.google.inject.Singleton
import java.util.Set
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.Field
import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.SimpleType
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*

@Singleton
public class BinaryStructSerializer {
	
	@Generate("java")
	def public void writeParser(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {


		val output = '''
		package ru.weawer.ww;
		
		import java.util.*;
		import java.util.stream.*;
		import java.time.*;
		import org.json.simple.*;
		import com.google.common.base.*;
		import com.google.common.collect.*;
		import org.apache.logging.log4j.LogManager;
		import org.apache.logging.log4j.Logger;
		
		public class BinaryStructSerializer {
			
			private static final Logger logger = LogManager.getLogger();
			
			public static <T> T fromJson(String json, Class<T> clazz) {
				Preconditions.checkArgument(json != null && !json.isEmpty(), "JSON is empty. Cannot deserialize from it");
				Serializer<T> serializer = (Serializer<T>) serializers.get(clazz);
				if(serializer == null) {
					logger.error("Serializer for {} not found", clazz.getName());
					return null;
				} else {
					return serializer.fromJsonObj((JSONObject) JSONValue.parse(json));
				}
			}
			
			public static <T> T fromJsonObj(JSONObject json, Class<T> clazz) {
				Preconditions.checkArgument(json != null && !json.isEmpty(), "JSON is empty. Cannot deserialize from it");
				Serializer<T> serializer = (Serializer<T>) serializers.get(clazz);
				if(serializer == null) {
					logger.error("Serializer for {} not found", clazz.getName());
					return null;
				} else {
					return serializer.fromJsonObj(json);
				}
			}
			
			public static <T> String toJson(T struct) {
				Preconditions.checkArgument(struct != null, "Struct is null. Cannot serialize to JSON");
				Serializer<T> serializer = (Serializer<T>) serializers.get(struct.getClass());
				if(serializer == null) {
					logger.error("Serializer for {} not found", struct.getClass().getName());
					return null;
				} else {
					return serializer.toJson(struct);
				}
			}
			
			private interface Serializer<T> {
				public String toJson(T struct);
				public T fromJsonObj(JSONObject json);
			}
			
			private static final Map<Class<?>, Serializer<?>> serializers = Maps.newHashMap();
			
			static {
				«FOR struct : resource.allContents
					.filter(typeof(Struct))
					.filter([isInPackages(packages)])
					.toIterable»
					serializers.put(«struct.fullname».class, new Serializer<«struct.fullname»>() {
						
						@Override
						public String toJson(«struct.fullname» struct) {
							return "{" +
								"\"structname\": \"«struct.fullname»\""
								«FOR field : struct.structFields»
									«IF field.isNullable»
									 	+ (struct.«field.name»() != null ? ", \"«field.name»\":" + «javaToJson(field.type, "struct." + field.name + "()")» : "")
									«ELSE»
										+ ", \"«field.name»\":" + «javaToJson(field.type, "struct." + field.name + "()")»
									«ENDIF»
								«ENDFOR»
							+ "}";
						}

						@Override
						public «struct.fullname» fromJsonObj(JSONObject obj) {
							«struct.fullname».Builder builder = «struct.fullname».builder();
							Object o = null;
							«FOR field : struct.structFields»
								o = ((JSONObject) obj).get("«field.name»");
								«IF isStruct(field.type)»
									builder.«field.name»(JSONStructSerializer.fromJsonObj((JSONObject) o, «(field.type.ref as Struct).fullname».class));
								«ELSEIF isMap(field.type) || isList(field.type)»
									builder.«field.name»(«typeNameToFunc(field.type)»fromJsonObj(o));
								«ELSEIF isSimple(field.type)»
									if(o != null && o instanceof String) { 
										builder.«field.name»(«restoreSimple(field.type.simple, "(String) o")»);
									}
								«ELSEIF isEnum(field.type)»
									if(o != null && o instanceof String) { 
										builder.«field.name»(«restoreEnum(field.type.ref as EnumType, "(String) o")»);
									}
								«ENDIF»
							«ENDFOR»
							return builder.build();
						}
					});
					
				«ENDFOR»
			}
			
			«FOR struct : resource.allContents
								.filter(typeof(Struct))
								.filter([isInPackages(packages)])
								.toIterable»			
				«FOR field : struct.structFields»
					«IF isMap(field.type)»
						«writeFunctionForMap(field.type)»
					«ELSEIF isList(field.type)»
						«writeFunctionForList(field.type)»
					«ENDIF»
				«ENDFOR»
			«ENDFOR»
		}
		
		'''
		fsa.generateFile("java/ru/weawer/ww/JSONStructSerializer.java", output)
	}
	
	def private String restoreSimple(SimpleType type, String objName) {
		switch(type) {
			case BOOLEAN: {
				"Boolean.parseBoolean(" + objName + ")"
			}
			case BYTE: {
				"Byte.parseByte(" + objName + ")"
			}
			case CHAR: {
				"(" + objName + ").charAt(0)"
			}
			case DATE: {
				"LocalDate.parse(" + objName + ")"
			}
			case DATETIME: {
				"LocalDateTime.parse(" + objName + ")"
			}
			case DOUBLE: {
				"Double.parseDouble(" + objName + ")"
			}
			case FLOAT: {
				"Float.parseFloat(" + objName + ")"
			}
			case GUID: {
				"java.util.UUID.fromString(" + objName + ")" 
			}
			case INT: {
				"Integer.parseInt(" + objName + ")"
			}
			case LONG: {
				"Long.parseLong(" + objName + ")"
			}
			case SHORT: {
				"Short.parseShort(" + objName + ")"
			}
			case STRING: {
				objName
			}
			case TIME: {
				"LocalTime.parse(" + objName + ")"
			}
			case TIMESTAMP: {
				"Long.parseLong(" + objName + ")"
			}
		}
	}
	
	def private String restoreEnum(EnumType type, String objName) {
		'''«type.fullname».fromString(«objName»)'''
	}
	
	def private String typeNameToFunc(Type t) {
		if(isStruct(t)) return (t.ref as Struct).name;
		if(isEnum(t))   return (t.ref as EnumType).name;
		if(isSimple(t)) return t.simple.getName();
		if(isList(t))   return "List" + typeNameToFunc(t.list.elem)
		if(isMap(t)) 	return "Map" + typeNameToFunc(t.map.key) + typeNameToFunc(t.map.value)
		return "";
	}
	
	def private boolean isNullable(Field f) {
		if(isSimple(f.type)) {
			switch(f.type.simple) {
				case BOOLEAN: 	return false
				case BYTE: 		return false
				case CHAR: 		return false
				case DATE: 		return true
				case DATETIME: 	return true
				case DOUBLE: 	return false
				case FLOAT: 	return false
				case GUID: 		return true
				case INT: 		return false
				case LONG: 		return false
				case SHORT: 	return false
				case STRING: 	return true
				case TIME: 		return false
				case TIMESTAMP: return false
			}
		}
		return true;
	}
	
	private Set<String> functionCache = Sets.newHashSet();
	
	def private String writeFunctionForList(Type list) {
		val String name = typeNameToFunc(list)
		if(functionCache.contains(name)) return "";
		functionCache.add(name);
		var String out = '''
		private static «list.toJavaType» «name»fromJsonObj(Object obj) {
			«list.toJavaType» list = Lists.newArrayList();
			if(obj instanceof JSONArray) {
				for(Object o : (JSONArray) obj) {
					list.add((«list.list.elem.toJavaType»)
						«IF isStruct(list.list.elem)»
							«(list.list.elem.ref as Struct).name».fromJsonObj(o)
						«ELSEIF isMap(list.list.elem) || isList(list.list.elem)»
							«typeNameToFunc(list.list.elem)»fromJsonObj(o)
						«ELSEIF isSimple(list.list.elem)»
							«restoreSimple(list.list.elem.simple, "o")»
						«ELSEIF isEnum(list.list.elem)»
							«restoreEnum(list.list.elem.ref as EnumType, "(String) o")»
						«ENDIF»
					);
				}
			}
			return list;
		}
		'''
		if(isMap(list.list.elem)) {
			out = out + writeFunctionForMap(list.list.elem);
		} else if(list.list.elem instanceof List) {
			out = out + writeFunctionForList(list.list.elem);
		}
		return out;  
	}
	
	def private String writeFunctionForMap(Type map) {
		val String name = typeNameToFunc(map)
		if(functionCache.contains(name)) return "";
		functionCache.add(name);
		var String out = '''
		private static «map.toJavaType» «name»fromJsonObj(Object obj) {
			«map.toJavaType» map = Maps.newHashMap();
			if(obj instanceof JSONObject) {
				JSONObject jo = (JSONObject) obj;
				for(Object e : jo.keySet()) {
					map.put((«map.map.key.toJavaObjectType»)
					«IF isStruct(map.map.key)»
						JSONStructSerializer.fromJson((String) jo.get(e), «(map.map.key.ref as Struct).fullname».class)
					«ELSEIF isMap(map.map.key) || isList(map.map.key)»
						«typeNameToFunc(map.map.key)»fromJsonObj(e)
					«ELSEIF isSimple(map.map.key)»
						«restoreSimple(map.map.key.simple, "(String) e")»
					«ELSEIF isEnum(map.map.key)»
						«restoreEnum(map.map.key.ref as EnumType, "(String) e")»
					«ENDIF»
					,
					(«map.map.value.toJavaObjectType») 
					«IF isStruct(map.map.value)»
						JSONStructSerializer.fromJson((String) jo.get(e), «(map.map.value.ref as Struct).fullname».class)
					«ELSEIF isMap(map.map.value) || isList(map.map.value)»
						«typeNameToFunc(map.map.value)»fromJsonObj(jo.get(e))
					«ELSEIF isSimple(map.map.value)»
						«restoreSimple(map.map.value.simple, "(String) jo.get(e)")»
					«ELSEIF isEnum(map.map.value)»
						«restoreEnum(map.map.value.ref as EnumType, "(String) jo.get(e)")»
					«ENDIF»
					);
				}
			}
			return map;
		}
		'''
		if(isMap(map.map.key)) {
			out = out + writeFunctionForMap(map.map.key);
		} else if(isList(map.map.key)) {
			out = out + writeFunctionForList(map.map.key);
		}
		if(isMap(map.map.value)) {
			out = out + writeFunctionForMap(map.map.value);
		} else if(isList(map.map.value)) {
			out = out + writeFunctionForList(map.map.value);
		}
		return out;  
	}
	
}