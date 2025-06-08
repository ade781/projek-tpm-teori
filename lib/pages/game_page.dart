// lib/pages/game_page.dart

import 'package:flutter/material.dart';
import 'dart:math';
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../models/game_state.dart';
import '../models/letter_status.dart';
import '../widgets/game_board.dart';
import '../widgets/keyboard.dart';
import '../services/notification_service.dart';
import '../services/stats_service.dart';
import 'stats_page.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final WordService _wordService = WordService();
  final StatsService _statsService = StatsService();
  GameState _gameState = GameState(status: GameStatus.loading);
  List<WordModel> _allWords = [];
  String _currentGuess = '';
  final int _wordLength = 5;
  final int _maxAttempts = 6;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    if (_gameState.status == GameStatus.playing) {
      print('Game sedang berjalan. Menjadwalkan notifikasi dalam 30 detik.');
      Future.delayed(const Duration(seconds: 5), () {
        NotificationService.showGameReminderNotification();
      });
    }
    super.dispose();
  }

  Future<void> _initializeGame() async {
    setState(() => _gameState = GameState(status: GameStatus.loading));
    try {
      var fetchedWords = await _wordService.fetchWords();
      _allWords =
          fetchedWords.where((w) => w.kata.length == _wordLength).toList();

      if (!mounted) return;
      if (_allWords.isEmpty) {
        setState(() => _gameState = GameState(status: GameStatus.error));
        return;
      }
      _startNewRound();
    } catch (e) {
      if (mounted) {
        setState(() => _gameState = GameState(status: GameStatus.error));
      }
    }
  }

  void _startNewRound() {
    if (_allWords.isEmpty) return;
    final Random random = Random();
    final WordModel randomWord = _allWords[random.nextInt(_allWords.length)];
    print(
      'Kata baru: ${randomWord.kata.toUpperCase()}, Arti: ${randomWord.arti}',
    );

    setState(() {
      _currentGuess = '';
      _gameState = GameState(
        currentWord: randomWord,
        status: GameStatus.playing,
      );
    });
  }

  void _onLetterPressed(String letter) {
    if (_gameState.status != GameStatus.playing) return;
    if (_currentGuess.length < _wordLength) {
      setState(() => _currentGuess += letter);
    }
  }

  void _onBackspacePressed() {
    if (_gameState.status != GameStatus.playing) return;
    if (_currentGuess.isNotEmpty) {
      setState(
        () =>
            _currentGuess = _currentGuess.substring(
              0,
              _currentGuess.length - 1,
            ),
      );
    }
  }

  void _onEnterPressed() {
    if (_gameState.status != GameStatus.playing ||
        _gameState.currentWord == null) {
      return;
    }
    if (_currentGuess.length != _wordLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata harus terdiri dari 5 huruf!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final newGuesses = List<String>.from(_gameState.guesses)
      ..add(_currentGuess.toUpperCase());
    final newKeyboardStatus = _updateKeyboardStatus(
      _currentGuess.toUpperCase(),
    );

    GameStatus newStatus = _gameState.status;
    bool isWin = false;

    if (_currentGuess.toUpperCase() ==
        _gameState.currentWord!.kata.toUpperCase()) {
      newStatus = GameStatus.won;
      isWin = true;
    } else if (newGuesses.length >= _maxAttempts) {
      newStatus = GameStatus.lost;
      isWin = false;
    }

    if (newStatus == GameStatus.won || newStatus == GameStatus.lost) {
      _statsService.saveGame(
        _gameState.currentWord!.kata.toUpperCase(),
        newGuesses,
        isWin,
      );
    }

    setState(() {
      _gameState = _gameState.copyWith(
        guesses: newGuesses,
        status: newStatus,
        keyboardStatus: newKeyboardStatus,
      );
      _currentGuess = '';
    });
  }

  Map<String, LetterStatus> _updateKeyboardStatus(String guess) {
    final newStatus = Map<String, LetterStatus>.from(_gameState.keyboardStatus);
    final correctWord = _gameState.currentWord!.kata.toUpperCase();

    for (int i = 0; i < guess.length; i++) {
      final letter = guess[i];
      final currentStatus = newStatus[letter];

      if (correctWord[i] == letter) {
        newStatus[letter] = LetterStatus.inWordCorrectLocation;
      } else if (correctWord.contains(letter)) {
        if (currentStatus != LetterStatus.inWordCorrectLocation) {
          newStatus[letter] = LetterStatus.inWordWrongLocation;
        }
      } else {
        newStatus[letter] = LetterStatus.notInWord;
      }
    }
    return newStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121213),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple, // Changed to purple
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Tebak Kata', // Added "Tebak Kata" title
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.2,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StatsPage()),
                );
              },
              tooltip: 'Lihat Statistik',
            ),
          ],
        ),
        body: _buildGameContent(),
      ),
    );
  }

  Widget _buildGameContent() {
    switch (_gameState.status) {
      case GameStatus.loading:
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.deepPurple, // Changed to purple
          ),
        );
      case GameStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Gagal memuat kata.',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Changed to purple
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: _initializeGame,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      case GameStatus.playing:
      case GameStatus.won:
      case GameStatus.lost:
        if (_gameState.currentWord == null) {
          return const Center(
            child: Text(
              'Terjadi kesalahan: Kata tidak tersedia.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const SizedBox(height: 10),
                GameBoard(
                  guesses: _gameState.guesses,
                  currentGuess: _currentGuess,
                  currentAttempt: _gameState.attempts,
                  correctWord: _gameState.currentWord!.kata,
                ),
                if (_gameState.status == GameStatus.won ||
                    _gameState.status == GameStatus.lost)
                  _buildGameEndDialog(),
                if (_gameState.status == GameStatus.playing) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Text(
                      'MADE BY ADE7',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Keyboard(
                    keyStatus: _gameState.keyboardStatus,
                    onLetterPressed: _onLetterPressed,
                    onEnterPressed: _onEnterPressed,
                    onBackspacePressed: _onBackspacePressed,
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildGameEndDialog() {
    final bool isWinner = _gameState.status == GameStatus.won;
    final String title = isWinner ? 'Selamat, Anda Menang! 🎉' : 'Anda Kalah!';
    final Color titleColor = isWinner ? Colors.green : Colors.red;
    final String correctWord = _gameState.currentWord!.kata.toUpperCase();
    final String meaning = _gameState.currentWord!.arti;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 18, color: Colors.white),
              children: [
                const TextSpan(text: 'Kata yang benar: '),
                TextSpan(
                  text: correctWord,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent, // Changed to purple
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arti: $meaning',
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple, // Changed to purple
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            onPressed: _startNewRound,
            child: const Text('Main Lagi', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
