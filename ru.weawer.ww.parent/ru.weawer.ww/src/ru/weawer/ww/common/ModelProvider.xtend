package ru.weawer.ww.common

import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.resource.ResourceSet
import java.net.URL

import ru.weawer.ww.ClasspathFileFinder
import java.util.List
import com.google.inject.Injector
import ru.weawer.ww.WwDslStandaloneSetupGenerated
import com.google.inject.Provider
import java.util.Set
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.TaggableElement
import com.google.common.collect.Sets
import java.util.Iterator
import org.eclipse.emf.common.notify.Notifier

public class ModelProvider {

	private static final ModelProvider modelProvider = new ModelProvider();
	
	def public static instance() {
		return modelProvider;
	}
	
	private final ResourceSet resourceSet;
	
	private new() {
		val List<URL> urls = new ClasspathFileFinder().findFilesInClassPath(".*ww");
		val Injector injector = new WwDslStandaloneSetupGenerated().createInjectorAndDoEMFRegistration();
		val Provider<ResourceSet> resourceSetProvider = injector.getProvider(typeof(ResourceSet));
		resourceSet = resourceSetProvider.get();
		for(URL url : urls) {
			resourceSet.getResource(URI.createURI(url.toURI().toString()), true);
		}
	}
	
	def public <T extends TaggableElement> Set<T> getElementsByTag(Class<T> c, String tagName) {
		return resourceSet.allContents
			.filter(typeof(TaggableElement))
			.filter[it.class == c]
			.filter[hasTag(tagName)]
			.toSet as Set<T>
	}
	
	def public <T extends TaggableElement> Set<T> getElementsByAnyTag(Class<T> c, Set<String> tags) {
		return resourceSet.allContents
			.filter(typeof(TaggableElement))
			.filter[c.isAssignableFrom(it.class)]
			.filter[hasAnyTag(tags)]
			.toSet as Set<T>
	}
	
	def public <T extends TaggableElement> Set<T> getElementsByAllTags(Class<T> c, Set<String> tags) {
//		val a1 = resourceSet.allContents.toSet;
//		val a2 = a1.filter(typeof(TaggableElement))
//		val a3 = a2.filter[c.isAssignableFrom(it.class)]
//		val a4 = a3.filter[hasAllTags(tags)]
		return resourceSet.allContents
			.filter(typeof(TaggableElement))
			.filter[c.isAssignableFrom(it.class)]
			.filter[hasAllTags(tags)]
			.toSet as Set<T>
	}
	
	def public Set<Struct> getSettingsByAnyTag(Set<String> tags) {
		return resourceSet.allContents
			.filter(typeof(Struct))
			.filter[type == 'setting']
			.filter[hasAnyTag(tags)]
			.toSet
	}
	
	def public Set<Struct> getSettingsByAllTags(Set<String> tags) {
		return resourceSet.allContents
			.filter(typeof(Struct))
			.filter[type == 'setting']
			.filter[hasAllTags(tags)]
			.toSet
	} 
	
	def public boolean hasTag(TaggableElement t, String tagName) {
		return t.tags.findFirst[it.tag.name.equals(tagName)] != null
	}
	
	def public boolean hasAnyTag(TaggableElement t, Set<String> tags) {
		return !Sets.intersection(t.tags.map[tag.name].toSet, tags).isEmpty
	}
	
	def public boolean hasAllTags(TaggableElement t, Set<String> tags) {
		return Sets.intersection(t.tags.map[tag.name].toSet, tags).size == tags.size
	}
}