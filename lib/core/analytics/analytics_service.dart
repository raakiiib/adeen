import 'package:firebase_analytics/firebase_analytics.dart';

/// Central service for all Firebase Analytics event tracking in Adeen.
///
/// Usage:
///   AnalyticsService.instance.logPrayerLogged(name: 'Fajr', status: 'completed');
///
/// All events are snake_case strings that appear verbatim in the Firebase console.
class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Returns the [FirebaseAnalyticsObserver] to pass to [MaterialApp.navigatorObservers].
  /// This enables automatic screen_view events for every page transition.
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ─────────────────────── App Lifecycle ────────────────────────

  /// Logged once when the app finishes its first launch (past splash).
  Future<void> logAppOpen() => _analytics.logAppOpen();

  // ─────────────────────── Prayer Tracker ───────────────────────

  /// Logged when user marks a prayer as completed, missed, or partial.
  Future<void> logPrayerLogged({
    required String prayerName, // e.g. "Fajr"
    required String status,     // "completed" | "missed" | "partial"
  }) =>
      _analytics.logEvent(
        name: 'prayer_logged',
        parameters: {
          'prayer_name': prayerName,
          'status': status,
        },
      );

  // ─────────────────────── Saom (Fasting) Tracker ───────────────

  /// Logged when user marks a fasting day entry.
  Future<void> logSaomLogged({required String status}) =>
      _analytics.logEvent(
        name: 'saom_logged',
        parameters: {'status': status},
      );

  // ─────────────────────── Qaza Tracker ─────────────────────────

  /// Logged when user logs a Qaza prayer entry.
  Future<void> logQazaLogged({required String prayerName}) =>
      _analytics.logEvent(
        name: 'qaza_logged',
        parameters: {'prayer_name': prayerName},
      );

  // ─────────────────────── Quran Quiz ───────────────────────────

  /// Logged when user starts a quiz session.
  Future<void> logQuizStarted() =>
      _analytics.logEvent(name: 'quiz_started');

  /// Logged when user answers a quiz question.
  Future<void> logQuizAnswered({required bool isCorrect}) =>
      _analytics.logEvent(
        name: 'quiz_answered',
        parameters: {'is_correct': isCorrect ? 1 : 0},
      );

  /// Logged when user completes a full quiz session.
  Future<void> logQuizCompleted({required int score, required int total}) =>
      _analytics.logEvent(
        name: 'quiz_completed',
        parameters: {
          'score': score,
          'total': total,
        },
      );

  // ─────────────────────── Qibla & Prayer Times ─────────────────

  /// Logged when user opens the Qibla compass screen.
  Future<void> logQiblaOpened() =>
      _analytics.logEvent(name: 'qibla_opened');

  /// Logged when prayer times are successfully loaded.
  Future<void> logPrayerTimesLoaded({required String method}) =>
      _analytics.logEvent(
        name: 'prayer_times_loaded',
        parameters: {'calculation_method': method},
      );

  // ─────────────────────── Mosque Map ───────────────────────────

  /// Logged when user searches for nearby mosques.
  Future<void> logMosqueSearched() =>
      _analytics.logEvent(name: 'mosque_searched');

  /// Logged when user taps "get directions" for a mosque.
  Future<void> logMosqueDirectionsOpened() =>
      _analytics.logEvent(name: 'mosque_directions_opened');

  // ─────────────────────── Settings ─────────────────────────────

  /// Logged when user changes the app language.
  Future<void> logLanguageChanged({required String languageCode}) =>
      _analytics.logEvent(
        name: 'language_changed',
        parameters: {'language_code': languageCode},
      );

  /// Logged when user changes the theme (light/dark/system).
  Future<void> logThemeChanged({required String theme}) =>
      _analytics.logEvent(
        name: 'theme_changed',
        parameters: {'theme': theme},
      );

  /// Logged when user changes the prayer calculation method.
  Future<void> logCalculationMethodChanged({required String method}) =>
      _analytics.logEvent(
        name: 'calculation_method_changed',
        parameters: {'method': method},
      );

  // ─────────────────────── Generic Screen View ──────────────────

  /// Log a manual screen view when automatic tracking isn't sufficient.
  Future<void> logScreenView({required String screenName}) =>
      _analytics.logScreenView(screenName: screenName);
}
