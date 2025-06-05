// lib/models/game_state.dart
// Komentar: Mendefinisikan state atau kondisi dari permainan.
// Untuk saat ini, kita buat placeholder kosong. Akan kita lengkapi nanti.

import '../models/word_model.dart'; // Impor WordModel karena GameState mungkin membutuhkannya

class GameState {
  // Properti untuk menyimpan kata yang sedang ditebak.
  final WordModel? currentWord;
  // Properti untuk menyimpan huruf-huruf yang sudah ditebak oleh pemain.
  final Set<String> guessedLetters;
  // Properti untuk menyimpan jumlah sisa percobaan.
  final int remainingAttempts;
  // Properti untuk menyimpan status permainan (misalnya, playing, won, lost).
  final GameStatus status;

  // Konstruktor GameState.
  GameState({
    this.currentWord,
    this.guessedLetters = const {},
    this.remainingAttempts = 6, // Contoh: 6 kali percobaan
    this.status = GameStatus.playing,
  });

  // Method untuk membuat salinan GameState dengan beberapa perubahan.
  // Ini berguna untuk manajemen state yang immutable.
  GameState copyWith({
    WordModel? currentWord,
    Set<String>? guessedLetters,
    int? remainingAttempts,
    GameStatus? status,
  }) {
    return GameState(
      currentWord: currentWord ?? this.currentWord,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      status: status ?? this.status,
    );
  }
}

// Enum untuk status permainan.
enum GameStatus {
  playing, // Permainan sedang berlangsung
  won, // Pemain memenangkan permainan
  lost, // Pemain kalah
  loading, // Sedang memuat data
  error, // Terjadi kesalahan
}
