/**
 * 
 */
package ru.weawer.ww;

import java.net.URISyntaxException;
import java.net.URL;
import java.util.Arrays;
import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtext.generator.JavaIoFileSystemAccess;
import org.eclipse.xtext.util.CancelIndicator;
import org.eclipse.xtext.validation.CheckMode;
import org.eclipse.xtext.validation.IResourceValidator;
import org.eclipse.xtext.validation.Issue;

//import com.db.sti.generator.UIModelGenerator;
import com.google.inject.Inject;
import com.google.inject.Injector;
import com.google.inject.Provider;

import ru.weawer.ww.generator.BinaryParsersGenerator;
import ru.weawer.ww.generator.BinaryStructSerializer;
import ru.weawer.ww.generator.EnumsGenerator;
import ru.weawer.ww.generator.InterfaceGenerator;
import ru.weawer.ww.generator.JsonStructSerializer;
import ru.weawer.ww.generator.WwDslGenerator;
import ru.weawer.ww.generator.settings.JavaClassesGenerator;

/**
 * @author iweawer
 *
 */
public class Main {

	public static final String OUTPUT_DIR = "outputDir";
	
	private static final String LANG_PROPERTY = "lang";
	private static final String GENERATORS_PROPERTY = "generators";
	private static final String PACKAGES_PROPERTY = "packages";
	private static final String OUTPUT_DIR_PROPERTY = "outputDir";
	
	public static void main(String[] args) {
		try {
		// Loading languages to generate
		String langProp = System.getProperty(LANG_PROPERTY);
		if(langProp == null || "".equals(langProp)) {
			System.err.println("No languages specified. Please provide them in form -Dlang=py,java,etc");
			return;
		}
		List<String> languages = Arrays.asList(langProp.split(","));
		
		// Loading packages to generate
		String packProp = System.getProperty(PACKAGES_PROPERTY);
		if(packProp == null || "".equals(packProp)) {
			System.err.println("No packages specified. Please provide them in form -Dpackage=com.foo,com.bar");
			return;
		}
		List<String> packages = Arrays.asList(packProp.split(","));
		
		// Loading output dir
		String outputDir = System.getProperty(OUTPUT_DIR_PROPERTY);
		if(outputDir == null || "".equals(outputDir)) {
			System.err.println("No output dir specified. Please provide it in form -DoutputDir=dirname");
			return;
		}
		
		Injector injector = new WwDslStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
		Main main = injector.getInstance(Main.class);
		
		WwDslGenerator dslGenerator = injector.getInstance(WwDslGenerator.class);
		dslGenerator.registerGenerator(injector.getInstance(EnumsGenerator.class));
		dslGenerator.registerGenerator(injector.getInstance(JavaClassesGenerator.class));
		dslGenerator.registerGenerator(injector.getInstance(JsonStructSerializer.class));
		dslGenerator.registerGenerator(injector.getInstance(BinaryParsersGenerator.class));
		dslGenerator.registerGenerator(injector.getInstance(BinaryStructSerializer.class));
		dslGenerator.registerGenerator(injector.getInstance(InterfaceGenerator.class));
		
		String generatorProp = System.getProperty(GENERATORS_PROPERTY);
		if(generatorProp != null && !generatorProp.isEmpty()) {
			List<String> generators = Arrays.asList(generatorProp.split(","));			
				
			for(String generator : generators) {
				try {
					dslGenerator.registerGenerator(Class.forName(generator).newInstance());
				} catch(Exception e) {
					System.err.println("Failed to load generator " + generator);
					e.printStackTrace();
				}
			}
		}
		List<URL> urls = new ClasspathFileFinder().findFilesInClassPath(".*ww");
		System.out.println("URLs: " + urls);
		System.out.println("Output dir: " + outputDir);
//		System.out.println("Path to crsdsl files: " + args[0]);
//		System.out.println("List of files: " + Arrays.asList(new File(args[0]).list()));
		main.runGenerator(languages, packages, urls, outputDir);
		} catch(Exception e) {
			e.printStackTrace();
		}
	}
	
	@Inject 
	private Provider<ResourceSet> resourceSetProvider;
	
	@Inject
	private IResourceValidator validator;
	
	@Inject
	private WwDslGenerator generator;
	
	@Inject 
	private JavaIoFileSystemAccess fsa;

	protected void runGenerator(List<String> languages, List<String> packages, List<URL> files, String outputDir) throws URISyntaxException {
		// load the resource
		ResourceSet set = resourceSetProvider.get();
		for(URL url : files) {
			System.out.println("Loading " + url);
			set.getResource(URI.createURI(url.toURI().toString()), true);
		}
		
		
		// validate the resource
		for(Resource resource : set.getResources()) {
			List<Issue> list = validator.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl);
			if (!list.isEmpty()) {
				for (Issue issue : list) {
					System.err.println(issue);
				}
				return;
			}
		}
		
		
		// configure and start the generator
		fsa.setOutputPath(outputDir);
		generator.doGenerate(languages, packages, set, fsa);	
		System.out.println("Code generation completed");
	}
}
