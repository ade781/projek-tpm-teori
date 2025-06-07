import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // State untuk peta dan data
  bool _isLoading = true;
  List<Map<String, dynamic>> _allFeatures = [];
  final List<Marker> _filteredMarkers = [];
  String _selectedAgama = 'Semua';
  final List<String> _agamaOptions = const [
    'Semua',
    'Muslim',
    'Christian',
    'Hindu',
    'Buddhist',
    'Jewish',
    'Lainnya',
  ];

  // State untuk fitur lokasi
  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadDataAndLocation();
  }

  Future<void> _loadDataAndLocation() async {
    await _loadIbadahData();
    await _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // --- PERBAIKAN: MINTA AKURASI TINGGI ---
    // Baris ini meminta perangkat untuk memprioritaskan GPS untuk akurasi terbaik.
    await location.changeSettings(accuracy: LocationAccuracy.high);

    final locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        _currentLocation = locationData;
      });
      // Setelah lokasi pertama didapat, langsung pusatkan peta ke sana
      _centerOnMyLocation();
    }

    _locationSubscription = location.onLocationChanged.listen((newLocation) {
      if (mounted) {
        setState(() {
          _currentLocation = newLocation;
        });
      }
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _centerOnMyLocation() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        17.0,
      );
    }
  }

  Future<void> _loadIbadahData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/tempat_ibadah.geojson',
      );
      final data = json.decode(response);

      if (mounted) {
        setState(() {
          _allFeatures = List<Map<String, dynamic>>.from(data['features']);
          _isLoading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      final errorMessage = 'Gagal memuat data lokasi. Error: ${e.toString()}';
      print(errorMessage);
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
  }

  void _applyFilter() {
    _filteredMarkers.clear();

    for (var feature in _allFeatures) {
      final properties = feature['properties'];
      if (properties == null) continue;

      final String rawAgama =
          (properties['religion'] ?? 'Lainnya').toString().trim().toLowerCase();

      String normalizedAgama;
      if (rawAgama.contains('islam') || rawAgama.contains('muslim')) {
        normalizedAgama = 'muslim';
      } else if (rawAgama.contains('christian') ||
          rawAgama.contains('kristen')) {
        normalizedAgama = 'christian';
      } else if (rawAgama.contains('hindu')) {
        normalizedAgama = 'hindu';
      } else if (rawAgama.contains('buddhist') || rawAgama.contains('budha')) {
        normalizedAgama = 'buddhist';
      } else if (rawAgama.contains('jewish') || rawAgama.contains('yahudi')) {
        normalizedAgama = 'jewish';
      } else {
        normalizedAgama = 'lainnya';
      }

      if (_selectedAgama.toLowerCase() == 'semua' ||
          normalizedAgama == _selectedAgama.toLowerCase()) {
        final geometry = feature['geometry'];
        if (geometry == null) continue;

        final String name = properties['name'] ?? 'Tanpa Nama';
        final List coordinates = geometry['coordinates'];
        final lat = coordinates[1];
        final lon = coordinates[0];

        _filteredMarkers.add(
          Marker(
            point: LatLng(lat, lon),
            width: 20, // Menggunakan ukuran yang Anda catat
            height: 20, // Menggunakan ukuran yang Anda catat
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(name),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _getMarkerColor(normalizedAgama),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getMarkerEmoji(normalizedAgama),
                    style: const TextStyle(fontSize: 24.0),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  String _getMarkerEmoji(String agama) {
    switch (agama) {
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

  Color _getMarkerColor(String agama) {
    switch (agama) {
      case 'muslim':
        return Colors.green.shade400;
      case 'christian':
        return Colors.blue.shade400;
      case 'hindu':
        return Colors.orange.shade400;
      case 'buddhist':
        return Colors.amber.shade400;
      case 'jewish':
        return Colors.deepPurple.shade300;
      default:
        return Colors.red.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Tempat Ibadah DIY'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnMyLocation,
        child: const Icon(Icons.my_location),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: LatLng(-7.7956, 110.3695),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          ..._filteredMarkers,
                          if (_currentLocation != null)
                            Marker(
                              point: LatLng(
                                _currentLocation!.latitude!,
                                _currentLocation!.longitude!,
                              ),
                              child: Icon(
                                Icons.person_pin_circle,
                                color: Colors.blue.shade600,
                                size: 40,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        children:
                            _agamaOptions.map((agama) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(agama),
                                  selected: _selectedAgama == agama,
                                  onSelected: (isSelected) {
                                    if (isSelected) {
                                      setState(() {
                                        _selectedAgama = agama;
                                        _applyFilter();
                                      });
                                    }
                                  },
                                  selectedColor: Theme.of(context).primaryColor,
                                  labelStyle: TextStyle(
                                    color:
                                        _selectedAgama == agama
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
