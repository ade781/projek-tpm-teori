import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultsSection extends StatelessWidget {
  final bool isLoading;
  final Map<String, double> convertedAmounts;
  final List<Animation<double>> animations;

  const ResultsSection({
    super.key,
    required this.isLoading,
    required this.convertedAmounts,
    required this.animations,
  });

  @override
  Widget build(BuildContext context) {
    if (convertedAmounts.isEmpty && !isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(Icons.all_out_sharp, size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'Hasil konversi akan muncul di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (convertedAmounts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Nilai dalam Mata Uang Lain',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(
                  204,
                ), // FIX: Replaced deprecated withOpacity
              ),
            ),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: convertedAmounts.length,
          itemBuilder: (context, index) {
            final entry = convertedAmounts.entries.elementAt(index);
            // Check if animations list is long enough
            if (animations.length <= index) {
              return _ResultItem(currency: entry.key, amount: entry.value);
            }
            return FadeTransition(
              opacity: animations[index],
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(animations[index]),
                child: _ResultItem(currency: entry.key, amount: entry.value),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String currency;
  final double amount;

  const _ResultItem({required this.currency, required this.amount});

  @override
  Widget build(BuildContext context) {
    // FIX: This variable is now correctly used, resolving the 'unused' warning.
    final numberFormat = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 2,
    );
    final currencyFullName = {
      'IDR': 'Rupiah Indonesia',
      'SAR': 'Rial Arab Saudi',
      'USD': 'Dolar Amerika',
      'EUR': 'Euro',
      'JPY': 'Yen Jepang',
      'GBP': 'Pound Inggris',
      'AUD': 'Dolar Australia',
      'SGD': 'Dolar Singapura',
      'MGA': 'Ariary Madagaskar',
      'CAD': 'Dolar Kanada',
      'CHF': 'Franc Swiss',
      'CNY': 'Yuan Tiongkok',
      'NZD': 'Dolar Selandia Baru',
      'INR': 'Rupee India',
      'BRL': 'Real Brasil',
      'RUB': 'Rubel Rusia',
      'KRW': 'Won Korea Selatan',
      'TRY': 'Lira Turki',
    };
    final currencyFlags = {
      'IDR': '🇮🇩',
      'SAR': '🇸🇦',
       'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'JPY': '🇯🇵',
      'GBP': '🇬🇧',
      'AUD': '🇦🇺',
      'SGD': '🇸🇬',
      'MGA': '🇲🇬',
      'CAD': '🇨🇦',
      'CHF': '🇨🇭',
      'CNY': '🇨🇳',
      'NZD': '🇳🇿',
      'INR': '🇮🇳',
      'BRL': '🇧🇷',
      'RUB': '🇷🇺',
      'KRW': '🇰🇷',
      'TRY': '🇹🇷',
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              currencyFlags[currency] ?? '🏳️',
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currency,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    currencyFullName[currency] ?? '',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // FIX: The Flexible/SingleChildScrollView structure resolves the syntax error.
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  numberFormat.format(amount),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
