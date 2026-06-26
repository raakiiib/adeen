import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adeen/core/database/database_service.dart';
import 'package:adeen/features/dashboard/data/aladhan_service.dart';
import 'package:adeen/features/dashboard/domain/prayer_models.dart';

// --- Locale Controller ---
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale(DatabaseService.getLocaleCode()));

  Future<void> toggleLocale() async {
    final newCode = state.languageCode == 'en' ? 'ar' : 'en';
    state = Locale(newCode);
    await DatabaseService.saveLocaleCode(newCode);
  }

  Future<void> setLocale(String code) async {
    state = Locale(code);
    await DatabaseService.saveLocaleCode(code);
  }
}

// --- Calculation Method Controller ---
final calculationMethodProvider = StateNotifierProvider<MethodNotifier, int>((ref) {
  return MethodNotifier();
});

class MethodNotifier extends StateNotifier<int> {
  MethodNotifier() : super(DatabaseService.getCalculationMethod());

  Future<void> updateMethod(int methodId) async {
    state = methodId;
    await DatabaseService.saveCalculationMethod(methodId);
  }
}

// --- Theme Mode Controller ---
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_getThemeModeFromIndex(DatabaseService.getThemeModeIndex()));

  static ThemeMode _getThemeModeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      case 0:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = mode;
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await DatabaseService.saveThemeModeIndex(index);
  }
}

// --- Color Preset Controller ---
final colorPresetProvider = StateNotifierProvider<ColorPresetNotifier, String>((ref) {
  return ColorPresetNotifier();
});

class ColorPresetNotifier extends StateNotifier<String> {
  ColorPresetNotifier() : super(DatabaseService.getColorPreset());

  Future<void> updatePreset(String presetName) async {
    state = presetName;
    await DatabaseService.saveColorPreset(presetName);
  }
}

// --- Location Controller ---
class LocationState {
  final double latitude;
  final double longitude;
  final String status; // 'loading', 'loaded', 'denied', 'error'

  LocationState({
    required this.latitude,
    required this.longitude,
    required this.status,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? status,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
    );
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
      : super(LocationState(
          latitude: 21.4225, // Default Mecca
          longitude: 39.8262,
          status: 'loading',
        )) {
    determinePosition();
  }

  Future<void> determinePosition() async {
    final cached = DatabaseService.getCachedLocation();
    if (cached != null) {
      state = LocationState(
        latitude: cached['latitude']!,
        longitude: cached['longitude']!,
        status: 'loaded',
      );
    }

    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(status: 'denied');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(status: 'denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(status: 'denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );

      state = LocationState(
        latitude: position.latitude,
        longitude: position.longitude,
        status: 'loaded',
      );

      await DatabaseService.saveCachedLocation(position.latitude, position.longitude);
    } catch (e) {
      if (cached == null) {
        state = state.copyWith(status: 'error');
      } else {
        state = state.copyWith(status: 'loaded');
      }
    }
  }
}

// --- Prayer Times State Holder ---
class PrayerTimesState {
  final PrayerTimes? todayTimings;
  final PrayerTimes? tomorrowTimings;
  final bool isLoading;
  final String? errorMessage;

  PrayerTimesState({
    this.todayTimings,
    this.tomorrowTimings,
    this.isLoading = false,
    this.errorMessage,
  });

  PrayerTimesState copyWith({
    PrayerTimes? todayTimings,
    PrayerTimes? tomorrowTimings,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PrayerTimesState(
      todayTimings: todayTimings ?? this.todayTimings,
      tomorrowTimings: tomorrowTimings ?? this.tomorrowTimings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final aladhanServiceProvider = Provider((ref) => AlAdhanService());

final prayerTimesProvider = StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  final service = ref.watch(aladhanServiceProvider);
  final location = ref.watch(locationProvider);
  final method = ref.watch(calculationMethodProvider);
  return PrayerTimesNotifier(service, location, method);
});

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final AlAdhanService _service;
  final LocationState _location;
  final int _method;

  PrayerTimesNotifier(this._service, this._location, this._method) : super(PrayerTimesState(isLoading: true)) {
    loadTimings();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
  }

  Future<void> loadTimings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final now = DateTime.now();
      final todayStr = _formatDate(now);
      final tomorrowStr = _formatDate(now.add(const Duration(days: 1)));

      final today = await _service.fetchPrayerTimes(
        date: todayStr,
        latitude: _location.latitude,
        longitude: _location.longitude,
        method: _method,
      );

      final tomorrow = await _service.fetchPrayerTimes(
        date: tomorrowStr,
        latitude: _location.latitude,
        longitude: _location.longitude,
        method: _method,
      );

      state = PrayerTimesState(
        todayTimings: today,
        tomorrowTimings: tomorrow,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

// --- Live Countdown Controller ---
class CountdownVal {
  final String currentPrayerKey;
  final String nextPrayerKey; // Localized key
  final Duration remaining;
  final String formattedTime; // HH:MM:SS
  final double progress; // 0.0 to 1.0

  CountdownVal({
    required this.currentPrayerKey,
    required this.nextPrayerKey,
    required this.remaining,
    required this.formattedTime,
    required this.progress,
  });
}

final prayerTimingsOnlyProvider = Provider<(PrayerTimes?, PrayerTimes?)>((ref) {
  final timingsState = ref.watch(prayerTimesProvider);
  return (timingsState.todayTimings, timingsState.tomorrowTimings);
});

final countdownProvider = StateNotifierProvider<CountdownNotifier, CountdownVal?>((ref) {
  final timings = ref.watch(prayerTimingsOnlyProvider);
  return CountdownNotifier(timings.$1, timings.$2);
});

class CountdownNotifier extends StateNotifier<CountdownVal?> {
  final PrayerTimes? _today;
  final PrayerTimes? _tomorrow;
  Timer? _timer;

  CountdownNotifier(this._today, this._tomorrow) : super(null) {
    if (_today != null) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _recalculate();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recalculate();
    });
  }

  void _recalculate() {
    final today = _today;
    final tomorrow = _tomorrow;
    if (today == null) return;

    final now = DateTime.now();

    final List<MapEntry<String, DateTime>> timingsToday = [
      MapEntry('fajr', today.getPrayerDateTime(today.fajr)),
      MapEntry('dhuhr', today.getPrayerDateTime(today.dhuhr)),
      MapEntry('asr', today.getPrayerDateTime(today.asr)),
      MapEntry('maghrib', today.getPrayerDateTime(today.maghrib)),
      MapEntry('isha', today.getPrayerDateTime(today.isha)),
    ];

    MapEntry<String, DateTime>? prevEvent;
    MapEntry<String, DateTime>? nextEvent;

    for (int i = 0; i < timingsToday.length; i++) {
      if (now.isBefore(timingsToday[i].value)) {
        nextEvent = timingsToday[i];
        prevEvent = i > 0 ? timingsToday[i - 1] : null;
        break;
      }
    }

    if (nextEvent == null && tomorrow != null) {
      prevEvent = timingsToday.last;
      nextEvent = MapEntry('fajr', tomorrow.getPrayerDateTime(tomorrow.fajr));
    }

    if (nextEvent == null) return;

    final DateTime prevDateTime = prevEvent?.value ?? nextEvent.value.subtract(const Duration(hours: 6));
    final DateTime nextDateTime = nextEvent.value;

    final remaining = nextDateTime.difference(now);

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final formattedTime = '$hours:$minutes:$seconds';

    final totalInterval = nextDateTime.difference(prevDateTime).inSeconds;
    final elapsed = now.difference(prevDateTime).inSeconds;
    double progress = totalInterval > 0 ? elapsed / totalInterval : 0.0;
    progress = progress.clamp(0.0, 1.0);

    String currentDisplayKey = prevEvent?.key ?? 'isha';

    state = CountdownVal(
      currentPrayerKey: currentDisplayKey,
      nextPrayerKey: nextEvent.key,
      remaining: remaining,
      formattedTime: formattedTime,
      progress: progress,
    );
  }
}

// --- Tracker Log Controller ---
final trackerDateProvider = StateProvider<String>((ref) {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
});

final trackerLogProvider = StateNotifierProvider<TrackerLogNotifier, TrackerLog>((ref) {
  final date = ref.watch(trackerDateProvider);
  return TrackerLogNotifier(date);
});

class TrackerLogNotifier extends StateNotifier<TrackerLog> {
  final String _date;

  TrackerLogNotifier(this._date) : super(TrackerLog.empty(_date)) {
    loadLog();
  }

  void loadLog() {
    final box = DatabaseService.getBox(DatabaseService.trackerBoxName);
    if (box.containsKey(_date)) {
      final data = box.get(_date);
      if (data is Map) {
        state = TrackerLog.fromJson(data);
        return;
      }
    }
    state = TrackerLog.empty(_date);
  }

  Future<void> togglePrayer(String prayerName) async {
    final completed = Map<String, bool>.from(state.completedPrayers);
    completed[prayerName] = !(completed[prayerName] ?? false);
    
    state = state.copyWith(completedPrayers: completed);
    await _saveToBox();
  }

  Future<void> toggleFasting() async {
    state = state.copyWith(fastedToday: !state.fastedToday);
    await _saveToBox();
  }

  Future<void> incrementQaza(String prayerName) async {
    final qaza = Map<String, int>.from(state.qazaCounts);
    qaza[prayerName] = (qaza[prayerName] ?? 0) + 1;

    state = state.copyWith(qazaCounts: qaza);
    await _saveToBox();
  }

  Future<void> decrementQaza(String prayerName) async {
    final qaza = Map<String, int>.from(state.qazaCounts);
    final current = qaza[prayerName] ?? 0;
    if (current > 0) {
      qaza[prayerName] = current - 1;
      state = state.copyWith(qazaCounts: qaza);
      await _saveToBox();
    }
  }

  Future<void> _saveToBox() async {
    final box = DatabaseService.getBox(DatabaseService.trackerBoxName);
    await box.put(_date, state.toJson());
  }
}

// --- Statistics Aggregation Provider ---
class UserStats {
  final int completedPrayersCount; // Completed in last 7 days (out of 35 max)
  final int fastingDaysCount;      // Fasted in last 7 days (out of 7 max)
  final Map<String, int> totalQazaBacklog; // Current active Qaza backlogs
  UserStats({
    required this.completedPrayersCount,
    required this.fastingDaysCount,
    required this.totalQazaBacklog,
  });
}

final statisticsProvider = Provider<UserStats>((ref) {
  // Watch current tracker log so stats auto-recalculate when items are checked
  final todayLog = ref.watch(trackerLogProvider);
  final box = DatabaseService.getBox(DatabaseService.trackerBoxName);
  
  int completedCount = 0;
  int fastingCount = 0;

  final now = DateTime.now();
  for (int i = 0; i < 7; i++) {
    final dateToCheck = now.subtract(Duration(days: i));
    final dateStr = '${dateToCheck.day.toString().padLeft(2, '0')}-${dateToCheck.month.toString().padLeft(2, '0')}-${dateToCheck.year}';
    
    if (box.containsKey(dateStr)) {
      final cachedVal = box.get(dateStr);
      if (cachedVal is Map) {
        final parsed = TrackerLog.fromJson(cachedVal);
        parsed.completedPrayers.values.forEach((v) {
          if (v) completedCount++;
        });
        if (parsed.fastedToday) {
          fastingCount++;
        }
      }
    }
  }

  return UserStats(
    completedPrayersCount: completedCount,
    fastingDaysCount: fastingCount,
    totalQazaBacklog: Map.from(todayLog.qazaCounts),
  );
});
