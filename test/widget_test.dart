// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projek_akhir_teori/app.dart';

// Hapus 'import 'package:projek_akhir_teori/main.dart';' karena tidak diperlukan di sini.

void main() {
  // Ubah deskripsi tes agar lebih relevan dengan aplikasi Anda, atau hapus jika tidak relevan.
  testWidgets('Login page shows up when not logged in', (
    WidgetTester tester,
  ) async {
    // --- PERBAIKAN DI SINI ---
    // Sekarang kita berikan nilai untuk parameter 'isLoggedIn' yang wajib diisi.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verifikasi bahwa halaman login ditampilkan dengan benar.
    // Cari widget TextField untuk username, contohnya.
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });
}
