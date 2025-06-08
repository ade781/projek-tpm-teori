import 'package:hive/hive.dart';

part 'game_history.g.dart';

@HiveType(typeId: 1)
class GameHistory extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final String correctWord;

  @HiveField(2)
  final List<String> guesses;

  @HiveField(3)
  final bool isWin;

  @HiveField(4)
  final DateTime timestamp;

  GameHistory({
    required this.username,
    required this.correctWord,
    required this.guesses,
    required this.isWin,
    required this.timestamp,
  });

  int get attempts => guesses.length;
}
