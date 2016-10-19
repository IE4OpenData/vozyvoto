package org.ie4opendata.vozyvoto;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import opennlp.tools.tokenize.TokenizerME;
import opennlp.tools.tokenize.TokenizerModel;

public class Tokenizer {

	TokenizerModel model;
	
	Tokenizer() {
		model = loadModel();
	}
	
	private TokenizerModel loadModel() {
		TokenizerModel model = null;
		InputStream modelIn = null;
		try {
			modelIn = new FileInputStream("models/en-token.bin");
			model = new TokenizerModel(modelIn);
		  
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
	
	public String[] tokenize(String sentence) {
		TokenizerME tokenizer = new TokenizerME(model);
		return tokenizer.tokenize(sentence);		
	}
}
