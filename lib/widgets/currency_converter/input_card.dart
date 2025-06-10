import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  final TextEditingController amountController;
  final String baseCurrency;
  final List<String> currencies;
  final ValueChanged<String?> onCurrencyChanged;

  const InputCard({
    super.key,
    required this.amountController,
    required this.baseCurrency,
    required this.currencies,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
              decoration: const InputDecoration(
                hintText: '0.00',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: baseCurrency,
                items:
                    currencies.map((String currency) {
                      return DropdownMenuItem<String>(
                        value: currency,
                        child: Text(
                          currency,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      );
                    }).toList(),
                onChanged: onCurrencyChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
