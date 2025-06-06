// Contoh UI sederhana untuk login
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'game_page.dart'; // Halaman game Anda
import 'register_page.dart'; // Halaman registrasi

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _login() async {
    final success = await _authService.loginUser(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const GamePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Gagal!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... Bangun UI Anda di sini (TextFields, Button, etc.)
    // Panggil _login() saat tombol login ditekan.
    // Beri tombol untuk navigasi ke RegisterPage.
    // Ini hanya contoh implementasi logika, bukan UI lengkap.
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterPage())),
              child: const Text('Belum punya akun? Registrasi'),
            ),
          ],
        ),
      ),
    );
  }
}