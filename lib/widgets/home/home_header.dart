import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeHeader extends StatefulWidget {
  final String? username;

  const HomeHeader({super.key, required this.username});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> with TickerProviderStateMixin {
  late AnimationController _staggeredTextController;
  late AnimationController _backgroundController;
  late List<Animation<double>> _fadeAnimations = [];
  late List<Animation<Offset>> _slideAnimations = [];
  late Animation<double> _dateFadeAnimation;

  @override
  void initState() {
    super.initState();

    final greeting = 'Halo, ${widget.username ?? 'Pengguna'}!';
    final greetingDuration = Duration(milliseconds: 50 * greeting.length);
    final totalDuration = Duration(
      milliseconds: greetingDuration.inMilliseconds + 500,
    );

    // Controller for the staggered text animation
    _staggeredTextController = AnimationController(
      vsync: this,
      duration: totalDuration,
    );

    // Controller for the background gradient pulse
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    // Create staggered animations for each character
    for (int i = 0; i < greeting.length; i++) {
      final double start = (i * 50) / totalDuration.inMilliseconds;
      final double end = start + (400 / totalDuration.inMilliseconds);

      _fadeAnimations.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _staggeredTextController,
            curve: Interval(start, end, curve: Curves.easeIn),
          ),
        ),
      );

      _slideAnimations.add(
        Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _staggeredTextController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }

    // Animation for the date, starts after the greeting is mostly done
    _dateFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredTextController,
        curve: Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    _staggeredTextController.forward();
  }

  @override
  void dispose() {
    _staggeredTextController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText() {
    final greeting = 'Halo, ${widget.username ?? 'Pengguna'}!';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(greeting.length, (index) {
        return AnimatedBuilder(
          animation: _staggeredTextController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimations[index],
              child: SlideTransition(
                position: _slideAnimations[index],
                child: child,
              ),
            );
          },
          child: Text(
            greeting[index],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              shadows: [
                Shadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            _buildAnimatedText(),
            const SizedBox(height: 2),
            FadeTransition(
              opacity: _dateFadeAnimation,
              child: Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        background: AnimatedBuilder(
          animation: _backgroundController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-1.0, -1.0),
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  radius: 1.5 + (_backgroundController.value * 0.5),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
