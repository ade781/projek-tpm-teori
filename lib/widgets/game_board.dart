import 'package:flutter/material.dart';
import '../models/letter_status.dart';
import 'tile.dart';

class GameBoard extends StatelessWidget {
  final List<String> guesses;
  final String currentGuess;
  final int currentAttempt;
  final String correctWord;

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
                final guessedWord = guesses[rowIndex];
                letter =
                    colIndex < guessedWord.length ? guessedWord[colIndex] : '';
                status = _evaluateLetter(letter, colIndex, guessedWord);
              } else if (rowIndex == currentAttempt) {
                letter =
                    colIndex < currentGuess.length
                        ? currentGuess[colIndex]
                        : '';
              } else {
                letter = '';
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GameTile(letter: letter.toUpperCase(), status: status),
              );
            }),
          ),
        );
      }),
    );
  }

  LetterStatus _evaluateLetter(String letter, int index, String guessedWord) {
    if (letter.isEmpty) return LetterStatus.initial;

    final upperLetter = letter.toUpperCase();
    final upperCorrectWord = correctWord.toUpperCase();

    List<bool> correctWordLetterUsed = List.generate(
      upperCorrectWord.length,
      (index) => false,
    );

    if (upperCorrectWord[index] == upperLetter) {
      correctWordLetterUsed[index] = true;
      return LetterStatus.inWordCorrectLocation;
    }

    for (int i = 0; i < upperCorrectWord.length; i++) {
      if (upperCorrectWord[i] == upperLetter &&
          !correctWordLetterUsed[i] &&
          upperCorrectWord[index] != upperLetter) {
        int countInCorrect = 0;
        int correctMatchesForThisLetter = 0;

        for (int k = 0; k < guessedWord.length; k++) {
          if (guessedWord[k].toUpperCase() == upperLetter) {
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

        int yellowsBeforeThis = 0;
        for (int k = 0; k < index; k++) {
          if (guessedWord[k].toUpperCase() == upperLetter &&
              upperCorrectWord[k] != upperLetter &&
              upperCorrectWord.contains(upperLetter)) {
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
          correctWordLetterUsed[i] = true;
          return LetterStatus.inWordWrongLocation;
        }
      }
    }
    return LetterStatus.notInWord;
  }
}
