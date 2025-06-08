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

  int get attempts => guesses.length;

  int get remainingAttempts => 6 - attempts;

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

enum GameStatus { playing, won, lost, loading, error }
