import 'package:flutter/material.dart';

import 'package:projek_akhir_teori/pages/splash_screen.dart';

class MyApp extends StatelessWidget {
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

      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
