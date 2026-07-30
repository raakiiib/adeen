import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/dashboard/presentation/screens/qaza_tracker_screen.dart';
import 'package:adeen/features/quiz/presentation/controllers/quiz_controller.dart';
import 'package:adeen/features/quiz/presentation/screens/quiz_results_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final stats = ref.watch(statisticsProvider);
    final quizState = ref.watch(quizStateProvider);

    // Calculate percentage
    const maxPrayers = 35;
    final prayerPercent = stats.completedPrayersCount / maxPrayers;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('profile').split(' & ')[0],
          style: TextStyle(
            fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. User Info Header (Flat styling, borderless container)
              // _buildProfileHeader(context, theme, localizations),
              // const SizedBox(height: 16),

              // 2. Weekly Prayer Completion Card (Borderless card)
              _buildPrayerStatsCard(
                context,
                stats.completedPrayersCount,
                maxPrayers,
                prayerPercent,
                localizations,
                theme,
              ),
              const SizedBox(height: 12),

              // 3. Weekly Fasting Progress Card (Borderless card)
              _buildFastingStatsCard(
                context,
                stats.fastingDaysCount,
                localizations,
                theme,
              ),
              const SizedBox(height: 12),

              // 4. Quranic Quiz Progress Link (Borderless card, taps to open quiz stats screen)
              _buildQuizStatsCard(context, quizState, localizations, theme),
              const SizedBox(height: 12),

              // 5. Qaza Backlog Card (Redesigned with horizontal stats pills, tappable to open tracker)
              _buildQazaBacklogCard(
                context,
                stats.totalQazaBacklog,
                localizations,
                theme,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
            child: Icon(
              Icons.person_rounded,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Adeen Member',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.translate('bismillah').split(', ')[0],
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerStatsCard(
    BuildContext context,
    int completed,
    int maxTotal,
    double percent,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Circular progress gauge
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 6,
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  Center(
                    child: Text(
                      localizations.localizeDigits(
                        '${(percent * 100).toInt()}%',
                      ),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('stats_weekly_prayers'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${localizations.localizeDigits(completed.toString())} ${localizations.translate('of_total')} ${localizations.localizeDigits(maxTotal.toString())} ${localizations.translate('completed')}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastingStatsCard(
    BuildContext context,
    int fastsLogged,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.tertiary.withOpacity(0.12),
              child: Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 16),

            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('stats_weekly_fasts'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${localizations.localizeDigits(fastsLogged.toString())} ${localizations.translate('of_total')} ${localizations.localizeDigits('7')} ${localizations.translate('days')}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizStatsCard(
    BuildContext context,
    QuizState quizState,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizResultsScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.tertiary.withOpacity(0.12),
                child: Icon(
                  Icons.quiz_rounded,
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
                      localizations.translate('quiz'),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${localizations.translate('quiz_lifetime_score')}: ${localizations.localizeDigits(quizState.totalPoints.toString())} ${localizations.translate('quiz_pts')}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQazaBacklogCard(
    BuildContext context,
    Map<String, int> backlog,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final totalQaza = backlog.values.fold(0, (sum, val) => sum + val);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QazaTrackerScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.tertiary.withOpacity(0.12),
                        child: Icon(
                          Icons.history_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.translate('qaza_backlog'),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap to edit or update logs',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: totalQaza > 0
                          ? Colors.red.shade400.withOpacity(0.12)
                          : Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      localizations.localizeDigits('$totalQaza'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: totalQaza > 0
                            ? Colors.red.shade400
                            : Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((p) {
                  final count = backlog[p] ?? 0;
                  final isSelected = count > 0;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.05)
                            : theme.colorScheme.onSurface.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            localizations
                                .translate(p.toLowerCase())
                                .substring(0, 3)
                                .toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.4,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            localizations.localizeDigits('$count'),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.5,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
