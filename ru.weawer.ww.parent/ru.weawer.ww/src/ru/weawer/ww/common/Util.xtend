package ru.weawer.ww.common

import com.google.common.collect.Lists
import com.google.common.collect.Sets
import java.util.List
import org.eclipse.emf.ecore.EObject
import ru.weawer.ww.wwDsl.Element
import ru.weawer.ww.wwDsl.EnumType
import ru.weawer.ww.wwDsl.Field
import ru.weawer.ww.wwDsl.Package
import ru.weawer.ww.wwDsl.SettingsContainer
import ru.weawer.ww.wwDsl.SimpleType
import ru.weawer.ww.wwDsl.Struct
import ru.weawer.ww.wwDsl.StructField
import ru.weawer.ww.wwDsl.Tag
import ru.weawer.ww.wwDsl.TagWithValue
import ru.weawer.ww.wwDsl.TaggableElement

public class Util {
	
	def public static String getPackage(EObject e) {
		if(e instanceof Package) {
			return e.name;
		}
		return getPackage(e.eContainer);
	}
	
	def public static boolean hasCustomValues(EnumType t) {
		return t.fields.map[^val].filter[it != 0].size > 0
	}
	
	def public static List<Struct> getSettings(SettingsContainer c) {
		val List<Struct> structs = Lists::newArrayList();
		structs.addAll(c.fields.filter[ref != null].map[ref].toList);
		structs.addAll(c.fields.filter[field != null].map[field].toList);
		if(c.fieldsExpr != null) {
			structs.addAll(
				c.fieldsExpr
				.map[ ex |
					ex.packages
					.map[element] // take all contents of packages
					.flatten // make single list from list of lists
					.toSet // remove duplicates
					.filter[it instanceof Struct]  // take only elements of type Struct
					.filter[(it as Struct).type.equals("setting")] // take only 'setting'
					.map[it as TaggableElement]   // cast to TaggableElement
					.filterByTag(ex.tags)       // filter by tags specified in filterExpr
				]
				.flatten
				.map[it as Struct]
				.toSet
			)
		}
		return structs;
	}
	
	def public static List<Field> getStructFields(Struct c) {
		val List<Field> fields = Lists::newArrayList();
		fields.addAll(c.fields.filter[ref != null].map[ref].toList);
		fields.addAll(c.fields.filter[field != null].map[field].toList);
		if(c.fieldsExpr != null) {
			val res = 
				c.fieldsExpr
				.map[ expr |
					expr.packages
					.map[element] // take all contents of packages
					.flatten // make single list from list of lists
					.toSet // remove duplicates
					.filter[it instanceof Field]  // take only elements of type Field
					.map[it as Field]   // cast to TaggableElement
					.filterByTag(expr.tags)       // filter by tags specified in filterExpr
				]
				.flatten
				.toSet
			fields.addAll(res)
		}
		return fields;
	}
	
	def public static <T extends TaggableElement> Iterable<T> filterByTag(Iterable<T> elements, Iterable<TagWithValue> includeTags) {
		if(includeTags == null || includeTags.size == 0) return elements;
		return elements.filter[!Sets::intersection(tags.map[tag].toSet, includeTags.map[tag].toSet).empty]
	}
	
	def public static String getFullname(Field f) {
		var String name = f.name;
		if(f.eContainer instanceof Package) {
			return (f.eContainer as Package).name + "." + f.name
		} else if(f.eContainer instanceof StructField) {
			val sf = f.eContainer as StructField
			val s = sf.eContainer as Struct
			val p = s.eContainer as Package
			return p.name + "." + s.name + "." + f.name
		}
		return name;
	}
	
	def public static String getFullname(Tag t) {
		return (t.eContainer as Package).name + "." + t.name 
	}
	
	def public static String getFullname(EnumType t) {
		return (t.eContainer as Package).name + "." + t.name 
	}
	
	def public static String getFullname(Struct t) {
		return (t.eContainer as Package).name + "." + t.name 
	}
	
	def public static String getLongname(Struct t) {
		return getFullname(t).replaceAll("\\.", "_")
	}
	
	def public static String getLongname(EnumType t) {
		return getFullname(t).replaceAll("\\.", "_")
	}
	
	def public static String getFullname(SettingsContainer t) {
		return (t.eContainer as Package).name + "." + t.name 
	}
	
	def public static boolean hasTag(TaggableElement e, String tagName) {
		return !e.tags.filter[tag.name.equals(tagName)].empty;
	}
	
	def public static String getTagValue(TaggableElement e, String tagName) {
		return e.tags.findFirst[tag.name.equals(tagName)]?.value;
	}
	
	def public static boolean isKey(Field f, Struct s) {
		if(s.keys == null) return false;
		return s.keys.map[getFullname].contains(f.fullname)
	}
	
	def public static boolean isEnum(Field f) {
		return f.type.ref != null && (f.type.ref instanceof EnumType)
	}
	
	def public static boolean isSimpleType(Field f) {
		return f.type.simple != null
	}
	
	def public static SimpleType getSimpleType(Field f) {
		return if (f.type.simple != null) f.type.simple else null 
	}
	
	def public static boolean isInPackages(Element element, List<String> packages) {
		val elemPack = getPackage(element);
		for(String pack : packages) {
			if(elemPack.startsWith(pack)) return true;
		}
		return false;
	}
	
	def public static String getDefaultValue(Field f) {
		if(f.^default == null) return ""
		if(f.^default.e != null) {
			return (f.^default.e.eContainer as EnumType).fullname + "." + f.^default.e.name;
		}
		return f.^default.s
	}
}
