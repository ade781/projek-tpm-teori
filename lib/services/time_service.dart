import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class TimezoneInfo {
  final String location;
  final String displayName;
  final String flag;
  TimezoneInfo({
    required this.location,
    required this.displayName,
    required this.flag,
  });
}

class TimeService {
  final List<TimezoneInfo> timezones = [
    TimezoneInfo(location: 'Asia/Jakarta', displayName: 'WIB', flag: '🇮🇩'),
    TimezoneInfo(location: 'Asia/Makassar', displayName: 'WITA', flag: '🇮🇩'),
    TimezoneInfo(location: 'Asia/Jayapura', displayName: 'WIT', flag: '🇮🇩'),
    TimezoneInfo(
      location: 'Europe/London',
      displayName: 'London',
      flag: '🇬🇧',
    ),

    TimezoneInfo(location: 'GMT', displayName: 'UTC / Greenwich', flag: '🌐'),
  ];

  tz.TZDateTime getCurrentTimeFor(String location) {
    return tz.TZDateTime.now(tz.getLocation(location));
  }

  String formatTime(tz.TZDateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  String formatDate(tz.TZDateTime time) {
    return DateFormat('EEEE, d MMMM yyyy').format(time);
  }

  String getUtcOffset(tz.TZDateTime time) {
    final offsetInHours = time.timeZoneOffset.inMilliseconds / (1000 * 60 * 60);

    if (offsetInHours == 0) {
      return 'UTC +0';
    }
    final sign = offsetInHours >= 0 ? '+' : '-';
    final hours = offsetInHours.abs().floor();
    return 'UTC $sign$hours';
  }
}
