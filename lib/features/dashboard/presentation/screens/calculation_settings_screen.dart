import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class CalculationSettingsScreen extends ConsumerWidget {
  const CalculationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeMethod = ref.watch(calculationMethodProvider);
    final activeSchool = ref.watch(juristicSchoolProvider);

    final methods = {
      0: localizations.translate('method_jafari'),
      1: localizations.translate('method_karachi'),
      2: localizations.translate('method_isna'),
      3: localizations.translate('method_mwl'),
      4: localizations.translate('method_umm_al_qura'),
      5: localizations.translate('method_egyptian'),
      7: localizations.translate('method_tehran'),
      8: localizations.translate('method_gulf'),
      9: localizations.translate('method_kuwait'),
      10: localizations.translate('method_qatar'),
      11: localizations.translate('method_singapore'),
      12: localizations.translate('method_france'),
      13: localizations.translate('method_turkey'),
      14: localizations.translate('method_russia'),
      15: localizations.translate('method_moonsighting'),
      16: localizations.translate('method_dubai'),
      17: localizations.translate('method_jakim'),
      18: localizations.translate('method_tunisia'),
      19: localizations.translate('method_algeria'),
      20: localizations.translate('method_kemenag'),
      21: localizations.translate('method_morocco'),
      22: localizations.translate('method_portugal'),
      23: localizations.translate('method_jordan'),
    };

    final schools = {
      0: localizations.translate('school_standard'),
      1: localizations.translate('school_hanafi'),
    };

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('calculation_settings'),
          style: TextStyle(
            
            fontWeight: FontWeight.bold,
            color: isDark ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.primary,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // ── Section 1: Juristic Method / School of Thought ──
            Text(
              localizations.translate('juristic_method').toUpperCase(),
              style: TextStyle(
                
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Theme.of(context).colorScheme.tertiary.withOpacity(0.8) : Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: schools.entries.map((entry) {
                    final bool isSelected = activeSchool == entry.key;
                    return RadioListTile<int>(
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      value: entry.key,
                      groupValue: activeSchool,
                      activeColor: Theme.of(context).colorScheme.tertiary,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(juristicSchoolProvider.notifier).updateSchool(val);
                          ref.read(prayerTimesProvider.notifier).loadTimings();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Section 2: Calculation Method ──
            Text(
              localizations.translate('method').toUpperCase(),
              style: TextStyle(
                
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Theme.of(context).colorScheme.tertiary.withOpacity(0.8) : Theme.of(context).colorScheme.primary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: methods.entries.map((entry) {
                    final bool isSelected = activeMethod == entry.key;
                    return RadioListTile<int>(
                      title: Text(
                        entry.value,
                        style: TextStyle(
                          
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      value: entry.key,
                      groupValue: activeMethod,
                      activeColor: Theme.of(context).colorScheme.tertiary,
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(calculationMethodProvider.notifier).updateMethod(val);
                          ref.read(prayerTimesProvider.notifier).loadTimings();
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
