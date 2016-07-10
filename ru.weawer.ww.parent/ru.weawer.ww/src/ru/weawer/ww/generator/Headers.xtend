package ru.weawer.ww.generator

import com.google.inject.Singleton
import com.google.inject.Inject

@Singleton
class Headers {
	
	private String javaHeader;
	private String mlabHeader;

	@Inject
	new() {
		val revision = "Unknown";
		javaHeader = '''
////////////////////////////////////////////////////////////////
//	PLEASE DO NOT EDIT!
//	The file is generated automatically from Weawer DSL
//	To change file edit master file .sti
//  Revision: «revision»
////////////////////////////////////////////////////////////////
	'''; 
	
		mlabHeader = '''
%///////////////////////////////////////////////////////////////
%	PLEASE DO NOT EDIT!
%	The file is generated automatically from Weawer DSL
%	To change file edit master file .ww
%   Revision: «revision»
%///////////////////////////////////////////////////////////////
	'''; 

	}	
	
	def public getJavaHeader(String filename) {
		return javaHeader.replaceAll(".ww", filename)
	}
	
	def public getJavaHeader() {
		return javaHeader
	}
	
	def public getMlabHeader(String filename) {
		return mlabHeader.replaceAll(".ww", filename)
	}
	
	
	def public getMlabHeader() {
		return mlabHeader
	}	
}
