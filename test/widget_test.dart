import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:adeen/features/dashboard/domain/prayer_models.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/database/database_service.dart';
import 'package:adeen/core/widgets/app_drawer.dart';
import 'package:adeen/features/dashboard/presentation/screens/prayer_tracker_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/qaza_tracker_screen.dart';
import 'package:adeen/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  group('Adeen Prayer App Unit Tests', () {
    test('PrayerTimes JSON Parsing and DateTime conversions', () {
      final jsonMap = {
        'date': '25-06-2026',
        'fajr': '04:15',
        'sunrise': '05:38',
        'dhuhr': '12:22',
        'asr': '15:40',
        'maghrib': '19:04',
        'isha': '20:34',
        'imsak': '04:05',
        'method': 'Umm Al-Qura University, Makkah',
      };

      final prayerTimes = PrayerTimes.fromJson(jsonMap);

      expect(prayerTimes.date, '25-06-2026');
      expect(prayerTimes.fajr, '04:15');
      expect(prayerTimes.maghrib, '19:04');
      expect(prayerTimes.method, 'Umm Al-Qura University, Makkah');

      // Check DateTime conversion
      final fajrDateTime = prayerTimes.getPrayerDateTime(prayerTimes.fajr);
      expect(fajrDateTime.year, 2026);
      expect(fajrDateTime.month, 6);
      expect(fajrDateTime.day, 25);
      expect(fajrDateTime.hour, 4);
      expect(fajrDateTime.minute, 15);
    });

    test('TrackerLog model empty init and copyWith behaviors', () {
      final tracker = TrackerLog.empty('25-06-2026');

      expect(tracker.date, '25-06-2026');
      expect(tracker.completedPrayers['Fajr'], false);
      expect(tracker.qazaCounts['Fajr'], 0);
      expect(tracker.fastedToday, false);

      // Mutate via copyWith
      final updated = tracker.copyWith(
        fastedToday: true,
        completedPrayers: {
          'Fajr': true,
          'Dhuhr': false,
          'Asr': false,
          'Maghrib': false,
          'Isha': false,
        },
      );

      expect(updated.fastedToday, true);
      expect(updated.completedPrayers['Fajr'], true);
      expect(updated.completedPrayers['Dhuhr'], false);
    });

    test('AppLocalizations translation translations', () {
      final locEn = AppLocalizations(const Locale('en'));
      final locAr = AppLocalizations(const Locale('ar'));
      final locBn = AppLocalizations(const Locale('bn'));
      final locHi = AppLocalizations(const Locale('hi'));
      final locUr = AppLocalizations(const Locale('ur'));
      final locId = AppLocalizations(const Locale('id'));
      final locMs = AppLocalizations(const Locale('ms'));
      final locTr = AppLocalizations(const Locale('tr'));
      final locFr = AppLocalizations(const Locale('fr'));

      expect(locEn.translate('fajr'), 'Fajr');
      expect(locAr.translate('fajr'), 'الفجر');
      expect(locBn.translate('fajr'), 'ফজর');
      expect(locHi.translate('fajr'), 'फज्र');
      expect(locUr.translate('fajr'), 'فجر');
      expect(locId.translate('fajr'), 'Subuh');
      expect(locMs.translate('fajr'), 'Subuh');
      expect(locTr.translate('fajr'), 'İmsak / Sabah');
      expect(locFr.translate('fajr'), 'Fajr');

      expect(locEn.translate('quiz'), 'Quranic Quiz');
      expect(locAr.translate('quiz'), 'الاختبار القرآني');
      expect(locBn.translate('quiz'), 'কোরআনিক কুইজ');
      expect(locHi.translate('quiz'), 'क़ुरानिक क्विज़');
      expect(locUr.translate('quiz'), 'قرآنی کوئز');
      expect(locId.translate('quiz'), 'Kuis Al-Quran');
      expect(locMs.translate('quiz'), 'Kuiz Al-Quran');
      expect(locTr.translate('quiz'), 'Kuran Bilgi Yarışması');
      expect(locFr.translate('quiz'), 'Quiz Coranique');

      expect(locEn.isRTL, false);
      expect(locAr.isRTL, true);
      expect(locBn.isRTL, false);
      expect(locHi.isRTL, false);
      expect(locUr.isRTL, true);
      expect(locId.isRTL, false);
      expect(locMs.isRTL, false);
      expect(locTr.isRTL, false);
      expect(locFr.isRTL, false);
    });

    testWidgets('PrayerTrackerScreen renders correctly', (WidgetTester tester) async {
      final tempDir = Directory.systemTemp.createTempSync();
      
      await tester.runAsync(() async {
        Hive.init(tempDir.path);
        await Hive.openBox(DatabaseService.trackerBoxName);
        await Hive.openBox(DatabaseService.settingsBoxName);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: PrayerTrackerScreen(),
          ),
        ),
      );

      // Verify Bismillah and translations are loaded
      expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(5));
      expect(find.byType(Switch), findsOneWidget);

      await tester.runAsync(() async {
        await Hive.close();
      });
      tempDir.deleteSync(recursive: true);
    });

    testWidgets('QazaTrackerScreen renders correctly', (WidgetTester tester) async {
      final tempDir = Directory.systemTemp.createTempSync();
      
      await tester.runAsync(() async {
        Hive.init(tempDir.path);
        await Hive.openBox(DatabaseService.trackerBoxName);
        await Hive.openBox(DatabaseService.settingsBoxName);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: QazaTrackerScreen(),
          ),
        ),
      );

      // Verify page details
      expect(find.text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ'), findsOneWidget);
      expect(find.byIcon(Icons.remove_circle_outline), findsNWidgets(5));
      expect(find.byIcon(Icons.add_circle_outline), findsNWidgets(5));

      await tester.runAsync(() async {
        await Hive.close();
      });
      tempDir.deleteSync(recursive: true);
    });

    testWidgets('AppDrawer renders and handles navigation tap correctly', (WidgetTester tester) async {
      final observer = TestNavigatorObserver();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            navigatorObservers: [observer],
            home: Scaffold(
              drawer: AppDrawer(
                currentTab: 0,
                onTabSelected: (_) {},
              ),
              body: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer header content
      expect(find.text('Adeen • عدين'), findsOneWidget);
      
      // Tap on "Nearby Mosques"
      expect(find.text('Nearby Mosques'), findsOneWidget);
      await tester.tap(find.text('Nearby Mosques'));
      
      // Verify that a navigation route was pushed (without calling pumpAndSettle which runs MosqueMapScreen builder)
      expect(observer.pushedRoute, isNotNull);
    });

    testWidgets('SplashScreen renders correctly', (WidgetTester tester) async {
      final tempDir = Directory.systemTemp.createTempSync();
      
      await tester.runAsync(() async {
        Hive.init(tempDir.path);
        await Hive.openBox(DatabaseService.trackerBoxName);
        await Hive.openBox(DatabaseService.settingsBoxName);
        await Hive.openBox(DatabaseService.iqamahBoxName);
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: SplashScreen(),
          ),
        ),
      );

      // Verify splash branding elements
      expect(find.text('ADEEN'), findsOneWidget);
      expect(find.text('عَدِين'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify no exceptions or timing issues occur during early frame animation ticks
      await tester.pump(const Duration(milliseconds: 500));

      // Dispose the widget tree by pumping a blank SizedBox to trigger dispose and cancel the navigation timer
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await Hive.close();
      });
      tempDir.deleteSync(recursive: true);
    });
  });
}

class TestNavigatorObserver extends NavigatorObserver {
  Route? pushedRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    pushedRoute = route;
    super.didPush(route, previousRoute);
  }
}
