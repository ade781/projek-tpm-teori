

import 'package:flutter/material.dart';
import 'dart:math'; // Untuk memilih kata secara acak
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../models/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/keyboard.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  // Instance dari WordService untuk mengambil data.
  final WordService _wordService = WordService();
  // State permainan saat ini.
  GameState _gameState = GameState(status: GameStatus.loading);
  // Daftar semua kata yang diambil dari API.
  List<WordModel> _allWords = [];

  // Alfabet untuk keyboard.
  final List<String> _alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('');

  @override
  void initState() {
    super.initState();
    // Memuat kata-kata saat halaman pertama kali dibuka.
    _initializeGame();
  }

  // Fungsi untuk menginisialisasi atau mereset permainan.
  Future<void> _initializeGame() async {
    // Set status menjadi loading.
    if (mounted) {
      // Pastikan widget masih ada di tree
      setState(() {
        _gameState = GameState(status: GameStatus.loading);
      });
    }

    try {
      // Mengambil semua kata dari service.
      _allWords = await _wordService.fetchWords();
      if (!mounted) return; // Cek lagi setelah await

      if (_allWords.isEmpty) {
        // Jika tidak ada kata yang didapat, set status error.
        setState(() {
          _gameState = GameState(status: GameStatus.error);
        });
        return;
      }
      // Memulai permainan baru dengan kata acak.
      _startNewRound();
    } catch (e) {
      // Jika terjadi error saat fetch, set status error.
      print('Error initializing game: $e');
      if (mounted) {
        // Pastikan widget masih ada di tree
        setState(() {
          _gameState = GameState(status: GameStatus.error);
        });
      }
    }
  }

  // Fungsi untuk memulai ronde baru.
  void _startNewRound() {
    if (_allWords.isEmpty) return; // Pastikan ada kata

    // Pilih kata acak dari daftar kata.
    final Random random = Random();
    final WordModel randomWord = _allWords[random.nextInt(_allWords.length)];

    print('Kata baru untuk ditebak: ${randomWord.kata}'); // Untuk debugging

    // Set state permainan baru.
    if (mounted) {
      // Pastikan widget masih ada di tree
      setState(() {
        _gameState = GameState(
          currentWord: randomWord,
          guessedLetters: {}, // Kosongkan huruf yang sudah ditebak
          remainingAttempts: 6, // Reset sisa percobaan
          status: GameStatus.playing,
        );
      });
    }
  }

  // Fungsi yang dipanggil ketika sebuah huruf ditekan pada keyboard.
  void _onLetterPressed(String letter) {
    if (_gameState.status != GameStatus.playing ||
        _gameState.currentWord == null) {
      return; // Jangan lakukan apa-apa jika game tidak sedang berjalan atau tidak ada kata
    }

    final String currentWordString = _gameState.currentWord!.kata.toUpperCase();
    final newGuessedLetters = Set<String>.from(_gameState.guessedLetters)
      ..add(letter);

    int newRemainingAttempts = _gameState.remainingAttempts;
    // Kurangi percobaan jika huruf yang ditebak tidak ada di kata dan belum pernah ditebak salah.
    // Pengecekan ini untuk memastikan sisa nyawa tidak berkurang untuk huruf yang sama yang salah ditebak berulang kali.
    if (!currentWordString.contains(letter) &&
        !_gameState.guessedLetters.contains(letter)) {
      newRemainingAttempts--;
    }

    // Cek apakah pemain menang.
    bool hasWon = true;
    for (var char in currentWordString.split('')) {
      if (!newGuessedLetters.contains(char)) {
        hasWon = false;
        break;
      }
    }

    GameStatus newStatus = _gameState.status;
    if (hasWon) {
      newStatus = GameStatus.won;
    } else if (newRemainingAttempts <= 0) {
      newStatus = GameStatus.lost;
    }

    // Update state permainan.
    if (mounted) {
      // Pastikan widget masih ada di tree
      setState(() {
        _gameState = _gameState.copyWith(
          guessedLetters: newGuessedLetters,
          remainingAttempts: newRemainingAttempts,
          status: newStatus,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar aplikasi.
      appBar: AppBar(
        title: const Text('Tebak Kata TPM'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Tombol untuk mereset permainan.
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeGame, // Memanggil fungsi reset
            tooltip: 'Mulai Ulang',
          ),
        ],
      ),
      // Body utama aplikasi.
      body: Center(
        child:
            _buildGameContent(), // Memanggil fungsi untuk membangun konten game
      ),
    );
  }

  // Fungsi untuk membangun konten utama permainan berdasarkan state.
  Widget _buildGameContent() {
    switch (_gameState.status) {
      case GameStatus.loading:
        // Tampilkan indikator loading jika data sedang dimuat.
        return const CircularProgressIndicator();
      case GameStatus.error:
        // Tampilkan pesan error jika terjadi kesalahan.
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat kata atau terjadi kesalahan jaringan. Silakan periksa koneksi Anda dan coba lagi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeGame,
              child: const Text('Coba Lagi'),
            ),
          ],
        );
      case GameStatus.playing:
      case GameStatus.won:
      case GameStatus.lost:
        // Tampilkan UI permainan jika sedang bermain, menang, atau kalah.
        if (_gameState.currentWord == null) {
          // Fallback jika currentWord null meskipun statusnya playing.
          // Ini seharusnya tidak terjadi jika logika _startNewRound benar.
          return const Text('Terjadi kesalahan: Kata saat ini tidak tersedia.');
        }
        return Padding(
          // Menambahkan Padding ke Column utama
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround, // Distribusi ruang
            children: <Widget>[
              // Informasi sisa percobaan.
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Sisa Percobaan: ${_gameState.remainingAttempts}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Widget untuk menampilkan papan permainan (kotak-kotak huruf).
              GameBoard(
                word: _gameState.currentWord!.kata.toUpperCase(),
                guessedLetters: _gameState.guessedLetters,
              ),
              // Tampilkan pesan jika menang atau kalah.
              if (_gameState.status == GameStatus.won)
                _buildGameEndMessage('Selamat, Anda Menang! 🎉'),
              if (_gameState.status == GameStatus.lost)
                _buildGameEndMessage(
                  'Anda Kalah! Kata yang benar: ${_gameState.currentWord!.kata.toUpperCase()}',
                ),
              // Widget untuk menampilkan keyboard.
              // Hanya aktifkan keyboard jika permainan sedang berlangsung.
              Keyboard(
                alphabet: _alphabet,
                guessedLetters: _gameState.guessedLetters,
                onLetterPressed:
                    _gameState.status == GameStatus.playing
                        ? _onLetterPressed
                        : (
                          String letter,
                        ) {}, 
                isEnabled: _gameState.status == GameStatus.playing,
              ),
            ],
          ),
        );

    }
  }

  // Widget untuk menampilkan pesan akhir permainan (menang/kalah).
  Widget _buildGameEndMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Agar Column mengambil ruang seperlunya
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color:
                  _gameState.status == GameStatus.won
                      ? Colors.green.shade700
                      : Colors.red.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _startNewRound, // Tombol untuk memulai ronde baru
            child: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }
}
