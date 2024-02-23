import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'LogoScreen.dart';
import 'TodoScreen.dart';

void main() {
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