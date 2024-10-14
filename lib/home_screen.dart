import 'dart:io';

import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String fullName;
  final String mobileNumber;
  final String birthDate;
  final String image;
  final String nationalIdImage;

  const HomeScreen({
    Key? key,
    required this.fullName,
    required this.mobileNumber,
    required this.birthDate,
    required this.image,
    required this.nationalIdImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Full Name: $fullName'),
            Text('Mobile Number: $mobileNumber'),
            Text('Birth Date: $birthDate'),
            SizedBox(height: 20),
            Text('Profile Picture:'),
            Image.file(File(image), width: 100, height: 100),
            SizedBox(height: 20),
            Text('National ID Image:'),
            Image.file(File(nationalIdImage), width: 100, height: 100),
          ],
        ),
      ),
    );
  }
}
