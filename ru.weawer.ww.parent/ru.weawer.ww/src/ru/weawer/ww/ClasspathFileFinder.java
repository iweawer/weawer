package ru.weawer.ww;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Enumeration;
import java.util.List;
import java.util.jar.JarEntry;
import java.util.jar.JarFile;

import com.google.common.collect.Lists;

public class ClasspathFileFinder {

	public List<URL> findFilesInClassPath(String fileNamePattern) {
		List<URL> result = Lists.newArrayList();
		String classPath = System.getProperty("java.class.path");
		String[] pathElements = classPath.split(System.getProperty("path.separator"));
		for (String element : pathElements) {
			try {
				File newFile = new File(element);
				if (newFile.isDirectory()) {
					result.addAll(findResourceInDirectory(newFile, fileNamePattern));
				} else {
					result.addAll(findResourceInFile(newFile, fileNamePattern));
				}
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return result;
	}

	@SuppressWarnings("deprecation")
	private List<URL> findResourceInFile(File resourceFile, String fileNamePattern) throws IOException {
		List<URL> result = Lists.newArrayList();
		if (resourceFile.canRead() && resourceFile.getAbsolutePath().endsWith(".jar")) {
			try(JarFile jarFile = new JarFile(resourceFile)) {;
				Enumeration<JarEntry> entries = jarFile.entries();
				while (entries.hasMoreElements()) {
					JarEntry singleEntry = entries.nextElement();
					if (singleEntry.getName().matches(fileNamePattern)) {
						URL url = this.getClass().getResource("/" + singleEntry.getName());
						result.add(url);
					}
				}
			}
		} else if(resourceFile.canRead() && resourceFile.isFile() && resourceFile.getName().matches(fileNamePattern)) {
			URL url = this.getClass().getResource("/" + resourceFile.getName());
			if(url == null) {
				url = resourceFile.toURL();
			}
			result.add(url);
		}
		return result;
	}

	@SuppressWarnings("deprecation")
	private List<URL> findResourceInDirectory(File directory, String fileNamePattern)
			throws IOException {
		List<URL> result = Lists.newArrayList();
		File[] files = directory.listFiles();
		for (File currentFile : files) {
			if (currentFile.getAbsolutePath().matches(fileNamePattern) && currentFile.isFile()) {
				URL url = this.getClass().getResource("/" + currentFile.getName());
				if(url == null) {
					url = currentFile.toURL();
				}
				result.add(url);
			} else if (currentFile.isDirectory()) {
				result.addAll(findResourceInDirectory(currentFile, fileNamePattern));
			} else {
				result.addAll(findResourceInFile(currentFile, fileNamePattern));
			}
		}
		return result;
	}
}
