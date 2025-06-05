import 'package:flutter/material.dart';
import 'pages/game_page.dart'; // Impor halaman permainan

class MyApp extends StatelessWidget {
  // Konstruktor untuk MyApp.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah widget dasar untuk aplikasi berbasis Material Design.
    return MaterialApp(
      // Judul aplikasi yang muncul di task manager, dll.
      title: 'Tebak Kata TPM',
      // Konfigurasi tema aplikasi.
      theme: ThemeData(
        // Skema warna utama aplikasi.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Mengaktifkan Material 3 untuk tampilan yang lebih modern.
        useMaterial3: true,
        // Font default untuk aplikasi.
        fontFamily: 'Poppins', // Anda bisa mengganti dengan font lain jika mau
      ),
      // Halaman utama yang akan ditampilkan saat aplikasi pertama kali dibuka.
      home: const GamePage(),
      // Menyembunyikan banner debug di pojok kanan atas.
      debugShowCheckedModeBanner: false,
    );
  }
}
