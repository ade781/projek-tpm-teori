import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // State untuk data dan UI
  bool _isLoading = true;
  List<Map<String, dynamic>> _allFeatures = [];
  final List<Marker> _filteredMarkers = [];

  // --- PERUBAHAN 1: Menggunakan nilai baru untuk filter ---
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

  @override
  void initState() {
    super.initState();
    _loadIbadahData();
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

      // Mengambil nilai agama dari JSON dan mengubahnya ke huruf kecil untuk perbandingan
      final String agamaFromJson =
          (properties['agama'] ?? 'Lainnya').toString().toLowerCase();

      // Membandingkan dengan nilai filter yang juga diubah ke huruf kecil
      if (_selectedAgama == 'Semua' ||
          agamaFromJson == _selectedAgama.toLowerCase()) {
        final geometry = feature['geometry'];
        if (geometry == null) continue;

        final String name = properties['name'] ?? 'Tanpa Nama';
        final List coordinates = geometry['coordinates'];
        final lat = coordinates[1];
        final lon = coordinates[0];

        _filteredMarkers.add(
          Marker(
            point: LatLng(lat, lon),
            child: IconButton(
              icon: Icon(
                Icons.location_on,
                color: _getMarkerColor(agamaFromJson),
                size: 40,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(name),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        );
      }
    }
    setState(() {});
  }

  // --- PERUBAHAN 2: Menyesuaikan warna marker dengan nilai baru ---
  Color _getMarkerColor(String agama) {
    switch (agama.toLowerCase()) {
      case 'muslim':
        return Colors.green;
      case 'christian':
        return Colors.blue;
      case 'hindu':
        return Colors.orange;
      case 'buddhist':
        return Colors.amber;
      case 'jewish':
        return Colors.deepPurple;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Tempat Ibadah DIY'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(-7.7956, 110.3695),
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: _filteredMarkers),
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
                              // Menggunakan nilai dari _agamaOptions untuk UI
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
                                      });
                                      _applyFilter();
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
