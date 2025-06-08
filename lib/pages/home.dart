import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // <-- Import Lottie package
import 'package:projek_akhir_teori/models/aqi_model.dart';
import 'package:projek_akhir_teori/models/quote_model.dart';
import 'package:projek_akhir_teori/pages/game_page.dart';
import 'package:projek_akhir_teori/services/auth_service.dart';
import 'package:projek_akhir_teori/pages/map_page.dart';
import 'package:projek_akhir_teori/pages/currency_converter_page.dart';
import 'package:projek_akhir_teori/pages/world_clock_page.dart';
import 'package:projek_akhir_teori/services/aqi_service.dart';
import 'package:projek_akhir_teori/services/quote_service.dart';
import 'package:intl/intl.dart';
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
  final QuoteService _quoteService = QuoteService();

  String? _username;
  late Future<AqiData?> _aqiFuture;
  late Future<QuoteModel> _quoteFuture;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _loadUserData();
    _aqiFuture = _aqiService.getAqiForCurrentLocation();
    _quoteFuture = _loadRandomQuote();
  }

  Future<QuoteModel> _loadRandomQuote() async {
    final quotes = await _quoteService.fetchQuotes();
    if (quotes.isEmpty) {
      return QuoteModel(
        id: '0',
        isi:
            'Selamat datang di Lurufa. Tarik ke bawah untuk memuat hikmah baru.',
      );
    }
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  Future<void> _refreshData() async {
    setState(() {
      _aqiFuture = _aqiService.getAqiForCurrentLocation();
      _quoteFuture = _loadRandomQuote();
    });
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
      backgroundColor: Colors.grey.shade100, 
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/Background_home.png", 
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: CustomScrollView(
            slivers: [
              _buildHeader(context),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              _buildQuoteCard(),
              _buildAqiCard(),
              _buildOtherFeaturesTitle(),
              _buildFeaturesList(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildHeader(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(DateTime.now());
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 120,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${_username ?? 'Pengguna'}!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                shadows: [
                  Shadow(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
            Text(
              formattedDate,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FutureBuilder<QuoteModel>(
          future: _quoteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Container(
                height: 80,
                alignment: Alignment.center,
                // --- PERUBAHAN LOADING QUOTE ---
                child: Lottie.asset('assets/quote_loading3.json', height: 80),
              );
            }
            if (snapshot.hasError) {
              return _buildInfoCard(
                icon: Icons.error_outline,
                text: "Gagal memuat hikmah.",
                color: Colors.red.shade100,
                iconColor: Colors.red.shade400,
              );
            }
            if (snapshot.hasData) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        snapshot.data!.isi,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAqiCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: FutureBuilder<AqiData?>(
          future: _aqiFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: -50,
                      child: Lottie.asset(
                        'assets/aqi_loading.json',
                        height: 300,
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return _buildInfoCard(
                icon: Icons.cloud_off_outlined,
                text: "Gagal memuat data AQI.",
                color: Colors.red.shade100,
                iconColor: Colors.red.shade400,
              );
            }
            final aqiData = snapshot.data!;
            return _AqiInfoCard(aqiData: aqiData);
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherFeaturesTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
        child: Text(
          'Jelajahi Fitur Lainnya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.gamepad_outlined,
        'title': 'Tebak Kata',
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
        'subtitle': 'Baca data dari sensor perangkat',
        'page': const SensorPage(),
      },
      {
        'icon': Icons.explore,
        'title': 'Kompas',
        'subtitle': 'Temukan arah mata angin',
        'page': const KompasPage(),
      },
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final feature = features[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _FeatureListItem(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              subtitle: feature['subtitle'] as String,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => feature['page'] as Widget,
                  ),
                );
              },
            ),
          );
        }, childCount: features.length),
      ),
    );
  }

  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
        child: Text(
          'MADE BY ADE7',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
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
    if (aqi <= 150) return "Tidak Sehat (Sensitif)";
    if (aqi <= 200) return "Tidak Sehat";
    if (aqi <= 300) return "Sangat Tidak Sehat";
    return "Berbahaya";
  }

  @override
  Widget build(BuildContext context) {
    final aqiColor = _getAqiColor(aqiData.aqi);
    final aqiStatus = _getAqiStatus(aqiData.aqi);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          // ignore: deprecated_member_use
          colors: [aqiColor.withOpacity(0.7), aqiColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: aqiColor.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kualitas Udara Saat Ini',
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  aqiData.cityName.split(',').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    aqiStatus,
                    style: TextStyle(
                      color: Colors.white.withAlpha(240),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                aqiData.aqi.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 52,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "US AQI",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeatureListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 4,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}
