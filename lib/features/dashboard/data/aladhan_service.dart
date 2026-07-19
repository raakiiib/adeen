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
    int school = 0,
  }) async {
    final box = DatabaseService.getBox(DatabaseService.prayerBoxName);
    
    // Create a unique key for this date, coordinates, calculation method and school
    // Rounded to 2 decimal places to utilize cache when minor location updates occur
    final latRounded = double.parse(latitude.toStringAsFixed(2));
    final lngRounded = double.parse(longitude.toStringAsFixed(2));
    final cacheKey = '${date}_${latRounded}_${lngRounded}_${method}_$school';

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
      'https://api.aladhan.com/v1/timings/$date?latitude=$latitude&longitude=$longitude&method=$method&school=$school',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200 && decoded['data'] != null) {
          final timings = decoded['data']['timings'] as Map<String, dynamic>;
          final dateInfo = decoded['data']['date'] as Map<String, dynamic>?;
          String hijriStr = '';
          if (dateInfo != null && dateInfo['hijri'] != null) {
            final hijri = dateInfo['hijri'] as Map<String, dynamic>;
            final day = hijri['day'] as String? ?? '';
            final monthEn = hijri['month']?['en'] as String? ?? '';
            final year = hijri['year'] as String? ?? '';
            hijriStr = '$day $monthEn $year';
          }
          
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
            hijriDate: hijriStr,
          );

          // Save to Hive Cache
          await box.put(cacheKey, prayerTimes.toJson());
          return prayerTimes;
        }
      }
      throw Exception('API Server returned invalid response');
    } catch (e) {
      // 3. Fallback on network failure
      // First try to return cached timings for this date that match the requested calculation method and school
      for (var key in box.keys) {
        final keyStr = key.toString();
        if (keyStr.startsWith(date) && keyStr.endsWith('_${method}_$school')) {
          final cachedData = box.get(key);
          if (cachedData is Map) {
            return PrayerTimes.fromJson(cachedData);
          }
        }
      }

      // If no cache for this date exists, fall back to Mecca timings calculated statically
      return _generateMeccaFallback(date, method, school);
    }
  }

  /// Fetches prayer times for an entire month, utilizing local cache if all days exist.
  Future<List<PrayerTimes>> fetchMonthlyCalendar({
    required int year,
    required int month,
    required double latitude,
    required double longitude,
    required int method,
    required int school,
  }) async {
    final box = DatabaseService.getBox(DatabaseService.prayerBoxName);
    final latRounded = double.parse(latitude.toStringAsFixed(2));
    final lngRounded = double.parse(longitude.toStringAsFixed(2));

    // Calculate number of days in this month
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final List<PrayerTimes> list = [];
    bool allCached = true;

    // 1. Try reading all days from local Hive Cache
    for (int day = 1; day <= daysInMonth; day++) {
      final dateStr = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
      final cacheKey = '${dateStr}_${latRounded}_${lngRounded}_${method}_$school';
      if (!box.containsKey(cacheKey)) {
        allCached = false;
        break;
      }
    }

    if (allCached) {
      for (int day = 1; day <= daysInMonth; day++) {
        final dateStr = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
        final cacheKey = '${dateStr}_${latRounded}_${lngRounded}_${method}_$school';
        final cachedData = box.get(cacheKey);
        if (cachedData is Map) {
          list.add(PrayerTimes.fromJson(cachedData));
        }
      }
      return list;
    }

    // 2. Query Remote AlAdhan Calendar API
    final url = Uri.parse(
      'https://api.aladhan.com/v1/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=$method&school=$school',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200 && decoded['data'] != null && decoded['data'] is List) {
          final dataList = decoded['data'] as List;
          final List<PrayerTimes> fetchedList = [];

          for (final dayData in dataList) {
            final timings = dayData['timings'] as Map<String, dynamic>;
            final dateInfo = dayData['date'] as Map<String, dynamic>?;
            final String dateStr = dateInfo?['gregorian']?['date'] as String? ?? '';
            
            String hijriStr = '';
            if (dateInfo != null && dateInfo['hijri'] != null) {
              final hijri = dateInfo['hijri'] as Map<String, dynamic>;
              final day = hijri['day'] as String? ?? '';
              final monthEn = hijri['month']?['en'] as String? ?? '';
              final hijriYear = hijri['year'] as String? ?? '';
              hijriStr = '$day $monthEn $hijriYear';
            }

            final prayerTimes = PrayerTimes(
              date: dateStr,
              fajr: timings['Fajr'] as String? ?? '04:30',
              sunrise: timings['Sunrise'] as String? ?? '06:00',
              dhuhr: timings['Dhuhr'] as String? ?? '12:30',
              asr: timings['Asr'] as String? ?? '15:45',
              maghrib: timings['Maghrib'] as String? ?? '18:50',
              isha: timings['Isha'] as String? ?? '20:15',
              imsak: timings['Imsak'] as String? ?? '04:20',
              method: _getMethodName(method),
              hijriDate: hijriStr,
            );

            // Cache in Hive
            final cacheKey = '${dateStr}_${latRounded}_${lngRounded}_${method}_$school';
            await box.put(cacheKey, prayerTimes.toJson());
            fetchedList.add(prayerTimes);
          }
          return fetchedList;
        }
      }
      throw Exception('API Server returned invalid response');
    } catch (e) {
      // 3. Fallback on network failure
      final List<PrayerTimes> fallbackList = [];
      for (int day = 1; day <= daysInMonth; day++) {
        final dateStr = '${day.toString().padLeft(2, '0')}-${month.toString().padLeft(2, '0')}-$year';
        final cacheKey = '${dateStr}_${latRounded}_${lngRounded}_${method}_$school';
        final cachedData = box.get(cacheKey);
        if (cachedData is Map) {
          fallbackList.add(PrayerTimes.fromJson(cachedData));
        } else {
          fallbackList.add(_generateMeccaFallback(dateStr, method, school));
        }
      }
      return fallbackList;
    }
  }


  Future<List<PrayerTimes>> fetchHijriCalendar({
    required int hijriYear,
    required int hijriMonth,
    required double latitude,
    required double longitude,
    required int method,
    required int school,
  }) async {
    final box = DatabaseService.getBox(DatabaseService.prayerBoxName);
    final latRounded = double.parse(latitude.toStringAsFixed(2));
    final lngRounded = double.parse(longitude.toStringAsFixed(2));

    final url = Uri.parse(
      'https://api.aladhan.com/v1/hijriCalendar/$hijriYear/$hijriMonth?latitude=$latitude&longitude=$longitude&method=$method&school=$school',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['code'] == 200 && decoded['data'] != null && decoded['data'] is List) {
          final dataList = decoded['data'] as List;
          final List<PrayerTimes> fetchedList = [];

          for (final dayData in dataList) {
            final timings = dayData['timings'] as Map<String, dynamic>;
            final dateInfo = dayData['date'] as Map<String, dynamic>?;
            final String dateStr = dateInfo?['gregorian']?['date'] as String? ?? '';
            
            String hijriStr = '';
            if (dateInfo != null && dateInfo['hijri'] != null) {
              final hijri = dateInfo['hijri'] as Map<String, dynamic>;
              final day = hijri['day'] as String? ?? '';
              final monthEn = hijri['month']?['en'] as String? ?? '';
              final year = hijri['year'] as String? ?? '';
              hijriStr = '$day $monthEn $year';
            }

            final prayerTimes = PrayerTimes(
              date: dateStr,
              fajr: timings['Fajr'] as String? ?? '04:30',
              sunrise: timings['Sunrise'] as String? ?? '06:00',
              dhuhr: timings['Dhuhr'] as String? ?? '12:30',
              asr: timings['Asr'] as String? ?? '15:45',
              maghrib: timings['Maghrib'] as String? ?? '18:50',
              isha: timings['Isha'] as String? ?? '20:15',
              imsak: timings['Imsak'] as String? ?? '04:20',
              method: _getMethodName(method),
              hijriDate: hijriStr,
            );

            // Cache locally under gregorian key
            final cacheKey = '${dateStr}_${latRounded}_${lngRounded}_${method}_$school';
            await box.put(cacheKey, prayerTimes.toJson());
            fetchedList.add(prayerTimes);
          }
          return fetchedList;
        }
      }
      throw Exception('Failed to load Hijri calendar');
    } catch (e) {
      // Offline fallback: scan local Hive Cache for matches
      final hijriMonthsEng = [
        'Muharram',
        'Safar',
        'Rabi\' I',
        'Rabi\' II',
        'Jumada I',
        'Jumada II',
        'Rajab',
        'Sha\'ban',
        'Ramadan',
        'Shawwal',
        'Dhu al-Qi\'ah',
        'Dhu al-Hijjah'
      ];
      if (hijriMonth >= 1 && hijriMonth <= 12) {
        final targetMonthName = hijriMonthsEng[hijriMonth - 1].toLowerCase();
        final List<PrayerTimes> cachedList = [];
        for (var value in box.values) {
          if (value is Map) {
            final pt = PrayerTimes.fromJson(value);
            if (pt.hijriDate.isNotEmpty) {
              final parts = pt.hijriDate.split(' ').where((el) => el.isNotEmpty).toList();
              if (parts.length >= 3) {
                final String mName = parts[1].toLowerCase();
                final String yName = parts[2];
                if (mName == targetMonthName && yName == hijriYear.toString()) {
                  cachedList.add(pt);
                }
              }
            }
          }
        }
        if (cachedList.length >= 29) {
          cachedList.sort((a, b) {
            final aDay = int.tryParse(a.hijriDate.split(' ')[0]) ?? 0;
            final bDay = int.tryParse(b.hijriDate.split(' ')[0]) ?? 0;
            return aDay.compareTo(bDay);
          });
          return cachedList;
        }
      }
      rethrow;
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

  PrayerTimes _generateMeccaFallback(String date, int method, int school) {
    // Statically return logical times for Mecca (lat 21.4225, lng 39.8262) for the given date
    // These are standard fallback timings so the user has offline-ready placeholders
    return PrayerTimes(
      date: date,
      fajr: '04:15',
      sunrise: '05:38',
      dhuhr: '12:22',
      asr: school == 1 ? '16:35' : '15:40',
      maghrib: '19:04',
      isha: '20:34',
      imsak: '04:05',
      method: '${_getMethodName(method)} (Offline Fallback)',
      hijriDate: '',
    );
  }
}
