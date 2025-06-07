// lib/app.dart
import 'package:flutter/material.dart';
// Hapus import yang tidak perlu
import 'package:projek_akhir_teori/pages/splash_screen.dart'; // Import splash screen

class MyApp extends StatelessWidget {
  // Hapus parameter isLoggedIn karena sudah tidak digunakan
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tebak Kata TPM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      // Jadikan SplashScreen sebagai halaman utama
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
