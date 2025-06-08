import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/models/aqi_model.dart';
import 'package:projek_akhir_teori/pages/game_page.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';
import 'package:projek_akhir_teori/pages/map_page.dart';
import 'package:projek_akhir_teori/pages/currency_converter_page.dart';
import 'package:projek_akhir_teori/pages/world_clock_page.dart';
import 'package:projek_akhir_teori/services/aqi_service.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:projek_akhir_teori/pages/sensor_page.dart';
import 'package:projek_akhir_teori/pages/kompas_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final AqiService _aqiService = AqiService();
  String? _username;
  late Future<AqiData?> _aqiFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadUserData();
    _aqiFuture = _aqiService.getAqiForCurrentLocation();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getLoggedInUserObject();
    if (mounted && user != null) {
      setState(() {
        _username = user.username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _aqiFuture = _aqiService.getAqiForCurrentLocation();
          });
        },
        child: CustomScrollView(
          slivers: [
            _buildHeader(),
            _buildAqiCard(),
            _buildOtherFeaturesTitle(),
            _buildFeaturesList(),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    final String formattedDate = DateFormat(
      'EEEE, d MMMM',
      'id_ID',
    ).format(DateTime.now());
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${_username ?? 'Pengguna'}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: TextStyle(color: Colors.deepPurple.shade300, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAqiCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FutureBuilder<AqiData?>(
          future: _aqiFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 250,
                child: Center(
                  child: Lottie.asset(
                    'assets/aqi_loading.json',
                    width: 250,
                    height: 250,
                  ),
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildErrorCard(snapshot.error.toString());
            }
            if (!snapshot.hasData) {
              return _buildErrorCard(
                "Tidak ada data kualitas udara ditemukan.",
              );
            }

            final aqiData = snapshot.data!;
            return _AqiInfoCard(aqiData: aqiData);
          },
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.deepPurple.shade100, width: 1),
      ),
      color: Colors.deepPurple.shade50,
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.deepPurple.shade400,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              "Gagal Memuat Data",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.deepPurple.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: TextStyle(color: Colors.deepPurple.shade600, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildOtherFeaturesTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          'Fitur Lainnya',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple.shade800,
          ),
        ),
      ),
    );
  }

  SliverList _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.gamepad_outlined,
        'title': 'Tebak kata',
        'subtitle': 'Uji kosakatamu di sini',
        'page': const GamePage(),
      },
      {
        'icon': Icons.map_outlined,
        'title': 'Peta Ibadah',
        'subtitle': 'Cari lokasi tempat ibadah',
        'page': const MapPage(),
      },
      {
        'icon': Icons.currency_exchange,
        'title': 'Konverter',
        'subtitle': 'Cek nilai tukar mata uang',
        'page': const CurrencyConverterPage(),
      },
      {
        'icon': Icons.access_time_filled,
        'title': 'Jam Dunia',
        'subtitle': 'Lihat waktu di berbagai negara',
        'page': const WorldClockPage(),
      },
      {
        'icon': Icons.sensors,
        'title': 'Data Sensor',
        'subtitle': 'Baca data dari accelerometer, gyroscope, magnetometer',
        'page': const SensorPage(),
      },
      {
        'icon': Icons.explore,
        'title': 'Kompas',
        'subtitle': 'Temukan arah mata angin',
        'page': const KompasPage(),
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final feature = features[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
          child: _buildFeatureListItem(
            feature['icon'] as IconData,
            feature['title'] as String,
            feature['subtitle'] as String,
            feature['page'] as Widget,
          ),
        );
      }, childCount: features.length),
    );
  }

  Widget _buildFeatureListItem(
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.deepPurple.shade100, width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => page)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: Colors.deepPurple.shade800),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.deepPurple.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.deepPurple.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AqiInfoCard extends StatelessWidget {
  final AqiData aqiData;
  const _AqiInfoCard({required this.aqiData});

  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow;
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }

  String _getAqiStatus(int aqi) {
    if (aqi <= 50) return "Baik";
    if (aqi <= 100) return "Sedang";
    if (aqi <= 150) return "Tidak Sehat bagi Kelompok Sensitif";
    if (aqi <= 200) return "Tidak Sehat";
    if (aqi <= 300) return "Sangat Tidak Sehat";
    return "Berbahaya";
  }

  @override
  Widget build(BuildContext context) {
    final aqiColor = _getAqiColor(aqiData.aqi);
    final aqiStatus = _getAqiStatus(aqiData.aqi);

    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurple.withAlpha(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [aqiColor.withAlpha(179), aqiColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aqiData.cityName.split(',').first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    aqiStatus,
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Text(
                  aqiData.aqi.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "AQI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
