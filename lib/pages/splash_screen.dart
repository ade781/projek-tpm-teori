// lib/pages/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:projek_akhir_teori/pages/login_page.dart';
import 'package:projek_akhir_teori/pages/main_screen.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _startTimerAndNavigate();
  }

  void _startTimerAndNavigate() {
    Timer(const Duration(seconds: 4), () async {
      final bool isLoggedIn = await _authService.isLoggedIn();

      // Gunakan 'mounted' untuk memastikan widget masih ada di tree
      if (!mounted) return;

      // Navigasi ke halaman yang sesuai
      // pushReplacementNamed agar pengguna tidak bisa kembali ke splash screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => isLoggedIn ? const MainScreen() : const LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Memberi latar belakang gradien yang serasi dengan tema aplikasi
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Widget Lottie untuk menampilkan animasi dari file JSON
              Lottie.asset(
                'assets/splash_loading.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'Projek Akhir Teori',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
