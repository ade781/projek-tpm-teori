import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:projek_akhir_teori/models/aqi_model.dart';
import 'package:projek_akhir_teori/widgets/common/info_card.dart';

// The main wrapper widget, which handles the FutureBuilder logic.
class AqiCard extends StatelessWidget {
  final Future<AqiData?> aqiFuture;

  const AqiCard({super.key, required this.aqiFuture});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: FutureBuilder<AqiData?>(
          future: aqiFuture,
          builder: (context, snapshot) {
            // While waiting for data, show a Lottie loading animation.
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
            // If there's an error or no data, show a generic info card.
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const InfoCard(
                icon: Icons.cloud_off_outlined,
                text: "Gagal memuat data AQI.",
                color: Color.fromRGBO(255, 235, 238, 1),
                iconColor: Color.fromRGBO(229, 62, 62, 1),
              );
            }
            // Once data is available, display the animated AQI card.
            final aqiData = snapshot.data!;
            return _AqiInfoCardAnimated(aqiData: aqiData);
          },
        ),
      ),
    );
  }
}

// This is a StatefulWidget to manage the number animation.
class _AqiInfoCardAnimated extends StatefulWidget {
  final AqiData aqiData;
  const _AqiInfoCardAnimated({required this.aqiData});

  @override
  State<_AqiInfoCardAnimated> createState() => _AqiInfoCardAnimatedState();
}

class _AqiInfoCardAnimatedState extends State<_AqiInfoCardAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _numberController;
  late Animation<int> _numberAnimation;

  @override
  void initState() {
    super.initState();
    // --- Initialize Controller ---
    // Controller for the number count-up animation.
    _numberController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // --- Define Animation ---
    // Animate the number from 0 to the target AQI value.
    _numberAnimation = IntTween(begin: 0, end: widget.aqiData.aqi).animate(
      CurvedAnimation(parent: _numberController, curve: Curves.easeOut),
    );

    // --- Start Animation ---
    _numberController.forward();
  }

  @override
  void dispose() {
    // Always dispose of controllers to prevent memory leaks.
    _numberController.dispose();
    super.dispose();
  }

  // --- Helper Methods for AQI Visuals ---
  Color _getAqiColor(int aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return Colors.yellow.shade600;
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
    final aqiColor = _getAqiColor(widget.aqiData.aqi);
    final aqiStatus = _getAqiStatus(widget.aqiData.aqi);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [aqiColor.withOpacity(0.7), aqiColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
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
                const Text(
                  'Kualitas Udara Saat Ini',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        blurRadius: 1.0,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.aqiData.cityName.split(',').first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [
                      Shadow(
                        blurRadius: 1.0,
                        color: Colors.black26,
                        offset: Offset(1, 1),
                      ),
                    ],
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
          // AnimatedBuilder rebuilds only the Text widget for the number animation.
          AnimatedBuilder(
            animation: _numberAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    _numberAnimation.value.toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Colors.white,
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2.0,
                          color: Colors.black38,
                          offset: Offset(2, 2),
                        ),
                      ],
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
              );
            },
          ),
        ],
      ),
    );
  }
}
