// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_teori/models/user_model.dart';
import 'app.dart';
// Hapus import auth_service karena tidak diperlukan di sini lagi
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
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  await Hive.openBox<User>('users');

  // Hapus logika pengecekan login dari sini
  // final authService = AuthService();
  // final bool isLoggedIn = await authService.isLoggedIn();

  // Cukup jalankan MyApp
  runApp(const MyApp());
}
