package ru.weawer.ww.generator

import com.google.inject.Singleton
import java.util.HashMap
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.List
import ru.weawer.ww.wwDsl.Map
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*

@Singleton
public class BinaryParsersGenerator {
	
	@Generate("java")
	def public void writeStructSerializer(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {


		val output = '''
		package ru.weawer.ww;
		
		import java.io.*;
		import java.nio.*;
		import java.nio.charset.Charset;
		import java.time.*;
		import java.util.*;
		import java.util.function.Function;
		import com.google.common.collect.*;
		import ru.weawer.ww.*;
		import ru.weawer.ww.struct.Struct;
		«FOR pack : packages»
		import «pack».*;
		«ENDFOR»
		
		public class BinaryParser {
			
			// boolean|byte|char|short|int|long|float|double|string|date|time|datetime|timestamp|guid
			
			/* boolean */
			public static final void writeboolean(ByteBuffer buf, boolean b) {
				buf.put(b ? (byte) 1 : (byte) 0);					
			}
			
			public static final boolean readboolean(ByteBuffer buf) {
				return buf.get() > 0 ? true : false;
			}
			
			public static final void addsize_boolean(AtomicInteger size, boolean b) {
				size.addAndGet(1);
			}
			
			/* byte */
			public static final void writebyte(ByteBuffer buf, byte b) {
				buf.put(b);
			}
			
			public static final byte readbyte(ByteBuffer buf) {
				return buf.get();
			}
			
			public static final void addsize_byte(AtomicInteger size, byte b) {
				size.addAndGet(1);
			}
			
			/* char */
			private static final Charset charset = Charset.forName("UTF-8");
			
			public static final void writechar(ByteBuffer buf, char c) {
				buf.putChar(c);
			}
			
			public static final char readchar(ByteBuffer buf) {
				return buf.getChar();
			}
			
			public static final void addsize_char(AtomicInteger size, char b) {
				size.addAndGet(2);
			}
			
			/* short */
			public static final void writeshort(ByteBuffer buf, short i) {
				buf.putShort(i);
			}
			
			public static final short readshort(ByteBuffer buf) {
				return buf.getShort();
			}
			
			public static final void addsize_short(AtomicInteger size, short b) {
				size.addAndGet(2);
			}
			
			/* int */
			public static final void writeint(ByteBuffer buf, int i) {
				buf.putInt(i);
			}
			
			public static final int readint(ByteBuffer buf) {
				return buf.getInt();
			}
			
			public static final void addsize_int(AtomicInteger size, int b) {
				size.addAndGet(4);
			}
			
			/* long */
			public static final void writelong(ByteBuffer buf, long l) {
				buf.putLong(l);
			}
			
			public static final long readlong(ByteBuffer buf) {
				return buf.getLong();
			}
			
			public static final void addsize_long(AtomicInteger size, long b) {
				size.addAndGet(8);
			}
			
			/* float */
			public static final void writefloat(ByteBuffer buf, float f) {
				buf.putFloat(f);
			}
			
			public static final float readfloat(ByteBuffer buf) {
				return buf.getFloat();
			}
			
			public static final void addsize_float(AtomicInteger size, float b) {
				size.addAndGet(4);
			}
			
			/* double */
			public static final void writedouble(ByteBuffer buf, double d) {
				buf.putDouble(d);
			}
			
			public static final double readdouble(ByteBuffer buf) {
				return buf.getDouble();
			}
			
			public static final void addsize_double(AtomicInteger size, double b) {
				size.addAndGet(8);
			}
			
			public static final void writestring(ByteBuffer buf, String s) {
				byte [] b = s.getBytes(charset);
				buf.putInt(b.length);
				buf.put(b);
			}
			
			public static final String readstring(ByteBuffer buf) {
				int __size = buf.getInt();
				if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
				byte [] b = new byte[__size];
				buf.get(b);
				return new String(b, charset);
			}
			
			public static final void addsize_string(AtomicInteger size, String b) {
				size.addAndGet(b.getBytes(charset).length);
			}
			
			// date|time|datetime|timestamp|guid
			
			/* date */
			public static final void writedate(ByteBuffer buf, LocalDate s) {
				byte [] b = s.toString().getBytes();
				buf.putInt(b.length);
				buf.put(b);
			}
			
			public static final LocalDate readdate(ByteBuffer buf) {
				int __size = buf.getInt();
				if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
				byte [] b = new byte[__size];
				buf.get(b);
				return LocalDate.parse(new String(b));
			}
			
			public static final void addsize_date(AtomicInteger size, LocalDate b) {
				size.addAndGet(b.toString().getBytes().length);
			}
			
			/* time */
			public static final void writetime(ByteBuffer buf, LocalTime s) {
				byte [] b = s.toString().getBytes();
				buf.putInt(b.length);
				buf.put(b);
			}
			
			public static final LocalTime readtime(ByteBuffer buf) {
				int __size = buf.getInt();
				if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
				byte [] b = new byte[__size];
				buf.get(b);
				return LocalTime.parse(new String(b));
			}
			
			public static final void addsize_time(AtomicInteger size, LocalTime b) {
				size.addAndGet(b.toString().getBytes().length);
			}
			
			/* datetime */
			public static final void writedatetime(ByteBuffer buf, LocalDateTime s) {
				byte [] b = s.toString().getBytes();
				buf.putInt(b.length);
				buf.put(b);
			}
			
			public static final LocalDateTime readdatetime(ByteBuffer buf) {
				int __size = buf.getInt();
				if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
				byte [] b = new byte[__size];
				buf.get(b);
				return LocalDateTime.parse(new String(b));
			}
			
			public static final void addsize_datetime(AtomicInteger size, LocalDateTime b) {
				size.addAndGet(b.toString().getBytes().length);
			}
			
			/* timestamp */
			public static final void writetimestamp(ByteBuffer buf, long l) {
				buf.putLong(l);
			}
			
			public static final long readtimestamp(ByteBuffer buf) {
				return buf.getLong();
			}
			
			public static final void addsize_timestamp(AtomicInteger size, long b) {
				size.addAndGet(8);
			}
			
			/* guid */
			public static final void writeguid(ByteBuffer buf, java.util.UUID s) {
				byte [] b = s.toString().getBytes();
				buf.putInt(b.length);
				buf.put(b);
			}
			
			public static final java.util.UUID readguid(ByteBuffer buf) {
				int __size = buf.getInt();
				if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
				byte [] b = new byte[__size];
				buf.get(b);
				return java.util.UUID.fromString(new String(b));
			}
			
			public static final void addsize_datetime(AtomicInteger size, java.util.UUID b) {
				size.addAndGet(b.toString().getBytes().length);
			}		
			
			/* bytearray */
			public static final void writebytearray(ByteBuffer buf, byte [] b) {
				buf.putInt(b.length);
				buf.put(b);
			}
			
			public static final byte [] readbytearray(ByteBuffer buf) {
				int __size = buf.getInt();
				if(__size > buf.capacity()) throw new RuntimeException("Too big bytearray size");
				byte [] b = new byte[__size];
				buf.get(b);
				return b;
			}
			
			public static final void addsize_datetime(AtomicInteger size, byte [] b) {
				size.addAndGet(b.length);
			}
			
			private static final ImmutableMap<Class<? extends Struct>, Function<ByteBuffer, ? extends Struct>> parsers;

			static {
				ImmutableMap.Builder<Class<? extends Struct>, Function<ByteBuffer, ? extends Struct>> builder = ImmutableMap.builder();
				«putParsers(packages, resource, fsa)»
				parsers = builder.build();
			}
			
			public static Function<ByteBuffer, ? extends Struct> parser(Class<? extends Struct> clazz) {
				return parsers.get(clazz);
			}
			
			«getListMapFunctions(packages, resource, fsa)»		
		}
		'''
		fsa.generateFile("java/ru/weawer/ww/BinaryParser.java", output);
	}
	
	def private String getListMapFunctions(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {
		var functions = new HashMap<String, String>
		for(type : resource.allContents.filter(typeof(Type)).toIterable) {
			if(isMap(type)) {
				putFunctionFor(type.map, functions)
			} else if(isList(type)) {
				putFunctionFor(type.list, functions)
			} else if(isStruct(type)) {
				putFunctionFor(type.ref as Struct, functions)
			} else if(isEnum(type)) {
				putFunctionFor(type.ref as EnumType, functions)
			}
		}
		for(type : resource.allContents.filter(typeof(Struct)).toIterable) {
			putFunctionFor(type, functions)
		}
		return functions.values.join("\n")
	}
	
	def private void putFunctionFor(Map m, HashMap<String, String> f) {
		var func = '''
		public static void write«m.toName»(ByteBuffer buf, «m.toJavaType» m) {
			writestring(buf, "«m.toName»");
			buf.putInt(m.size());
			for(Map.Entry<«m.key.toJavaObjectType», «m.value.toJavaObjectType»> e : m.entrySet()) {
				write«m.key.toName»(buf, e.getKey());
				write«m.value.toName»(buf, e.getValue());
			}
		}
		
		public static «m.toJavaType» read«m.toName»(ByteBuffer buf) {
			String __name = readstring(buf);
			int __size = buf.getInt();
			if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
			«m.toJavaType» m = Maps.newHashMap();
			for(int i = 0; i < __size; i++) {
				m.put(read«m.key.toName»(buf), read«m.value.toName»(buf));
			}
			return m;
		}
		
		public static void addsize_«m.toName»(AtomicInteger size, «m.toJavaType» m) {
			addsize_string(size, "«m.toName»");
			addsize_int(size, 0); // map size
			for(Map.Entry<«m.key.toJavaObjectType», «m.value.toJavaObjectType»> e : m.entrySet()) {
				addsize_«m.key.toName»(size, e.getKey());
				addsize_«m.value.toName»(size, e.getValue());
			}
		}
		'''
		if(isMap(m.key)) {
			putFunctionFor(m.key.map, f)
		} else if(isList(m.key)) {
			putFunctionFor(m.key.list, f)
		} else if(isStruct(m.key)) {
			putFunctionFor(m.key.ref as Struct, f)
		} else if(isEnum(m.key)) {
			putFunctionFor(m.key.ref as EnumType, f)
		} 
		if(isMap(m.value)) {
			putFunctionFor(m.value.map, f)
		} else if(isList(m.value)) {
			putFunctionFor(m.value.list, f)
		} else if(isStruct(m.value)) {
			putFunctionFor(m.value.ref as Struct, f)
		} else if(isEnum(m.value)) {
			putFunctionFor(m.value.ref as EnumType, f)
		}
		
		f.put(m.toName, func)
	}
	
	def private void putFunctionFor(List l, HashMap<String, String> f) {
		var func = '''
		public static void write«l.toName»(ByteBuffer buf, «l.toJavaType» l) {
			writestring(buf, "«l.toName»");
			buf.putInt(l.size());
			for(«l.elem.toJavaType» t : l) {
				write«l.elem.toName»(buf, t);
			}
		}
		
		public static «l.toJavaType» read«l.toName»(ByteBuffer buf) {
			String __name = readstring(buf);
			int __size = buf.getInt();
			if(__size > buf.capacity()) throw new RuntimeException("Too big string size");
			«l.toJavaType» m = Lists.newArrayList();
			for(int i = 0; i < __size; i++) {
				m.add(read«l.elem.toName»(buf));
			}
			return m;
		}
		
		public static void addsize_«l.toName»(AtomicInteger size, «l.toJavaType» l) {
			addsize_string(size, "«l.toName»");
			addsize_int(size, 0); // list size
			for(«l.elem.toJavaType» t : l) {
				addsize_«l.elem.toName»(size, t);
			}
		}
		'''
		if(isMap(l.elem)) {
			putFunctionFor(l.elem.map, f)
		} else if(isList(l.elem)) {
			putFunctionFor(l.elem.list, f)
		} else if(isStruct(l.elem)) {
			putFunctionFor(l.elem.ref as Struct, f)
		} else if(isEnum(l.elem)) {
			putFunctionFor(l.elem.ref as EnumType, f)
		}
		f.put(l.toName, func);
	}
	
	def private void putFunctionFor(Struct d, HashMap<String, String> f) {
		var func = '''
		public static void write«d.longname»(ByteBuffer buf, «d.fullname» d) {
			d.toByteArray(buf);
		}
		
		public static «d.fullname» read«d.longname»(ByteBuffer buf) {
			return «d.name».fromByteArray(buf);
		}
		
		public static void addsize_«d.longname»(AtomicInteger size, «d.fullname» d) {
			size.addAndGet(d.getByteSize());
		}
		'''
		f.put(d.fullname, func);
	}
	
	def private void putFunctionFor(EnumType e, HashMap<String, String> f) {
		var func = '''
		public static void write«e.longname»(ByteBuffer buf, «e.name» d) {
			writeint(buf, d.val());
		}
		
		public static «e.name» read«e.longname»(ByteBuffer buf) {
			return «e.name».fromVal(readint(buf));
		}
		
		public static void addsize_«e.longname»(AtomicInteger size, «e.name» d) {
			size.addAndGet(4);
		}
		'''
		f.put(e.fullname, func);
	}
	
	def private String putParsers(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {
		'''
		«FOR struct : resource.allContents
							.filter(typeof(Struct))
							.filter([isInPackages(packages)])
							.toIterable»
			builder.put(«struct.fullname».class, BinaryParser::read«struct.longname»);
		«ENDFOR»
		'''
	}
	
}