import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/mosque_map/domain/mosque_model.dart';
import 'package:adeen/core/database/database_service.dart';
import 'package:adeen/features/mosque_map/data/places_service.dart';

// Filter types
enum MosqueFilter { all, womenSection, parking, jummahShifts }

// Filter provider
final mosqueFilterProvider = StateProvider<MosqueFilter>((ref) => MosqueFilter.all);

final googlePlacesServiceProvider = Provider((ref) => GooglePlacesService());

// Provider to store Places API error messages
final placesApiErrorProvider = StateProvider<String?>((ref) => null);

// Mosque list provider
final mosqueListProvider = StateNotifierProvider<MosqueListNotifier, List<MosqueModel>>((ref) {
  final location = ref.watch(locationProvider);
  final locale = ref.watch(localeProvider);
  final places = ref.watch(googlePlacesServiceProvider);
  return MosqueListNotifier(location, locale.languageCode, places, ref);
});

class MosqueListNotifier extends StateNotifier<List<MosqueModel>> {
  final LocationState _location;
  final String _lang;
  final GooglePlacesService _placesService;
  final Ref _ref;

  MosqueListNotifier(this._location, this._lang, this._placesService, this._ref) : super([]) {
    loadMosques();
  }

  /// Attempts to load real mosques from Google Places API (New) and cache them locally.
  /// Evicts any cached coordinate models older than 30 days to comply with Google's Service Constraints.
  Future<void> loadMosques({bool forceRefresh = false}) async {
    final lat = _location.latitude;
    final lng = _location.longitude;

    // Reset error state on each load attempt
    _ref.read(placesApiErrorProvider.notifier).state = null;

    final box = DatabaseService.getBox(DatabaseService.mosquesBoxName);
    final settingsBox = DatabaseService.getBox(DatabaseService.settingsBoxName);
    final now = DateTime.now().millisecondsSinceEpoch;
    const int duration30Days = 30 * 24 * 60 * 60 * 1000;
    const int duration7Days = 7 * 24 * 60 * 60 * 1000;
    const double searchRadius = 10000.0; // 10km search and view radius

    // 1. Evict any cached mosque data older than 30 days (Google API compliance)
    final allKeys = List.from(box.keys);
    for (var key in allKeys) {
      final cached = box.get(key);
      if (cached is Map) {
        final fetchedAt = cached['fetchedAt'] as int? ?? 0;
        if (now - fetchedAt > duration30Days) {
          await box.delete(key);
        }
      }
    }

    // 2. Determine if cache is hit based on search center history.
    // Cache is hit if:
    // - forceRefresh is false
    // - last_mosque_fetch_metadata exists
    // - distance between current location and last fetch location <= 2000.0 meters (2km)
    // - last fetch timestamp is < 7 days old
    bool isCacheHit = false;
    final lastFetch = settingsBox.get('last_mosque_fetch_metadata');
    if (lastFetch is Map && !forceRefresh) {
      final double lastLat = (lastFetch['latitude'] as num?)?.toDouble() ?? 0.0;
      final double lastLng = (lastFetch['longitude'] as num?)?.toDouble() ?? 0.0;
      final int lastTime = (lastFetch['timestamp'] as num?)?.toInt() ?? 0;

      final double distanceMoved = Geolocator.distanceBetween(lat, lng, lastLat, lastLng);
      if (distanceMoved <= 2000.0 && (now - lastTime) < duration7Days) {
        isCacheHit = true;
      }
    }

    // 3. Query Google Places API (New) if it's a cache miss or force reload
    if (!isCacheHit) {
      try {
        final realMosques = await _placesService.fetchNearbyMosques(
          latitude: lat,
          longitude: lng,
          lang: _lang,
        );

        // Delete any mock templates from the database so they don't clutter the map
        final keys = List.from(box.keys);
        for (var key in keys) {
          if (key.toString().startsWith('mosque_')) {
            await box.delete(key);
          }
        }

        // Merge fetched real mosques into database
        for (var m in realMosques) {
          if (!box.containsKey(m.id)) {
            await box.put(m.id, m.toJson());
          } else {
            // Update Google Maps coordinates and name while preserving user overrides
            final cached = box.get(m.id);
            if (cached is Map) {
              final cachedMosque = MosqueModel.fromJson(cached);
              final merged = MosqueModel(
                id: m.id,
                name: m.name,
                latitude: m.latitude,
                longitude: m.longitude,
                hasWomenSection: cachedMosque.hasWomenSection,
                hasParking: cachedMosque.hasParking,
                hasJummahShifts: cachedMosque.hasJummahShifts,
                iqamahTimes: cachedMosque.iqamahTimes,
                fetchedAt: now,
              );
              await box.put(m.id, merged.toJson());
            }
          }
        }

        // Save new query center and timestamp
        await settingsBox.put('last_mosque_fetch_metadata', {
          'latitude': lat,
          'longitude': lng,
          'timestamp': now,
        });

      } catch (e) {
        String displayError = e.toString();
        if (displayError.startsWith('Exception: ')) {
          displayError = displayError.substring('Exception: '.length);
        }
        _ref.read(placesApiErrorProvider.notifier).state = displayError;
        debugPrint('Places API fetch failed: $displayError. Loading from local database.');
      }
    }

    // 4. Populate mock templates ONLY if local database is completely empty (no cached real mosques)
    // This serves as an offline/developer fallback when API is not configured or fails on first run.
    if (box.isEmpty) {
      final mocks = _getMockTemplates(lat, lng, _lang == 'ar');
      for (var mock in mocks) {
        await box.put(mock.id, mock.toJson());
      }
    }

    // 5. Load all cached mosques and filter within 10km radius
    final List<MosqueModel> nearby = [];
    final refreshedLocal = box.values.map((v) => MosqueModel.fromJson(v as Map)).toList();
    for (var m in refreshedLocal) {
      final double distanceInMeters = Geolocator.distanceBetween(
        lat,
        lng,
        m.latitude,
        m.longitude,
      );
      if (distanceInMeters <= searchRadius) {
        nearby.add(m);
      }
    }

    state = nearby;
  }

  List<MosqueModel> _getMockTemplates(double lat, double lng, bool isAr) {
    final List<Map<String, dynamic>> templates = [
      {
        'id': 'mosque_1',
        'name': isAr ? 'جامع الروضة الكبير' : 'Al-Rawdah Grand Mosque',
        'latOffset': 0.005,
        'lngOffset': 0.006,
        'hasWomenSection': true,
        'hasParking': true,
        'hasJummahShifts': true,
        'iqamah': {'Fajr': '05:00', 'Dhuhr': '13:15', 'Asr': '16:30', 'Maghrib': '19:15', 'Isha': '20:45'},
      },
      {
        'id': 'mosque_2',
        'name': isAr ? 'مسجد التوحيد الأثري' : 'Tawheed Landmark Mosque',
        'latOffset': -0.007,
        'lngOffset': 0.009,
        'hasWomenSection': false,
        'hasParking': true,
        'hasJummahShifts': false,
        'iqamah': {'Fajr': '04:55', 'Dhuhr': '13:00', 'Asr': '16:15', 'Maghrib': '19:20', 'Isha': '20:30'},
      },
      {
        'id': 'mosque_3',
        'name': isAr ? 'مسجد السلام والتقوى' : 'As-Salam Mosque',
        'latOffset': 0.015,
        'lngOffset': -0.018,
        'hasWomenSection': true,
        'hasParking': false,
        'hasJummahShifts': true,
        'iqamah': {'Fajr': '05:05', 'Dhuhr': '13:30', 'Asr': '16:45', 'Maghrib': '19:15', 'Isha': '20:50'},
      },
      {
        'id': 'mosque_4',
        'name': isAr ? 'مصلى الهدى والرحمة' : 'Al-Huda Musallah',
        'latOffset': -0.014,
        'lngOffset': -0.015,
        'hasWomenSection': false,
        'hasParking': false,
        'hasJummahShifts': false,
        'iqamah': {'Fajr': '04:50', 'Dhuhr': '13:00', 'Asr': '16:00', 'Maghrib': '19:10', 'Isha': '20:30'},
      },
      {
        'id': 'mosque_5',
        'name': isAr ? 'مسجد الفتح' : 'Al-Fath Mosque',
        'latOffset': 0.045,
        'lngOffset': 0.038,
        'hasWomenSection': true,
        'hasParking': true,
        'hasJummahShifts': false,
        'iqamah': {'Fajr': '05:00', 'Dhuhr': '13:15', 'Asr': '16:20', 'Maghrib': '19:12', 'Isha': '20:40'},
      },
      {
        'id': 'mosque_6',
        'name': isAr ? 'مسجد النور والهدى' : 'An-Noor Mosque',
        'latOffset': -0.052,
        'lngOffset': 0.048,
        'hasWomenSection': true,
        'hasParking': true,
        'hasJummahShifts': true,
        'iqamah': {'Fajr': '04:55', 'Dhuhr': '13:00', 'Asr': '16:30', 'Maghrib': '19:18', 'Isha': '20:45'},
      },
      {
        'id': 'mosque_7',
        'name': isAr ? 'مسجد الرحمن' : 'Ar-Rahman Mosque',
        'latOffset': -0.032,
        'lngOffset': -0.065,
        'hasWomenSection': false,
        'hasParking': true,
        'hasJummahShifts': true,
        'iqamah': {'Fajr': '05:10', 'Dhuhr': '13:20', 'Asr': '16:40', 'Maghrib': '19:25', 'Isha': '20:55'},
      },
      {
        'id': 'mosque_8',
        'name': isAr ? 'مصلى الإيمان' : 'Al-Iman Musallah',
        'latOffset': 0.068,
        'lngOffset': -0.035,
        'hasWomenSection': true,
        'hasParking': false,
        'hasJummahShifts': false,
        'iqamah': {'Fajr': '04:50', 'Dhuhr': '13:00', 'Asr': '16:15', 'Maghrib': '19:10', 'Isha': '20:30'},
      },
    ];

    final now = DateTime.now().millisecondsSinceEpoch;
    return templates.map((temp) {
      return MosqueModel(
        id: temp['id'] as String,
        name: temp['name'] as String,
        latitude: lat + (temp['latOffset'] as double),
        longitude: lng + (temp['lngOffset'] as double),
        hasWomenSection: temp['hasWomenSection'] as bool,
        hasParking: temp['hasParking'] as bool,
        hasJummahShifts: temp['hasJummahShifts'] as bool,
        iqamahTimes: Map<String, String>.from(temp['iqamah'] as Map),
        fetchedAt: now,
      );
    }).toList();
  }

  /// Updates community Iqamah time locally.
  Future<void> updateIqamahTime(String mosqueId, String prayer, String newTime) async {
    final box = DatabaseService.getBox(DatabaseService.mosquesBoxName);
    if (box.containsKey(mosqueId)) {
      final cached = box.get(mosqueId);
      if (cached is Map) {
        final mosque = MosqueModel.fromJson(cached);
        final updatedTimes = Map<String, String>.from(mosque.iqamahTimes);
        updatedTimes[prayer] = newTime;

        final updated = MosqueModel(
          id: mosque.id,
          name: mosque.name,
          latitude: mosque.latitude,
          longitude: mosque.longitude,
          hasWomenSection: mosque.hasWomenSection,
          hasParking: mosque.hasParking,
          hasJummahShifts: mosque.hasJummahShifts,
          iqamahTimes: updatedTimes,
          fetchedAt: mosque.fetchedAt,
        );
        await box.put(mosqueId, updated.toJson());
        await loadMosques();
      }
    }
  }

  /// Updates amenities (women's section, parking, Jummah shifts) locally.
  Future<void> updateAmenities(
    String mosqueId, {
    required bool hasWomenSection,
    required bool hasParking,
    required bool hasJummahShifts,
  }) async {
    final box = DatabaseService.getBox(DatabaseService.mosquesBoxName);
    if (box.containsKey(mosqueId)) {
      final cached = box.get(mosqueId);
      if (cached is Map) {
        final mosque = MosqueModel.fromJson(cached);
        final updated = MosqueModel(
          id: mosque.id,
          name: mosque.name,
          latitude: mosque.latitude,
          longitude: mosque.longitude,
          hasWomenSection: hasWomenSection,
          hasParking: hasParking,
          hasJummahShifts: hasJummahShifts,
          iqamahTimes: mosque.iqamahTimes,
          fetchedAt: mosque.fetchedAt,
        );
        await box.put(mosqueId, updated.toJson());
        await loadMosques();
      }
    }
  }
}

// Filtered Mosque List Provider
final filteredMosqueProvider = Provider<List<MosqueModel>>((ref) {
  final list = ref.watch(mosqueListProvider);
  final filter = ref.watch(mosqueFilterProvider);

  switch (filter) {
    case MosqueFilter.womenSection:
      return list.where((m) => m.hasWomenSection).toList();
    case MosqueFilter.parking:
      return list.where((m) => m.hasParking).toList();
    case MosqueFilter.jummahShifts:
      return list.where((m) => m.hasJummahShifts).toList();
    case MosqueFilter.all:
      return list;
  }
});
