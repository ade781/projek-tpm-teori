// lib/widgets/tile.dart
// Komentar: Widget untuk menampilkan satu kotak huruf di papan permainan.
// Menampilkan huruf jika sudah terungkap, atau kotak kosong jika belum.

import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final String letter; // Huruf untuk tile ini
  final bool isRevealed; // Apakah huruf ini sudah terungkap

  // Konstruktor untuk Tile.
  const Tile({super.key, required this.letter, required this.isRevealed});

  @override
  Widget build(BuildContext context) {
    // Container untuk setiap tile.
    return Container(
      // Ukuran tile.
      width: 40,
      height: 40,
      // Dekorasi untuk tile (border, warna).
      decoration: BoxDecoration(
        // Warna latar belakang: putih jika terungkap, abu-abu muda jika belum.
        color: isRevealed ? Colors.white : Colors.grey[300],
        // Border di sekeliling tile.
        border: Border.all(color: Colors.grey.shade500, width: 1.5),
        // Membuat sudut tile sedikit membulat.
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          // Memberikan sedikit efek bayangan.
          if (isRevealed)
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      // Menampilkan huruf di tengah tile jika sudah terungkap.
      child: Center(
        child: Text(
          // Tampilkan huruf jika terungkap, kosongkan jika tidak.
          isRevealed ? letter : '',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            // Warna teks: hitam jika terungkap.
            color: isRevealed ? Colors.black87 : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
