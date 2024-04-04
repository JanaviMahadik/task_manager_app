import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'LogoScreen.dart';
import 'TodoScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final FirebaseFirestore db = FirebaseFirestore.instance;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager App',
        initialRoute: '/logo',
        routes: {
          '/': (context) => TodoScreen(),
          '/login': (context) => LoginPage(),
          '/logo': (context) => LogoScreen(),
        }
    );
  }
}