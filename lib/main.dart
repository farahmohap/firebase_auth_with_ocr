import 'package:firebase_auth_app/cubit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'login_screen.dart';  // Adjust according to your file structure

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => FormCubit(),  // Create the FormCubit here
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Firebase Auth App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LoginScreen(),  // Set LoginScreen as the initial screen
      ),
    );
  }
}
