import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class PrayerTrackerScreen extends ConsumerWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tracker = ref.watch(trackerLogProvider);
    final notifier = ref.read(trackerLogProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('prayer_tracker'),
          style: TextStyle(
            fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Ramadan Fasting Tracker Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
                        child: Icon(
                          Icons.nights_stay_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('fasting_tracker'),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tracker.fastedToday
                                  ? localizations.translate('fasting_completed')
                                  : localizations.translate('fasting_not_completed'),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: tracker.fastedToday
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: tracker.fastedToday,
                        activeColor: Theme.of(context).colorScheme.tertiary,
                        activeTrackColor: theme.colorScheme.primary.withOpacity(0.3),
                        onChanged: (val) {
                          notifier.toggleFasting();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Daily Prayers Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations.translate('prayers_logged'),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Keep track of your mandatory prayers today. Consistent logs form your spiritual routine.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.dividerColor.withOpacity(0.08)),
                      
                      // List of prayers (flat tiles, no border on rows)
                      Column(
                        children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((p) {
                          final isDone = tracker.completedPrayers[p] ?? false;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => notifier.togglePrayer(p),
                            leading: Checkbox(
                              value: isDone,
                              activeColor: theme.colorScheme.primary,
                              checkColor: isDark ? AppTheme.emeraldDeep : Colors.white,
                              onChanged: (val) {
                                notifier.togglePrayer(p);
                              },
                            ),
                            title: Text(
                              localizations.translate(p.toLowerCase()),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                                color: isDone ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: isDone
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: Theme.of(context).colorScheme.tertiary,
                                    size: 18,
                                  )
                                : null,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
