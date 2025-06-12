import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart' hide Marker;

// Import widget-widget yang sudah dipisah
import '../widgets/map/map_control_buttons.dart';
import '../widgets/map/place_info_panel.dart';
import '../widgets/map/religion_filter_chips.dart';
import '../widgets/map/map_search_bar.dart'; // <-- IMPORT WIDGET BARU

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
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

  final MapController _mapController = MapController();
  LocationData? _currentLocation;
  StreamSubscription<LocationData>? _locationSubscription;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final List<Map<String, dynamic>> _searchSuggestions = [];

  Map<String, dynamic>? _selectedPlace;

  @override
  void initState() {
    super.initState();
    _loadDataAndLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFilter();
    });
  }

  void _centerOnMyLocation() {
    if (_currentLocation != null) {
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        17.0,
      );
    }
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

    await location.changeSettings(accuracy: LocationAccuracy.high);

    final locationData = await location.getLocation();
    if (mounted) {
      setState(() {
        _currentLocation = locationData;
        _isLoading = false;
      });
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

  Future<void> _loadIbadahData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/tempat_ibadah.geojson',
      );
      final data = json.decode(response);

      if (mounted) {
        setState(() {
          _allFeatures = List<Map<String, dynamic>>.from(data['features']);
        });
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data lokasi: ${e.toString()}')),
        );
      }
    }
  }

  void _applyFilter() {
    _filteredMarkers.clear();
    _searchSuggestions.clear();
    final String lowerCaseSearchQuery = _searchQuery.toLowerCase();

    for (var feature in _allFeatures) {
      final properties = feature['properties'];
      if (properties == null) continue;

      final String name = properties['name'] ?? 'Tanpa Nama';
      final String rawAgama =
          (properties['religion'] ?? 'Lainnya').toString().trim().toLowerCase();
      final String normalizedAgama = _normalizeAgama(rawAgama);

      final bool matchesAgama =
          _selectedAgama.toLowerCase() == 'semua' ||
          normalizedAgama == _selectedAgama.toLowerCase();
      final bool matchesSearch =
          lowerCaseSearchQuery.isEmpty ||
          name.toLowerCase().contains(lowerCaseSearchQuery);

      if (lowerCaseSearchQuery.isNotEmpty &&
          name.toLowerCase().contains(lowerCaseSearchQuery)) {
        _searchSuggestions.add(feature);
      }

      if (matchesAgama && matchesSearch) {
        final geometry = feature['geometry'];
        if (geometry == null) continue;

        final List coordinates = geometry['coordinates'];
        final lat = coordinates[1];
        final lon = coordinates[0];

        _filteredMarkers.add(
          Marker(
            point: LatLng(lat, lon),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPlace = {'name': name, 'religion': normalizedAgama};
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _getMarkerColor(normalizedAgama),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((255 * 0.3).round()),
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
    setState(() {});
  }

  void _goToLocation(Map<String, dynamic> feature) {
    final geometry = feature['geometry'];
    if (geometry == null) return;
    final List coordinates = geometry['coordinates'];
    _mapController.move(LatLng(coordinates[1], coordinates[0]), 17.0);

    setState(() {
      _searchController.clear();
      _searchSuggestions.clear();
      _selectedPlace = {
        'name': feature['properties']['name'] ?? 'Tanpa Nama',
        'religion': _normalizeAgama(
          feature['properties']['religion'] ?? 'Lainnya',
        ),
      };
    });
  }

  String _normalizeAgama(String rawAgama) {
    if (rawAgama.contains('islam') || rawAgama.contains('muslim')) {
      return 'muslim';
    } else if (rawAgama.contains('christian') || rawAgama.contains('kristen')) {
      return 'christian';
    } else if (rawAgama.contains('hindu')) {
      return 'hindu';
    } else if (rawAgama.contains('buddhist') || rawAgama.contains('budha')) {
      return 'buddhist';
    } else if (rawAgama.contains('jewish') || rawAgama.contains('yahudi')) {
      return 'jewish';
    } else {
      return 'lainnya';
    }
  }

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

  Color _getMarkerColor(String agama) {
    switch (agama.toLowerCase()) {
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
      body:
          _isLoading
              ? Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset('assets/map_loading.json'),
                ),
              )
              : Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(-7.7956, 110.3695),
                      initialZoom: 12.0,
                      onTap: (_, __) {
                        if (_selectedPlace != null) {
                          setState(() {
                            _selectedPlace = null;
                          });
                        }
                      },
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
                  // Gunakan widget yang sudah dibuat
                  Column(
                    children: [
                      MapSearchBar(
                        searchController: _searchController,
                        searchQuery: _searchQuery,
                        searchSuggestions: _searchSuggestions,
                        onSuggestionTapped: _goToLocation,
                      ),
                      ReligionFilterChips(
                        agamaOptions: _agamaOptions,
                        selectedAgama: _selectedAgama,
                        onSelected: (agama) {
                          setState(() {
                            _selectedAgama = agama;
                            _applyFilter();
                          });
                        },
                      ),
                    ],
                  ),
                  PlaceInfoPanel(
                    selectedPlace: _selectedPlace,
                    onClose: () {
                      setState(() {
                        _selectedPlace = null;
                      });
                    },
                    getMarkerColor: _getMarkerColor,
                  ),
                  MapControlButtons(
                    mapController: _mapController,
                    onCenterOnMyLocation: _centerOnMyLocation,
                    isPlaceSelected: _selectedPlace != null,
                  ),
                ],
              ),
    );
  }
}
