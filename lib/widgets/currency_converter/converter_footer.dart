import 'package:flutter/material.dart';

class ConverterFooter extends StatelessWidget {
  final String lastUpdated;
  const ConverterFooter({super.key, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Center(
        child: Column(
          children: [
            Text(
              'Data disediakan oleh ExchangeRate-API.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Terakhir diperbarui: $lastUpdated WIB',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            const Text(
              'MADE BY ADE7',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
