import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home.dart';

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tebak Kata TPM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),

      home: isLoggedIn ? const LoginPage() : const HomePage(),

      debugShowCheckedModeBanner: false,
    );
  }
}
