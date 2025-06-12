import 'package:flutter/material.dart';

class HeadingReadout extends StatelessWidget {
  final double? heading;

  const HeadingReadout({super.key, this.heading});

  String _getDirectionString(double heading) {
    heading = (heading % 360 + 360) % 360;

    if (heading >= 0 && heading < 22.5 || heading >= 337.5 && heading < 360) {
      return 'Utara (N)';
    }
    if (heading >= 22.5 && heading < 67.5) return 'Timur Laut (NE)';
    if (heading >= 67.5 && heading < 112.5) return 'Timur (E)';
    if (heading >= 112.5 && heading < 157.5) return 'Tenggara (SE)';
    if (heading >= 157.5 && heading < 202.5) return 'Selatan (S)';
    if (heading >= 202.5 && heading < 247.5) return 'Barat Daya (SW)';
    if (heading >= 247.5 && heading < 292.5) return 'Barat (W)';
    if (heading >= 292.5 && heading < 337.5) return 'Barat Laut (NW)';
    return 'Tidak diketahui';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          heading != null ? '${heading!.toStringAsFixed(1)}°' : 'N/A',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          heading != null ? _getDirectionString(heading!) : '',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white.withAlpha((0.8 * 255).round()),
          ),
        ),
      ],
    );
  }
}
