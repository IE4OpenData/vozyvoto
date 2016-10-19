package org.ie4opendata.vozyvoto;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;

import opennlp.tools.namefind.NameFinderME;
import opennlp.tools.namefind.TokenNameFinderModel;
import opennlp.tools.util.Span;

import org.apache.commons.io.FileUtils;

public class TokenNameFinder {
	
	static File output = new File("./output.csv");

	private TokenNameFinderModel loadSpanishModel() throws IOException {
		InputStream modelIn = new FileInputStream("./models/es-ner-person.bin");
		TokenNameFinderModel model = null;
		try {
		  model = new TokenNameFinderModel(modelIn);
		}
		catch (IOException e) {
		  e.printStackTrace();
		}
		finally {
		  if (modelIn != null) {
		    try {
		      modelIn.close();
		    }
		    catch (IOException e) {
		    }
		  }
		}
		return model;
	}
	
	public void findNames(String filename, String document) throws IOException {
		
		TokenNameFinderModel model = loadSpanishModel();

		NameFinderME nameFinder = new NameFinderME(model);
		
		String[] sentences = new SentenceDetector().detectSentences(document);

		Tokenizer tokenizer = new Tokenizer();
		for (String sentence : sentences) {
			String[] tokens = tokenizer.tokenize(sentence);
			Span[] nameSpans = nameFinder.find(tokens);
			if( nameSpans.length > 0 ) {
				System.out.println(Arrays.toString(Span.spansToStrings(nameSpans, tokens)));
				output(filename, Arrays.toString(Span.spansToStrings(nameSpans, tokens)), sentence.replace("\n"," "));
			}
//	    	//3. print names
//			double[] spanProbs = nameFinder.probs(nameSpans);
//	    	for( int i = 0; i<nameSpans.length; i++) {
//	    		System.out.print(tokens[nameSpans[i].getStart()] + " " + tokens[nameSpans[i].getEnd()-1]);
//	    		System.out.println(", Probability is: "+spanProbs[i]);
//	    	}	

		}	
	}
	
	private void output(String filename, String entities, String sentence) {
		String str = 
				filename + "\t" + entities.replace("[", "").replace("]","") + 
				"\t" + sentence.replace("\n",  "") + "\n";
		try {
			FileUtils.write(output, str, true);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}
