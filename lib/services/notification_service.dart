// lib/services/notification_service.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Menambahkan callback untuk menangani saat notifikasi diklik
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Di sini Anda bisa menambahkan logika navigasi jika diperlukan
        // Misalnya: buka halaman game saat notifikasi diklik
        print('Notifikasi diklik dengan payload: ${response.payload}');
      },
    );
  }

  static Future<void> requestPermissions() async {
    // ... (kode ini tidak berubah)
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'game_channel_styled',
            'Game Notifications Styled',
            description: 'Channel for styled game reminders.',
            importance: Importance.max,
          ),
        );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> showGameReminderNotification() async {
    final String imagePath = await _getImagePathFromAssets(
      'assets/notification_banner.png',
    );

    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
          FilePathAndroidBitmap(imagePath),
          largeIcon: FilePathAndroidBitmap(imagePath),
          contentTitle: '<b>Permainan Belum Selesai!</b>',
          htmlFormatContentTitle: true,
          summaryText: 'Yuk, lanjutkan permainan tebak kata!',
          htmlFormatSummaryText: true,
        );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'game_channel_styled',
          'Game Notifications Styled',
          channelDescription: 'Channel for styled game reminders.',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigPictureStyleInformation,
          ticker: 'ticker',
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      1,
      'Lanjutkan Permainan?',
      'Tebak kata menantimu. Selesaikan tantangannya!',
      notificationDetails,
      payload: 'game_page_reminder',
    );
  }


  static Future<String> _getImagePathFromAssets(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File(
      '${(await getTemporaryDirectory()).path}/${assetPath.split('/').last}',
    );
    await file.writeAsBytes(
      byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      ),
    );
    return file.path;
  }
}
