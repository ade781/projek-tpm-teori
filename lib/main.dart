import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:projek_akhir_teori/models/game_history.dart';
import 'package:projek_akhir_teori/models/user_model.dart';
import 'app.dart';
import 'services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  tz.initializeTimeZones();
  await dotenv.load(fileName: ".env");
  await NotificationService.init();
  await NotificationService.requestPermissions();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(GameHistoryAdapter());
  }

  await Hive.openBox<User>('users');
  await Hive.openBox<GameHistory>('game_history');

  runApp(const MyApp());
}
