package ru.weawer.ww.generator.cassandra

import com.google.inject.Inject
import com.google.inject.Singleton
import java.util.List
import java.util.concurrent.atomic.AtomicInteger
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IFileSystemAccess2
import ru.weawer.ww.wwDsl.EnumType

import static extension ru.weawer.ww.common.Util.*
import static extension ru.weawer.ww.common.TypeUtil.*
import ru.weawer.ww.generator.Headers
import ru.weawer.ww.generator.Generate
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.Type
import ru.weawer.ww.wwDsl.SimpleType

@Singleton
class CassandraGenerator {
	
	@Inject private Headers headers;
	
	@Generate("cassandra")
	def public void generateCassandraDef(List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {
		val output = '''
		«FOR s : 
		resource
		.allContents
		.toIterable
		.filter(typeof(Struct))
		.filter([isInPackages(packages)])
		.filter[(keys != null && keys.size > 0) || single]
		»
			CREATE TABLE «s» (
				«FOR f : s.allStructFields.filter[!hasTag("Transient")]»
					«f.name» «f.type.toCassandraType»,
					«IF s.single»
						id TEXT,
						primary key id
					«ELSE»
						primary key («s.keys.map[name].join(", ")»)
					«ENDIF»
				«ENDFOR»
			);
		«ENDFOR»
		'''
		
		fsa.generateFile("cassandra/cassandra_def.cql", output)
	}

	@Generate("cassandra")
	def public void generateCassandraRepository(List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {
		
		resource
		.allContents
		.toIterable
		.filter(typeof(Struct))
		.filter([isInPackages(packages)])

		val output = 
		'''
		package ru.weawer.ww;
			
		import com.google.common.base.*;
		import com.google.common.collect.*;
		
		import java.util.*;
		import java.util.concurrent.ConcurrentHashMap;
		
		import org.slf4j.LoggerFactory;
		import org.slf4j.Logger;
		
		public EntityRepository<S> {
			
			private static final Logger logger = LoggerFactory.getLogger(CassandraRepository.class);
			
			public void save(S entity);
			
			public void save(Iterable<S> entities);
		
			public findOne(Object ... keys);
		
			public boolean exists(Object ... keys);
		
			public Iterable<S> findAll();
		
			public Iterable<S> findAll(Iterable<Object[]> keys);
		
			public long count();
		
			public void delete(Object ... keys);
		
			public void delete(S entity);
		
			public void delete(Iterable<S> entities);
		
			public void deleteAll(); 

			private interface Repository {
				
			}

		}
		'''
		fsa.generateFile("java/ru/weawer/ww/CassandraRepository.java", output);
	}
	
	def private String toCassandraType(Type type) {
		if(isSimple(type)) {
			switch(type.simple) {
				case SimpleType.BOOLEAN: return "BOOLEAN"
				case SimpleType.BYTE: return "SMALLINT"
				case SimpleType.CHAR: return "SMALLINT"
				case SimpleType.SHORT: return "SMALLINT"
				case SimpleType.INT: return "INT"
				case SimpleType.LONG: return "BIGINT"
				case SimpleType.FLOAT: return "FLOAT"
				case SimpleType.DOUBLE: return "DOUBLE"
				case SimpleType.STRING: return "TEXT"
				case SimpleType.DATE: return "DATE"
				case SimpleType.TIME: return "TIME"
				case SimpleType.DATETIME: return "TEXT"
				case SimpleType.TIMESTAMP: return "BIGINT"
				case SimpleType.GUID: return "UUID"
				case SimpleType.BYTEARRAY: return "BLOB"
			}
		} else {
			return "text"
		};
	}
}