// lib/models/game_state.dart
// State permainan dirombak untuk mendukung mekanik seperti Wordle/Katla.

import '../models/word_model.dart';
import 'letter_status.dart'; // Impor enum yang baru dibuat

class GameState {
  // Kata yang harus ditebak.
  final WordModel? currentWord;
  // Daftar kata yang sudah disubmit oleh pemain.
  final List<String> guesses;
  // Status permainan (misalnya, playing, won, lost).
  final GameStatus status;
  // Menyimpan status warna untuk setiap tombol keyboard.
  final Map<String, LetterStatus> keyboardStatus;

  // Konstruktor GameState.
  GameState({
    this.currentWord,
    this.guesses = const [],
    this.status = GameStatus.playing,
    this.keyboardStatus = const {},
  });

  // Jumlah percobaan yang sudah dilakukan adalah panjang dari list `guesses`.
  int get attempts => guesses.length;

  // Sisa percobaan (dari total 6).
  int get remainingAttempts => 6 - attempts;

  // Method untuk membuat salinan GameState dengan beberapa perubahan.
  GameState copyWith({
    WordModel? currentWord,
    List<String>? guesses,
    GameStatus? status,
    Map<String, LetterStatus>? keyboardStatus,
  }) {
    return GameState(
      currentWord: currentWord ?? this.currentWord,
      guesses: guesses ?? this.guesses,
      status: status ?? this.status,
      keyboardStatus: keyboardStatus ?? this.keyboardStatus,
    );
  }
}

// Enum untuk status permainan (tidak ada perubahan di sini).
enum GameStatus {
  playing, // Permainan sedang berlangsung
  won, // Pemain memenangkan permainan
  lost, // Pemain kalah
  loading, // Sedang memuat data
  error, // Terjadi kesalahan
}
