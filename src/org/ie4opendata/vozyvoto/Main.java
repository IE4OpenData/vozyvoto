package org.ie4opendata.vozyvoto;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;

public class Main {

	public static void main(String[] args) throws IOException {
		TokenNameFinder namer = new TokenNameFinder();
		String dir = args[0];
		TokenNameFinder.output.delete();
		File[] files = new File(dir).listFiles();
		for( File file : files ) {
			String input = FileUtils.readFileToString(file);
			input = input.replace(".-", ".");
			namer.findNames(file.getName(), input);		
		}
	}
}
