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
            _heading = event.heading; // Nilai heading dari 0-360 derajat
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cek jika kompas tidak didukung atau tidak ada data
            if (_heading == null)
              const Text(
                'Memuat data kompas... Pastikan perangkat Anda mendukung sensor kompas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              // Widget untuk menampilkan kompas
              _buildCompass(_heading!),
            const SizedBox(height: 30),
            Text(
              _heading != null
                  ? '${_heading!.toStringAsFixed(1)}°' // Tampilkan heading dalam 1 desimal
                  : 'N/A',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            Text(
              _heading != null ? _getDirectionString(_heading!) : '',
              style: TextStyle(fontSize: 24, color: Colors.grey.shade700),
            ),
          ],
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
          // Background kompas
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomPaint(painter: _CompassPainter()),
          ),
          // Jarum kompas
          Container(
            width: 10,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.red, // Ujung merah menghadap Utara
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Container(
            width: 10,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.blue, // Ujung biru menghadap Selatan
              borderRadius: BorderRadius.circular(5),
            ),
            transform: Matrix4.rotationZ(pi), // Putar 180 derajat
          ),
          // Lingkaran kecil di tengah
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mendapatkan arah mata angin (N, NE, E, dll.)
  String _getDirectionString(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'Utara';
    if (heading >= 22.5 && heading < 67.5) return 'Timur Laut';
    if (heading >= 67.5 && heading < 112.5) return 'Timur';
    if (heading >= 112.5 && heading < 157.5) return 'Tenggara';
    if (heading >= 157.5 && heading < 202.5) return 'Selatan';
    if (heading >= 202.5 && heading < 247.5) return 'Barat Daya';
    if (heading >= 247.5 && heading < 292.5) return 'Barat';
    if (heading >= 292.5 && heading < 337.5) return 'Barat Laut';
    return '';
  }
}

// CustomPainter untuk menggambar tanda arah mata angin di kompas
class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Menggambar arah utama
    _drawDirectionText(
      canvas,
      textPainter,
      'N',
      0.0,
      center,
      radius,
      Colors.black,
      FontWeight.bold,
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
    );
  }

  void _drawDirectionText(
    Canvas canvas,
    TextPainter textPainter,
    String text,
    double angleDegrees,
    Offset center,
    double radius,
    Color color,
    FontWeight fontWeight,
  ) {
    final angleRadians =
        (angleDegrees - 90) * (pi / 180); // Offset 90 derajat agar N di atas
    final x = center.dx + (radius * 0.75) * cos(angleRadians);
    final y = center.dy + (radius * 0.75) * sin(angleRadians);

    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(color: color, fontSize: 20, fontWeight: fontWeight),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
