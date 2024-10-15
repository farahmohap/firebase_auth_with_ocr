import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
class ImageLabelingExample extends StatefulWidget {
  @override
  _ImageLabelingExampleState createState() => _ImageLabelingExampleState();
}

class _ImageLabelingExampleState extends State<ImageLabelingExample> {
  String _labels = '';

  Future<void> _pickImageAndLabel() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final imageLabeler = ImageLabeler(options: ImageLabelerOptions());

      // Process the image to get labels
      final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
      StringBuffer labelsBuffer = StringBuffer();

      for (ImageLabel label in labels) {
        labelsBuffer.writeln('${label.label}: ${label.confidence.toStringAsFixed(2)}');
      }

      setState(() {
        _labels = labelsBuffer.toString(); // Store the labels
      });

      imageLabeler.close(); // Always close the labeler when done
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Labeling Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImageAndLabel,
              child: Text('Capture Image'),
            ),
            SizedBox(height: 20),
            Text(
              'Detected Labels:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(_labels.isNotEmpty ? _labels : 'No labels detected'),
          ],
        ),
      ),
    );
  }
}
