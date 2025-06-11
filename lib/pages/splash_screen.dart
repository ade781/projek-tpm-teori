import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    _checkConnectivityAndNavigate();
  }

  Future<void> _checkConnectivityAndNavigate() async {
    final connectivityResult = await (Connectivity().checkConnectivity());

    if (!mounted) return;

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showConnectionDialog();
    } else {
      final bool isLoggedIn = await _authService.isLoggedIn();
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder:
              (context) => isLoggedIn ? const MainScreen() : const LoginPage(),
        ),
      );
    }
  }

  void _showConnectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Koneksi Diperlukan'),
          content: const Text(
            'Aplikasi ini membutuhkan koneksi internet. Mohon aktifkan data atau WiFi Anda dan coba lagi.',
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Coba Lagi'),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              Lottie.asset(
                'assets/splash_loading.json',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'Projek Akhir',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Teknologi Pemrograman Mobile',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 