import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/models/game_history.dart';
import 'package:intl/intl.dart';

class GameHistorySection extends StatelessWidget {
  final Future<List<GameHistory>> gameHistoryFuture;

  const GameHistorySection({super.key, required this.gameHistoryFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameHistory>>(
      future: gameHistoryFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildInfoState(
            context,
            'Gagal memuat riwayat: ${snapshot.error}',
            Icons.error_outline,
            Theme.of(context).colorScheme.error,
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildInfoState(
            context,
            'Belum ada riwayat permainan. Yuk, mainkan Tebak Kata!',
            Icons.history_toggle_off,
            Theme.of(context).colorScheme.onSurfaceVariant,
          );
        } else {
          final history = snapshot.data!;
          final recentHistory = history.take(5).toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentHistory.length,
            itemBuilder: (context, index) {
              final game = recentHistory[index];
              return _buildGameHistoryCard(context, game);
            },
          );
        }
      },
    );
  }

  Widget _buildInfoState(
    BuildContext context,
    String message,
    IconData icon,
    Color color,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: color.withOpacity(0.7)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameHistoryCard(BuildContext context, GameHistory game) {
    final theme = Theme.of(context);
    final isWin = game.isWin;
    final cardColor = isWin ? Colors.green.shade50 : Colors.red.shade50;
    final headerColor = isWin ? Colors.green.shade800 : Colors.red.shade800;
    final iconData =
        isWin
            ? Icons.emoji_events_outlined
            : Icons.sentiment_dissatisfied_outlined;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: cardColor,
        border: Border.all(color: headerColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: headerColor.withOpacity(0.1),
              child: Icon(iconData, color: headerColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isWin ? 'MENANG!' : 'KALAH',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: headerColor,
                        ),
                      ),
                      Text(
                        DateFormat('d MMM y, HH:mm').format(game.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      text: 'Kata: ',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                      children: [
                        TextSpan(
                          text: game.correctWord.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Percobaan: ${game.attempts}',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
