package ru.weawer.ww.generator

import com.google.inject.Inject
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.emf.ecore.resource.ResourceSet
import ru.weawer.ww.wwDsl.Interface

import static extension ru.weawer.ww.common.TypeUtil.*
import static extension ru.weawer.ww.common.Util.*

public class InterfaceGenerator {
	
	@Inject private Headers headers;
	
	@Generate("java")
	def public void writeInterfaces(java.util.List<String> packages, ResourceSet resource, IFileSystemAccess2 fsa) {

		for(i : resource.allContents
			.filter(typeof(Interface))
			.filter([isInPackages(packages)])
			.toIterable
		) {
			val output = '''
			«headers.getJavaHeader(i.eResource.URI.lastSegment.toString)»
			package «i.package»; 
			
			import ru.weawer.ww.struct.Struct;
			
			«IF i.comment != null»
			// «i.comment»
			«ENDIF»
			public interface «i.name» extends Struct«i.extends.map[", " + fullname].join()» {
				«FOR field : i.interfaceFields»
					public «field.type.toJavaType» «field.name»();
				«ENDFOR»
			}
			'''
			fsa.generateFile("java/" + i.fullname.replaceAll("\\.", "/") + ".java", output)			
		}

	}
}