import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/theme/islamic_painters.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class QazaTrackerScreen extends ConsumerWidget {
  const QazaTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tracker = ref.watch(trackerLogProvider);
    final notifier = ref.read(trackerLogProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('qaza_tracker'),
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

              // Qaza Description & Visual Info
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
                            Icons.history,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            localizations.translate('qaza_backlog'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Track and log prayers you have missed (Qaza). As you make up for them, decrement the counter here to stay on top of your backlog.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      // List of Missed Qaza Prayers
                      Column(
                        children: ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'].map((p) {
                          final count = tracker.qazaCounts[p] ?? 0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: count > 0
                                      ? AppTheme.warmGold.withOpacity(0.4)
                                      : Colors.grey.withOpacity(0.15),
                                ),
                                color: count > 0
                                    ? theme.colorScheme.primary.withOpacity(0.02)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    localizations.translate(p.toLowerCase()),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: count > 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () => notifier.decrementQaza(p),
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          size: 24,
                                        ),
                                        color: Colors.red.shade400,
                                      ),
                                      Container(
                                        constraints: const BoxConstraints(minWidth: 40),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$count',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: count > 0
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => notifier.incrementQaza(p),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                          size: 24,
                                        ),
                                        color: theme.colorScheme.secondary,
                                      ),
                                    ],
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
              const SizedBox(height: 32),

              // Tasbih/Beads decorative motif
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
