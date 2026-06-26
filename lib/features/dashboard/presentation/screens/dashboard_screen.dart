import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/theme/islamic_painters.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/dashboard/presentation/screens/prayer_tracker_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/qaza_tracker_screen.dart';
import 'package:adeen/features/profile/presentation/screens/profile_screen.dart';
import 'package:adeen/features/mosque_map/presentation/screens/mosque_map_screen.dart';
import 'package:adeen/features/quiz/presentation/screens/quiz_session_screen.dart';
import 'package:adeen/features/settings/presentation/screens/settings_screen.dart';

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
          color: AppTheme.warmGold,
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
                // 1. Premium Header (Bismillah & Language Switcher)
                _buildHeader(context, ref, isRtl, localizations),
                const SizedBox(height: 16),

                // Location Status / Method indicator
                // _buildLocationStatusRow(
                //   context,
                //   ref,
                //   locationState,
                //   timingsState,
                //   localizations,
                // ),
                // const SizedBox(height: 16),

                // 2. Main Live Countdown Card
                _buildCountdownCard(context, ref, localizations),
                const SizedBox(height: 16),

                // 2b. Fasting Times (Sehri & Iftar) Card
                _buildFastingTimesCard(
                  context,
                  ref,
                  timingsState,
                  localizations,
                ),
                const SizedBox(height: 16),

                // 2c. Special Times & Forbidden Periods Card
                _buildSpecialTimesCard(
                  context,
                  ref,
                  timingsState,
                  localizations,
                ),
                const SizedBox(height: 24),

                // 3. Timetable Section
                _buildSectionHeader(
                  context,
                  localizations.translate('app_title').split(' • ')[0],
                  Icons.schedule,
                ),
                const SizedBox(height: 12),
                _buildPrayerTimetable(
                  context,
                  ref,
                  timingsState,
                  localizations,
                ),
                const SizedBox(height: 24),

                // 4. Spiritual Hub Grid
                _buildSectionHeader(
                  context,
                  localizations.translate('explore_tools'),
                  Icons.grid_view_rounded,
                ),
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
  ) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.menu, size: 28),
          color: theme.brightness == Brightness.dark
              ? AppTheme.warmGold
              : theme.colorScheme.primary,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        const SizedBox(width: 8),
        // Bismillah Calligraphy + Subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CustomPaint(
              //   size: const Size(200, 30),
              //   painter: BismillahCalligraphyPainter(
              //     color: Theme.of(context).brightness == Brightness.dark
              //         ? AppTheme.warmGold
              //         : Theme.of(context).colorScheme.primary,
              //   ),
              // ),
              // const SizedBox(height: 4),
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppTheme.warmGold
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        // Settings Icon Button in top right corner
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.warmGold, width: 1.5),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Icon(
                Icons.settings,
                size: 22,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
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
      locText =
          '${locationState.latitude.toStringAsFixed(3)}°, ${locationState.longitude.toStringAsFixed(3)}°';
    } else {
      locText = '${localizations.translate('offline_msg')} (Mecca Fallback)';
      icon = Icons.cloud_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? theme.colorScheme.primary.withOpacity(0.15)
            : theme.colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? AppTheme.warmGold.withOpacity(0.15)
              : theme.colorScheme.secondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppTheme.warmGold),
              const SizedBox(width: 6),
              Text(
                locText,
                style: textStyle?.copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          // Calculation Method Dropdown / Button
          GestureDetector(
            onTap: () =>
                _showCalculationMethodDialog(context, ref, localizations),
            child: Row(
              children: [
                Text(
                  timingsState.todayTimings?.method.split(' (')[0] ??
                      'Umm Al-Qura',
                  style: textStyle?.copyWith(
                    color: AppTheme.warmGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 16,
                  color: AppTheme.warmGold,
                ),
              ],
            ),
          ),
        ],
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
          height: 180,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: AppTheme.warmGold),
        ),
      );
    }

    final String currentPrayerLabel = localizations.translate('current_prayer');
    final String currentPrayerName = localizations
        .translate(countdown.currentPrayerKey)
        .toUpperCase();
    final String nextPrayerLabel = localizations.translate('next_prayer');
    final String nextPrayerName = localizations
        .translate(countdown.nextPrayerKey)
        .toUpperCase();
    final String leftLabel = localizations.translate('left').toLowerCase();

    final int elapsedPercent = (countdown.progress * 100).toInt();
    final int remainingPercent = 100 - elapsedPercent;

    final String timeElapsedLabel = localizations.translate('time_elapsed');
    final String remainingLabel = localizations.translate('remaining');

    return Container(
      height: 220,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.brightness == Brightness.dark
              ? [
                  theme.colorScheme.primary.withOpacity(0.15),
                  theme.colorScheme.secondary.withOpacity(0.08),
                ]
              : [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Architectural Arch background frame drawing
            Positioned.fill(
              child: CustomPaint(
                painter: IslamicArchPainter(
                  outlineColor: AppTheme.warmGold.withOpacity(0.12),
                  fillColor: const Color.fromARGB(0, 221, 227, 102),
                  strokeWidth: 2.0,
                ),
              ),
            ),
            // Crescent Moon Vector
            PositionedDirectional(
              end: 16,
              top: 16,
              width: 50,
              height: 50,
              child: CustomPaint(
                painter: CrescentMoonPainter(
                  color: AppTheme.warmGold.withOpacity(0.15),
                ),
              ),
            ),
            // Main text info
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Row showing Current active prayer badge and Next prayer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warmGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.warmGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.warmGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$currentPrayerLabel: $currentPrayerName',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warmGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warmGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppTheme.warmGold.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppTheme.warmGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$nextPrayerLabel: $nextPrayerName',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.warmGold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Text(
                      //   '$nextPrayerLabel: $nextPrayerName',
                      //   style: TextStyle(
                      //     fontFamily: 'Poppins',
                      //     fontSize: 11,
                      //     fontWeight: FontWeight.w600,
                      //     color: Colors.white.withOpacity(0.7),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Prominent countdown showing time remaining for current active window
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        countdown.formattedTime,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 38,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.premiumGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        leftLabel,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.warmGold.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Details info label of progress
                  Text(
                    '$elapsedPercent% $timeElapsedLabel • $remainingPercent% $remainingLabel',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress indicator of the active period
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: countdown.progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.warmGold,
                      ),
                      minHeight: 6,
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

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.warmGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontFamily: 'Playfair Display',
            color: theme.brightness == Brightness.dark
                ? AppTheme.warmGold
                : theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimetable(
    BuildContext context,
    WidgetRef ref,
    PrayerTimesState timingsState,
    AppLocalizations localizations,
  ) {
    final theme = Theme.of(context);
    final today = timingsState.todayTimings;
    if (today == null) {
      if (timingsState.isLoading) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppTheme.warmGold),
          ),
        );
      }
      return Center(
        child: Text(
          'Error loading timings',
          style: TextStyle(color: Colors.red.shade400),
        ),
      );
    }

    final list = [
      _PrayerRowItem('fajr', today.fajr),
      _PrayerRowItem('sunrise', today.sunrise, isSunrise: true),
      _PrayerRowItem('dhuhr', today.dhuhr),
      _PrayerRowItem('asr', today.asr),
      _PrayerRowItem('maghrib', today.maghrib),
      _PrayerRowItem('isha', today.isha),
    ];

    // Find the next active prayer name to highlight it
    final countdown = ref.watch(countdownProvider);
    final String activeKey = countdown?.nextPrayerKey ?? '';

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (c, i) =>
            Divider(height: 1, color: theme.dividerColor),
        itemBuilder: (context, index) {
          final item = list[index];

          // Map imsak -> sehri / maghrib -> iftar to match countdown key highlights
          bool isHighlighted = false;
          if (item.key == 'imsak' && activeKey == 'sehri') {
            isHighlighted = true;
          } else if (item.key == 'maghrib' && activeKey == 'iftar') {
            isHighlighted = true;
          } else if (item.key == activeKey) {
            isHighlighted = true;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                        : Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.08))
                  : Colors.transparent,
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? const Radius.circular(16) : Radius.zero,
                bottom: index == list.length - 1
                    ? const Radius.circular(16)
                    : Radius.zero,
              ),
              border: isHighlighted
                  ? Border.all(
                      color: AppTheme.warmGold.withOpacity(0.5),
                      width: 1.0,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Dot indicator
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? AppTheme.premiumGold
                            : (item.isSunrise
                                  ? Colors.grey
                                  : Theme.of(
                                      context,
                                    ).colorScheme.secondary.withOpacity(0.4)),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Prayer Name
                    Text(
                      localizations.translate(item.key),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: isHighlighted
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isHighlighted
                            ? AppTheme.premiumGold
                            : Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                    if (item.isSehriOrIftar) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warmGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.key == 'imsak' ? 'SEHRI' : 'IFTAR',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.premiumGold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                // Prayer Time
                Text(
                  _formatTo12Hour(item.time),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: isHighlighted
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isHighlighted ? AppTheme.premiumGold : null,
                  ),
                ),
              ],
            ),
          );
        },
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
              title: localizations.translate('mosques'),
              subtitle: localizations.translate('hub_mosques_sub'),
              icon: Icons.map_outlined,
              iconColor: theme.colorScheme.primary,
              iconBgColor: theme.colorScheme.primary.withOpacity(0.12),
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
              iconColor: AppTheme.warmGold,
              iconBgColor: AppTheme.warmGold.withOpacity(0.15),
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
        const SizedBox(height: 8),
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
              title: localizations.translate('profile'),
              subtitle: localizations.translate('hub_profile_sub'),
              icon: Icons.person_outline,
              iconColor: Colors.blue.shade400,
              iconBgColor: Colors.blue.shade400.withOpacity(0.12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              theme: theme,
            ),
            const SizedBox(width: 8),
            _buildGridCard(
              context: context,
              title: localizations.translate('settings'),
              subtitle: localizations.translate('hub_settings_sub'),
              icon: Icons.settings_outlined,
              iconColor: Colors.orange.shade400,
              iconBgColor: Colors.orange.shade400.withOpacity(0.12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              theme: theme,
            ),
          ],
        ),
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
                ? AppTheme.warmGold.withOpacity(0.1)
                : theme.colorScheme.primary.withOpacity(0.08),
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
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
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

  void _showCalculationMethodDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations localizations,
  ) {
    final activeMethod = ref.read(calculationMethodProvider);

    final methods = {
      1: 'Karachi (Sciences)',
      2: 'ISNA (North America)',
      3: 'MWL (World League)',
      4: 'Umm Al-Qura (Makkah)',
      5: 'Egyptian Authority',
      8: 'Gulf Region',
      9: 'Kuwait',
      10: 'Qatar',
      11: 'MUIS (Singapore)',
      13: 'Diyanet (Turkey)',
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            localizations.translate('method'),
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: methods.entries.map((entry) {
                return RadioListTile<int>(
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                  ),
                  value: entry.key,
                  groupValue: activeMethod,
                  activeColor: AppTheme.warmGold,
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(calculationMethodProvider.notifier)
                          .updateMethod(val);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.translate('cancel'),
                style: const TextStyle(color: AppTheme.warmGold),
              ),
            ),
          ],
        );
      },
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          // Sehri Column
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wb_twilight_outlined,
                      size: 18,
                      color: AppTheme.warmGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      localizations.translate('sehri'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTo12Hour(today.imsak),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.premiumGold,
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
                    const Icon(
                      Icons.nights_stay_outlined,
                      size: 18,
                      color: AppTheme.warmGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      localizations.translate('iftar'),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTo12Hour(today.maghrib),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.premiumGold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTo12Hour(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (e) {
      return time24;
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
    final tomorrow = timingsState.tomorrowTimings;

    if (today == null) return const SizedBox.shrink();

    // Rebuild every second using the existing countdown timer provider
    ref.watch(countdownProvider);

    final now = DateTime.now();
    final forbiddenKey = today.getActiveForbiddenPeriodKey(now);
    final isForbidden = forbiddenKey != null;

    // Check if Tahajjud is active (between today's Isha and tomorrow's Fajr / today's Fajr fallback)
    final tahajjudStart = today.tahajjudStart;
    final tahajjudEnd = today.getTahajjudEnd(tomorrow);
    final isTahajjudActive = now.isAfter(tahajjudStart) && now.isBefore(tahajjudEnd);

    // Check if Ishraq is active
    final ishraqStart = today.ishraqStart;
    final ishraqEnd = today.ishraqEnd;
    final isIshraqActive = (now.isAfter(ishraqStart) || now.isAtSameMomentAs(ishraqStart)) &&
        (now.isBefore(ishraqEnd) || now.isAtSameMomentAs(ishraqEnd));

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              children: [
                const Icon(
                  Icons.lock_clock_outlined,
                  color: AppTheme.warmGold,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.translate('special_timings'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Live Permission Status Badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isForbidden
                    ? theme.colorScheme.error.withOpacity(0.08)
                    : const Color(0xFF0F9D58).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isForbidden
                      ? theme.colorScheme.error.withOpacity(0.3)
                      : const Color(0xFF0F9D58).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isForbidden
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isForbidden ? theme.colorScheme.error : const Color(0xFF0F9D58),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isForbidden
                              ? localizations.translate('prayer_forbidden')
                              : localizations.translate('prayer_allowed'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isForbidden ? theme.colorScheme.error : const Color(0xFF0F9D58),
                          ),
                        ),
                        if (isForbidden) ...[
                          const SizedBox(height: 2),
                          Text(
                            localizations.translate(forbiddenKey),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: theme.colorScheme.error.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Special Voluntary Prayers (Tahajjud & Ishraq)
            _buildSpecialRow(
              title: localizations.translate('tahajjud_prayer'),
              subtitle: localizations.translate('tahajjud_desc'),
              timeRange: '${_formatDateTimeTo12Hour(tahajjudStart)} - ${_formatDateTimeTo12Hour(tahajjudEnd)}',
              additionalInfo: '${localizations.translate('tahajjud_best')}: ${_formatDateTimeTo12Hour(today.getTahajjudBestStart(tomorrow))} - ${_formatDateTimeTo12Hour(tahajjudEnd)}',
              isActive: isTahajjudActive,
              activeLabel: localizations.translate('tahajjud_active'),
              icon: Icons.nights_stay_outlined,
              theme: theme,
            ),
            const Divider(height: 24),
            _buildSpecialRow(
              title: localizations.translate('ishraq_prayer'),
              subtitle: localizations.translate('ishraq_desc'),
              timeRange: '${_formatDateTimeTo12Hour(ishraqStart)} - ${_formatDateTimeTo12Hour(ishraqEnd)}',
              isActive: isIshraqActive,
              activeLabel: localizations.translate('ishraq_active'),
              icon: Icons.wb_twilight_outlined,
              theme: theme,
            ),
            const Divider(height: 24),

            // Section 2: Forbidden Windows
            Text(
              localizations.translate('forbidden_status').toUpperCase(),
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 10),
            _buildForbiddenTimeRow(
              label: localizations.translate('forbidden_sunrise'),
              timeRange: '${_formatDateTimeTo12Hour(today.sunriseForbiddenStart)} - ${_formatDateTimeTo12Hour(today.sunriseForbiddenEnd)}',
              theme: theme,
            ),
            const SizedBox(height: 8),
            _buildForbiddenTimeRow(
              label: localizations.translate('forbidden_zawal'),
              timeRange: '${_formatDateTimeTo12Hour(today.zawalForbiddenStart)} - ${_formatDateTimeTo12Hour(today.zawalForbiddenEnd)}',
              theme: theme,
            ),
            const SizedBox(height: 8),
            _buildForbiddenTimeRow(
              label: localizations.translate('forbidden_sunset'),
              timeRange: '${_formatDateTimeTo12Hour(today.sunsetForbiddenStart)} - ${_formatDateTimeTo12Hour(today.sunsetForbiddenEnd)}',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialRow({
    required String title,
    required String subtitle,
    required String timeRange,
    String? additionalInfo,
    required bool isActive,
    required String activeLabel,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.warmGold.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.warmGold, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.premiumGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppTheme.premiumGold.withOpacity(0.5), width: 0.5),
                      ),
                      child: Text(
                        activeLabel.split(' ')[0].toUpperCase(),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.premiumGold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                timeRange,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.premiumGold,
                ),
              ),
              if (additionalInfo != null) ...[
                const SizedBox(height: 4),
                Text(
                  additionalInfo,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForbiddenTimeRow({
    required String label,
    required String timeRange,
    required ThemeData theme,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          timeRange,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.error.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  String _formatDateTimeTo12Hour(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$hour12:$minuteStr $period';
  }
}

class _PrayerRowItem {
  final String key;
  final String time;
  final bool isSehriOrIftar;
  final bool isSunrise;

  _PrayerRowItem(
    this.key,
    this.time, {
    this.isSehriOrIftar = false,
    this.isSunrise = false,
  });
}
