import 'package:flutter/material.dart';

class ConvertButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const ConvertButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon:
            isLoading
                ? Container()
                : const Icon(Icons.currency_exchange, size: 20),
        label:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
                : const Text(
                  'Konversi Sekarang',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
        ),
      ),
    );
  }
}
