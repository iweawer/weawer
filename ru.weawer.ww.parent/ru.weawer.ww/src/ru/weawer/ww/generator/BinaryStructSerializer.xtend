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
		import java.nio.ByteBuffer;
		import com.google.common.base.*;
		import com.google.common.collect.*;
		import org.slf4j.LoggerFactory;
		import org.slf4j.Logger;
		import ru.weawer.ww.struct.Struct;
		
		public class BinaryStructSerializer {
			
			private static final Logger logger = LoggerFactory.getLogger(BinaryStructSerializer.class);
			
			public static Object fromByteBuf(ByteBuffer buf) {
				Preconditions.checkArgument(buf != null, "ByteBuffer is null. Cannot deserialize from it");
				Serializer<T> serializer = (Serializer<T>) serializers.get(clazz);
				if(serializer == null) {
					logger.error("Serializer for {} not found", clazz.getName());
					return null;
				} else {
					return serializer.fromByteBuf(buf);
				}
			}
			
			public static <T extends Struct> void toByteArray(T struct, ByteBuffer buf) {
				Preconditions.checkArgument(struct != null, "Struct is null. Cannot serialize to byte array");
				Serializer<T> serializer = (Serializer<T>) serializers.get(struct.getClass());
				if(serializer == null) {
					logger.error("Serializer for {} not found", struct.getClass().getName());
					return null;
				} else {
					return serializer.toByteArray(struct, buf);
				}
			}
			
			public static <T extends Struct> void toByteArray(T struct, ByteBuffer buf) {
				Preconditions.checkArgument(struct != null, "Struct is null. Cannot serialize to byte array");
				Serializer<T> serializer = (Serializer<T>) serializers.get(struct.getClass());
				if(serializer == null) {
					logger.error("Serializer for {} not found", struct.getClass().getName());
					return null;
				} else {
					return serializer.toByteArray(struct, buf);
				}
			}
			
			private interface Serializer<T extends Struct> {
				public void toByteArray(T struct, ByteBuffer buf);
				public byte [] toByteArray(T struct);
				public Object fromByteBuf(ByteBuffer buf);
			}
			
			private static final Map<Class<?>, Serializer<?>> serializers = Maps.newHashMap();
			
			static {
				«FOR struct : resource.allContents
					.filter(typeof(Struct))
					.filter([isInPackages(packages)])
					.toIterable»
					serializers.put(«struct.fullname».class, new Serializer<«struct.fullname»>() {
						
						private static final int BITMASK_LENGTH = «if(struct.structFields.filter[nullable].size % 8 > 0) 
								struct.structFields.filter[nullable].size / 8 + 1 
								else 
								struct.structFields.filter[nullable].size / 8»; 

						
						@Override
						public void toByteArray(T struct, ByteBuffer buf) {
							final int __length_position = buf.position();
							buf.position(buf.position() + 4);
							BinaryParser.writestring(buf, "«struct.longname»");
							«IF struct.structFields.filter[nullable].size > 0»
								final int __bitmap_position = buf.position();
								byte[] __bitmap = new byte[BITMASK_LENGTH]; 
								buf.position(__bitmap_position + BITMASK_LENGTH);
								BitSet bitSet = BitSet.valueOf(__bitmap);						
							«ENDIF»
							
							«reset»
							
							«FOR field : struct.structFields»
								«IF isJavaSimpleType(field.type) || !field.isNullable»
									BinaryParser.write«field.type.toName»(buf, struct.«field.name»());
								«ELSE»
									if(«field.name» == null) {
										bitSet.set(«k»); 
									} else {
										BinaryParser.write«field.type.toName»(buf, struct.«field.name»());
									}
								«ENDIF»
								«increment»
							«ENDFOR»
							int __length = buf.position() - __length_position - 4;
							buf.putInt(__length_position, __length);
							«IF struct.structFields.filter[nullable].size > 0»
								__bitmap = bitSet.toByteArray();
								for(int __i = 0; __i < __bitmap.length; __i++) {
									buf.put(__bitmap_position + __i, __bitmap[__i]);
								}
							«ENDIF»
						}
						
						@Override
						public byte [] toByteArray(T struct) {
							ByteBuffer buf = ByteBuffer.allocate(struct.getByteSize());
							toByteArray(struct, buf);
							buf.flip();
							byte [] b = new byte[buf.limit()];
							buf.get(b, 0, b.length);
							return b;
						}
						
						@Override
						public Object fromByteBuf(ByteBuffer buf) {
							final Builder builder = builder();
							final int __length = buf.getInt();
							final String __name = BinaryParser.readstring(buf);
							«IF struct.structFields.filter[nullable].size > 0» 
								final byte[] __bitmap = new byte[BITMASK_LENGTH];
								buf.get(__bitmap);
								BitSet bitSet = BitSet.valueOf(__bitmap);
							«ENDIF»
							«reset()»
							«FOR field : struct.structFields»
								«IF isJavaSimpleType(field.type) || !field.isNullable»
									builder.«field.name»(BinaryParser.read«field.type.toName»(buf));
								«ELSE»
									if(!bitSet.get(«k»)) builder.«field.name»(BinaryParser.read«field.type.toName»(buf));
								«ENDIF»
								«increment()»
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
		fsa.generateFile("java/ru/weawer/ww/BinaryStructSerializer.java", output)
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
	
	private static int k;
	
	def static private void increment() {
		k = k + 1;
	}
	
	def static private void reset() {
		k = 0;
	}
	
}