import 'package:flutter/material.dart';
import '../models/letter_status.dart';

class GameTile extends StatelessWidget {
  final String letter;
  final LetterStatus status;

  const GameTile({
    super.key,
    required this.letter,
    this.status = LetterStatus.initial,
  });

  // Fungsi untuk mendapatkan warna berdasarkan status
  Color _getBackgroundColor(BuildContext context) {
    switch (status) {
      case LetterStatus.inWordCorrectLocation:
        return Colors.green.shade600; // Hijau
      case LetterStatus.inWordWrongLocation:
        return Colors.amber.shade600; // Kuning
      case LetterStatus.notInWord:
        return Colors.grey.shade700; // Abu-abu gelap
      case LetterStatus.initial:
      default:
        return Theme.of(context).scaffoldBackgroundColor; // Warna default
    }
  }

  // Fungsi untuk mendapatkan warna border
  Border _getBorder(BuildContext context) {
    if (status == LetterStatus.initial && letter.isEmpty) {
      return Border.all(color: Colors.grey.shade600, width: 2);
    }
    return Border.all(color: Colors.transparent, width: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55, // Sedikit lebih besar
      height: 55,
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        border: _getBorder(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
