package ru.weawer.ww.generator

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.List
import java.util.concurrent.atomic.AtomicInteger
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.wwDsl.EnumType

import static extension ru.weawer.ww.common.Util.*

@Singleton
class EnumsGenerator {
	
	@Inject private Headers headers;
	
	def int incrementCounter(AtomicInteger counter) {
		return counter.incrementAndGet();		
	}
	
	@Generate("java")
	def public void generateJava(List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {
		resource
		.allContents
		.toIterable
		.filter(typeof(EnumType))
		.filter([isInPackages(packages)])
		.forEach[generateJava(fsa)]
	}
	
	def private void generateJava(EnumType e, IFileSystemAccess fsa) {
		val allzero = e.isAllZero
		
		var i = new AtomicInteger(0);
		val output = 
		'''
		«headers.getJavaHeader(e.eResource.getURI.lastSegment.toString)»
		package «e.getPackage»;
			
		«IF e.comment != null»
		/**
		 * «e.comment.replaceAll("\n", "\n *")»
		 */
		«ENDIF»
		import com.google.common.base.*;
		import com.google.common.collect.*;
		
		import java.util.*;
		import java.util.concurrent.ConcurrentHashMap;
		
		import org.slf4j.LoggerFactory;
		import org.slf4j.Logger;
		
		public enum «e.name» {
			«FOR f : e.fields»
			«f.name»(«if(allzero) i.get() else f.^val», 1L << «if(allzero) i.get() else f.^val»), «f.comment»
			«increment(i)»
			«ENDFOR»
			;
			
			private static final Logger logger = LoggerFactory.getLogger(«e.name».class);
			
			private final int val;
			private final long bit;
			
			«e.name»(int val, long bit) { this.val = val; this.bit = bit; }
				
			public long bit() {	return bit; }
			public int val() { return val; }
			
			private static final Function<«e.name», Long> toBit = new Function<«e.name», Long>() {
				public Long apply(«e.name» e) {
					return e.bit();
				}
			};
			
			private static final Function<«e.name», String> toName = new Function<«e.name», String>() {
				public String apply(«e.name» e) {
					return e.name();
				}
			};
			
			private static final Function<«e.name», Integer> toVal = new Function<«e.name», Integer>() {
				public Integer apply(«e.name» e) {
					return e.val();
				}
			};
			
			final static Map<Long, String> combinedNames = new ConcurrentHashMap<Long, String>();
			final static Map<Long, «e.name»> bitToName = Maps.uniqueIndex(Arrays.asList(values()), toBit);
			
			public static String decode(long bitmask) {
				String res = combinedNames.get(bitmask);
				if (res == null) {
					res = Joiner.on(",").join(Sets.newLinkedHashSet(Collections2.transform(get(bitmask), toName)));
					combinedNames.put(bitmask, res);
				}
				return res;
			}
			
		
			public static Set<«e.name»> get(long bitmap) {
				Set<«e.name»> set = Sets.newLinkedHashSet();
				for(int i = 0; i < 64; i++) {
					long bit = 1L << i;
					if((bit & bitmap) > 0) {
						«e.name» name = bitToName.get(bit);
						Preconditions.checkArgument(name != null, "Incorrect bit is set!");
						set.add(name);
					}
				}
				return set;
			}
			
			public static «e.name» fromString(String s) {
				if(s == null) return null;
				try {
					return valueOf(s);
				} catch(Exception e) {
					logger.error("Unsupported value for enum «e.name»: " + s); 
				}
				return null;
			}
			
			// «i = new AtomicInteger(0)»
			private static final ImmutableMap<Integer, «e.name»> byVal = ImmutableMap.<Integer, «e.name»> builder()
			«FOR f : e.fields»
					.put(«if(allzero) i.get() else f.^val», «f.name»)
					«increment(i)»
			«ENDFOR»
					.build();
				
			public static «e.name» fromVal(int val) {
				return byVal.get(val);
			}
		}
		'''
		fsa.generateFile("java/" + e.fullname.replaceAll("\\.", "/") + ".java", output)
	}

	
	def private void increment(AtomicInteger i) {
		i.incrementAndGet
	}
	
	def private boolean isAllZero(EnumType e) {
		return e.fields.filter[it.^val != 0].size == 0
	}
}
