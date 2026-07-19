import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class SehriIftarCalendarScreen extends ConsumerWidget {
  final String? initialHijriDate;

  const SehriIftarCalendarScreen({
    super.key,
    this.initialHijriDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sehriIftarCalendarProvider(initialHijriDate));
    final notifier = ref.read(sehriIftarCalendarProvider(initialHijriDate).notifier);
    
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final String monthName = localizations.translate('hijri_month_${state.selectedMonth}');
    final String titleText = '$monthName ${localizations.localizeDigits(state.selectedYear.toString())}';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${localizations.translate('sehri')} & ${localizations.translate('iftar')}',
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Hijri Month Navigation Selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.06),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: AppTheme.warmGold,
                    onPressed: () {
                      int newMonth = state.selectedMonth - 1;
                      int newYear = state.selectedYear;
                      if (newMonth < 1) {
                        newMonth = 12;
                        newYear -= 1;
                      }
                      notifier.changeMonth(newMonth, newYear);
                    },
                  ),
                  Text(
                    titleText,
                    style: const TextStyle(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.premiumGold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: AppTheme.warmGold,
                    onPressed: () {
                      int newMonth = state.selectedMonth + 1;
                      int newYear = state.selectedYear;
                      if (newMonth > 12) {
                        newMonth = 1;
                        newYear += 1;
                      }
                      notifier.changeMonth(newMonth, newYear);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Header Row for the Table List
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    localizations.translate('tab_date').toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    localizations.translate('sehri').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    localizations.translate('iftar').toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body Content (Loading / Error / List)
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.warmGold),
                  )
                : state.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : state.timings.isEmpty
                        ? Center(
                            child: Text(
                              localizations.translate('no_timings_found'),
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            itemCount: state.timings.length,
                            itemBuilder: (context, index) {
                              final item = state.timings[index];
                              final bool isToday = _isDateToday(item.date);
                              
                              // Extract Hijri Day Number from string (e.g. "1 Ramadan 1447" -> "01")
                              String hijriDayStr = '';
                              if (item.hijriDate.isNotEmpty) {
                                final parts = item.hijriDate.split(' ').where((e) => e.isNotEmpty).toList();
                                if (parts.isNotEmpty) {
                                  hijriDayStr = parts[0].padLeft(2, '0');
                                }
                              }

                              // Parse and format Gregorian date
                              String gregDateStr = '';
                              try {
                                final parts = item.date.split('-');
                                if (parts.length >= 3) {
                                  final dt = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                                  gregDateStr = DateFormat('EEE, d MMM', localizations.locale.languageCode).format(dt);
                                }
                              } catch (_) {
                                gregDateStr = item.date;
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? AppTheme.warmGold.withOpacity(0.08)
                                      : theme.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isToday
                                        ? AppTheme.warmGold
                                        : theme.dividerColor.withOpacity(0.06),
                                    width: isToday ? 1.5 : 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                                  child: Row(
                                    children: [
                                      // Hijri Day Number & Gregorian Tag
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  localizations.localizeDigits(hijriDayStr),
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: isToday ? AppTheme.premiumGold : theme.colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  monthName,
                                                  style: TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 11,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              localizations.localizeDigits(gregDateStr),
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 11,
                                                color: theme.colorScheme.onSurface.withOpacity(0.55),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Sehri Time (Imsak)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatTo12Hour(localizations, item.imsak),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),

                                      // Iftar Time (Maghrib)
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          _formatTo12Hour(localizations, item.maghrib),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isToday ? AppTheme.premiumGold : theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  bool _isDateToday(String dateStr) {
    try {
      final now = DateTime.now();
      final parts = dateStr.split('-');
      if (parts.length < 3) return false;
      return now.day == int.parse(parts[0]) &&
          now.month == int.parse(parts[1]) &&
          now.year == int.parse(parts[2]);
    } catch (_) {
      return false;
    }
  }

  String _formatTo12Hour(AppLocalizations localizations, String time24) {
    if (time24.isEmpty) return '';
    try {
      if (time24.contains('(')) {
        time24 = time24.split('(')[0].trim();
      }
      final parts = time24.split(':');
      if (parts.length < 2) return localizations.localizeDigits(time24);
      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      final formatted = '$hour12:$minuteStr $period';
      return localizations.localizeDigits(formatted);
    } catch (_) {
      return localizations.localizeDigits(time24);
    }
  }
}
