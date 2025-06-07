// lib/models/aqi_model.dart

class AqiData {
  final int aqi;
  final String cityName;

  AqiData({required this.aqi, required this.cityName});

  factory AqiData.fromJson(Map<String, dynamic> json) {
    // Melakukan pengecekan untuk memastikan data tidak null
    final aqiValue =
        (json['data']?['aqi'] is int) ? json['data']['aqi'] as int : 0;

    final city =
        (json['data']?['city']?['name'] is String)
            ? json['data']['city']['name'] as String
            : 'Lokasi tidak diketahui';

    return AqiData(aqi: aqiValue, cityName: city);
  }
}
