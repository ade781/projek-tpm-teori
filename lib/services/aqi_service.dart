import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:projek_akhir_teori/models/aqi_model.dart';

class AqiService {
  final String? _apiKey = dotenv.env['AQI_API_KEY'];

  Future<AqiData?> getAqiForCurrentLocation() async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception("AQI API Key tidak ditemukan di .env");
    }

    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception("Layanan lokasi tidak diaktifkan.");
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
      
        throw Exception("Izin lokasi ditolak.");
      }
    }

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lon = locationData.longitude;

    if (lat == null || lon == null) {
      throw Exception("Gagal mendapatkan koordinat lokasi.");
    }

   
    final url = Uri.parse(
      'https://api.waqi.info/feed/geo:$lat;$lon/?token=$_apiKey',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'ok') {
          return AqiData.fromJson(data);
        } else {
          throw Exception('Gagal mendapatkan data AQI: ${data['data']}');
        }
      } else {
        throw Exception(
          'Gagal terhubung ke server AQI. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat mengambil data AQI: $e');
    }
  }
}
