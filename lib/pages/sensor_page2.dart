import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorPage2 extends StatelessWidget {
  const SensorPage2({super.key});

  @override
  Widget build(BuildContext context) {
    HapticFeedback.lightImpact();

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.8, -1.0),
            radius: 1.5,
            colors: [Color(0xFF16213e), Color(0xFF1a1a2e)],
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
                      (event) => _buildVectorData(event as AccelerometerEvent),
                ),
                const SizedBox(height: 20),
                _SensorCard(
                  title: 'Gyroscope',
                  subtitle: 'Kecepatan rotasi perangkat (rad/s)',
                  icon: Icons.rotate_right_rounded,
                  stream: gyroscopeEventStream(),
                  builder: (event) => _buildVectorData(event as GyroscopeEvent),
                ),
                const SizedBox(height: 20),
                _SensorCard(
                  title: 'Magnetometer',
                  subtitle: 'Medan magnet di sekitar (μT)',
                  icon: Icons.explore_rounded,
                  stream: magnetometerEventStream(),
                  builder:
                      (event) => _buildVectorData(event as MagnetometerEvent),
                ),
                const SizedBox(height: 40),
                const Text(
                  'MADE BY ADE7',
                  style: TextStyle(
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVectorData(dynamic event) {
    return Column(
      children: [
        _SensorDataRow(label: 'X', value: event.x),
        _SensorDataRow(label: 'Y', value: event.y),
        _SensorDataRow(label: 'Z', value: event.z),
      ],
    );
  }
}

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
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white70, size: 32),
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
    );
  }
}

class _SensorDataRow extends StatelessWidget {
  final String label;
  final double value;

  const _SensorDataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final normalizedValue = (value.clamp(-15.0, 15.0) + 15.0) / 30.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LinearProgressIndicator(
              value: normalizedValue,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.cyanAccent,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 70,
            child: Text(
              value.toStringAsFixed(2),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
