package ru.weawer.ww.generator

import com.google.inject.Singleton
import java.util.List
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*

@Singleton
public class BinaryStructSerializer {
	
	@Generate("java")
	def public void writeParser(List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {


		val output = '''
		package ru.weawer.ww;
		
		import java.util.*;
		import java.util.stream.*;
		import java.util.concurrent.atomic.AtomicInteger;
		import java.time.*;
		import java.nio.ByteBuffer;
		import java.nio.charset.Charset;
		import com.google.common.base.*;
		import com.google.common.collect.*;
		import org.slf4j.LoggerFactory;
		import org.slf4j.Logger;
		import ru.weawer.ww.struct.Struct;
		
		public class BinaryStructSerializer {
			
			private static final Logger logger = LoggerFactory.getLogger(BinaryStructSerializer.class);
			
			private static final Charset charset = Charset.forName("UTF-8");
				
				public static Object fromByteBuf(ByteBuffer buf) {
					Preconditions.checkArgument(buf != null, "ByteBuffer is null. Cannot deserialize from it");
					final int pos = buf.position();
					buf.getInt(); // total length
					int name_length = buf.getInt();
					byte [] nameArray = new byte[name_length];
					buf.get(nameArray);
					String name = new String(nameArray, charset);
					buf.position(pos);
					Serializer<?> serializer = serializers.get(name);
					if(serializer == null) {
						logger.error("Serializer for {} not found", name);
						return null;
					} else {
						return serializer.fromByteBuf(buf);
					}
				}
			
			public static <T extends Struct> void toByteArray(T struct, ByteBuffer buf) {
				Preconditions.checkArgument(struct != null, "Struct is null. Cannot serialize to byte array");
				Serializer<T> serializer = (Serializer<T>) serializers.get(struct.getClass().getName());
				if(serializer == null) {
					logger.error("Serializer for {} not found", struct.getClass().getName());
					throw new RuntimeException("Serializer for " + struct.getClass().getName() + " not found");
				} else {
					serializer.toByteArray(struct, buf);
				}
			}
			
			public static <T extends Struct> byte [] toByteArray(T struct) {
				Preconditions.checkArgument(struct != null, "Struct is null. Cannot serialize to byte array");
				Serializer<T> serializer = (Serializer<T>) serializers.get(struct.getClass().getName());
				if(serializer == null) {
					logger.error("Serializer for {} not found", struct.getClass().getName());
					return null;
				} else {
					return serializer.toByteArray(struct);
				}
			}
			
			private interface Serializer<T extends Struct> {
				public void toByteArray(T struct, ByteBuffer buf);
				public byte [] toByteArray(T struct);
				public Object fromByteBuf(ByteBuffer buf);
			}
			
			private static final Map<String, Serializer<?>> serializers = Maps.newHashMap();
			
			static {
				«FOR struct : resource.allContents
					.filter(typeof(Struct))
					.filter([isInPackages(packages)])
					.toIterable»
					serializers.put("«struct.fullname»", new Serializer<«struct.fullname»>() {
						
						private static final int BITMASK_LENGTH = «if(struct.structFields.filter[nullable].size % 8 > 0) 
								struct.structFields.filter[nullable].size / 8 + 1 
								else 
								struct.structFields.filter[nullable].size / 8»; 

						
						@Override
						public void toByteArray(«struct.fullname» struct, ByteBuffer buf) {
							final int __length_position = buf.position();
							buf.position(buf.position() + 4);
							BinaryParser.writestring(buf, "«struct.fullname»");
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
						public byte [] toByteArray(«struct.fullname» struct) {
							ByteBuffer buf = ByteBuffer.allocate(struct.getByteSize());
							toByteArray(struct, buf);
							buf.flip();
							byte [] b = new byte[buf.limit()];
							buf.get(b, 0, b.length);
							return b;
						}
						
						@Override
						public Object fromByteBuf(ByteBuffer buf) {
							final «struct.fullname».Builder builder = «struct.fullname».builder();
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
		}
		
		'''
		fsa.generateFile("java/ru/weawer/ww/BinaryStructSerializer.java", output)
	}
		
	def private String typeNameToFunc(Type t) {
		if(isStruct(t)) return (t.ref as Struct).name;
		if(isEnum(t))   return (t.ref as EnumType).name;
		if(isSimple(t)) return t.simple.getName();
		if(isList(t))   return "List" + typeNameToFunc(t.list.elem)
		if(isMap(t)) 	return "Map" + typeNameToFunc(t.map.key) + typeNameToFunc(t.map.value)
		return "";
	}
		
	private static int k;
	
	def static private void increment() {
		k = k + 1;
	}
	
	def static private void reset() {
		k = 0;
	}
	
}