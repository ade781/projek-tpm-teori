import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:projek_akhir_teori/models/quote_model.dart';
import 'package:projek_akhir_teori/widgets/common/info_card.dart';

class QuoteCard extends StatelessWidget {
  final Future<QuoteModel> quoteFuture;

  const QuoteCard({super.key, required this.quoteFuture});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: FutureBuilder<QuoteModel>(
          future: quoteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Container(
                height: 80,
                alignment: Alignment.center,
                child: Lottie.asset('assets/quote_loading3.json', height: 80),
              );
            }
            if (snapshot.hasError) {
              return const InfoCard(
                icon: Icons.error_outline,
                text: "Gagal memuat hikmah.",
                color: Color.fromRGBO(255, 235, 238, 1),
                iconColor: Color.fromRGBO(229, 62, 62, 1),
              );
            }
            if (snapshot.hasData) {
              // Add a Key to force re-creation of the state when the quote changes.
              return _AnimatedQuoteContent(
                key: ValueKey(snapshot.data!.isi),
                quote: snapshot.data!,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _AnimatedQuoteContent extends StatefulWidget {
  final QuoteModel quote;

  const _AnimatedQuoteContent({super.key, required this.quote});

  @override
  State<_AnimatedQuoteContent> createState() => _AnimatedQuoteContentState();
}

class _AnimatedQuoteContentState extends State<_AnimatedQuoteContent>
    with TickerProviderStateMixin {
  late AnimationController _typingController;
  late AnimationController _entryController;
  late AnimationController _iconPulseController;

  late Animation<int> _typingAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _iconPulseAnimation;

  @override
  void initState() {
    super.initState();
    // Controller for the typing effect
    _typingController = AnimationController(
      duration: Duration(milliseconds: 30 * widget.quote.isi.length),
      vsync: this,
    );

    // Controller for the card entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Controller for the pulsing icon animation
    _iconPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Typing animation from 0 to the full length of the quote string
    _typingAnimation = IntTween(
      begin: 0,
      end: widget.quote.isi.length,
    ).animate(CurvedAnimation(parent: _typingController, curve: Curves.linear));

    // Entry animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_entryController);
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    // Icon pulse animation
    _iconPulseAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(_iconPulseController);

    // Start the animations
    _entryController.forward().whenComplete(() => _typingController.forward());
  }

  @override
  void dispose() {
    _typingController.dispose();
    _entryController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.deepPurple.withOpacity(0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated icon
              FadeTransition(
                opacity: _iconPulseAnimation,
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Animated text
              Expanded(
                child: AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    final visibleText = widget.quote.isi.substring(
                      0,
                      _typingAnimation.value,
                    );
                    return Text(
                      visibleText,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade800,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
