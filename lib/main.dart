// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_teori/models/user_model.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); 


  await dotenv.load(fileName: ".env");

  // INISIALISASI NOTIFIKASI
  await NotificationService.init();
  await NotificationService.requestPermissions();

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }

  await Hive.openBox<User>('users');

  final authService = AuthService();
  final bool isLoggedIn = await authService.isLoggedIn();

  runApp(MyApp(isLoggedIn: isLoggedIn));
}
