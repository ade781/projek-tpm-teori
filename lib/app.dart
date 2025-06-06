// lib/app.dart
import 'package:flutter/material.dart';
import 'pages/game_page.dart';
import 'pages/login_page.dart'; // Impor halaman login Anda

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

      home: isLoggedIn ? const GamePage() : const LoginPage(),

      debugShowCheckedModeBanner: false,
    );
  }
}
