// lib/pages/sensor_page.dart

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class SensorPage extends StatefulWidget {
  const SensorPage({super.key});

  @override
  State<SensorPage> createState() => _SensorPageState();
}

class _SensorPageState extends State<SensorPage> {
  // Variabel untuk menyimpan data accelerometer
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;

  // Variabel untuk menyimpan data gyroscope
  double _gyroscopeX = 0.0;
  double _gyroscopeY = 0.0;
  double _gyroscopeZ = 0.0;

  // Variabel untuk menyimpan data magnetometer
  double _magnetometerX = 0.0;
  double _magnetometerY = 0.0;
  double _magnetometerZ = 0.0;

  // Variabel untuk menyimpan data proximity (sensor jarak)
  int _proximityValue = 0; // Diubah dari double ke int
  bool _isProximitySensorAvailable = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> _listenProximitySensor() async {
    try {
      ProximitySensor.events.listen(
        (int event) {
          // Diubah dari double ke int
          if (mounted) {
            setState(() {
              _proximityValue = event;
              _isProximitySensorAvailable = true;
            });
          }
        },
        onError: (error) {
          debugPrint('Proximity sensor stream error: $error');
          if (mounted) {
            setState(() {
              _isProximitySensorAvailable = false;
            });
          }
        },
        onDone: () {
          debugPrint('Proximity sensor stream finished.');
        },
      );
    } catch (e) {
      debugPrint('Error accessing proximity sensor: $e');
      if (mounted) {
        setState(() {
          _isProximitySensorAvailable = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Sensor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSensorCard(
              'Accelerometer',
              'Mengukur percepatan yang diterapkan pada perangkat di sepanjang ketiga sumbu (X, Y, dan Z), termasuk gravitasi.',
              _accelerometerX,
              _accelerometerY,
              _accelerometerZ,
            ),
            const SizedBox(height: 20),
            _buildSensorCard(
              'Gyroscope',
              'Mengukur laju rotasi perangkat di sekitar sumbu X, Y, dan Z.',
              _gyroscopeX,
              _gyroscopeY,
              _gyroscopeZ,
            ),
            const SizedBox(height: 20),
            _buildSensorCard(
              'Magnetometer',
              'Mengukur kekuatan medan magnet di sepanjang sumbu X, Y, dan Z. Dapat digunakan untuk kompas.',
              _magnetometerX,
              _magnetometerY,
              _magnetometerZ,
            ),
            const SizedBox(height: 20),
            _buildProximitySensorCard(
              'Sensor Jarak (Proximity)',
              'Mendeteksi kedekatan objek ke layar perangkat, biasanya digunakan untuk mematikan layar saat melakukan panggilan.',
              _proximityValue,
              _isProximitySensorAvailable,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    String description,
    double x,
    double y,
    double z,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            _buildSensorValueRow('Sumbu X', x),
            _buildSensorValueRow('Sumbu Y', y),
            _buildSensorValueRow('Sumbu Z', z),
          ],
        ),
      ),
    );
  }

  Widget _buildProximitySensorCard(
    String title,
    String description,
    int proximityValue,
    bool isAvailable,
  ) {
    final bool isNear = proximityValue > 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Status Sensor:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  isAvailable ? 'Tersedia' : 'Tidak Tersedia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            if (isAvailable) ...[
              const SizedBox(height: 8),
              _buildSensorValueRow('Nilai Sensor', proximityValue.toDouble()),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Status Objek:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    isNear ? 'Dekat' : 'Jauh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isNear ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSensorValueRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value.toStringAsFixed(3),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
