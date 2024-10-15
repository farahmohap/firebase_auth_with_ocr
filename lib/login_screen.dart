import 'package:firebase_auth_app/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _login(context),
                  child: const Text('Login'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignupScreen(),
                      ),
                    );
                  },
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    final name = nameController.text;
    final mobile = mobileController.text;

    if (name.isEmpty || mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Check if the user exists in Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('formData')
          .where('fullName', isEqualTo: name)
          .where('mobileNumber', isEqualTo: mobile)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // User exists, retrieve user data
        final userData = snapshot.docs.first.data();
        final birthDate =
            userData['birthDate'] ?? ''; // Default to empty if not found
        final image = userData['image'] ?? ''; // Default to empty if not found
        final nationalIdImage =
            userData['nationalIdImage'] ?? ''; // Default to empty if not found

        // Navigate to HomeScreen with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              fullName: name,
              mobileNumber: mobile,
              birthDate: birthDate,
              // image: image,
              // nationalIdImage: nationalIdImage,
            ),
          ),
        );
      } else {
        // User not found, show error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found, please sign up!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

/*
  // void _checkUserAndNavigate(BuildContext context) async {
  //   final name = nameController.text;
  //   final mobile = mobileController.text;

  //   if (name.isEmpty || mobile.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //           content: Text('Please fill in name and mobile before signing up')),
  //     );
  //     return;
  //   }

  //   try {
  //     // Check if the user already exists
  //     final snapshot = await FirebaseFirestore.instance
  //         .collection('formData')
  //         .where('fullName', isEqualTo: name)
  //         .where('mobileNumber', isEqualTo: mobile)
  //         .get();

  //     if (snapshot.docs.isEmpty) {
  //       // User does not exist, navigate to signup screen
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => SignupScreen(),
  //         ),
  //       );
  //     } else {
  //       // User exists, navigate to home screen instead
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('User already exists! Logging in...')),
  //       );
  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => HomeScreen(name: name, mobile: mobile)),
  //       );
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: $e')),
  //     );
  //   }
  // }


}*/
