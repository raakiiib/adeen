import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class QazaTrackerScreen extends ConsumerWidget {
  const QazaTrackerScreen({super.key});

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
          localizations.translate('qaza_tracker'),
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
              // Qaza Description & Visual Info
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
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
                            child: Icon(
                              Icons.history_rounded,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            localizations.translate('qaza_backlog'),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Track and log prayers you have missed (Qaza). As you make up for them, decrement the counter here to stay on top of your backlog.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          height: 1.4,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.dividerColor.withOpacity(0.08)),
                      
                      // List of Missed Qaza Prayers (flat tiles, no border on rows)
                      Column(
                        children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((p) {
                          final count = tracker.qazaCounts[p] ?? 0;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              localizations.translate(p.toLowerCase()),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                                color: count > 0 ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => notifier.decrementQaza(p),
                                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 22),
                                  color: Colors.red.shade400,
                                ),
                                Container(
                                  constraints: const BoxConstraints(minWidth: 32),
                                  alignment: Alignment.center,
                                  child: Text(
                                    localizations.localizeDigits('$count'),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: count > 0
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => notifier.incrementQaza(p),
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
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
