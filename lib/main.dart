// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_teori/models/game_history.dart'; // <-- IMPORT BARU
import 'package:projek_akhir_teori/models/user_model.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await dotenv.load(fileName: ".env");

  await NotificationService.init();
  await NotificationService.requestPermissions();

  await Hive.initFlutter();

  // Daftarkan semua adapter
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GameHistoryAdapter()); // <-- DAFTARKAN ADAPTER BARU
  }

  // Buka semua box
  await Hive.openBox<User>('users');
  await Hive.openBox<GameHistory>('game_history'); // <-- BUKA BOX BARU

  runApp(const MyApp());
}
