import 'package:collection/collection.dart';
import 'package:hive/hive.dart';
import 'package:projek_akhir_teori/models/game_history.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';

class UserStats {
  final int totalGames;
  final int winPercentage;
  final int currentStreak;
  final int maxStreak;
  final Map<int, int> guessDistribution;

  UserStats({
    this.totalGames = 0,
    this.winPercentage = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.guessDistribution = const {},
  });
}

class StatsService {
  final AuthService _authService = AuthService();
  late final Box<GameHistory> _historyBox;

  StatsService() {
    _historyBox = Hive.box<GameHistory>('game_history');
  }

  // Menyimpan riwayat game yang baru selesai
  Future<void> saveGame(
    String correctWord,
    List<String> guesses,
    bool isWin,
  ) async {
    final username = await _authService.getLoggedInUser();
    if (username == null) return;

    final gameHistory = GameHistory(
      username: username,
      correctWord: correctWord,
      guesses: guesses,
      isWin: isWin,
      timestamp: DateTime.now(),
    );

    await _historyBox.add(gameHistory);
  }

  Future<UserStats> getCurrentUserStats() async {
    final username = await _authService.getLoggedInUser();
    if (username == null) return UserStats();

    final userGames =
        _historyBox.values
            .where((game) => game.username == username)
            .sortedBy((game) => game.timestamp)
            .toList();

    if (userGames.isEmpty) return UserStats();

    final totalGames = userGames.length;
    final totalWins = userGames.where((g) => g.isWin).length;
    final winPercentage =
        totalGames > 0 ? ((totalWins / totalGames) * 100).round() : 0;

    final guessDistribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (var game in userGames.where((g) => g.isWin)) {
      final attempts = game.attempts;
      if (guessDistribution.containsKey(attempts)) {
        guessDistribution[attempts] = guessDistribution[attempts]! + 1;
      }
    }

    int maxStreak = 0;
    int currentStreak = 0;
    for (var game in userGames) {
      if (game.isWin) {
        currentStreak++;
      } else {
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
        currentStreak = 0;
      }
    }
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
    if (userGames.last.isWin == false) {
      currentStreak = 0;
    }

    return UserStats(
      totalGames: totalGames,
      winPercentage: winPercentage,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      guessDistribution: guessDistribution,
    );
  }

  Future<List<GameHistory>> getGameHistoryForUser(String username) async {
    return _historyBox.values
        .where((game) => game.username == username)
        .sortedBy((game) => game.timestamp)
        .toList()
        .reversed
        .toList();
  }
}
