// lib/services/time_service.dart

import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

// Model untuk menyimpan informasi setiap zona waktu
class TimezoneInfo {
  final String location; // Nama lokasi dari database IANA
  final String displayName; // Nama yang akan ditampilkan di UI
  final String flag; // Emoji bendera

  TimezoneInfo({
    required this.location,
    required this.displayName,
    required this.flag,
  });
}

// Layanan untuk mengelola logika waktu
class TimeService {
  // Daftar zona waktu yang akan ditampilkan
  final List<TimezoneInfo> timezones = [
    TimezoneInfo(location: 'Asia/Jakarta', displayName: 'WIB', flag: '🇮🇩'),
    TimezoneInfo(location: 'Asia/Makassar', displayName: 'WITA', flag: '🇮🇩'),
    TimezoneInfo(location: 'Asia/Jayapura', displayName: 'WIT', flag: '🇮🇩'),
    TimezoneInfo(location: 'Europe/London', displayName: 'London', flag: '🇬🇧'),
    // --- PERBAIKAN FINAL ---
    // Mengganti 'Etc/Greenwich' dengan 'GMT' yang merupakan identifier standar
    TimezoneInfo(location: 'GMT', displayName: 'UTC / Greenwich', flag: '🌐'),
  ];

  // Mengambil waktu saat ini untuk zona waktu tertentu
  tz.TZDateTime getCurrentTimeFor(String location) {
    return tz.TZDateTime.now(tz.getLocation(location));
  }

  // Memformat waktu ke dalam format HH:mm:ss
  String formatTime(tz.TZDateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  // Memformat tanggal ke dalam format yang mudah dibaca
  String formatDate(tz.TZDateTime time) {
    return DateFormat('EEEE, d MMMM yyyy').format(time);
  }

  // Mendapatkan informasi offset dari UTC
  String getUtcOffset(tz.TZDateTime time) {
    final offsetInHours = time.timeZoneOffset.inMilliseconds / (1000 * 60 * 60);
    // Cek jika offset adalah 0 untuk kasus khusus UTC
    if (offsetInHours == 0) {
      return 'UTC +0';
    }
    final sign = offsetInHours >= 0 ? '+' : '-';
    final hours = offsetInHours.abs().floor();
    return 'UTC $sign$hours';
  }
}
