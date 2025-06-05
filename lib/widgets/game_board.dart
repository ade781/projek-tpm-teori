// lib/widgets/game_board.dart
// Komentar: Widget untuk menampilkan papan permainan (kotak-kotak huruf).
// Menerima kata yang harus ditebak dan huruf yang sudah ditebak.

import 'package:flutter/material.dart';
import 'title.dart'; // Impor widget Tile

class GameBoard extends StatelessWidget {
  final String word; // Kata yang harus ditebak
  final Set<String> guessedLetters; // Huruf yang sudah ditebak

  // Konstruktor untuk GameBoard.
  const GameBoard({
    super.key,
    required this.word,
    required this.guessedLetters,
  });

  @override
  Widget build(BuildContext context) {
    // Membagi kata menjadi daftar karakter.
    List<String> characters = word.toUpperCase().split('');

    // Membuat tampilan baris untuk setiap karakter dalam kata.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 8.0),
      child: Wrap(
        // Menggunakan Wrap agar tile bisa pindah baris jika tidak cukup
        spacing: 8.0, // Jarak horizontal antar tile
        runSpacing: 8.0, // Jarak vertikal antar baris tile
        alignment: WrapAlignment.center,
        children:
            characters.map((char) {
              // Membuat widget Tile untuk setiap karakter.
              // Tile akan menampilkan karakter jika sudah ditebak.
              return Tile(
                letter: char,
                isRevealed: guessedLetters.contains(char),
              );
            }).toList(),
      ),
    );
  }
}
