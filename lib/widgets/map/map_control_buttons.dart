import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapControlButtons extends StatelessWidget {
  final MapController mapController;
  final VoidCallback onCenterOnMyLocation;
  final bool isPlaceSelected;

  const MapControlButtons({
    super.key,
    required this.mapController,
    required this.onCenterOnMyLocation,
    required this.isPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: isPlaceSelected ? 120 : 20,
      right: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  context: context,
                  icon: Icons.my_location,
                  onPressed: onCenterOnMyLocation,
                  isTop: true,
                ),
                _buildControlButton(
                  context: context,
                  icon: Icons.add,
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    );
                  },
                ),
                _buildControlButton(
                  context: context,
                  icon: Icons.remove,
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                  isBottom: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border:
                isBottom
                    ? null
                    : Border(
                      bottom: BorderSide(color: Colors.black.withOpacity(0.1)),
                    ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColorDark.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}
