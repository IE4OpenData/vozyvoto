package org.ie4opendata.vozyvoto;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import opennlp.tools.sentdetect.SentenceDetectorME;
import opennlp.tools.sentdetect.SentenceModel;

public class SentenceDetector {
	
	SentenceModel model;

	SentenceDetector() {
		model = loadModel();
	}
	
	private SentenceModel loadModel() {
		InputStream modelIn = null;
		SentenceModel model = null;

		try {
		  modelIn = new FileInputStream("./models/en-sent.bin");
		  model = new SentenceModel(modelIn);
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
	
	public String[] detectSentences(String document) throws IOException {
		SentenceDetectorME sentenceDetector = new SentenceDetectorME(model);
		return sentenceDetector.sentDetect(document);
	}

}
