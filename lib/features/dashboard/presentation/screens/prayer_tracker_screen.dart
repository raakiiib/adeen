import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/theme/islamic_painters.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class PrayerTrackerScreen extends ConsumerWidget {
  const PrayerTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tracker = ref.watch(trackerLogProvider);
    final notifier = ref.read(trackerLogProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('prayer_tracker'),
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onBackground,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Premium Header / Islamic visual anchor
              Center(
                child: Column(
                  children: [
                    Text(
                      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.brightness == Brightness.dark
                            ? AppTheme.warmGold
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.translate('bismillah'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Ramadan Fasting Tracker Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.warmGold.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.05),
                        theme.colorScheme.secondary.withOpacity(0.05),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      // Crescent moon painter
                      SizedBox(
                        width: 44,
                        height: 44,
                        child: CustomPaint(
                          painter: CrescentMoonPainter(
                            color: AppTheme.warmGold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('fasting_tracker'),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tracker.fastedToday
                                  ? localizations.translate('fasting_completed')
                                  : localizations.translate('fasting_not_completed'),
                              style: TextStyle(
                                fontSize: 13,
                                color: tracker.fastedToday
                                    ? theme.colorScheme.secondary
                                    : theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: tracker.fastedToday,
                        activeColor: AppTheme.premiumGold,
                        activeTrackColor: theme.colorScheme.primary.withOpacity(0.5),
                        onChanged: (val) {
                          notifier.toggleFasting();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Daily Prayers Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppTheme.warmGold.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.task_alt,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations.translate('prayers_logged'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep track of your mandatory prayers today. Consistent logs form your spiritual routine.',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),
                      
                      // List of prayers
                      Column(
                        children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((p) {
                          final isDone = tracker.completedPrayers[p] ?? false;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: InkWell(
                              onTap: () => notifier.togglePrayer(p),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDone
                                        ? AppTheme.warmGold.withOpacity(0.5)
                                        : Colors.grey.withOpacity(0.15),
                                  ),
                                  color: isDone
                                      ? theme.colorScheme.primary.withOpacity(0.04)
                                      : Colors.transparent,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: isDone,
                                      activeColor: theme.colorScheme.primary,
                                      checkColor: AppTheme.warmGold,
                                      onChanged: (val) {
                                        notifier.togglePrayer(p);
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      localizations.translate(p.toLowerCase()),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: isDone
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isDone
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (isDone)
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppTheme.warmGold,
                                        size: 20,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Bottom decorative border motif
              Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CustomPaint(
                    painter: TasbihBeadsPainter(
                      color: AppTheme.warmGold.withOpacity(0.1),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
