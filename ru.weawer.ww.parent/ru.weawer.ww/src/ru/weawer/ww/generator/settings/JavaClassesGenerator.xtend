package ru.weawer.ww.generator.settings

import com.google.inject.Inject
import com.google.inject.Singleton
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.generator.Generate
import ru.weawer.ww.generator.Headers
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.Field
import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.Map
import ru.weawer.ww.wwDsl.SimpleType
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*
import ru.weawer.ww.common.TypeUtil

@Singleton
public class JavaClassesGenerator {
	
	@Inject private Headers headers;
	
	@Generate("java")
	def public void writeSettingClasses(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {

		for(struct : resource.allContents
			.filter(typeof(Struct))
			.filter([isInPackages(packages)])
			.toIterable
		) {
			val output = '''
			«headers.getJavaHeader(struct.eResource.URI.lastSegment.toString)»
			package «struct.package»; 
			
			import java.util.*;
			import java.util.stream.*;
			import java.time.*;
			import java.nio.charset.Charset;
			import java.io.*;
			import java.nio.*;
			import java.util.concurrent.atomic.AtomicInteger;
			
			import org.json.simple.*;
			import com.google.common.base.*;
			import com.google.common.collect.*;
			import org.slf4j.LoggerFactory;
			import org.slf4j.Logger;
			import ru.weawer.ww.JSONStructSerializer;
			import ru.weawer.ww.BinaryStructSerializer;
			import ru.weawer.ww.BinaryParser;
			import ru.weawer.ww.struct.Struct;
			«IF struct.type == "setting"»
				import ru.weawer.ww.settings.Setting;
				import ru.weawer.ww.settings.SettingField;
			«ENDIF»
			«IF struct.comment != null»
			// «struct.comment»
			«ENDIF»
			public class «struct.name» implements Struct«IF struct.type=='setting'», Setting«ENDIF» 
				«IF struct.implements != null && struct.implements.size > 0», «struct.implements.map[fullname].join(", ")»«ENDIF» {
				
				private static final Logger logger = LoggerFactory.getLogger(«struct.name».class);
				private static final Charset charset = Charset.forName("UTF-8");
				
				public static enum Field {
					«struct.allStructFields.map[name].join(",\n")»
				}
				
				private static final int BITMASK_LENGTH = «if(struct.allStructFields.filter[nullable].size % 8 > 0) 
												struct.allStructFields.filter[nullable].size / 8 + 1 
												else 
												struct.allStructFields.filter[nullable].size / 8»; 
				
				private int hashcode;
				
				private final String sysKey;
				
				«IF struct.type == "setting"»
					private long updateTS;
					
					public long updateTS() {
						return updateTS;
					}
					
					public void updateTS(long updateTS) {
						this.updateTS = updateTS;
					}
				«ENDIF»
				«IF struct.single»
					private «struct.name»() {
						sysKey = "«struct.fullname»";
					}
				«ELSEIF struct.keys == null || struct.keys.size == 0»
					private «struct.name»() {
						sysKey = null;
					}
				«ELSE»
					private «struct.name»(«struct.keys.map[type.toJavaType + " " + name].join(", ")») {
						«FOR f : struct.keys.filter[!type.isJavaSimpleType]»
							Preconditions.checkArgument(«f.name» != null, "«struct.name»: Key field «f.name» cannot be null");
						«ENDFOR»
						«FOR f : struct.keys»
							this.«f.name» = «f.name»;
						«ENDFOR»
						«FOR field : struct.allStructFields.filter[hasDefaultValue && !isKey(struct)]»
							this.«field.name» = «getJavaDefaultValue(field)»;
						«ENDFOR»
						sysKey = «struct.keys.map['''String.valueOf(«name»)'''].join(" + SYS_KEY_SEPARATOR + ")»;
					}
				«ENDIF»

				«FOR field : struct.allStructFields»
					// «field.comment»
					private «field.type.toJavaType» «field.name»;
					
					public «field.type.toJavaType» «field.name»() {
						return «field.name»;
					}
					«IF !field.isKey(struct) && (field.mutable || struct.mutable)»
						public «struct.name» «field.name»(«field.type.toJavaType» «field.name») {
							«IF !field.nullable && !field.type.isJavaSimpleType»
								Preconditions.checkArgument(«field.name» != null, "Field «field.name» is null");
							«ENDIF»
							this.«field.name» = «field.name»;
							return this;
						}
					«ENDIF»
				«ENDFOR»

				«IF struct.type == "setting"»
					
					@Override
					public String shortSettingName() {
						return "«struct.name»";
					}
					
					@Override
					public String settingName() {
						return "«struct.fullname»";
					}

					@SuppressWarnings("unchecked")
					public «struct.name» update(«struct.name» s, boolean checkKey, boolean updateKey) {
						if(checkKey && !sysKey().equals(s.sysKey())) {
							logger.error("Setting key mismatch: " + sysKey() + " != " + s.sysKey());
							return this;
						}
						Builder b = copy();
						b.updateTS(s.updateTS());
						if(updateKey) {
							«FOR f : struct.allStructFields.filter[isKey(struct)]»
								b.«f.name»(s.«f.name»());						
							«ENDFOR»
						}
						«FOR f : struct.allStructFields.filter[!isKey(struct)]»
							b.«f.name»(s.«f.name»());						
						«ENDFOR»
						return b.build();
					}
				«ENDIF»

				public String sysKey() {
					return sysKey;
				}

				private void calculateHashCode() {
					int hashCode = 0;
					«FOR f : struct.allStructFields»
						«IF isJavaSimpleType(f.type)»							
							hashCode = hashCode * 37 + «f.type.hashCode(f.name)»;
						«ELSE»
							«IF f.isNullable»if(«f.name» != null) «ENDIF»hashCode = hashCode * 37 + «f.name».hashCode();
						«ENDIF»
					«ENDFOR»
					hashcode = hashCode;
				}
				
				@Override
				public int hashCode() {
					«IF struct.mutable || struct.allStructFields.filter[mutable].size > 0»
						return calculateHashCode();
					«ELSE»
						return hashcode;
					«ENDIF»
				}
				
				@Override
				public boolean equals(Object o) {
					if(o instanceof «struct.name») {
						«struct.name» that = («struct.name») o;
						«FOR f : struct.allStructFields»
							«IF isSimple(f.type)»	
								«IF !f.type.isJavaSimpleType && f.nullable»
									if( (this.«f.name»() != null && that.«f.name»() == null) || 
										(this.«f.name»() == null && that.«f.name»() != null) ||
										(this.«f.name»() != null && !this.«f.name»().equals(that.«f.name»())) 
									   ) { 
									   		return false;
									   }
								«ELSE»						
									if(! («TypeUtil.equals(f.type, f.name)»)) return false;
								«ENDIF»
							«ELSE»
								if(!this.«f.name»().equals(that.«f.name»())) return false;
							«ENDIF»
						«ENDFOR»
						return true;
					}
					return false;
				}
				
				public Builder copy() {
					return builder()
					«struct.allStructFields.map['''.«name»(«name»)'''].join("\n")»;
				}
				
				public static Builder builder() {
					return new Builder();
				}
				
				public static class Builder {
					private Builder() { 
						«FOR field : struct.allStructFields.filter[hasDefaultValue && !isKey(struct)]»
							this.«field.name» = «getJavaDefaultValue(field)»;
						«ENDFOR»
					}
					«IF struct.type == "setting"»
						private long updateTS;
						
						public Builder updateTS(long updateTS) {
							this.updateTS = updateTS;
							return this;
						}
					«ENDIF»
					
					«FOR field : struct.allStructFields»
						// «field.comment»
						private «field.type.toJavaType» «field.name»«IF field.hasDefaultValue» = «getJavaDefaultValue(field)»«ENDIF»;
						private boolean «field.name»_isSet;
						
						public Builder «field.name»(«field.type.toJavaType» «field.name») {
							this.«field.name» = «field.name»;
							this.«field.name»_isSet = true;
							return this;
						}
						
						public «field.type.toJavaType» «field.name»() {
							return «field.name»;
						}
						
						public boolean «field.name»_isSet() {
							return «field.name»_isSet;
						}
					«ENDFOR»
					
					public «struct.name» build() {
						«FOR field : struct.allStructFields.filter[isKey(struct) || (!nullable && !hasDefaultValue)]»
							Preconditions.checkArgument(«IF !field.type.isJavaSimpleType»«field.name» != null && «ENDIF»«field.name»_isSet, "«struct.name»: Key field «field.name» is not set. Failed to create object");
						«ENDFOR»
						«struct.name» r = new «struct.name»(«struct.allStructFields.filter[isKey(struct)].map[name].join(", ")»);
						«FOR field : struct.allStructFields.filter[!isKey(struct)]»
							r.«field.name» = «field.name»;
						«ENDFOR»
						«IF struct.type == "setting"»
							r.updateTS(updateTS);
						«ENDIF»
						r.calculateHashCode();
						return r;
					}
					
					public Builder fromMap(Map<String, String> fields) {
						for(String field : fields.keySet()) {
							Object o = fields.get(field);
							switch(field) {
								«FOR field : struct.allStructFields»
									case "«field.name»":
										«IF field.type instanceof Struct»
											«field.name»(JSONStructSerializer.fromJson(fields.get(field), «(field.type as Struct).fullname».class);
										«ELSEIF field.type instanceof Map || field.type instanceof Map»
											«field.name»(JSONStructSerializer.«typeNameToFunc(field.type)»_fromJsonObj(JSONValue.parse(fields.get(field))));
										«ELSEIF isSimple(field.type)»
											if(o != null && o instanceof String) { 
												«field.name»(«restoreSimple(field.type.simple, "(String) o")»);
											}
										«ELSEIF isEnum(field.type)»
											if(o != null && o instanceof String) { 
												«field.name»(«restoreEnum(field.type.ref as EnumType, "(String) o")»);
											}
										«ENDIF»
										break;
									«ENDFOR»
								}

						}
						«IF struct.type == "setting"»
							if(fields.containsKey("updateTS")) {
								updateTS(Long.parseLong(fields.get("updateTS")));
							}
						«ENDIF»
						return this;
					}
				}
				
				@Override
				public String toJson() {
					return JSONStructSerializer.toJson(this);
				}
				
				@Override
				public byte [] toByteArray() {
					return BinaryStructSerializer.toByteArray(this);
				}
				
				@Override
				public void toByteArray(ByteBuffer buf) {
					BinaryStructSerializer.toByteArray(this, buf);
				}
				
				public static «struct.fullname» fromByteBuf(ByteBuffer buf) {
					return («struct.fullname») BinaryStructSerializer.fromByteBuf(buf);
				}
				
				@Override
				public int getByteSize() {
					AtomicInteger size = new AtomicInteger(0);
					size.addAndGet(4); // length
					size.addAndGet(4 + "«struct.fullname»".getBytes(charset).length); // struct name
					«IF struct.allStructFields.filter[nullable].size > 0»
						size.addAndGet(BITMASK_LENGTH);
					«ENDIF»
					
					«reset»
					
					«FOR field : struct.allStructFields»
						«IF isInterface(field.type)»
							«IF field.isNullable»
								if(«field.name» != null) {
									size.addAndGet(«field.name»().getByteSize());
								}
							«ELSE»
								size.addAndGet(«field.name»().getByteSize());
							«ENDIF»
						«ELSEIF isJavaSimpleType(field.type) || !field.isNullable»
							BinaryParser.addsize_«field.type.toName»(size, «field.name»());
						«ELSE»
							if(«field.name» != null) {
								BinaryParser.addsize_«field.type.toName»(size, «field.name»());
							}
						«ENDIF»
						«increment»
					«ENDFOR»
					return size.get();
				}
			}
			'''
			fsa.generateFile("java/" + struct.fullname.replaceAll("\\.", "/") + ".java", output)
		}
	}
		
	//	def private boolean isKey(Struct s, Field f) {
	//		return s.keys.contains(f)
	//	}
		
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
			case BYTEARRAY: {
				"(" + objName + ").getBytes(charset)"
			}
		}
	}
	
	def private String restoreEnum(EnumType type, String objName) {
		
		'''«type.fullname».fromString(«objName»)'''
	}	
	
	def private boolean hasDefaultValue(Field f) {
		return f.^default != null || f.type instanceof List || f.type instanceof Map
	}
	
	def private String getJavaDefaultValue(Field f) {
		if(f.^default != null) {
			if(f.^default.e != null) {
				return (f.^default.e.eContainer as EnumType).name + "." + f.^default.e.name;
			}
			switch(f.type.simple) {
				case BOOLEAN: {
					return f.^default.s
				}
				case BYTE: {
					return f.^default.s
				}
				case CHAR: {
					return f.^default.s
				}
				case DATE: {
					return "LocalDate.parse(\"" + f.^default.s + "\")"
				}
				case DATETIME: {
					return "LocalDateTime.parse(\"" + f.^default.s + "\")"
				}
				case DOUBLE: {
					return f.^default.s
				}
				case FLOAT: {
					return f.^default.s + "f"
				}
				case GUID: {
					return "null" 
				}
				case INT: {
					return f.^default.s
				}
				case LONG: {
					return f.^default.s
				}
				case SHORT: {
					return f.^default.s
				}
				case STRING: {
					return f.^default.s
				}
				case TIME: {
					return "LocalTime.parse(\"" + f.^default.s + "\")"
				}
				case TIMESTAMP: {
					return f.^default.s
				}
				case BYTEARRAY: {
					return "null"
				}
			}
		} else {
			if(f.type instanceof List) {
				return "Lists.newArrayList()"
			}
			if(f.type instanceof Map) {
				return "Maps.newHashMap()"
			}
		}
	}
	
	def private String typeNameToFunc(Type t) {
		if(isStruct(t)) return (t.ref as Struct).name;
		if(isEnum(t))   return (t.ref as EnumType).name;
		if(isSimple(t)) return t.simple.getName();
		if(isList(t))   return "List" + typeNameToFunc(t.list.elem)
		if(isMap(t)) 	return "Map" + typeNameToFunc(t.map.key) + typeNameToFunc(t.map.value)
		return "";
	}
	
//	
//	def private String saveToDb(Field field) {
//		if(isEnum(field.type)) {
//			return javaToJson(field.type, field.name + "()");
//		} else if(isSimple(field.type)) {
//			val String v = field.name + "()"
//			switch(field.type.simple) {
//				case BOOLEAN: return v + " ? 1d : 0d"
//				case BYTE: return "(double) " + v
//				case CHAR: return "String.valueOf(" + v + ")"
//				case DATE: return "String.valueOf(" + v + ")"
//				case DATETIME: return "String.valueOf(" + v + ")"
//				case DOUBLE: return field.name + "()"
//				case FLOAT: return "(double) " + v
//				case GUID: return "String.valueOf(" + v + ")"
//				case INT: return "(double) " + v
//				case LONG: return "(double) " + v
//				case SHORT: return "(double) " + v
//				case STRING: return v
//				case TIME: return "String.valueOf(" + v + ")"
//				case TIMESTAMP: return "(double) " + v
//				case BYTEARRAY: return "new String(" + v + ")"
//			}
//		} else {
//			return javaToJson(field.type, field.name + "()")
//		}
//	}
//	
	private static int k;
	
	def static private void increment() {
		k = k + 1;
	}
	
	def static private void reset() {
		k = 0;
	}
}