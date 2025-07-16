import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

abstract class OCRService {
  Future<List<String>> extractLines(File image);
}

class MLOCRService implements OCRService {
  @override
  Future<List<String>> extractLines(File image) async {
    final inputImage = InputImage.fromFile(image);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final recognizedText = await textRecognizer.processImage(inputImage);
    List<String> allLines = [];
    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines.map((e) => e.text));
    }
    return allLines;
  }
}
