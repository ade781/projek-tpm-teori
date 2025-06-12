
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:projek_akhir_teori/pages/sensor_page2.dart'; 


class SensorPage extends StatelessWidget {
  const SensorPage({super.key});

  @override
  Widget build(BuildContext context) {
    HapticFeedback.lightImpact();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D2B),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Sensor Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white70,
     
        actions: [
          IconButton(
            icon: const Icon(Icons.view_agenda_outlined),
            tooltip: 'Ganti Tampilan',
            onPressed: () {
            
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SensorPage2()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
        
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.2,
            colors: [Color(0xFF1F1F47), Color(0xFF0D0D2B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _SensorCard(
                  title: 'Akselerometer',
                  subtitle: 'Percepatan perangkat (m/s²)',
                  icon: Icons.speed_rounded,
                  stream: accelerometerEventStream(),
                  builder:
                      (event) =>
                          _buildVectorGauges(event as AccelerometerEvent),
                ),
                const SizedBox(height: 20),
                _SensorCard(
                  title: 'Gyroscope',
                  subtitle: 'Kecepatan rotasi perangkat (rad/s)',
                  icon: Icons.rotate_right_rounded,
                  stream: gyroscopeEventStream(),
                  builder:
                      (event) => _buildVectorGauges(event as GyroscopeEvent),
                ),
                const SizedBox(height: 20),
                _SensorCard(
                  title: 'Magnetometer',
                  subtitle: 'Medan magnet di sekitar (μT)',
                  icon: Icons.explore_rounded,
                  stream: magnetometerEventStream(),
                  builder:
                      (event) => _buildVectorGauges(event as MagnetometerEvent),
                ),
                const SizedBox(height: 40),
                const Text(
                  'MADE BY ADE7',
                  style: TextStyle(
                    color: Colors.white12,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVectorGauges(dynamic event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _SensorGauge(label: 'X', value: event.x),
        _SensorGauge(label: 'Y', value: event.y),
        _SensorGauge(label: 'Z', value: event.z),
      ],
    );
  }
}

// (Kode untuk _SensorCard, _SensorGauge, dan _GaugePainter tetap sama seperti sebelumnya)
// ... (Sisa kode dari file ini tidak perlu diubah) ...
class _SensorCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Stream<dynamic> stream;
  final Widget Function(dynamic event) builder;

  const _SensorCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.stream,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.cyanAccent, size: 28),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 30, color: Colors.white24),
              StreamBuilder<dynamic>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.redAccent),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Menunggu data sensor...',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }
                  return builder(snapshot.data);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorGauge extends StatefulWidget {
  final String label;
  final double value;
  final double maxValue;

  const _SensorGauge({
    required this.label,
    required this.value,
    // ignore: unused_element_parameter
    this.maxValue = 20.0,
  });

  @override
  State<_SensorGauge> createState() => _SensorGaugeState();
}

class _SensorGaugeState extends State<_SensorGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentValue = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: _currentValue, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {});
    });
    _currentValue = widget.value;
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _SensorGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _currentValue,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0.0);
      _currentValue = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: _GaugePainter(
              value: _animation.value,
              maxValue: widget.maxValue,
            ),
            child: Center(
              child: Text(
                _animation.value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double maxValue;

  _GaugePainter({required this.value, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;
    const startAngle = -pi * 0.75;
    const sweepAngle = pi * 1.5;

    final backgroundPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final normalizedValue =
        (value.clamp(-maxValue, maxValue) + maxValue) / (maxValue * 2);
    final valueSweepAngle = normalizedValue * sweepAngle;

    final foregroundPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
            startAngle: startAngle,
            endAngle: startAngle + sweepAngle,
            colors: [Colors.cyanAccent, Colors.purpleAccent],
          ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      valueSweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
