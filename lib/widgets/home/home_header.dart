import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatefulWidget {
  final String? username;

  const HomeHeader({super.key, required this.username});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  // All AnimationControllers and related Animations have been removed

  @override
  void initState() {
    super.initState();
    // Animation-related initializations have been removed
  }

  @override
  void dispose() {
    // Animation-related disposals have been removed
    super.dispose();
  }

  Widget _buildSimpleText() {
    final greeting = 'Halo, ${widget.username ?? 'Pengguna'}!';
    return FittedBox(
      // Retain FittedBox to prevent overflow for long text
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        greeting,
        style: TextStyle(
          // Add subtle styling
          fontSize: 22,
          fontWeight: FontWeight.bold, // Bolder text
          color:
              Theme.of(context).colorScheme.primary, // Use primary theme color
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure locale is set for DateFormat
    Intl.defaultLocale = 'id_ID';
    final String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy', // Corrected date format pattern (e.g., Kamis, 13 Juni 2025)
    ).format(DateTime.now());

    return SliverAppBar(
      backgroundColor:
          Colors.transparent, // Transparent background for gradient below
      expandedHeight: 120,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSimpleText(), // Use simplified text widget
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700, // Dark grey color for date text
              ),
            ),
          ],
        ),
        background: Container(
          // Add a subtle radial gradient
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-1.0, -1.0),
              colors: [
                Theme.of(
                  context,
                ).colorScheme.primary.withAlpha(25), // Approx 0.1 opacity
                Colors.transparent,
              ],
              radius: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
