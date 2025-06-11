// lib/pages/stats_page.dart

import 'package:collection/collection.dart'; 
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/services/stats_service.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}


class _StatsPageState extends State<StatsPage> {
  final StatsService _statsService = StatsService();
  late Future<UserStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _statsService.getCurrentUserStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121213),
      appBar: AppBar(
        title: const Text('Statistik Permainan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<UserStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.totalGames == 0) {
            return const Center(
              child: Text(
                'Belum ada riwayat permainan.\nAyo mainkan gamenya!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final stats = snapshot.data!;
          return _buildStatsView(stats);
        },
      ),
    );
  }

  Widget _buildStatsView(UserStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKeyStats(stats),
          const SizedBox(height: 40),
          const Text(
            'Distribusi Tebakan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildGuessDistributionChart(stats.guessDistribution),
        ],
      ),
    );
  }

  Widget _buildKeyStats(UserStats stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(value: stats.totalGames.toString(), label: 'Dimainkan'),
        _StatItem(value: '${stats.winPercentage}%', label: 'Menang'),
        _StatItem(
          value: stats.currentStreak.toString(),
          label: 'Streak Saat Ini',
        ),
        _StatItem(value: stats.maxStreak.toString(), label: 'Streak Tertinggi'),
      ],
    );
  }

  Widget _buildGuessDistributionChart(Map<int, int> distribution) {
    final maxValue =
        (distribution.values.maxOrNull ?? 0) > 0
            ? (distribution.values.max).toDouble()
            : 1.0;

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    (value.toInt() + 1).toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: List.generate(6, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: distribution[index + 1]!.toDouble(),
                  color: Colors.green,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
