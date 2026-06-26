import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:adeen/features/dashboard/domain/prayer_models.dart';
import 'package:adeen/core/database/database_service.dart';

class AlAdhanService {
  final http.Client _client;
  AlAdhanService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches prayer times for a specific date and GPS coordinates.
  /// Format of date: 'dd-MM-yyyy' (e.g. '25-06-2026')
  Future<PrayerTimes> fetchPrayerTimes({
    required String date,
    required double latitude,
    required double longitude,
    required int method,
  }) async {
    final box = DatabaseService.getBox(DatabaseService.prayerBoxName);
    
    // Create a unique key for this date, coordinates, and calculation method
    // Rounded to 2 decimal places to utilize cache when minor location updates occur
    final latRounded = double.parse(latitude.toStringAsFixed(2));
    final lngRounded = double.parse(longitude.toStringAsFixed(2));
    final cacheKey = '${date}_${latRounded}_${lngRounded}_$method';

    // 1. Try reading from local Hive Cache
    if (box.containsKey(cacheKey)) {
      final cachedData = box.get(cacheKey);
      if (cachedData is Map) {
        try {
          return PrayerTimes.fromJson(cachedData);
        } catch (e) {
          // If decoding failed, clear and fetch from API
          await box.delete(cacheKey);
        }
      }
    }

    // 2. Query Remote AlAdhan API
    final url = Uri.parse(
      'https://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=$method',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200 && decoded['data'] != null) {
          final timings = decoded['data']['timings'] as Map<String, dynamic>;
          
          final prayerTimes = PrayerTimes(
            date: date,
            fajr: timings['Fajr'] as String? ?? '04:30',
            sunrise: timings['Sunrise'] as String? ?? '06:00',
            dhuhr: timings['Dhuhr'] as String? ?? '12:30',
            asr: timings['Asr'] as String? ?? '15:45',
            maghrib: timings['Maghrib'] as String? ?? '18:50',
            isha: timings['Isha'] as String? ?? '20:15',
            imsak: timings['Imsak'] as String? ?? '04:20',
            method: _getMethodName(method),
          );

          // Save to Hive Cache
          await box.put(cacheKey, prayerTimes.toJson());
          return prayerTimes;
        }
      }
      throw Exception('API Server returned invalid response');
    } catch (e) {
      // 3. Fallback on network failure
      // First try to return cached timings for this date that match the requested calculation method
      for (var key in box.keys) {
        final keyStr = key.toString();
        if (keyStr.startsWith(date) && keyStr.endsWith('_$method')) {
          final cachedData = box.get(key);
          if (cachedData is Map) {
            return PrayerTimes.fromJson(cachedData);
          }
        }
      }

      // If no cache for this date exists, fall back to Mecca timings calculated statically
      return _generateMeccaFallback(date, method);
    }
  }

  String _getMethodName(int methodId) {
    switch (methodId) {
      case 1: return 'University of Islamic Sciences, Karachi';
      case 2: return 'Islamic Society of North America (ISNA)';
      case 3: return 'Muslim World League (MWL)';
      case 4: return 'Umm Al-Qura University, Makkah';
      case 5: return 'Egyptian General Authority of Survey';
      case 8: return 'Gulf Region';
      case 9: return 'Kuwait';
      case 10: return 'Qatar';
      case 11: return 'MUIS, Singapore';
      case 12: return 'UOIF, France';
      case 13: return 'Diyanet, Turkey';
      case 14: return 'Russia';
      default: return 'Umm Al-Qura University, Makkah';
    }
  }

  PrayerTimes _generateMeccaFallback(String date, int method) {
    // Statically return logical times for Mecca (lat 21.4225, lng 39.8262) for the given date
    // These are standard fallback timings so the user has offline-ready placeholders
    return PrayerTimes(
      date: date,
      fajr: '04:15',
      sunrise: '05:38',
      dhuhr: '12:22',
      asr: '15:40',
      maghrib: '19:04',
      isha: '20:34',
      imsak: '04:05',
      method: '${_getMethodName(method)} (Offline Fallback)',
    );
  }
}
