// lib/pages/kompas_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart'; // Impor paket kompas

class KompasPage extends StatefulWidget {
  const KompasPage({super.key});

  @override
  State<KompasPage> createState() => _KompasPageState();
}

class _KompasPageState extends State<KompasPage> {
  double? _heading; // Heading dalam derajat dari utara magnetis

  @override
  void initState() {
    super.initState();
    // Memulai mendengarkan event kompas
    if (FlutterCompass.events != null) {
      FlutterCompass.events!.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            // Nilai heading bisa null jika sensor tidak tersedia atau sedang inisialisasi
            if (event.heading != null) {
              // Normalisasi nilai heading: memastikan selalu antara 0.0 dan 360.0
              _heading = (event.heading! % 360 + 360) % 360;
            } else {
              _heading = null; // Biarkan null jika tidak ada data
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kompas Digital'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Container(
        // Tambahkan Container untuk background gradien
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(
                context,
              ).colorScheme.primary.withAlpha(200), // Sedikit transparan
              Theme.of(context).colorScheme.secondary.withAlpha(200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cek jika kompas tidak didukung atau tidak ada data
              if (_heading == null)
                const Text(
                  'Memuat data kompas... Pastikan perangkat Anda mendukung sensor kompas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                )
              else
                // Widget untuk menampilkan kompas
                _buildCompass(_heading!),
              const SizedBox(height: 30),
              Text(
                _heading != null
                    ? '${_heading!.toStringAsFixed(1)}°' // Tampilkan heading dalam 1 desimal
                    : 'N/A',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                _heading != null ? _getDirectionString(_heading!) : '',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white.withAlpha(
                    (0.8 * 255).round(),
                  ), // Menggunakan withAlpha
                ),
              ),
              const SizedBox(height: 50), // Spasi di atas teks "MADE BY ADE7"
              const Text(
                'MADE BY ADE7',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menggambar kompas dan jarumnya
  Widget _buildCompass(double heading) {
    return Transform.rotate(
      // Rotasi berlawanan arah jarum jam dari arah utara (0 derajat)
      angle: (-heading * (pi / 180)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background kompas dengan gradien
          Container(
            width: 280, // Ukuran kompas lebih besar untuk memberi ruang
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade300, Colors.grey.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(
                    (0.3 * 255).round(),
                  ), // Menggunakan withAlpha
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(5, 5),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha(
                    (0.1 * 255).round(),
                  ), // Menggunakan withAlpha
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: CustomPaint(painter: _CompassPainter()),
          ),
          // Jarum kompas (bagian Utara)
          CustomPaint(
            painter: _NeedlePainter(color: Colors.red.shade700, isNorth: true),
            size: const Size(
              10,
              180,
            ), // Ukuran jarum disesuaikan dengan lingkaran yang lebih besar
          ),
          // Jarum kompas (bagian Selatan)
          CustomPaint(
            painter: _NeedlePainter(
              color: Colors.blue.shade700,
              isNorth: false,
            ),
            size: const Size(10, 180), // Ukuran jarum disesuaikan
          ),
          // Lingkaran kecil di tengah
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withAlpha((0.5 * 255).round()),
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDirectionString(double heading) {
    heading = (heading % 360 + 360) % 360; // normalisasi heading

    if (heading >= 0 && heading < 22.5 || heading >= 337.5 && heading < 360) {
      return 'Utara (N)';
    }
    if (heading >= 22.5 && heading < 67.5) return 'Timur Laut (NE)';
    if (heading >= 67.5 && heading < 112.5) return 'Timur (E)';
    if (heading >= 112.5 && heading < 157.5) return 'Tenggara (SE)';
    if (heading >= 157.5 && heading < 202.5) return 'Selatan (S)';
    if (heading >= 202.5 && heading < 247.5) return 'Barat Daya (SW)';
    if (heading >= 247.5 && heading < 292.5) return 'Barat (W)';
    if (heading >= 292.5 && heading < 337.5) return 'Barat Laut (NW)';
    return 'Tidak diketahui';
  }
}

// CustomPainter untuk menggambar tanda arah mata angin dan skala di kompas
class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Gambar lingkaran luar kompas
    canvas.drawCircle(center, radius, paint);

    // Menggambar tick marks dan angka derajat
    for (int i = 0; i < 360; i += 5) {
      // Setiap 5 derajat
      final isMajor = (i % 30 == 0); // Setiap 30 derajat untuk angka
      final isHalfMajor =
          (i % 15 == 0 && !isMajor); // Setiap 15 derajat untuk tick besar

      final tickLength = isMajor ? 15.0 : (isHalfMajor ? 10.0 : 5.0);
      final tickWidth = isMajor ? 3.0 : 1.0;
      final tickPaint =
          Paint()
            ..color = Colors.black
            ..strokeWidth = tickWidth
            ..style = PaintingStyle.stroke;

      final angle = (i - 90) * (pi / 180); // Adjust for 0 (North) at top
      final p1 = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final p2 = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);

      if (isMajor) {
        textPainter.text = TextSpan(
          text: i.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        // Memposisikan angka derajat sedikit di luar ticks
        final textX = center.dx + (radius - tickLength - 18) * cos(angle);
        final textY = center.dy + (radius - tickLength - 18) * sin(angle);
        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }
    }

    // Menggambar arah mata angin (N, NE, E, SE, S, SW, W, NW)
    // Teks diposisikan di luar lingkaran utama kompas dengan multiplier > 1.0
    _drawDirectionText(
      canvas,
      textPainter,
      'N',
      0.0,
      center,
      radius,
      Colors.red,
      FontWeight.bold,
      24,
      1.15,
    ); // Lebih jauh dari pusat
    _drawDirectionText(
      canvas,
      textPainter,
      'NE',
      45.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'E',
      90.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'SE',
      135.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'S',
      180.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'SW',
      225.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'W',
      270.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
      24,
      1.15,
    );
    _drawDirectionText(
      canvas,
      textPainter,
      'NW',
      315.0,
      center,
      radius,
      Colors.black,
      FontWeight.normal,
      16,
      1.10,
    );
  }

  // Fungsi pembantu untuk menggambar teks arah mata angin
  void _drawDirectionText(
    Canvas canvas,
    TextPainter textPainter,
    String text,
    double angleDegrees,
    Offset center,
    double radius,
    Color color,
    FontWeight fontWeight,
    double fontSize,
    double textRadiusMultiplier,
  ) {
    final angleRadians =
        (angleDegrees - 90) * (pi / 180); // Offset 90 derajat agar N di atas
    final textRadius =
        radius * textRadiusMultiplier; // Jarak teks dari tengah, disesuaikan
    final x = center.dx + textRadius * cos(angleRadians);
    final y = center.dy + textRadius * sin(angleRadians);

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // Karena gambar statis, tidak perlu repaint setiap frame
  }
}

// CustomPainter untuk menggambar jarum kompas
class _NeedlePainter extends CustomPainter {
  final Color color;
  final bool
  isNorth; // True untuk jarum Utara (merah), false untuk Selatan (biru)

  _NeedlePainter({required this.color, required this.isNorth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Titik ujung jarum (lebih jauh dari tengah)
    final needleTip = Offset(
      center.dx,
      isNorth ? center.dy - size.height * 0.45 : center.dy + size.height * 0.45,
    );
    // Titik pangkal jarum (lebih dekat ke tengah)
    final needleBase = Offset(
      center.dx,
      isNorth ? center.dy + size.height * 0.45 : center.dy - size.height * 0.45,
    );

    final path = Path();
    path.moveTo(needleTip.dx, needleTip.dy);
    path.lineTo(center.dx - size.width / 2, needleBase.dy); // Lebar di pangkal
    path.lineTo(center.dx + size.width / 2, needleBase.dy); // Lebar di pangkal
    path.close();

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Tambahkan garis tengah pada jarum agar terlihat lebih bagus
    final centerLinePaint =
        Paint()
          ..color = Colors.white.withAlpha((0.7 * 255).round())
          ..strokeWidth = 1;
    canvas.drawLine(needleTip, needleBase, centerLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Jarum perlu direpaint setiap kali heading berubah, jadi ini harus true.
    return true;
  }
}
