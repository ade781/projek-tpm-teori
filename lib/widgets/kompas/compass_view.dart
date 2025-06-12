import 'dart:math';
import 'package:flutter/material.dart';
import 'compass_painters.dart';

class CompassView extends StatelessWidget {
  final double heading;

  const CompassView({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (-heading * (pi / 180)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Latar belakang dial kompas
          Container(
            width: 280,
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
                  color: Colors.black.withAlpha((0.3 * 255).round()),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(5, 5),
                ),
                BoxShadow(
                  color: Colors.white.withAlpha((0.1 * 255).round()),
                  blurRadius: 15,
                  spreadRadius: 3,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: CustomPaint(painter: CompassDialPainter()),
          ),

          // Jarum Utara (Merah)
          CustomPaint(
            painter: NeedlePainter(color: Colors.red.shade700, isNorth: true),
            size: const Size(10, 180),
          ),

          // Jarum Selatan (Biru)
          CustomPaint(
            painter: NeedlePainter(color: Colors.blue.shade700, isNorth: false),
            size: const Size(10, 180),
          ),

          // Titik tengah
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
}
