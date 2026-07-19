import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/dashboard/presentation/screens/prayer_calendar_screen.dart';
import 'package:adeen/features/dashboard/domain/prayer_models.dart';

class TodayPrayersScreen extends ConsumerWidget {
  const TodayPrayersScreen({super.key});

  String _formatTo12Hour(AppLocalizations localizations, String time24) {
    if (time24.isEmpty) return '';
    try {
      if (time24.contains('(')) {
        time24 = time24.split('(')[0].trim();
      }
      final parts = time24.split(':');
      if (parts.length < 2) return time24;
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      final formatted = '$hour12:$minuteStr $period';
      return localizations.localizeDigits(formatted);
    } catch (e) {
      return localizations.localizeDigits(time24);
    }
  }

  void _showPrayerInfoDialog(BuildContext context, AppLocalizations localizations, String titleKey, String bodyKey) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            localizations.translate(titleKey),
            style: const TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            localizations.translate(bodyKey),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              height: 1.5,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final timingsState = ref.watch(prayerTimesProvider);
    final today = timingsState.todayTimings;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('today_prayers'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: timingsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.warmGold),
            )
          : today == null
              ? Center(
                  child: Text(
                    'Error loading timings',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Header Card with date and Hijri date
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.dividerColor.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  Text(
                                    localizations.localizeDigits(DateFormat('EEEE, d MMMM yyyy', localizations.locale.languageCode).format(DateTime.now())),
                                  style: const TextStyle(
                                    fontFamily: 'Playfair Display',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                if (today.hijriDate.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.formatHijriDate(today.hijriDate),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.premiumGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                localizations.translate('state_active').toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _TodayTimetableList(
                      timing: today,
                      localizations: localizations,
                      theme: theme,
                      format12Hour: (t) => _formatTo12Hour(localizations, t),
                      showHelpDialog: (title, body) => _showPrayerInfoDialog(context, localizations, title, body),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.dividerColor.withOpacity(0.08),
                          width: 1,
                        ),
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
                                      ? AppTheme.warmGold.withOpacity(0.12)
                                      : theme.colorScheme.primary.withOpacity(0.06),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: theme.brightness == Brightness.dark
                                      ? AppTheme.warmGold
                                      : theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      localizations.translate('view_calendar'),
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      localizations.translate('calendar_subtitle'),
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: theme.colorScheme.onSurface.withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 20,
                                color: theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _PrayerRowItem {
  final String key;
  final String startTime;
  final String endTime;
  _PrayerRowItem(this.key, this.startTime, this.endTime);
}

class _TodayTimetableList extends ConsumerWidget {
  final PrayerTimes timing;
  final AppLocalizations localizations;
  final ThemeData theme;
  final String Function(String) format12Hour;
  final Function(String, String) showHelpDialog;

  const _TodayTimetableList({
    required this.timing,
    required this.localizations,
    required this.theme,
    required this.format12Hour,
    required this.showHelpDialog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String tomorrowFajr = timing.fajr;

    final String tahajjudStartStr =
        '${timing.tahajjudStart.hour.toString().padLeft(2, '0')}:${timing.tahajjudStart.minute.toString().padLeft(2, '0')}';
    final String tahajjudEndStr =
        '${timing.getTahajjudEnd(null).hour.toString().padLeft(2, '0')}:${timing.getTahajjudEnd(null).minute.toString().padLeft(2, '0')}';

    final list = [
      _PrayerRowItem('fajr', timing.fajr, timing.sunrise),
      _PrayerRowItem('ishraq', timing.ishraq, timing.chasht),
      _PrayerRowItem('chasht_duha', timing.chasht, timing.zawalStart),
      _PrayerRowItem('dhuhr', timing.dhuhr, timing.asr),
      _PrayerRowItem('asr', timing.asr, timing.maghrib),
      _PrayerRowItem('maghrib', timing.maghrib, timing.isha),
      _PrayerRowItem('isha', timing.isha, tomorrowFajr),
      _PrayerRowItem('tahajjud_prayer', tahajjudStartStr, tahajjudEndStr),
    ];

    final countdown = ref.watch(countdownProvider);
    final String currentKey = countdown?.currentPrayerKey ?? '';
    final String activeKey = countdown?.nextPrayerKey ?? '';

    IconData getPrayerIcon(String key) {
      switch (key) {
        case 'fajr':
          return Icons.wb_twilight_outlined;
        case 'ishraq':
          return Icons.wb_sunny_outlined;
        case 'chasht_duha':
          return Icons.wb_sunny;
        case 'dhuhr':
          return Icons.wb_sunny_rounded;
        case 'asr':
          return Icons.cloud_queue_rounded;
        case 'maghrib':
          return Icons.nights_stay_outlined;
        case 'isha':
          return Icons.nightlight_round_outlined;
        case 'tahajjud_prayer':
          return Icons.nights_stay;
        default:
          return Icons.schedule;
      }
    }

    return Column(
      children: list.map((item) {
        bool isCurrent = false;
        bool isUpcoming = false;

        if (item.key == 'tahajjud_prayer') {
          final now = DateTime.now();
          final tahajjudStart = timing.tahajjudStart;
          final tahajjudEnd = timing.getTahajjudEnd(null);
          isCurrent = now.isAfter(tahajjudStart) && now.isBefore(tahajjudEnd);
          isUpcoming = (activeKey == 'isha');
        } else {
          isCurrent = (item.key == currentKey);
          isUpcoming = (item.key == activeKey);
        }

        final Color textColor = isCurrent
            ? AppTheme.premiumGold
            : (isUpcoming
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface);

        final FontWeight textWeight = (isCurrent || isUpcoming) ? FontWeight.bold : FontWeight.w500;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isCurrent
                ? (theme.brightness == Brightness.dark
                    ? theme.colorScheme.primary.withOpacity(0.18)
                    : theme.colorScheme.primary.withOpacity(0.04))
                : (isUpcoming
                    ? (theme.brightness == Brightness.dark
                        ? theme.colorScheme.primary.withOpacity(0.10)
                        : theme.colorScheme.primary.withOpacity(0.02))
                    : theme.cardTheme.color ?? theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent
                  ? AppTheme.warmGold
                  : (isUpcoming
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.dividerColor.withOpacity(0.08)),
              width: isCurrent ? 1.5 : (isUpcoming ? 1.2 : 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    getPrayerIcon(item.key),
                    size: 20,
                    color: isCurrent
                        ? AppTheme.premiumGold
                        : (isUpcoming
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.55)),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    localizations.translate((DateTime.now().weekday == DateTime.friday && item.key == 'dhuhr') ? 'jumah_prayer' : item.key),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: textWeight,
                      color: textColor,
                    ),
                  ),
                  if (isCurrent || isUpcoming) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.premiumGold : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        localizations.translate(isCurrent ? 'state_active' : 'state_upcoming').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (item.key == 'ishraq' || item.key == 'chasht_duha' || item.key == 'tahajjud_prayer') ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        if (item.key == 'ishraq') {
                          showHelpDialog('ishraq_info_title', 'ishraq_info_body');
                        } else if (item.key == 'chasht_duha') {
                          showHelpDialog('chasht_info_title', 'chasht_info_body');
                        } else {
                          showHelpDialog('tahajjud_info_title', 'tahajjud_info_body');
                        }
                      },
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 15,
                        color: isCurrent
                            ? AppTheme.premiumGold.withOpacity(0.7)
                            : theme.colorScheme.onSurface.withOpacity(0.35),
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Text(
                    format12Hour(item.startTime),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: textWeight,
                      color: textColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: isCurrent
                          ? AppTheme.warmGold
                          : theme.colorScheme.onSurface.withOpacity(0.25),
                    ),
                  ),
                  Text(
                    format12Hour(item.endTime),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: isCurrent
                          ? AppTheme.premiumGold.withOpacity(0.8)
                          : theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
