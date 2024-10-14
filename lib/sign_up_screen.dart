import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: mobileController,
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: birthDateController,
              decoration: InputDecoration(labelText: 'Birthdate (dd/mm/yyyy)'),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 20),

            // Picture selection button
            ElevatedButton(
              onPressed: () => _pickImage(),
              child: Text('Take Picture'),
            ),

            // Display selected picture with delete option
            if (_image != null)
              Row(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        _nationalIdImage = null; // Clear the selected national ID image
                      });
                    },
                  ),
                ],
              ),

            // Display extracted text
            if (extractedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Extracted Text: $extractedText'),
              ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _signup(context),
              child: Text('Sign Up'),
            ),
          ],
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
      setState(() {}); // Update the UI to display the selected national ID image

      // Perform OCR on the captured image
      //final text = await OCRScanText.scanTextFromFile(_nationalIdImage!.path);
      // setState(() {
      //   extractedText = text ?? 'No text found'; // Store extracted text
      // });

      // You can save the extracted text as needed (e.g., save to Firestore)
    }
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
          'nationalIdImage': _nationalIdImage!.path, // Store the path of the scanned national ID
          'extractedText': extractedText, // Store the extracted text from the ID
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
