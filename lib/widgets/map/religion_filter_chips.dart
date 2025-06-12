import 'dart:ui';
import 'package:flutter/material.dart';

class ReligionFilterChips extends StatelessWidget {
  final List<String> agamaOptions;
  final String selectedAgama;
  final Function(String) onSelected;

  const ReligionFilterChips({
    super.key,
    required this.agamaOptions,
    required this.selectedAgama,
    required this.onSelected,
  });

  IconData _getReligionIcon(String agama) {
    switch (agama.toLowerCase()) {
      case 'semua':
        return Icons.public;
      case 'muslim':
        return Icons.mosque;
      case 'christian':
        return Icons.church;
      case 'hindu':
        return Icons.temple_hindu;
      case 'buddhist':
        return Icons.temple_buddhist;
      case 'jewish':
        return Icons.synagogue;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: agamaOptions.length,
        itemBuilder: (context, index) {
          final agama = agamaOptions[index];
          final isSelected = selectedAgama == agama;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => onSelected(agama),
              borderRadius: BorderRadius.circular(25),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        isSelected
                            ? [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColorDark,
                            ]
                            : [
                              Colors.white.withOpacity(0.6),
                              Colors.white.withOpacity(0.8),
                            ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.3),
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getReligionIcon(agama),
                      size: 20,
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.black.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      agama,
                      style: TextStyle(
                        color:
                            isSelected
                                ? Colors.white
                                : Colors.black.withOpacity(0.8),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
