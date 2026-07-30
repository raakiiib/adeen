import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/dashboard/presentation/screens/prayer_tracker_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/qaza_tracker_screen.dart';
import 'package:adeen/features/mosque_map/presentation/screens/mosque_map_screen.dart';
import 'package:adeen/features/quiz/presentation/screens/quiz_session_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/prayer_calendar_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/today_prayers_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/sehri_iftar_calendar_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/calculation_settings_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isRtl = localizations.isRTL;

    final locationState = ref.watch(locationProvider);
    final timingsState = ref.watch(prayerTimesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(locationProvider.notifier).determinePosition();
            await ref.read(prayerTimesProvider.notifier).loadTimings();
          },
          color: Theme.of(context).colorScheme.tertiary,
          backgroundColor: theme.cardTheme.color,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Premium Header (Gregorian & Hijri Dates)
                _buildHeader(context, ref, isRtl, localizations, timingsState),
                const SizedBox(height: 16),

                // Location Status / Method indicator
                _buildLocationStatusRow(
                  context,
                  ref,
                  locationState,
                  timingsState,
                  localizations,
                ),
                const SizedBox(height: 8),

                // 2. Main Live Countdown Card
                _buildCountdownCard(context, ref, localizations),
                const SizedBox(height: 8),

                // 2b. Fasting Times (Sehri & Iftar) Card
                _buildFastingTimesCard(
                  context,
                  ref,
                  timingsState,
                  localizations,
                ),
                const SizedBox(height: 8),

                // 2c. Special Times & Forbidden Periods Card
                _buildSpecialTimesCard(
                  context,
                  ref,
                  timingsState,
                  localizations,
                ),
                const SizedBox(height: 12),

                // 3. Timetable Section (Now on top, without section header)
                _buildCalendarEntryCard(context, localizations, theme),

                // const SizedBox(height: 12),
                // 4. Spiritual Hub Grid
                // _buildSectionHeader(
                //   context,
                //   localizations.translate('explore_tools'),
                //   Icons.grid_view_rounded,
                // ),
                const SizedBox(height: 12),
                _buildFeaturesGrid(context, ref, localizations, theme),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    bool isRtl,
    AppLocalizations localizations,
    PrayerTimesState timingsState,
  ) {
    final theme = Theme.of(context);
    final today = timingsState.todayTimings;

    final now = DateTime.now();
    final String dayName = DateFormat(
      'EEEE',
      localizations.locale.languageCode,
    ).format(now);
    final String englishDate = localizations.localizeDigits(
      DateFormat('d MMMM y', localizations.locale.languageCode).format(now),
    );

    String hijriStr = today?.hijriDate ?? '';
    if (hijriStr.isEmpty) {
      hijriStr = _getApproximateHijriDate(now);
    }
    hijriStr = localizations.formatHijriDate(hijriStr);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.notes_rounded,
              size: 22,
              color: theme.brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$dayName, $englishDate',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hijriStr,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationStatusRow(
    BuildContext context,
    WidgetRef ref,
    LocationState locationState,
    PrayerTimesState timingsState,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium;

    String locText = '';
    IconData icon = Icons.location_on_outlined;

    if (locationState.status == 'loading') {
      locText = localizations.translate('loading');
      icon = Icons.refresh;
    } else if (locationState.status == 'loaded') {
      locText = localizations.localizeDigits(
        '${locationState.latitude.toStringAsFixed(3)}°, ${locationState.longitude.toStringAsFixed(3)}°',
      );
    } else {
      locText = '${localizations.translate('offline_msg')} (Mecca Fallback)';
      icon = Icons.cloud_off;
    }

    final activeMethod = ref.watch(calculationMethodProvider);

    final methods = {
      1: localizations.translate('method_karachi'),
      2: localizations.translate('method_isna'),
      3: localizations.translate('method_mwl'),
      4: localizations.translate('method_umm_al_qura'),
      5: localizations.translate('method_egyptian'),
      8: localizations.translate('method_gulf'),
      9: localizations.translate('method_kuwait'),
      10: localizations.translate('method_qatar'),
      11: localizations.translate('method_singapore'),
      13: localizations.translate('method_turkey'),
    };

    final methodName =
        methods[activeMethod] ??
        timingsState.todayTimings?.method.split(' (')[0] ??
        'Umm Al-Qura';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Theme.of(context).colorScheme.tertiary.withOpacity(0.15)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          width: 1,
        ),
      ),
      color: theme.brightness == Brightness.dark
          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.05),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CalculationSettingsScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locText,
                        style: textStyle?.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        methodName,
                        style: textStyle?.copyWith(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final countdown = ref.watch(countdownProvider);

    if (countdown == null) {
      return Card(
        child: Container(
          height: 120,
          alignment: Alignment.center,
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
      );
    }

    final bool isForbidden = countdown.currentPrayerKey.startsWith(
      'forbidden_',
    );
    final Color badgeColor = isForbidden
        ? theme.colorScheme.error
        : Theme.of(context).colorScheme.tertiary;

    final bool isFriday = DateTime.now().weekday == DateTime.friday;
    String currentKey = countdown.currentPrayerKey;
    if (isFriday && currentKey == 'dhuhr') currentKey = 'jumah_prayer';
    String nextKey = countdown.nextPrayerKey;
    if (isFriday && nextKey == 'dhuhr') nextKey = 'jumah_prayer';

    final String currentPrayerLabel = localizations.translate('current_prayer');
    final String currentPrayerName = localizations
        .translate(currentKey)
        .toUpperCase();
    final String nextPrayerLabel = localizations.translate('next_prayer');
    final String nextPrayerName = localizations
        .translate(nextKey)
        .toUpperCase();
    final String leftLabel = localizations.translate('left').toLowerCase();

    final int elapsedPercent = (countdown.progress * 100).toInt();

    return Card(
      shape: isForbidden
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.error.withOpacity(0.5),
                width: 1.5,
              ),
            )
          : null,
      color: isForbidden ? theme.colorScheme.error.withOpacity(0.04) : null,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TodayPrayersScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Left: Current Prayer ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Micro-label
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          currentPrayerLabel.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: badgeColor.withOpacity(0.75),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // Prayer name — large
                    Text(
                      currentPrayerName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isForbidden
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Start → End time
                    // Start → End time
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          localizations.localizeDigits(
                            _formatTo12Hour(
                              localizations,
                              '${countdown.currentPrayerStartTime.hour.toString().padLeft(2, '0')}:${countdown.currentPrayerStartTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                        ),
                        Text(
                          localizations.localizeDigits(
                            _formatTo12Hour(
                              localizations,
                              '${countdown.currentPrayerEndTime.hour.toString().padLeft(2, '0')}:${countdown.currentPrayerEndTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    if (isForbidden) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 12,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              localizations.translate('prayer_not_permitted'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.error,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // ── Centre: Circular Progress Ring ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring track
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 7,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onSurface.withOpacity(0.07),
                          ),
                        ),
                      ),
                      // Coloured progress arc (time elapsed)
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: countdown.progress,
                          strokeWidth: 7,
                          strokeCap: StrokeCap.round,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isForbidden
                                ? theme.colorScheme.error
                                : Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                      // Inner content: countdown + "left"
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            localizations.localizeDigits(
                              countdown.formattedTime,
                            ),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isForbidden
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurface,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            leftLabel,
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${localizations.localizeDigits(elapsedPercent.toString())}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isForbidden
                                  ? theme.colorScheme.error
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Right: Next Prayer ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    nextPrayerLabel.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    nextPrayerName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Next prayer start time
                  // Text(
                  //   localizations.localizeDigits(
                  //     _formatTo12Hour(
                  //       localizations,
                  //       '${countdown.nextPrayerStartTime.hour.toString().padLeft(2, '0')}:${countdown.nextPrayerStartTime.minute.toString().padLeft(2, '0')}',
                  //     ),
                  //   ),
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w600,
                  //     color: Theme.of(
                  //       context,
                  //     ).colorScheme.primary.withOpacity(0.85),
                  //   ),
                  // ),
                  // Next prayer end time
                  Text(
                    localizations.localizeDigits(
                      _formatTo12Hour(
                        localizations,
                        '${countdown.nextPrayerEndTime.hour.toString().padLeft(2, '0')}:${countdown.nextPrayerEndTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.tertiary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.brightness == Brightness.dark
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarEntryCard(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrayerCalendarScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.tertiary.withOpacity(0.12)
                      : Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  color: theme.brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.translate('view_calendar'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      localizations.translate('calendar_subtitle'),
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.45),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            _buildGridCard(
              context: context,
              title: localizations.translate('prayer_tracker'),
              subtitle: localizations.translate('hub_tracker_sub'),
              icon: Icons.task_alt_outlined,
              iconColor: const Color(0xFF0F9D58),
              iconBgColor: const Color(0xFF0F9D58).withOpacity(0.12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrayerTrackerScreen(),
                  ),
                );
              },
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildGridCard(
              context: context,
              title: localizations.translate('qaza_tracker'),
              subtitle: localizations.translate('hub_qaza_sub'),
              icon: Icons.history_outlined,
              iconColor: Colors.red.shade400,
              iconBgColor: Colors.red.shade400.withOpacity(0.12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QazaTrackerScreen(),
                  ),
                );
              },
              theme: theme,
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          children: [
            _buildGridCard(
              context: context,
              title: localizations.translate('mosques'),
              subtitle: localizations.translate('hub_mosques_sub'),
              icon: Icons.map_outlined,
              iconColor: Theme.of(context).colorScheme.primary,
              iconBgColor: Theme.of(
                context,
              ).colorScheme.primary.withOpacity(0.12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MosqueMapScreen(),
                  ),
                );
              },
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildGridCard(
              context: context,
              title: localizations.translate('quiz'),
              subtitle: localizations.translate('hub_quiz_sub'),
              icon: Icons.quiz_outlined,
              iconColor: Theme.of(context).colorScheme.tertiary,
              iconBgColor: Theme.of(
                context,
              ).colorScheme.tertiary.withOpacity(0.15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizSessionScreen(),
                  ),
                );
              },
              theme: theme,
            ),
          ],
        ),

        // const SizedBox(height: 8),
        // Row(
        //   children: [
        //     _buildGridCard(
        //       context: context,
        //       title: localizations.translate('profile'),
        //       subtitle: localizations.translate('hub_profile_sub'),
        //       icon: Icons.person_outline,
        //       iconColor: Colors.blue.shade400,
        //       iconBgColor: Colors.blue.shade400.withOpacity(0.12),
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const ProfileScreen(),
        //           ),
        //         );
        //       },
        //       theme: theme,
        //     ),
        //     const SizedBox(width: 8),
        //     _buildGridCard(
        //       context: context,
        //       title: localizations.translate('settings'),
        //       subtitle: localizations.translate('hub_settings_sub'),
        //       icon: Icons.settings_outlined,
        //       iconColor: Colors.orange.shade400,
        //       iconBgColor: Colors.orange.shade400.withOpacity(0.12),
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //             builder: (context) => const SettingsScreen(),
        //           ),
        //         );
        //       },
        //       theme: theme,
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 8),
        // Row(
        //   children: [
        //     _buildGridCard(
        //       context: context,
        //       title: localizations.translate('qibla_finder'),
        //       subtitle: localizations.translate('hub_qibla_sub'),
        //       icon: Icons.explore_outlined,
        //       iconColor: Theme.of(context).colorScheme.tertiary,
        //       iconBgColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.14),
        //       onTap: () {
        //         Navigator.push(
        //           context,
        //           MaterialPageRoute(builder: (context) => const QiblaScreen()),
        //         );
        //       },
        //       theme: theme,
        //     ),
        //     const SizedBox(width: 8),
        //     const Expanded(child: SizedBox()),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Card(
        elevation: 0.5,
        color: isDark ? theme.cardTheme.color : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Theme.of(context).colorScheme.tertiary.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.08),
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconBgColor,
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFastingTimesCard(
    BuildContext context,
    WidgetRef ref,
    PrayerTimesState timingsState,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final today = timingsState.todayTimings;

    if (today == null) return const SizedBox.shrink();

    // Rebuild every second using the existing countdown timer provider
    ref.watch(countdownProvider);

    DateTime? parseTimeStringToday(String timeStr) {
      try {
        if (timeStr.contains('(')) {
          timeStr = timeStr.split('(')[0].trim();
        }
        final parts = timeStr.split(':');
        final now = DateTime.now();
        return DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      } catch (e) {
        return null;
      }
    }

    final now = DateTime.now();
    final todayImsak = parseTimeStringToday(today.imsak);
    final todayMaghrib = parseTimeStringToday(today.maghrib);

    String statusText = '';
    Duration remaining = Duration.zero;
    double progress = 0.0;

    if (todayImsak != null && todayMaghrib != null) {
      if (now.isBefore(todayImsak)) {
        statusText = localizations.translate('sehri_ends_in');
        remaining = todayImsak.difference(now);
        final yesterdayMaghrib = todayMaghrib.subtract(const Duration(days: 1));
        final totalSecs = todayImsak.difference(yesterdayMaghrib).inSeconds;
        final elapsedSecs = now.difference(yesterdayMaghrib).inSeconds;
        if (totalSecs > 0) {
          progress = (elapsedSecs / totalSecs).clamp(0.0, 1.0);
        }
      } else if (now.isBefore(todayMaghrib)) {
        statusText = localizations.translate('iftar_in');
        remaining = todayMaghrib.difference(now);
        final totalSecs = todayMaghrib.difference(todayImsak).inSeconds;
        final elapsedSecs = now.difference(todayImsak).inSeconds;
        if (totalSecs > 0) {
          progress = (elapsedSecs / totalSecs).clamp(0.0, 1.0);
        }
      } else {
        statusText = localizations.translate('sehri_ends_in');
        final tomorrowImsak = todayImsak.add(const Duration(days: 1));
        remaining = tomorrowImsak.difference(now);
        final totalSecs = tomorrowImsak.difference(todayMaghrib).inSeconds;
        final elapsedSecs = now.difference(todayMaghrib).inSeconds;
        if (totalSecs > 0) {
          progress = (elapsedSecs / totalSecs).clamp(0.0, 1.0);
        }
      }
    }

    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final remainingStr = localizations.localizeDigits(
      '$hours:$minutes:$seconds',
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SehriIftarCalendarScreen(initialHijriDate: today.hijriDate),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Sehri Column
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wb_twilight_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              localizations.translate('sehri'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTo12Hour(localizations, today.imsak),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(height: 48, width: 1, color: theme.dividerColor),

                  // Iftar Column
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.nights_stay_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              localizations.translate('iftar'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTo12Hour(localizations, today.maghrib),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (todayImsak != null &&
                  todayMaghrib != null &&
                  remaining.inMinutes <= 90) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.tertiary.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      remainingStr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.tertiary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTo12Hour(AppLocalizations localizations, String time24) {
    if (time24.isEmpty) return '';
    try {
      if (time24.contains('(')) {
        time24 = time24.split('(')[0].trim();
      }
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12
          ? localizations.translate('pm')
          : localizations.translate('am');
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      final formatted = '$hour12:$minuteStr $period';
      return localizations.localizeDigits(formatted);
    } catch (e) {
      return localizations.localizeDigits(time24);
    }
  }

  Widget _buildSpecialTimesCard(
    BuildContext context,
    WidgetRef ref,
    PrayerTimesState timingsState,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final today = timingsState.todayTimings;

    if (today == null) return const SizedBox.shrink();

    // Rebuild every second using the existing countdown timer provider
    ref.watch(countdownProvider);

    final now = DateTime.now();
    final forbiddenKey = today.getActiveForbiddenPeriodKey(now);
    final isForbidden = forbiddenKey != null;

    final bool isSunriseActive = forbiddenKey == 'forbidden_sunrise';
    final bool isZawalActive = forbiddenKey == 'forbidden_zawal';
    final bool isSunsetActive = forbiddenKey == 'forbidden_sunset';

    Widget buildForbiddenRow(
      String labelKey,
      IconData icon,
      DateTime start,
      DateTime end,
      bool isActive,
    ) {
      final String label = localizations.translate(labelKey);
      final String startTimeStr = _formatDateTimeTo12Hour(localizations, start);
      final String endTimeStr = _formatDateTimeTo12Hour(localizations, end);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 2.0),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.error.withOpacity(0.08)
              : theme.cardTheme.color?.withOpacity(0.4) ??
                    theme.colorScheme.surface.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? theme.colorScheme.error.withOpacity(0.3)
                : theme.dividerColor.withOpacity(0.05),
            width: isActive ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurface.withOpacity(0.55),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isActive
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurface.withOpacity(0.85),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        localizations.translate('state_active').toUpperCase(),
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  startTimeStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive
                        ? theme.colorScheme.error
                        : Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 10,
                    color: isActive
                        ? theme.colorScheme.error.withOpacity(0.5)
                        : theme.colorScheme.onSurface.withOpacity(0.25),
                  ),
                ),
                Text(
                  endTimeStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                    color: isActive
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: isForbidden
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.error.withOpacity(0.5),
                width: 1.5,
              ),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.dividerColor.withOpacity(0.08),
                width: 1,
              ),
            ),
      color: isForbidden ? theme.colorScheme.error.withOpacity(0.04) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isForbidden
                          ? Icons.warning_amber_rounded
                          : Icons.info_outline_rounded,
                      color: isForbidden
                          ? theme.colorScheme.error
                          : Theme.of(context).colorScheme.tertiary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      localizations.translate('special_timings'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isForbidden
                            ? theme.colorScheme.error.withOpacity(0.8)
                            : theme.colorScheme.onSurface.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isForbidden
                        ? theme.colorScheme.error.withOpacity(0.08)
                        : const Color(0xFF0F9D58).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isForbidden
                          ? theme.colorScheme.error.withOpacity(0.2)
                          : const Color(0xFF0F9D58).withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isForbidden
                              ? theme.colorScheme.error
                              : const Color(0xFF0F9D58),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isForbidden
                            ? localizations
                                  .translate('prayer_forbidden')
                                  .toUpperCase()
                            : localizations
                                  .translate('prayer_allowed')
                                  .toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isForbidden
                              ? theme.colorScheme.error
                              : const Color(0xFF0F9D58),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                buildForbiddenRow(
                  'forbidden_sunrise',
                  Icons.wb_sunny_outlined,
                  today.sunriseForbiddenStart,
                  today.sunriseForbiddenEnd,
                  isSunriseActive,
                ),
                buildForbiddenRow(
                  'forbidden_zawal',
                  Icons.wb_twilight_outlined,
                  today.zawalForbiddenStart,
                  today.zawalForbiddenEnd,
                  isZawalActive,
                ),
                buildForbiddenRow(
                  'forbidden_sunset',
                  Icons.wb_twilight_outlined,
                  today.sunsetForbiddenStart,
                  today.sunsetForbiddenEnd,
                  isSunsetActive,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTimeTo12Hour(AppLocalizations localizations, DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12
        ? localizations.translate('pm')
        : localizations.translate('am');
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return localizations.localizeDigits('$hour12:$minuteStr $period');
  }

  String _getApproximateHijriDate(DateTime gregorian) {
    int year = gregorian.year;
    int month = gregorian.month;
    int day = gregorian.day;

    if (month < 3) {
      year -= 1;
      month += 12;
    }

    int a = (year / 100).floor();
    int b = (a / 4).floor();
    int c = 2 - a + b;
    int e = (365.25 * (year + 4716)).floor();
    int f = (30.6001 * (month + 1)).floor();
    double jd = c + day + e + f - 1524.5;

    double imjd = jd - 1948439.5;
    int cycle = (imjd / 10631).floor();
    int cycleRem = (imjd % 10631).floor();

    int iYear = (cycleRem / 354.36667).floor();
    int iYearRem = (cycleRem - (iYear * 354.36667).floor()).floor();

    int iMonth = ((iYearRem + 30) / 29.5).floor();
    if (iMonth > 12) iMonth = 12;
    int iDay = iYearRem - ((iMonth - 1) * 29.5).floor() + 1;

    int hijriYear = cycle * 30 + iYear + 1;
    int hijriMonth = iMonth;
    int hijriDay = iDay;

    final months = [
      'Muharram',
      'Safar',
      'Rabi\' al-Awwal',
      'Rabi\' al-Thani',
      'Jumada al-Awwal',
      'Jumada al-Thani',
      'Rajab',
      'Sha\'ban',
      'Ramadan',
      'Shawwal',
      'Dhu al-Qidah',
      'Dhu al-Hijjah',
    ];

    final String mName = months[hijriMonth - 1];
    return '$hijriDay $mName $hijriYear AH';
  }
}
