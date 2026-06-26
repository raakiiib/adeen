import 'package:hive_flutter/hive_flutter.dart';

class DatabaseService {
  static const String prayerBoxName = 'prayer_timings';
  static const String trackerBoxName = 'tracker_log';
  static const String iqamahBoxName = 'iqamah_updates';
  static const String settingsBoxName = 'settings';
  static const String mosquesBoxName = 'mosques_cached';
  static const String answeredQuizzesBoxName = 'answered_quizzes';
  static const String quizTranslationsBoxName = 'quiz_translations';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Open boxes for direct access
    await Hive.openBox(prayerBoxName);
    await Hive.openBox(trackerBoxName);
    await Hive.openBox(iqamahBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox(mosquesBoxName);
    await Hive.openBox(answeredQuizzesBoxName);
    await Hive.openBox(quizTranslationsBoxName);
  }

  // Generic helpers
  static Box getBox(String boxName) => Hive.box(boxName);

  // Settings: Locale
  static String getLocaleCode() {
    final box = getBox(settingsBoxName);
    return box.get('locale', defaultValue: 'en') as String;
  }

  static Future<void> saveLocaleCode(String code) async {
    final box = getBox(settingsBoxName);
    await box.put('locale', code);
  }

  // Settings: Calculation Method
  static int getCalculationMethod() {
    final box = getBox(settingsBoxName);
    return box.get('method', defaultValue: 4) as int; // Default 4 = Umm Al-Qura
  }

  static Future<void> saveCalculationMethod(int methodId) async {
    final box = getBox(settingsBoxName);
    await box.put('method', methodId);
  }

  // Settings: Theme Mode (0 = System, 1 = Light, 2 = Dark)
  static int getThemeModeIndex() {
    final box = getBox(settingsBoxName);
    return box.get('themeMode', defaultValue: 0) as int;
  }

  static Future<void> saveThemeModeIndex(int index) async {
    final box = getBox(settingsBoxName);
    await box.put('themeMode', index);
  }

  // Settings: Color Preset ('emerald', 'sapphire', 'ruby')
  static String getColorPreset() {
    final box = getBox(settingsBoxName);
    return box.get('colorPreset', defaultValue: 'emerald') as String;
  }

  static Future<void> saveColorPreset(String preset) async {
    final box = getBox(settingsBoxName);
    await box.put('colorPreset', preset);
  }

  // Location cache
  static Map<String, double>? getCachedLocation() {
    final box = getBox(settingsBoxName);
    final lat = box.get('latitude') as double?;
    final lng = box.get('longitude') as double?;
    if (lat != null && lng != null) {
      return {'latitude': lat, 'longitude': lng};
    }
    return null;
  }

  static Future<void> saveCachedLocation(double lat, double lng) async {
    final box = getBox(settingsBoxName);
    await box.put('latitude', lat);
    await box.put('longitude', lng);
  }

  // Quiz: Total Points
  static int getQuizTotalPoints() {
    final box = getBox(settingsBoxName);
    return box.get('quiz_total_points', defaultValue: 0) as int;
  }

  static Future<void> saveQuizTotalPoints(int points) async {
    final box = getBox(settingsBoxName);
    await box.put('quiz_total_points', points);
  }
}
