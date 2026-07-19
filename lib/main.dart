import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/database/database_service.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_drawer.dart';
import 'core/widgets/language_setup_dialog.dart';
import 'features/dashboard/presentation/controllers/prayer_controller.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized prior to loading database
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database boxes for local offline caches
  await DatabaseService.init();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to locale adjustments (persisted in Hive settings box)
    final activeLocale = ref.watch(localeProvider);
    final activeThemeMode = ref.watch(themeModeProvider);
    final activePreset = ref.watch(colorPresetProvider);

    return MaterialApp(
      title: 'Adeen',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.getTheme(Brightness.light, activePreset),
      darkTheme: AppTheme.getTheme(Brightness.dark, activePreset),
      themeMode: activeThemeMode,

      // Localization & RTL configurations
      locale: activeLocale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
        Locale('bn'),
        Locale('hi'),
        Locale('ur'),
        Locale('id'),
        Locale('ms'),
        Locale('tr'),
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      home: const SplashScreen(),
    );
  }
}

class MainNavigationHub extends ConsumerStatefulWidget {
  const MainNavigationHub({super.key});

  @override
  ConsumerState<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends ConsumerState<MainNavigationHub> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? _lastPressedAt;

  @override
  void initState() {
    super.initState();
    // After initialization, check and show the language preference selection if not asked yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptLanguage();
    });
  }

  void _checkAndPromptLanguage() {
    if (!DatabaseService.getLanguagePreferenceAsked()) {
      LanguageSetupDialog.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // 1. If drawer is open, close it
        if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
          _scaffoldKey.currentState?.closeDrawer();
          return;
        }

        // 2. Double-back detection for exiting
        final now = DateTime.now();
        final backButtonHasNotBeenPressedOrExpired =
            _lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2);

        if (backButtonHasNotBeenPressedOrExpired) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations.translate('exit_warning'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: AppTheme.warmGold,
                ),
              ),
              backgroundColor: theme.colorScheme.primary,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          return;
        }

        // Exit the app
        await SystemNavigator.pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: AppDrawer(currentTab: 0, onTabSelected: (_) {}),
        body: const DashboardScreen(),
      ),
    );
  }
}
