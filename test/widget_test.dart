import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart'; // Import package Lottie untuk verifikasi
import 'package:projek_akhir_teori/app.dart';
import 'package:projek_akhir_teori/pages/splash_screen.dart';

void main() {
  // Deskripsi tes diperbarui untuk mencerminkan alur baru.
  testWidgets('SplashScreen shows up first with Lottie animation', (
    WidgetTester tester,
  ) async {
    // --- PERBAIKAN ---
    // MyApp sekarang dipanggil tanpa parameter apapun, sesuai dengan definisinya yang baru.
    await tester.pumpWidget(const MyApp());

    // Verifikasi bahwa SplashScreen adalah widget pertama yang muncul.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Verifikasi bahwa ada animasi Lottie yang ditampilkan di dalam splash screen.
    // Ini memastikan file 'splash_loading.json' Anda dimuat.
    expect(find.byType(Lottie), findsOneWidget);

    // Anda juga bisa memverifikasi teks yang ada di splash screen.
    expect(find.text('Projek Akhir Teori'), findsOneWidget);

    // Karena navigasi terjadi setelah timer, kita tidak perlu menguji
    // halaman login/home di sini untuk menjaga tes tetap sederhana.
    // Pengujian ini cukup untuk memastikan titik masuk aplikasi sudah benar.
  });
}
