// lib/widgets/keyboard.dart
// Komentar: Widget untuk menampilkan keyboard virtual.
// Menerima daftar huruf, huruf yang sudah ditebak, dan callback saat tombol ditekan.

import 'package:flutter/material.dart';

class Keyboard extends StatelessWidget {
  final List<String> alphabet; // Daftar huruf untuk keyboard (A-Z)
  final Set<String> guessedLetters; // Huruf yang sudah ditebak
  final Function(String) onLetterPressed; // Callback saat tombol huruf ditekan
  final bool isEnabled; // Untuk mengaktifkan atau menonaktifkan keyboard

  // Konstruktor untuk Keyboard.
  const Keyboard({
    super.key,
    required this.alphabet,
    required this.guessedLetters,
    required this.onLetterPressed,
    this.isEnabled = true, // Defaultnya keyboard aktif
  });

  @override
  Widget build(BuildContext context) {
    // Menggunakan Wrap agar tombol keyboard bisa menyesuaikan diri.
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 6.0, // Jarak horizontal antar tombol
        runSpacing: 6.0, // Jarak vertikal antar baris tombol
        alignment: WrapAlignment.center,
        children:
            alphabet.map((letter) {
              // Mengecek apakah huruf ini sudah pernah ditebak.
              final bool alreadyGuessed = guessedLetters.contains(letter);
              // Menentukan apakah tombol bisa ditekan (belum ditebak dan keyboard aktif).
              final bool canPress = !alreadyGuessed && isEnabled;

              return ElevatedButton(
                // Callback saat tombol ditekan, hanya jika bisa ditekan.
                onPressed: canPress ? () => onLetterPressed(letter) : null,
                style: ElevatedButton.styleFrom(
                  // Warna tombol: abu-abu jika sudah ditebak atau keyboard nonaktif,
                  // warna primer jika bisa ditekan.
                  backgroundColor:
                      alreadyGuessed || !isEnabled
                          ? Colors.grey.shade400
                          : Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Mengurangi elevasi jika tombol nonaktif.
                  elevation: canPress ? 2 : 0,
                ),
                child: Text(letter),
              );
            }).toList(),
      ),
    );
  }
}
