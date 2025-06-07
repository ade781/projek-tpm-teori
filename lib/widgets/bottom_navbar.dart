import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Memberi sedikit bayangan agar navbar terlihat "mengambang"
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            // Efek ripple saat di-tap
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,

            // Jarak antara ikon dan teks
            gap: 8,

            // Warna ikon dan teks saat aktif
            activeColor: Colors.white,

            // Ukuran ikon
            iconSize: 24,

            // Padding internal untuk setiap tombol
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),

            // Durasi animasi transisi
            duration: const Duration(milliseconds: 400),

            // Warna background dari tombol yang aktif
            tabBackgroundColor: Theme.of(context).colorScheme.primary,

            // Warna ikon dan teks saat tidak aktif
            color: Colors.grey[600],

            // Daftar tombol/tab
            tabs: const [
              GButton(icon: Icons.home, text: 'Home'),
              GButton(icon: Icons.smart_toy_outlined, text: 'Chatbot'),
              GButton(icon: Icons.person, text: 'Profile'),
            ],

            // State management
            selectedIndex: currentIndex,
            onTabChange: onTap,
          ),
        ),
      ),
    );
  }
}
