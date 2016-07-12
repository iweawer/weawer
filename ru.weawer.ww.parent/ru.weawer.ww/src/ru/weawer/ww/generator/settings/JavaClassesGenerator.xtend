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

@Singleton
public class JavaClassesGenerator {
	
	@Inject private Headers headers;
	
	@Generate("java")
	def public void writeSettingClasses(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {

		for(setting : resource.allContents
			.filter(typeof(Struct))
			.filter([isInPackages(packages)])
			.filter([type == 'setting'])
			.toIterable
		) {
			val output = '''
			«headers.getJavaHeader(setting.eResource.URI.lastSegment.toString)»
			package «setting.package»;
			
			import java.util.*;
			import java.util.stream.*;
			import java.time.*;
			import org.json.simple.*;
			import com.google.common.base.*;
			import com.google.common.collect.*;
			import org.apache.logging.log4j.LogManager;
			import org.apache.logging.log4j.Logger;
			import ru.weawer.ww.settings.Setting;
			import ru.weawer.ww.settings.SettingField;
			
			«IF setting.comment != null»
			// «setting.comment»
			«ENDIF»
			public class «setting.name»	implements Setting {
				
				private static final Logger logger = LogManager.getLogger();
				
				public static enum Field {
					«setting.structFields.map[name].join(",\n")»
				}
				
				private final String sysKey;
				private long updateTS;
				
				public long updateTS() {
					return updateTS;
				}
				
				public void updateTS(long updateTS) {
					this.updateTS = updateTS;
				}
				
				«IF setting.single»
					public «setting.name»() {
						sysKey = "«setting.name»";
					}
				«ELSEIF setting.keys.size == 0»
					public «setting.name»() {
						sysKey = null;
					}
				«ELSE»
					public «setting.name»(«setting.keys.map[type.toJavaType + " " + name].join(", ")») {
						«FOR f : setting.keys.filter[!type.isJavaSimpleType]»
							Preconditions.checkArgument(«f.name» != null, "«setting.name»: Key field «f.name» cannot be null");
						«ENDFOR»
						«FOR f : setting.keys»
							this.«f.name» = «f.name»;
						«ENDFOR»
						«FOR field : setting.structFields.filter[hasDefaultValue && !isKey(setting)]»
							this.«field.name» = «getJavaDefaultValue(field)»;
						«ENDFOR»
						sysKey = «setting.keys.map['''String.valueOf(«name»)'''].join(" + SYS_KEY_SEPARATOR + ")»;
					}
				«ENDIF»
				«IF setting.structFields.size > 0 && setting.structFields.filter[!isKey(setting)].size > 0»
					public «setting.name»(«setting.structFields.map[type.toJavaType + " " + name].join(", ")») {
						«FOR f : setting.structFields»
							this.«f.name» = «f.name»;
						«ENDFOR»
						«IF setting.keys.size > 0»
							sysKey = «setting.keys.map['''String.valueOf(«name»)'''].join(" + SYS_KEY_SEPARATOR + ")»;
						«ELSEIF setting.single»
							sysKey = "«setting.name»";
						«ELSE»
							sysKey = null;
						«ENDIF»
					}
				«ENDIF»
				
				«FOR field : setting.structFields»
					// «field.comment»
					private final «field.type.toJavaType» «field.name»;
					
					public «field.type.toJavaType» «field.name»() {
						return «field.name»;
					}

				«ENDFOR»
				public Object fieldValue(Field f) {
					switch(f) {
						«FOR f : setting.structFields»
						case «f.name»:
							return «f.name»();
						«ENDFOR»
					}
					return null;
				}
				
				@Override
				public Object fieldValue(String fieldName) {
					try {
						return fieldValue(Field.valueOf(fieldName));
					} catch(RuntimeException e) {
						// TODO iweawer: do we need to do anything here?
					}
					return null;
				}
				
				@Override
				public Object [] fieldValues() {
					return new Object[] {
						«setting.structFields.map[name + "()"].join(", ")»
					};
				}
				
				@Override
				public Map<String, Object> fieldValuesAsMap() {
					return ImmutableMap.<String, Object> builder()
						«setting.structFields.map[".put(\"" + name + "\", " + name + "())"].join("\n")»
						.build();
				}
				
				@Override
				public String settingName() {
					return "«setting.name»";
				}
				
				@Override
				public String fullSettingName() {
					return "«setting.fullname»";
				}
				
«««				@Override
«««				public Iterable<SettingField> fields() {
«««					Set<SettingField> fields = Sets.newHashSet();
«««					«FOR field : setting.structFields»
«««					fields.add(new SettingField("«setting.fullname»", sysKey, "«field.name»", «saveToKdb(field)»));
«««					«ENDFOR»
«««					return fields;
«««				}
			
				@Override
				public String sysKey() {
					return sysKey;
				}
				
				public Builder copy() {
					return builder()
					«setting.structFields.map['''.«name»(«name»)'''].join("\n")»;
				}
				
				@SuppressWarnings("unchecked")
				public «setting.name» update(«setting.name» s, boolean checkKey, boolean updateKey) {
					if(checkKey && !sysKey().equals(s.sysKey())) {
						logger.error("Setting key mismatch: " + sysKey() + " != " + s.sysKey());
						return this;
					}
					Builder b = copy();
					b.updateTS(s.updateTS());
					if(updateKey) {
						«FOR f : setting.structFields.filter[isKey(setting)]»
							b.«f.name»(f.«f.name»());						
						«ENDFOR»
					}
					«FOR f : setting.structFields.filter[!isKey(setting)]»
						b.«f.name»(f.«f.name»());						
					«ENDFOR»
					return b.build();
				}
				
				public static Builder builder() {
					return new Builder();
				}
				
				public static class Builder {
					private Builder() { }
					
					private long updateTS;
					
					public Builder updateTS(long updateTS) {
						this.updateTS = updateTS;
						return this;
					}
					
					«FOR field : setting.structFields»
						// «field.comment»
						private «field.type.toJavaType» «field.name»«IF field.hasDefaultValue» = «getJavaDefaultValue(field)»«ENDIF»;
						private boolean «field.name»_isSet;
						
						public Builder «field.name»(«field.type.toJavaType» «field.name») {
							this.«field.name» = «field.name»;
							this.«field.name»_isSet = true;
							return this;
						}
					«ENDFOR»
					
					public «setting.name» build() {
						«FOR field : setting.keys»
						Preconditions.checkArgument(«IF !field.type.isJavaSimpleType»«field.name» != null && «ENDIF»«field.name»_isSet, "«setting.name»: Key field «field.name» is not set. Failed to create object");
						«ENDFOR»
						«setting.name» r = new «setting.name»(«setting.structFields.map[name].join(", ")»);
						r.updateTS(updateTS);
						return r;
					}
					
					public «setting.name» fromMap(Map<String, String> fields) {
						for(String field : fields.keySet()) {
							Object o = fields.get(field);
							switch(field) {
								«FOR field : setting.structFields»
									case "«field.name»":
										«IF field.type instanceof Struct»
											«field.name»(JSONStructSerializer.fromJson(fields.get(field), «(field.type as Struct).fullname».class);
										«ELSEIF field.type instanceof Map || field.type instanceof Map»
											«field.name»(JSONStructSerializer.«typeNameToFunc(field.type)»_fromJsonObj(JSONValue.parse(fields.get(field))));
										«ELSEIF isSimple(field.type)»
											if(o != null && o instanceof String) { 
												«field.name»Builder.«field.name»(«restoreSimple(field.type.simple, "(String) o")»);
											}
										«ELSEIF isEnum(field.type)»
											if(o != null && o instanceof String) { 
												«field.name»Builder.«field.name»(«restoreEnum(field.type.ref as EnumType, "(String) o")»);
											}
										«ENDIF»
										break;
									«ENDFOR»
								}

						}
						if(fields.containsKey("updateTS")) {
							updateTS(Long.parseLong(fields.get("updateTS")));
						}
						return build();
					}
					
					
					
				}
			}
			'''
			fsa.generateFile("java/" + setting.fullname.replaceAll("\\.", "/") + ".java", output)
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
		}
	}
	
	def private String restoreEnum(EnumType type, String objName) {
		'''«type.fullname».fromString(«objName»)'''
	}	
//	def private String restoreFromSetting(Field f) {
//		if(isList(f.type) || isMap(f.type)) {
//			return '''b.«f.name»(f.getString() != null ? («toJavaObjectType(f.type)») JSONValue.parse(f.getString()) : null);'''
//		} else if(f.type instanceof SimpleTypeAndEnum) {
//			if((f.type as SimpleTypeAndEnum).e != null) {
//				val e = (f.type as SimpleTypeAndEnum).e
//			
//				return '''
//					try {
//						if(f.getString() != null) b.«f.name»(«e.fullname».valueOf(f.getString()));
//					} catch(Exception e) {
//						logger.error("Unsupported value for enum «e.fullname»: " + f.getString()); 
//					}
//					'''
//			} else {
//				val SimpleType st = (f.type as SimpleTypeAndEnum).s
//				switch(st) {
//					case BOOLEAN: {
//						"b." + f.name + "(!Double.isNaN(f.getDouble()) && f.getDouble() != 0);"
//					}
//					case BYTE: {
//						"b." + f.name + "((f.getDouble() != null ? (byte) f.getDouble().doubleValue() : 0));"
//					}
//					case CHAR: {
//						"b." + f.name + "(f.getString().charAt(0));"
//					}
//					case DATE: {
//						"b." + f.name + "(LocalDate.parse(f.getString()));"
//					}
//					case DATETIME: {
//						"b." + f.name + "(LocalDateTime.parse(f.getString()));"
//					}
//					case DOUBLE: {
//						"b." + f.name + "(f.getDouble());"
//					}
//					case FLOAT: {
//						"b." + f.name + "(f.getDouble() != null ? (float) f.getDouble().doubleValue() : Float.NaN);"
//					}
//					case GUID: {
//						"b." + f.name + "(java.util.UUID.fromString(f.getString()));" 
//					}
//					case INT: {
//						"b." + f.name + "(f.getDouble() != null ? (int) f.getDouble().doubleValue() : 0);"
//					}
//					case LONG: {
//						"b." + f.name + "(f.getDouble() != null ? (long) f.getDouble().doubleValue() : 0);"
//					}
//					case SHORT: {
//						"b." + f.name + "((f.getDouble() != null ? (short) f.getDouble().doubleValue() : 0));"
//					}
//					case STRING: {
//						"b." + f.name + "(f.getString());"
//					}
//					case TIME: {
//						"b." + f.name + "(LocalTime.parse(f.getString()));"
//					}
//					case TIMESTAMP: {
//						"b." + f.name + "((f.getDouble() != null ? (long) f.getDouble().doubleValue() : 0));"
//					}
//				}
//			}
//		}
//	}
	
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
	
//	def private boolean isNullable(Field f) {
//		if(f.type instanceof SimpleTypeAndEnum) {
//			val SimpleTypeAndEnum t = f.type as SimpleTypeAndEnum
//			if(t.e != null) {
//				return true;
//			} else {
//				val SimpleType st = (f.type as SimpleTypeAndEnum).s
//				switch(st) {
//					case BOOLEAN: 	return false
//					case BYTE: 		return false
//					case CHAR: 		return false
//					case DATE: 		return true
//					case DATETIME: 	return true
//					case DOUBLE: 	return false
//					case FLOAT: 	return false
//					case GUID: 		return true
//					case INT: 		return false
//					case LONG: 		return false
//					case SHORT: 	return false
//					case STRING: 	return true
//					case TIME: 		return false
//					case TIMESTAMP: return false
//				}
//			}
//		}
//		return true;
//	}
	
	def private String typeNameToFunc(Type t) {
		if(isStruct(t)) return (t.ref as Struct).name;
		if(isEnum(t))   return (t.ref as EnumType).name;
		if(isSimple(t)) return t.simple.getName();
		if(isList(t))   return "List" + typeNameToFunc(t.list.elem)
		if(isMap(t)) 	return "Map" + typeNameToFunc(t.map.key) + typeNameToFunc(t.map.value)
		return "";
	}
	
//	
//	def private String saveToKdb(Field field) {
//		if(field.type instanceof SimpleTypeAndEnum) {
//			if((field.type as SimpleTypeAndEnum).e != null) {
//				return javaToJson(field.type, field.name + "()");
//			} else {
//				val String v = field.name + "()"
//				switch((field.type as SimpleTypeAndEnum).s) {
//					case BOOLEAN: return v + " ? 1d : 0d"
//					case BYTE: return "(double) " + v
//					case CHAR: return "String.valueOf(" + v + ")"
//					case DATE: return "String.valueOf(" + v + ")"
//					case DATETIME: return "String.valueOf(" + v + ")"
//					case DOUBLE: return field.name + "()"
//					case FLOAT: return "(double) " + v
//					case GUID: return "String.valueOf(" + v + ")"
//					case INT: return "(double) " + v
//					case LONG: return "(double) " + v
//					case SHORT: return "(double) " + v
//					case STRING: return v
//					case TIME: return "String.valueOf(" + v + ")"
//					case TIMESTAMP: return "(double) " + v
//				}
//			}
//			
//		} else {
//			return javaToJson(field.type, field.name + "()")
//		}
//	}
}