// lib/pages/home.dart

import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/pages/game_page.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';
import 'package:projek_akhir_teori/pages/map_page.dart';
import 'package:projek_akhir_teori/pages/currency_converter_page.dart';
import 'package:projek_akhir_teori/pages/world_clock_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  String? _username;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk memuat data pengguna saat halaman pertama kali dibuka
    _loadUserData();
  }

  // --- FITUR BARU: Memuat Nama Pengguna ---
  // Fungsi async untuk mengambil nama pengguna dari AuthService.
  Future<void> _loadUserData() async {
    final user = await _authService.getLoggedInUserObject();
    // Periksa 'mounted' untuk memastikan widget masih ada di tree sebelum setState.
    if (mounted && user != null) {
      setState(() {
        _username = user.username;
      });
    }
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
        // --- PERUBAHAN 4: Layout Utama ---
        // Menggunakan SafeArea dan ListView untuk tata letak yang aman dan bisa di-scroll.
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            children: <Widget>[
              Text(
                'Selamat Datang,',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _username ??
                    'Pengguna', // Tampilkan nama pengguna, atau 'Pengguna' jika belum dimuat
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 40),

              _MenuCard(
                icon: Icons.gamepad_outlined,
                title: 'Lurufa (Tebak Kata)',
                subtitle: 'Uji kosakatamu di sini',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const GamePage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _MenuCard(
                icon: Icons.map_outlined,
                title: 'Peta Ibadah',
                subtitle: 'Cari lokasi tempat ibadah terdekat',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MapPage()),
                  );
                },
              ),
              _MenuCard(
                icon: Icons.currency_exchange,
                title: 'Konversi Mata Uang',
                subtitle: 'Cek nilai tukar Rupiah, Rial, Dollar, Euro',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CurrencyConverterPage(),
                    ),
                  );
                },
              ),
              _MenuCard(
                icon: Icons.access_time_filled,
                title: 'Jam Dunia',
                subtitle: 'Lihat waktu di berbagai belahan dunia',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const WorldClockPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
