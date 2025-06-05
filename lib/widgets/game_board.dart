// lib/widgets/game_board.dart
// Widget untuk menampilkan grid permainan 6x5 seperti Wordle.

import 'package:flutter/material.dart';
// import 'package:projek_akhir_teori/widgets/game_tile.dart'; // Dihapus karena berlebihan
import '../models/letter_status.dart';
import 'tile.dart'; // Impor yang benar dan cukup

class GameBoard extends StatelessWidget {
  final List<String> guesses; // Daftar kata yang sudah disubmit
  final String currentGuess; // Kata yang sedang diketik
  final int currentAttempt; // Percobaan ke berapa (indeks baris)
  final String correctWord; // Kata yang benar

  const GameBoard({
    super.key,
    required this.guesses,
    required this.currentGuess,
    required this.currentAttempt,
    required this.correctWord,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(6, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (colIndex) {
              final String letter;
              LetterStatus status = LetterStatus.initial;

              if (rowIndex < currentAttempt) {
                // Baris untuk tebakan yang sudah disubmit
                final guessedWord = guesses[rowIndex];
                letter =
                    colIndex < guessedWord.length ? guessedWord[colIndex] : '';
                status = _evaluateLetter(letter, colIndex, guessedWord);
              } else if (rowIndex == currentAttempt) {
                // Baris aktif yang sedang diketik
                letter =
                    colIndex < currentGuess.length
                        ? currentGuess[colIndex]
                        : '';
                // Untuk tile yang sedang diketik dan belum disubmit,
                // statusnya initial tapi tetap tampilkan hurufnya.
                // Warna akan ditentukan oleh GameTile berdasarkan status initial & ada/tidaknya huruf.
              } else {
                // Baris kosong di masa depan
                letter = '';
                // status tetap LetterStatus.initial
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GameTile(
                  letter: letter.toUpperCase(),
                  status: status,
                ), // pastikan huruf besar
              );
            }),
          ),
        );
      }),
    );
  }

  // Logika utama untuk menentukan status (warna) setiap huruf
  LetterStatus _evaluateLetter(String letter, int index, String guessedWord) {
    if (letter.isEmpty) return LetterStatus.initial;

    final upperLetter = letter.toUpperCase();
    final upperCorrectWord = correctWord.toUpperCase();

    // Buat daftar untuk melacak huruf di kata yang benar yang sudah "digunakan" untuk status kuning
    // agar tidak salah menandai duplikat huruf.
    List<bool> correctWordLetterUsed = List.generate(
      upperCorrectWord.length,
      (index) => false,
    );

    // Cek dulu untuk semua yang hijau (benar posisi & huruf)
    if (upperCorrectWord[index] == upperLetter) {
      correctWordLetterUsed[index] =
          true; // Tandai huruf ini sudah terpakai untuk hijau
      return LetterStatus.inWordCorrectLocation;
    }

    // Kemudian cek untuk yang kuning (ada di kata tapi salah posisi)
    // Iterasi melalui kata yang benar untuk mencari kecocokan huruf
    for (int i = 0; i < upperCorrectWord.length; i++) {
      // Jika huruf ada di kata yang benar, DAN posisinya berbeda, DAN huruf di posisi tsb belum dipakai utk hijau/kuning lain
      if (upperCorrectWord[i] == upperLetter &&
          !correctWordLetterUsed[i] &&
          upperCorrectWord[index] != upperLetter) {
        // Cek lebih lanjut untuk kasus duplikat huruf pada tebakan
        int countInGuess = 0;
        int countInCorrect = 0;
        int correctMatchesForThisLetter = 0;

        for (int k = 0; k < guessedWord.length; k++) {
          if (guessedWord[k].toUpperCase() == upperLetter) {
            countInGuess++;
            if (upperCorrectWord[k] == upperLetter) {
              correctMatchesForThisLetter++;
            }
          }
        }
        for (int k = 0; k < upperCorrectWord.length; k++) {
          if (upperCorrectWord[k] == upperLetter) {
            countInCorrect++;
          }
        }

        // Hitung berapa banyak huruf ini yang sudah diberi warna kuning sebelumnya di tebakan ini
        int yellowsBeforeThis = 0;
        for (int k = 0; k < index; k++) {
          if (guessedWord[k].toUpperCase() == upperLetter &&
              upperCorrectWord[k] != upperLetter &&
              upperCorrectWord.contains(upperLetter)) {
            // Perlu cek lagi apakah huruf ke-k ini memang seharusnya kuning
            bool trueYellow = false;
            List<bool> tempUsed = List.from(correctWordLetterUsed);
            for (int l = 0; l < upperCorrectWord.length; l++) {
              if (upperCorrectWord[l] == guessedWord[k].toUpperCase() &&
                  !tempUsed[l] &&
                  upperCorrectWord[k] != guessedWord[k].toUpperCase()) {
                tempUsed[l] = true;
                trueYellow = true;
                break;
              }
            }
            if (trueYellow) yellowsBeforeThis++;
          }
        }

        if (yellowsBeforeThis <
            (countInCorrect - correctMatchesForThisLetter)) {
          correctWordLetterUsed[i] = true; // Tandai sudah terpakai untuk kuning
          return LetterStatus.inWordWrongLocation;
        }
      }
    }

    // Jika tidak keduanya, berarti tidak ada di kata
    return LetterStatus.notInWord;
  }
}
