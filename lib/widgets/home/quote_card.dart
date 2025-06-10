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
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
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
}
