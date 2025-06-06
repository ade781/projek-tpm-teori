// lib/pages/home.dart

import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/pages/game_page.dart';
import 'package:projek_akhir_teori/pages/login_page.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    void logout() async {
      await authService.logout();
      // Navigasi ke LoginPage dan hapus semua rute sebelumnya.
      // Ini mencegah pengguna menekan tombol kembali untuk masuk ke HomePage setelah logout.
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false, // Predikat ini menghapus semua rute.
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Tombol Logout di AppBar
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Selamat Datang!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Tombol Menu "Tebak Kata"
            ElevatedButton.icon(
              icon: const Icon(Icons.gamepad_outlined),
              label: const Text('Tebak Kata'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Navigasi ke halaman permainan
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GamePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
