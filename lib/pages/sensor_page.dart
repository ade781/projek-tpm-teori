// lib/pages/sensor_page.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> with TickerProviderStateMixin {
  // Variabel data sensor
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;

  double _gyroscopeX = 0.0;
  double _gyroscopeY = 0.0;
  double _gyroscopeZ = 0.0;

  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;

  // Kontrol animasi
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi animasi
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Mendengarkan aliran data sensor
    accelerometerEventStream().listen((AccelerometerEvent event) {
      if (mounted) {
        setState(() {
          _accelerometerX = event.x;
          _accelerometerY = event.y;
          _accelerometerZ = event.z;
        });
      }
    });

    gyroscopeEventStream().listen((GyroscopeEvent event) {
      if (mounted) {
        setState(() {
          _gyroscopeX = event.x;
          _gyroscopeY = event.y;
          _gyroscopeZ = event.z;
        });
      }
    });

    magnetometerEventStream().listen((MagnetometerEvent event) {
      if (mounted) {
        setState(() {
          _magnetometerX = event.x;
          _magnetometerY = event.y;
          _magnetometerZ = event.z;
        });
      }
    });

    _listenProximitySensor();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _listenProximitySensor() async {
    try {
      ProximitySensor.events.listen(
        (int event) {
          if (mounted) {
            setState(() {});
          }
        },
        onError: (error) {
          debugPrint('Error sensor jarak: $error');
        },
        onDone: () {
          debugPrint('Aliran sensor jarak selesai.');
        },
      );
    } catch (e) {
      debugPrint('Gagal mengakses sensor jarak: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Sensor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.2),
            ],
            center: Alignment.topRight,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header dengan ikon animasi
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Center(
                    child: Icon(
                      Icons.sensors,
                      size: 60,
                      color: theme.colorScheme.secondary.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Data Sensor Real-time',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Visualisasi gerakan perangkat dan sensor lingkungan',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),

                // Kartu sensor
                _buildSensorCard(
                  context,
                  'Akselerometer',
                  Icons.speed,
                  'Mengukur percepatan perangkat termasuk gravitasi',
                  _accelerometerX,
                  _accelerometerY,
                  _accelerometerZ,
                ),
                const SizedBox(height: 20),
                _buildSensorCard(
                  context,
                  'Gyroscope',
                  Icons.rotate_right,
                  'Mengukur kecepatan rotasi perangkat',
                  _gyroscopeX,
                  _gyroscopeY,
                  _gyroscopeZ,
                ),
                const SizedBox(height: 20),
                _buildSensorCard(
                  context,
                  'Magnetometer',
                  Icons.explore,
                  'Mengukur kekuatan medan magnet',
                  _magnetometerX,
                  _magnetometerY,
                  _magnetometerZ,
                ),
                const SizedBox(height: 30),

                // Footer
                Center(
                  child: Column(
                    children: [
                      const Divider(color: Colors.white54),
                      const SizedBox(height: 8),
                      Text(
                        'DIBUAT OLEH ADE7',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context,
    String title,
    IconData icon,
    String description,
    double x,
    double y,
    double z,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.secondary.withOpacity(0.2),
          width: 1,
        ),
      ),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              isDarkMode
                  ? Colors.grey.shade900.withOpacity(0.7)
                  : Colors.white.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: theme.colorScheme.secondary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 16),
              _buildSensorValueRow('Sumbu X', x, theme),
              _buildSensorValueRow('Sumbu Y', y, theme),
              _buildSensorValueRow('Sumbu Z', z, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorValueRow(String label, double value, ThemeData theme) {
    final color =
        value.abs() > 5 ? theme.colorScheme.error : theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
            ),
            child: Text(
              value.toStringAsFixed(3),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
