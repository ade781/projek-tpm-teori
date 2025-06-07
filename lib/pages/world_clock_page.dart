// lib/pages/world_clock_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/services/time_service.dart';

class WorldClockPage extends StatefulWidget {
  const WorldClockPage({super.key});

  @override
  State<WorldClockPage> createState() => _WorldClockPageState();
}

class _WorldClockPageState extends State<WorldClockPage> {
  final TimeService _timeService = TimeService();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Atur timer untuk memperbarui UI setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // Memicu build ulang untuk memperbarui waktu
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Batalkan timer saat halaman ditutup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Membuat body berada di belakang AppBar
      appBar: AppBar(
        title: const Text(
          'Jam Dunia',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _timeService.timezones.length,
            itemBuilder: (context, index) {
              final timezoneInfo = _timeService.timezones[index];
              return _buildClockCard(timezoneInfo);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildClockCard(TimezoneInfo timezoneInfo) {
    final currentTime = _timeService.getCurrentTimeFor(timezoneInfo.location);
    final formattedTime = _timeService.formatTime(currentTime);
    final formattedDate = _timeService.formatDate(currentTime);
    final utcOffset = _timeService.getUtcOffset(currentTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      color: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Kolom untuk nama kota dan tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${timezoneInfo.flag} ${timezoneInfo.displayName}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Kolom untuk jam dan offset UTC
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w200, // Font tipis untuk jam
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  utcOffset,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
