import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/theme/islamic_painters.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/settings/presentation/screens/settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    final stats = ref.watch(statisticsProvider);

    // Calculate percentage
    const maxPrayers = 35;
    final prayerPercent = stats.completedPrayersCount / maxPrayers;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('profile').split(' & ')[0],
          style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Navigates directly to the Settings screen
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: localizations.translate('settings'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. User Info Header
            _buildProfileHeader(context, theme, localizations),
            const SizedBox(height: 24),

            // 2. Weekly Prayer Completion Progress Gauges
            _buildPrayerStatsCard(context, stats.completedPrayersCount, maxPrayers, prayerPercent, localizations, theme),
            const SizedBox(height: 16),

            // 3. Weekly Fasting Progress Card
            _buildFastingStatsCard(context, stats.fastingDaysCount, localizations, theme),
            const SizedBox(height: 16),

            // 4. Qaza Backlog Card
            _buildQazaBacklogCard(context, stats.totalQazaBacklog, localizations, theme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ThemeData theme, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        children: [
          // Ornate Circle Avatar with custom Tasbih Painter drawing
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(100, 100),
                painter: TasbihBeadsPainter(color: AppTheme.warmGold),
              ),
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Adeen Member',
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.translate('bismillah').split(', ')[0],
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              fontSize: 12,
              color: AppTheme.warmGold,
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Circular progress gauge
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 8,
                    backgroundColor: theme.brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.premiumGold),
                  ),
                  Center(
                    child: Text(
                      localizations.localizeDigits('${(percent * 100).toInt()}%'),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppTheme.premiumGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('stats_weekly_prayers'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${localizations.localizeDigits(completed.toString())} ${localizations.translate('of_total')} ${localizations.localizeDigits(maxTotal.toString())} ${localizations.translate('completed')}',
                    style: theme.textTheme.bodyMedium,
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Calendar icon / drawing
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warmGold.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month,
                size: 32,
                color: AppTheme.warmGold,
              ),
            ),
            const SizedBox(width: 20),
            
            // Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.translate('stats_weekly_fasts'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${localizations.localizeDigits(fastsLogged.toString())} ${localizations.translate('of_total')} ${localizations.localizeDigits('7')} ${localizations.translate('days')}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, size: 20, color: AppTheme.warmGold),
                    const SizedBox(width: 8),
                    Text(
                      localizations.translate('qaza_backlog'),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: totalQaza > 0 ? Colors.red.shade400.withOpacity(0.15) : theme.colorScheme.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    localizations.localizeDigits('$totalQaza'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: totalQaza > 0 ? Colors.red.shade400 : theme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Render specific prayers breakdown
            Column(
              children: backlog.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.translate(entry.key.toLowerCase()),
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                      Text(
                        localizations.localizeDigits('${entry.value}'),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          color: entry.value > 0 ? AppTheme.warmGold : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
