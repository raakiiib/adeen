import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  return LocationNotifier(ref);
});

class LocationNotifier extends StateNotifier<LocationState> {
  final Ref _ref;

  LocationNotifier(this._ref)
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
      
      // Attempt to auto-detect language asynchronously if not asked yet
      if (!DatabaseService.getLanguagePreferenceAsked()) {
        detectLanguageFromLocation(cached['latitude']!, cached['longitude']!);
      }
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

      // Attempt to auto-detect language based on coordinates if not asked yet
      if (!DatabaseService.getLanguagePreferenceAsked()) {
        await detectLanguageFromLocation(position.latitude, position.longitude);
      }
    } catch (e) {
      if (cached == null) {
        state = state.copyWith(status: 'error');
      } else {
        state = state.copyWith(status: 'loaded');
      }
    }
  }

  Future<void> detectLanguageFromLocation(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
          'https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=$latitude&longitude=$longitude&localityLanguage=en');
      final response = await http.get(url).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final countryCode = data['countryCode'] as String?;
        if (countryCode != null && countryCode.isNotEmpty) {
          final detectedLocale = _mapCountryToLocale(countryCode.toUpperCase());
          _ref.read(localeProvider.notifier).setLocale(detectedLocale);
        }
      }
    } catch (e) {
      debugPrint("Failed to detect language from location: $e");
    }
  }

  String _mapCountryToLocale(String countryCode) {
    const Map<String, String> countryToLanguage = {
      'BD': 'bn', // Bengali
      'IN': 'hi', // Hindi (default for India)
      'PK': 'ur', // Urdu
      'ID': 'id', // Indonesian
      'MY': 'ms', // Malay
      'SG': 'ms', // Singapore
      'BN': 'ms', // Brunei
      'TR': 'tr', // Turkish
      'FR': 'fr', // French
      'BE': 'fr', // Belgium
      'CH': 'fr', // Switzerland
      'CA': 'fr', // Canada
      'SN': 'fr', // Senegal
      'CI': 'fr', // Ivory Coast
      'CM': 'fr', // Cameroon
      'MG': 'fr', // Madagascar
      'NE': 'fr', // Niger
      'ML': 'fr', // Mali
      'BF': 'fr', // Burkina Faso
      'TG': 'fr', // Togo
      'BJ': 'fr', // Benin
      'SA': 'ar', // Saudi Arabia
      'EG': 'ar', // Egypt
      'AE': 'ar', // UAE
      'QA': 'ar', // Qatar
      'KW': 'ar', // Kuwait
      'OM': 'ar', // Oman
      'BH': 'ar', // Bahrain
      'JO': 'ar', // Jordan
      'LB': 'ar', // Lebanon
      'SY': 'ar', // Syria
      'IQ': 'ar', // Iraq
      'YE': 'ar', // Yemen
      'MA': 'ar', // Morocco
      'DZ': 'ar', // Algeria
      'TN': 'ar', // Tunisia
      'LY': 'ar', // Libya
      'SD': 'ar', // Sudan
      'PS': 'ar', // Palestine
    };
    return countryToLanguage[countryCode] ?? 'en';
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

// --- School of Thought / Juristic Method Controller ---
final juristicSchoolProvider = StateNotifierProvider<SchoolNotifier, int>((ref) {
  return SchoolNotifier();
});

class SchoolNotifier extends StateNotifier<int> {
  SchoolNotifier() : super(DatabaseService.getJuristicSchool());

  Future<void> updateSchool(int schoolId) async {
    state = schoolId;
    await DatabaseService.saveJuristicSchool(schoolId);
  }
}

final prayerTimesProvider = StateNotifierProvider<PrayerTimesNotifier, PrayerTimesState>((ref) {
  final service = ref.watch(aladhanServiceProvider);
  final location = ref.watch(locationProvider);
  final method = ref.watch(calculationMethodProvider);
  final school = ref.watch(juristicSchoolProvider);
  return PrayerTimesNotifier(service, location, method, school);
});

class PrayerTimesNotifier extends StateNotifier<PrayerTimesState> {
  final AlAdhanService _service;
  final LocationState _location;
  final int _method;
  final int _school;

  PrayerTimesNotifier(this._service, this._location, this._method, this._school) : super(PrayerTimesState(isLoading: true)) {
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
        school: _school,
      );

      final tomorrow = await _service.fetchPrayerTimes(
        date: tomorrowStr,
        latitude: _location.latitude,
        longitude: _location.longitude,
        method: _method,
        school: _school,
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
  final String nextPrayerKey;
  final Duration remaining;
  final String formattedTime; // HH:MM:SS
  final double progress; // 0.0 to 1.0
  final DateTime currentPrayerStartTime;
  final DateTime currentPrayerEndTime;
  final DateTime nextPrayerStartTime;
  final DateTime nextPrayerEndTime;

  CountdownVal({
    required this.currentPrayerKey,
    required this.nextPrayerKey,
    required this.remaining,
    required this.formattedTime,
    required this.progress,
    required this.currentPrayerStartTime,
    required this.currentPrayerEndTime,
    required this.nextPrayerStartTime,
    required this.nextPrayerEndTime,
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

class _TimeSegment {
  final String key;
  final DateTime startTime;
  final DateTime endTime;
  final String nextPrayerKey;

  _TimeSegment({
    required this.key,
    required this.startTime,
    required this.endTime,
    required this.nextPrayerKey,
  });
}

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

    final fajrToday = today.getPrayerDateTime(today.fajr);
    final sunriseToday = today.getPrayerDateTime(today.sunrise);
    final sunriseForbiddenEndToday = sunriseToday.add(const Duration(minutes: 15));
    final ishraqEndToday = sunriseToday.add(const Duration(minutes: 45));
    final zawalForbiddenStartToday = today.getPrayerDateTime(today.dhuhr).subtract(const Duration(minutes: 10));
    final dhuhrToday = today.getPrayerDateTime(today.dhuhr);
    final asrToday = today.getPrayerDateTime(today.asr);
    final sunsetForbiddenStartToday = today.getPrayerDateTime(today.maghrib).subtract(const Duration(minutes: 15));
    final maghribToday = today.getPrayerDateTime(today.maghrib);
    final ishaToday = today.getPrayerDateTime(today.isha);

    final fajrTomorrow = tomorrow != null
        ? tomorrow.getPrayerDateTime(tomorrow.fajr)
        : fajrToday.add(const Duration(days: 1));

    // Build the chronological 24-hour segments timeline
    final List<_TimeSegment> segments = [
      // Yesterday's Isha segment to cover the period before Fajr today
      _TimeSegment(
        key: 'isha',
        startTime: ishaToday.subtract(const Duration(days: 1)),
        endTime: fajrToday,
        nextPrayerKey: 'fajr',
      ),
      // Fajr
      _TimeSegment(
        key: 'fajr',
        startTime: fajrToday,
        endTime: sunriseToday,
        nextPrayerKey: 'ishraq',
      ),
      // Sunrise Forbidden Period
      _TimeSegment(
        key: 'forbidden_sunrise',
        startTime: sunriseToday,
        endTime: sunriseForbiddenEndToday,
        nextPrayerKey: 'ishraq',
      ),
      // Ishraq
      _TimeSegment(
        key: 'ishraq',
        startTime: sunriseForbiddenEndToday,
        endTime: ishraqEndToday,
        nextPrayerKey: 'chasht_duha',
      ),
      // Chasht (Duha)
      _TimeSegment(
        key: 'chasht_duha',
        startTime: ishraqEndToday,
        endTime: zawalForbiddenStartToday,
        nextPrayerKey: 'dhuhr',
      ),
      // Zawal Forbidden Period
      _TimeSegment(
        key: 'forbidden_zawal',
        startTime: zawalForbiddenStartToday,
        endTime: dhuhrToday,
        nextPrayerKey: 'dhuhr',
      ),
      // Dhuhr
      _TimeSegment(
        key: 'dhuhr',
        startTime: dhuhrToday,
        endTime: asrToday,
        nextPrayerKey: 'asr',
      ),
      // Asr
      _TimeSegment(
        key: 'asr',
        startTime: asrToday,
        endTime: sunsetForbiddenStartToday,
        nextPrayerKey: 'maghrib',
      ),
      // Sunset Forbidden Period
      _TimeSegment(
        key: 'forbidden_sunset',
        startTime: sunsetForbiddenStartToday,
        endTime: maghribToday,
        nextPrayerKey: 'maghrib',
      ),
      // Maghrib
      _TimeSegment(
        key: 'maghrib',
        startTime: maghribToday,
        endTime: ishaToday,
        nextPrayerKey: 'isha',
      ),
      // Isha Today
      _TimeSegment(
        key: 'isha',
        startTime: ishaToday,
        endTime: fajrTomorrow,
        nextPrayerKey: 'fajr',
      ),
    ];

    _TimeSegment? activeSegment;
    int activeIndex = segments.length - 1;
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if ((now.isAfter(seg.startTime) || now.isAtSameMomentAs(seg.startTime)) &&
          now.isBefore(seg.endTime)) {
        activeSegment = seg;
        activeIndex = i;
        break;
      }
    }
    activeSegment ??= segments.last;

    // Find next segment for its start/end times
    final nextIndex = (activeIndex + 1) < segments.length ? activeIndex + 1 : 0;
    final nextSegment = segments[nextIndex];

    final remaining = activeSegment.endTime.difference(now);

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final formattedTime = '$hours:$minutes:$seconds';

    final totalInterval = activeSegment.endTime.difference(activeSegment.startTime).inSeconds;
    final elapsed = now.difference(activeSegment.startTime).inSeconds;
    double progress = totalInterval > 0 ? elapsed / totalInterval : 0.0;
    progress = progress.clamp(0.0, 1.0);

    state = CountdownVal(
      currentPrayerKey: activeSegment.key,
      nextPrayerKey: activeSegment.nextPrayerKey,
      remaining: remaining,
      formattedTime: formattedTime,
      progress: progress,
      currentPrayerStartTime: activeSegment.startTime,
      currentPrayerEndTime: activeSegment.endTime,
      nextPrayerStartTime: nextSegment.startTime,
      nextPrayerEndTime: nextSegment.endTime,
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

// --- Prayer Calendar Screen State ---
class PrayerCalendarState {
  final String selectedTab; // 'week', 'month', 'date'
  final DateTime selectedDate;
  final int selectedMonth;
  final int selectedYear;
  final bool isLoading;
  final List<PrayerTimes> weeklyTimings;
  final List<PrayerTimes> monthlyTimings;
  final List<PrayerTimes> dateTimings;
  final String? errorMessage;

  PrayerCalendarState({
    required this.selectedTab,
    required this.selectedDate,
    required this.selectedMonth,
    required this.selectedYear,
    required this.isLoading,
    required this.weeklyTimings,
    required this.monthlyTimings,
    required this.dateTimings,
    this.errorMessage,
  });

  PrayerCalendarState copyWith({
    String? selectedTab,
    DateTime? selectedDate,
    int? selectedMonth,
    int? selectedYear,
    bool? isLoading,
    List<PrayerTimes>? weeklyTimings,
    List<PrayerTimes>? monthlyTimings,
    List<PrayerTimes>? dateTimings,
    String? errorMessage,
  }) {
    return PrayerCalendarState(
      selectedTab: selectedTab ?? this.selectedTab,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      isLoading: isLoading ?? this.isLoading,
      weeklyTimings: weeklyTimings ?? this.weeklyTimings,
      monthlyTimings: monthlyTimings ?? this.monthlyTimings,
      dateTimings: dateTimings ?? this.dateTimings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PrayerCalendarNotifier extends StateNotifier<PrayerCalendarState> {
  final AlAdhanService _service;
  final LocationState _location;
  final int _method;
  final int _school;

  PrayerCalendarNotifier(this._service, this._location, this._method, this._school)
      : super(PrayerCalendarState(
          selectedTab: 'week',
          selectedDate: DateTime.now(),
          selectedMonth: DateTime.now().month,
          selectedYear: DateTime.now().year,
          isLoading: true,
          weeklyTimings: [],
          monthlyTimings: [],
          dateTimings: [],
        )) {
    loadTimings();
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}';
  }

  Future<void> loadTimings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (state.selectedTab == 'week') {
        // Fetch 7 days starting from today
        final List<Future<PrayerTimes>> futures = [];
        final today = DateTime.now();
        for (int i = 0; i < 7; i++) {
          final targetDate = today.add(Duration(days: i));
          futures.add(
            _service.fetchPrayerTimes(
              date: _formatDate(targetDate),
              latitude: _location.latitude,
              longitude: _location.longitude,
              method: _method,
              school: _school,
            ),
          );
        }
        final results = await Future.wait(futures);
        state = state.copyWith(weeklyTimings: results, isLoading: false);
      } else if (state.selectedTab == 'month') {
        // Fetch full monthly calendar
        final results = await _service.fetchMonthlyCalendar(
          year: state.selectedYear,
          month: state.selectedMonth,
          latitude: _location.latitude,
          longitude: _location.longitude,
          method: _method,
          school: _school,
        );
        state = state.copyWith(monthlyTimings: results, isLoading: false);
      } else {
        // Fetch specific date timing
        final result = await _service.fetchPrayerTimes(
          date: _formatDate(state.selectedDate),
          latitude: _location.latitude,
          longitude: _location.longitude,
          method: _method,
          school: _school,
        );
        state = state.copyWith(dateTimings: [result], isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> changeTab(String tab) async {
    state = state.copyWith(selectedTab: tab);
    await loadTimings();
  }

  Future<void> changeDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await loadTimings();
  }

  Future<void> changeMonth(int month, int year) async {
    state = state.copyWith(selectedMonth: month, selectedYear: year);
    await loadTimings();
  }

  void resetState() {
    state = PrayerCalendarState(
      selectedTab: 'week',
      selectedDate: DateTime.now(),
      selectedMonth: DateTime.now().month,
      selectedYear: DateTime.now().year,
      isLoading: true,
      weeklyTimings: [],
      monthlyTimings: [],
      dateTimings: [],
    );
    loadTimings();
  }
}

final prayerCalendarProvider = StateNotifierProvider<PrayerCalendarNotifier, PrayerCalendarState>((ref) {
  final service = ref.watch(aladhanServiceProvider);
  final location = ref.watch(locationProvider);
  final method = ref.watch(calculationMethodProvider);
  final school = ref.watch(juristicSchoolProvider);
  return PrayerCalendarNotifier(service, location, method, school);
});

// --- Sehri & Iftar Monthly Calendar State & Notifier ---
class SehriIftarCalendarState {
  final int selectedMonth; // Hijri month (1 to 12)
  final int selectedYear;  // Hijri year (e.g. 1447)
  final bool isLoading;
  final List<PrayerTimes> timings;
  final String? errorMessage;

  SehriIftarCalendarState({
    required this.selectedMonth,
    required this.selectedYear,
    required this.isLoading,
    required this.timings,
    this.errorMessage,
  });

  SehriIftarCalendarState copyWith({
    int? selectedMonth,
    int? selectedYear,
    bool? isLoading,
    List<PrayerTimes>? timings,
    String? errorMessage,
  }) {
    return SehriIftarCalendarState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      isLoading: isLoading ?? this.isLoading,
      timings: timings ?? this.timings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SehriIftarCalendarNotifier extends StateNotifier<SehriIftarCalendarState> {
  final AlAdhanService _service;
  final LocationState _location;
  final int _method;
  final int _school;

  SehriIftarCalendarNotifier(
    this._service,
    this._location,
    this._method,
    this._school,
    String? initialHijriDate,
  ) : super(SehriIftarCalendarState(
          selectedMonth: _parseInitialMonth(initialHijriDate),
          selectedYear: _parseInitialYear(initialHijriDate),
          isLoading: true,
          timings: [],
        )) {
    loadTimings();
  }

  static int _parseInitialMonth(String? hijriStr) {
    if (hijriStr == null || hijriStr.isEmpty) return 9; // Fallback to Ramadan
    final parts = hijriStr.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.length < 3) return 9;
    final String monthClean = parts[1]
        .toLowerCase()
        .replaceAll('ā', 'a')
        .replaceAll('ī', 'i')
        .replaceAll('ū', 'u')
        .replaceAll('ḍ', 'd')
        .replaceAll('ḥ', 'h')
        .replaceAll('ṣ', 's')
        .replaceAll('ṭ', 't')
        .replaceAll('z̄', 'z')
        .replaceAll('ẓ', 'z')
        .replaceAll(RegExp(r"[^a-z']"), '');
    if (monthClean.contains('muharram') || monthClean.contains('محرم')) return 1;
    if (monthClean.contains('safar') || monthClean.contains('صفر')) return 2;
    if (monthClean.contains('rabi') && (monthClean.contains('awwal') || monthClean.contains('أول') || monthClean.contains(' i') || monthClean.contains('i\u0304'))) return 3;
    if (monthClean.contains('rabi') && (monthClean.contains('thani') || monthClean.contains('ثاني') || monthClean.contains(' ii') || monthClean.contains('i\u0304i\u0304'))) return 4;
    if (monthClean.contains('jumada') && (monthClean.contains('awwal') || monthClean.contains('أولى') || monthClean.contains(' i') || monthClean.contains('i\u0304'))) return 5;
    if (monthClean.contains('jumada') && (monthClean.contains('thani') || monthClean.contains('آخر') || monthClean.contains(' ii') || monthClean.contains('i\u0304i\u0304'))) return 6;
    if (monthClean.contains('rajab') || monthClean.contains('رجب')) return 7;
    if (monthClean.contains('shaban') || monthClean.contains('sha\'ban') || monthClean.contains('شعبان') || monthClean.contains('sha\u02bban')) return 8;
    if (monthClean.contains('ramad') || monthClean.contains('رمضان')) return 9;
    if (monthClean.contains('shaww') || monthClean.contains('شوال')) return 10;
    if (monthClean.contains('qidah') || monthClean.contains('qi\'dah') || monthClean.contains('قعدة')) return 11;
    if (monthClean.contains('hijjah') || monthClean.contains('حجة')) return 12;
    return 9;
  }

  static int _parseInitialYear(String? hijriStr) {
    if (hijriStr == null || hijriStr.isEmpty) return 1447; // Default
    final parts = hijriStr.split(' ').where((e) => e.isNotEmpty).toList();
    if (parts.length >= 3) {
      final y = int.tryParse(parts[2]);
      if (y != null) return y;
    }
    return 1447;
  }

  Future<void> loadTimings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final results = await _service.fetchHijriCalendar(
        hijriYear: state.selectedYear,
        hijriMonth: state.selectedMonth,
        latitude: _location.latitude,
        longitude: _location.longitude,
        method: _method,
        school: _school,
      );
      state = state.copyWith(timings: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> changeMonth(int month, int year) async {
    state = state.copyWith(selectedMonth: month, selectedYear: year);
    await loadTimings();
  }
}

final sehriIftarCalendarProvider = StateNotifierProvider.family<SehriIftarCalendarNotifier, SehriIftarCalendarState, String?>((ref, initialHijriDate) {
  final service = ref.watch(aladhanServiceProvider);
  final location = ref.watch(locationProvider);
  final method = ref.watch(calculationMethodProvider);
  final school = ref.watch(juristicSchoolProvider);
  return SehriIftarCalendarNotifier(service, location, method, school, initialHijriDate);
});
