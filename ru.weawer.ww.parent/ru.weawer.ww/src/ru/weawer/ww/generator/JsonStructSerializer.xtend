package ru.weawer.ww.generator

import com.google.common.collect.Sets
import com.google.inject.Singleton
import java.util.Set
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.SimpleType
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*
import ru.weawer.ww.wwDsl.Interface

@Singleton
public class JsonStructSerializer {
	
	@Generate("java")
	def public void writeStructSerializer(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {


		val output = '''
		package ru.weawer.ww;
		
		import java.util.*;
		import java.util.stream.*;
		import java.time.*;
		import org.json.simple.*;
		import com.google.common.base.*;
		import com.google.common.collect.*;
		import org.slf4j.LoggerFactory;
		import org.slf4j.Logger;
		
		public class JSONStructSerializer {
			
			private static final Logger logger = LoggerFactory.getLogger(JSONStructSerializer.class);
			
			public static Object fromJson(String json) {
				Preconditions.checkArgument(json != null && !json.isEmpty(), "JSON is empty. Cannot deserialize from it");
				JSONObject jsonObj = (JSONObject) JSONValue.parse(json);
				return fromJsonObj(jsonObj);
			}
			
			public static Object fromJsonObj(JSONObject jsonObj) {
				String structName = (String) jsonObj.get("structName");
				if(structName != null) {
					Serializer serializer = (Serializer) serializers.get(structName);
					if(serializer == null) {
						logger.error("Serializer for {} not found", structName);
						return null;
					} else {
						return serializer.fromJsonObj(jsonObj);
					}
				}
				logger.error("Cannot deserialize. Missing structName: " + structName);
				return null;
			}
			
			public static <T> String toJson(T struct) {
				Preconditions.checkArgument(struct != null, "Struct is null. Cannot serialize to JSON");
				Serializer<T> serializer = (Serializer<T>) serializers.get(struct.getClass().getName());
				if(serializer == null) {
					logger.error("Serializer for {} not found", struct.getClass().getName());
					return null;
				} else {
					return serializer.toJson(struct);
				}
			}
			
			private interface Serializer<T> {
				public String toJson(T struct);
				public Object fromJsonObj(JSONObject json);
			}
			
			private static final Map<String, Serializer<?>> serializers = Maps.newHashMap();
			
			static {
				«FOR struct : resource.allContents
					.filter(typeof(Struct))
					.filter([isInPackages(packages)])
					.toIterable»
					serializers.put("«struct.fullname»", new Serializer<«struct.fullname»>() {
						
						@Override
						public String toJson(«struct.fullname» struct) {
							return "{" +
								"\"structName\": \"" + struct.getClass().getName() + "\""
								«IF struct.type == 'setting'»
									+ ", \"sysKey\": \"" + struct.sysKey() + "\""
								«ENDIF»
								«FOR field : struct.allStructFields»
									«IF field.isNullable»
									 	+ (struct.«field.name»() != null ? ", \"«field.name»\":" + «javaToJson(field.type, "struct." + field.name + "()", false)» : "")
									«ELSE»
										+ ", \"«field.name»\":" + «javaToJson(field.type, "struct." + field.name + "()", false)»
									«ENDIF»
								«ENDFOR»
							+ "}";
						}

						@Override
						public Object fromJsonObj(JSONObject obj) {
							«struct.fullname».Builder builder = «struct.fullname».builder();
							Object o = null;
							«FOR field : struct.allStructFields»
								o = ((JSONObject) obj).get("«field.name»");
								«IF isStruct(field.type)»
									builder.«field.name»((«(field.type.ref as Struct).fullname») JSONStructSerializer.fromJsonObj((JSONObject) o));
								«ELSEIF isInterface(field.type)»
									builder.«field.name»((«(field.type.ref as Interface).fullname») JSONStructSerializer.fromJsonObj((JSONObject) o));
								«ELSEIF isMap(field.type) || isList(field.type)»
									builder.«field.name»(«typeNameToFunc(field.type)»fromJsonObj(o));
								«ELSEIF isSimple(field.type)»
									if(o != null) { 
										builder.«field.name»(«restoreSimple(field.type.simple, "o")»);
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
				«FOR field : struct.allStructFields»
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
				"(Boolean) " + objName
			}
			case BYTE: {
				"((Long) " + objName + ").byteValue()"
			}
			case CHAR: {
				"((String) " + objName + ").charAt(0)"
			}
			case DATE: {
				"LocalDate.parse((String) " + objName + ")"
			}
			case DATETIME: {
				"LocalDateTime.parse((String) " + objName + ")"
			}
			case DOUBLE: {
				"(Double) " + objName
			}
			case FLOAT: {
				"((Double) " + objName + ").floatValue()"
			}
			case GUID: {
				"java.util.UUID.fromString((String) " + objName + ")" 
			}
			case INT: {
				"((Long) " + objName + ").intValue()"
			}
			case LONG: {
				"(Long) " + objName
			}
			case SHORT: {
				"((Long) " + objName + ").shortValue()"
			}
			case STRING: {
				"(String) " + objName
			}
			case TIME: {
				"LocalTime.parse((String) " + objName + ")"
			}
			case TIMESTAMP: {
				"(Long) " + objName
			}
			case BYTEARRAY: {
				"ru.weawer.ww.struct.Struct.byteArrayFromString((String) " + objName + ")"
			}
		}
	}
	
	def private String restoreSimpleFromString(SimpleType type, String objName) {
		switch(type) {
			case BOOLEAN: {
				"Boolean.parseBoolean((String) " + objName +")"
			}
			case BYTE: {
				"(byte) Integer.parseInt((String) " + objName +")"
			}
			case CHAR: {
				"((String) " + objName + ").charAt(0)"
			}
			case DATE: {
				"LocalDate.parse((String) " + objName + ")"
			}
			case DATETIME: {
				"LocalDateTime.parse((String) " + objName + ")"
			}
			case DOUBLE: {
				"Double.parseDouble((String) " + objName +")"
			}
			case FLOAT: {
				"Float.parseFloat((String) " + objName +")"
			}
			case GUID: {
				"java.util.UUID.fromString((String) " + objName + ")" 
			}
			case INT: {
				"Integer.parseInt((String) " + objName +")"
			}
			case LONG: {
				"Long.parseLong((String) " + objName +")"
			}
			case SHORT: {
				"Short.parseShort((String) " + objName +")"
			}
			case STRING: {
				"(String) " + objName
			}
			case TIME: {
				"LocalTime.parse((String) " + objName + ")"
			}
			case TIMESTAMP: {
				"Long.parseLong((String) " + objName +")"
			}
			case BYTEARRAY: {
				"ru.weawer.ww.struct.Struct.byteArrayFromString((String) " + objName + ")"
			}
		}
	}
	
	def private String restoreEnum(EnumType type, String objName) {
		var Double l = 12.23;
		l.floatValue
		'''«type.fullname».fromString(«objName»)'''
	}
	
	def private String typeNameToFunc(Type t) {
		if(isStruct(t)) return (t.ref as Struct).name;
		if(isInterface(t)) return (t.ref as Interface).name;
		if(isEnum(t))   return (t.ref as EnumType).name;
		if(isSimple(t)) return t.simple.getName();
		if(isList(t))   return "List" + typeNameToFunc(t.list.elem)
		if(isMap(t)) 	return "Map" + typeNameToFunc(t.map.key) + typeNameToFunc(t.map.value)
		return "";
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
					list.add(
						«IF isStruct(list.list.elem) || isInterface(list.list.elem)»
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
					map.put(
					«IF isStruct(map.map.key)»
						JSONStructSerializer.fromJson((String) jo.get(e), «(map.map.key.ref as Struct).fullname».class)
					«ELSEIF isInterface(map.map.key)»
						JSONStructSerializer.fromJson((String) jo.get(e), «(map.map.key.ref as Interface).fullname».class)	
					«ELSEIF isMap(map.map.key) || isList(map.map.key)»
						«typeNameToFunc(map.map.key)»fromJsonObj(e)
					«ELSEIF isSimple(map.map.key)»
						«restoreSimpleFromString(map.map.key.simple, "e")»
					«ELSEIF isEnum(map.map.key)»
						«restoreEnum(map.map.key.ref as EnumType, "(String) e")»
					«ENDIF»
					,
					«IF isStruct(map.map.value)»
						JSONStructSerializer.fromJson((String) jo.get(e), «(map.map.value.ref as Struct).fullname».class)
					«ELSEIF isInterface(map.map.value)»
						JSONStructSerializer.fromJson((String) jo.get(e), «(map.map.value.ref as Interface).fullname».class)	
					«ELSEIF isMap(map.map.value) || isList(map.map.value)»
						«typeNameToFunc(map.map.value)»fromJsonObj(jo.get(e))
					«ELSEIF isSimple(map.map.value)»
						«restoreSimple(map.map.value.simple, "jo.get(e)")»
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