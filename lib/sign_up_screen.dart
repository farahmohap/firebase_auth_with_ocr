import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _image; // For the profile picture
  XFile? _nationalIdImage; // For the national ID scan
  String extractedText = ''; // To store extracted text
  final TextRecognizer textRecognizer = TextRecognizer();

  @override
  void dispose() {
    textRecognizer.close(); // Close the recognizer when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: birthDateController,
                decoration:
                    const InputDecoration(labelText: 'Birthdate (dd/mm/yyyy)'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 20),
          
              // Profile picture selection button
              ElevatedButton(
                onPressed: () => _pickImage(),
                child: const Text('Take Profile Picture'),
              ),
          
              // Display selected profile picture with delete option
              if (_image != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(
                      File(_image!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _image = null; // Clear the selected image
                        });
                      },
                    ),
                  ],
                ),
          
              SizedBox(height: 10),
          
              // National ID scan button
              ElevatedButton(
                onPressed: () => _scanNationalID(),
                child: Text('Scan National ID'),
              ),
          
              // Display selected National ID image with delete option
              if (_nationalIdImage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(
                      File(_nationalIdImage!.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _nationalIdImage =
                              null; // Clear the selected national ID image
                          extractedText = ''; // Clear extracted text
                        });
                      },
                    ),
                  ],
                ),
          
              // Display extracted text
              if (extractedText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('National ID: $extractedText'),
                ),
          
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _signup(context),
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    // Use the image picker to capture an image
    _image = await _picker.pickImage(source: ImageSource.camera);
    if (_image != null) {
      setState(() {}); // Update the UI to display the selected image
    }
  }

  Future<void> _scanNationalID() async {
    // Use the image picker to capture an image for National ID
    _nationalIdImage = await _picker.pickImage(source: ImageSource.camera);
    if (_nationalIdImage != null) {
      setState(
          () {}); // Update the UI to display the selected national ID image

      // Perform text recognition on the captured image
      await _recognizeText();
    }
  }

  Future<void> _recognizeText() async {
    final inputImage = InputImage.fromFilePath(_nationalIdImage!.path);
    final recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      extractedText = recognizedText.text; // Store the full extracted text
    });

    // Regex to match exactly 14 consecutive digits
    String? idNumber = _extractSpecificText(recognizedText.text, r'\b\d{14}\b');
    if (idNumber != null) {
      extractedText =
          idNumber; // Update extractedText with the specific ID number found
    }
  }

  String? _extractSpecificText(String text, String pattern) {
    final regex = RegExp(pattern);
    final match = regex.firstMatch(text);
    return match?.group(0); // Return the matched text if found
  }

  void _signup(BuildContext context) async {
    final name = nameController.text;
    final mobile = mobileController.text;
    final birthDate = birthDateController.text;

    if (name.isEmpty ||
        mobile.isEmpty ||
        birthDate.isEmpty ||
        _image == null ||
        _nationalIdImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and take pictures')),
      );
      return;
    }

    try {
      // Check if the user already exists in Firestore based on mobile number
      final snapshot = await FirebaseFirestore.instance
          .collection('formData')
          .where('mobileNumber', isEqualTo: mobile)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // User already exists based on mobile number
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User already exists! Please login instead.')),
        );
        // Navigate back to LoginScreen
        Navigator.pop(context);
      } else {
        // User does not exist, proceed to create a new account
        await FirebaseFirestore.instance.collection('formData').add({
          'fullName': name,
          'mobileNumber': mobile,
          'birthDate': birthDate,
          'image': _image!.path, // Store the path of the captured image
          'nationalIdImage': _nationalIdImage!
              .path, // Store the path of the scanned national ID
          'nationalId':
              extractedText, // Store the extracted text from the ID under 'nationalId'
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );

        // Optionally navigate to LoginScreen or HomeScreen
        Navigator.pop(context); // Navigate back to LoginScreen after signup
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
