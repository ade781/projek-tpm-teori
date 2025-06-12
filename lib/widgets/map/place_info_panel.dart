import 'dart:ui';
import 'package:flutter/material.dart';

class PlaceInfoPanel extends StatelessWidget {
  final Map<String, dynamic>? selectedPlace;
  final Function() onClose;
  final Color Function(String) getMarkerColor;

  const PlaceInfoPanel({
    super.key,
    required this.selectedPlace,
    required this.onClose,
    required this.getMarkerColor,
  });

  String _getMarkerEmoji(String agama) {
    switch (agama.toLowerCase()) {
      case 'muslim':
        return '🕌';
      case 'christian':
        return '⛪';
      case 'hindu':
        return '🛕';
      case 'buddhist':
        return '☸️';
      case 'jewish':
        return '✡️';
      default:
        return '📍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isVisible = selectedPlace != null;
    final Color panelColor =
        isVisible
            ? getMarkerColor(selectedPlace!['religion'])
            : Colors.transparent;

    return Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isVisible ? 1.0 : 0.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isVisible ? 100.0 : 0.0,
          margin: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  gradient: LinearGradient(
                    colors: [
                      panelColor.withOpacity(0.7),
                      panelColor.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child:
                    !isVisible
                        ? const SizedBox.shrink()
                        : Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getMarkerEmoji(selectedPlace!['religion']),
                                style: const TextStyle(fontSize: 32.0),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedPlace!['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 2,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Agama: ${(selectedPlace!['religion'] as String)[0].toUpperCase()}${(selectedPlace!['religion'] as String).substring(1)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: onClose,
                                borderRadius: BorderRadius.circular(15),
                                child: const CircleAvatar(
                                  backgroundColor: Colors.black26,
                                  radius: 15,
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
