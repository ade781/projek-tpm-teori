// lib/widgets/keyboard.dart
// Keyboard virtual dengan tombol Enter, Backspace, dan pewarnaan status.

import 'package:flutter/material.dart';
import '../models/letter_status.dart';

class Keyboard extends StatelessWidget {
  final Map<String, LetterStatus> keyStatus;
  final Function(String) onLetterPressed;
  final VoidCallback onEnterPressed;
  final VoidCallback onBackspacePressed;

  // Layout keyboard QWERTY
  static const List<String> row1 = [
    'Q',
    'W',
    'E',
    'R',
    'T',
    'Y',
    'U',
    'I',
    'O',
    'P',
  ];
  static const List<String> row2 = [
    'A',
    'S',
    'D',
    'F',
    'G',
    'H',
    'J',
    'K',
    'L',
  ];
  static const List<String> row3 = [
    'ENTER',
    'Z',
    'X',
    'C',
    'V',
    'B',
    'N',
    'M',
    '⌫',
  ];

  const Keyboard({
    super.key,
    required this.keyStatus,
    required this.onLetterPressed,
    required this.onEnterPressed,
    required this.onBackspacePressed,
  });

  // Fungsi untuk mendapatkan warna tombol keyboard
  Color _getKeyColor(String key, BuildContext context) {
    final status = keyStatus[key] ?? LetterStatus.initial;
    switch (status) {
      case LetterStatus.inWordCorrectLocation:
        return Colors.green.shade600;
      case LetterStatus.inWordWrongLocation:
        return Colors.amber.shade600;
      case LetterStatus.notInWord:
        return Colors.grey.shade800;
      case LetterStatus.initial:
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(row1, context),
        _buildRow(row2, context),
        _buildRow(row3, context),
      ],
    );
  }

  Widget _buildRow(List<String> keys, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            keys.map((key) {
              if (key == 'ENTER') {
                return _buildSpecialKey(
                  key,
                  Icons.check,
                  onEnterPressed,
                  flex: 2,
                );
              }
              if (key == '⌫') {
                return _buildSpecialKey(
                  key,
                  Icons.backspace_outlined,
                  onBackspacePressed,
                  flex: 2,
                );
              }
              return _buildLetterKey(key, context);
            }).toList(),
      ),
    );
  }

  Widget _buildLetterKey(String key, BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: () => onLetterPressed(key),
          style: ElevatedButton.styleFrom(
            backgroundColor: _getKeyColor(key, context),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(
    String key,
    IconData icon,
    VoidCallback onPressed, {
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Icon(icon, size: 24),
        ),
      ),
    );
  }
}
