import 'package:flutter/material.dart';
import 'dart:math';
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../models/game_state.dart';
import '../models/letter_status.dart';
import '../widgets/game_board.dart';
import '../widgets/keyboard.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final WordService _wordService = WordService();
  GameState _gameState = GameState(status: GameStatus.loading);
  List<WordModel> _allWords = [];
  String _currentGuess = ''; // Menyimpan kata yang sedang diketik
  final int _wordLength = 5; // Panjang kata yang valid
  final int _maxAttempts = 6; // Maksimal percobaan

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    setState(() => _gameState = GameState(status: GameStatus.loading));
    try {
      // Ambil kata-kata, filter yang panjangnya 5 huruf
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
      if (mounted)
        setState(() => _gameState = GameState(status: GameStatus.error));
    }
  }

  void _startNewRound() {
    if (_allWords.isEmpty) return;
    final Random random = Random();
    final WordModel randomWord = _allWords[random.nextInt(_allWords.length)];
    print('Kata baru: ${randomWord.kata.toUpperCase()}');

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
        _gameState.currentWord == null)
      return;
    if (_currentGuess.length != _wordLength) {
      // Opsional: Tampilkan pesan bahwa kata harus 5 huruf
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

    // Cek status menang atau kalah
    GameStatus newStatus = _gameState.status;
    if (_currentGuess.toUpperCase() ==
        _gameState.currentWord!.kata.toUpperCase()) {
      newStatus = GameStatus.won;
    } else if (newGuesses.length >= _maxAttempts) {
      newStatus = GameStatus.lost;
    }

    setState(() {
      _gameState = _gameState.copyWith(
        guesses: newGuesses,
        status: newStatus,
        keyboardStatus: newKeyboardStatus,
      );
      _currentGuess = ''; // Reset kata yang sedang diketik
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
        // Jangan downgrade dari 'hijau' ke 'kuning'
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
    // Ganti tema dasar agar lebih gelap dan cocok
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121213),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tebak Kata (Katla)'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _startNewRound,
              tooltip: 'Mulai Ulang',
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
        return const Center(child: CircularProgressIndicator());
      case GameStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Gagal memuat kata.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(
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
            child: Text('Terjadi kesalahan: Kata tidak tersedia.'),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const SizedBox(height: 10),
              GameBoard(
                guesses: _gameState.guesses,
                currentGuess: _currentGuess,
                currentAttempt: _gameState.attempts,
                correctWord: _gameState.currentWord!.kata,
              ),
              if (_gameState.status == GameStatus.won)
                _buildGameEndMessage('Selamat, Anda Menang! 🎉'),
              if (_gameState.status == GameStatus.lost)
                _buildGameEndMessage(
                  'Anda Kalah! Kata yang benar: ${_gameState.currentWord!.kata.toUpperCase()}',
                ),
              const Spacer(),
              Keyboard(
                keyStatus: _gameState.keyboardStatus,
                onLetterPressed: _onLetterPressed,
                onEnterPressed: _onEnterPressed,
                onBackspacePressed: _onBackspacePressed,
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
    }
  }

  Widget _buildGameEndMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color:
                  _gameState.status == GameStatus.won
                      ? Colors.green
                      : Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _startNewRound,
            child: const Text('Main Lagi'),
          ),
        ],
      ),
    );
  }
}
