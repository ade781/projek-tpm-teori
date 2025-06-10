import 'package:flutter/material.dart';
import 'package:projek_akhir_teori/pages/currency_converter_page.dart';
import 'package:projek_akhir_teori/pages/game_page.dart';
import 'package:projek_akhir_teori/pages/kompas_page.dart';
import 'package:projek_akhir_teori/pages/map_page.dart';
import 'package:projek_akhir_teori/pages/sensor_page.dart';
import 'package:projek_akhir_teori/pages/world_clock_page.dart';

// The main widget is now a StatefulWidget to handle animations.
class FeatureList extends StatefulWidget {
  const FeatureList({super.key});

  @override
  State<FeatureList> createState() => _FeatureListState();
}

class _FeatureListState extends State<FeatureList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500 * features.length),
    );

    _fadeAnimations = [];
    _slideAnimations = [];

    // Create staggered animations for each feature item.
    for (int i = 0; i < features.length; i++) {
      final double begin = i * (1.0 / features.length);
      final double end = (i + 1) * (1.0 / features.length);

      // Fade animation
      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(begin, end, curve: Curves.easeIn),
          ),
        ),
      );

      // Slide animation (from bottom to top)
      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(begin, end, curve: Curves.easeOut),
          ),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final feature = features[index];
          // Wrap each item with its corresponding animation.
          return FadeTransition(
            opacity: _fadeAnimations[index],
            child: SlideTransition(
              position: _slideAnimations[index],
              child: Padding(
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
              ),
            ),
          );
        }, childCount: features.length),
      ),
    );
  }
}

// The individual list item with enhanced styling.
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.deepPurple.withOpacity(0.1),
        highlightColor: Colors.deepPurple.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      Theme.of(context).colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
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
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
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
      ),
    );
  }
}
