import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/dashboard/domain/prayer_models.dart';

class PrayerCalendarScreen extends ConsumerStatefulWidget {
  const PrayerCalendarScreen({super.key});

  @override
  ConsumerState<PrayerCalendarScreen> createState() => _PrayerCalendarScreenState();
}

class _PrayerCalendarScreenState extends ConsumerState<PrayerCalendarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    final notifier = ref.read(prayerCalendarProvider.notifier);
    final String tabName = _getTabName(_tabController.index);
    notifier.changeTab(tabName);
  }

  String _getTabName(int index) {
    switch (index) {
      case 1:
        return 'month';
      case 2:
        return 'date';
      case 0:
      default:
        return 'week';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    ref.read(prayerCalendarProvider.notifier).resetState();
    super.dispose();
  }

  String _formatTo12Hour(String time24) {
    final localizations = AppLocalizations.of(context);
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final calendarState = ref.watch(prayerCalendarProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('view_calendar'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.warmGold,
          labelColor: theme.brightness == Brightness.dark ? AppTheme.warmGold : theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.55),
          tabs: [
            Tab(text: localizations.translate('tab_week')),
            Tab(text: localizations.translate('tab_month')),
            Tab(text: localizations.translate('tab_date')),
          ],
        ),
      ),
      body: calendarState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.warmGold),
            )
          : calendarState.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      calendarState.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildWeekTab(context, calendarState.weeklyTimings, localizations, theme),
                    _buildMonthTab(context, calendarState.monthlyTimings, localizations, theme),
                    _buildDateTab(context, calendarState, localizations, theme),
                  ],
                ),
    );
  }

  Widget _buildWeekTab(
    BuildContext context,
    List<PrayerTimes> timings,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    if (timings.isEmpty) {
      return Center(child: Text(localizations.translate('no_timings_found')));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: timings.length,
      itemBuilder: (context, index) {
        final timing = timings[index];
        return _WeeklyDayCard(
          timing: timing,
          isToday: _isDateToday(timing.date),
          localizations: localizations,
          theme: theme,
          format12Hour: _formatTo12Hour,
          showHelpDialog: (title, body) => _showPrayerInfoDialog(context, localizations, title, body),
        );
      },
    );
  }

  Widget _buildMonthTab(
    BuildContext context,
    List<PrayerTimes> timings,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    if (timings.isEmpty) {
      return Center(child: Text(localizations.translate('no_timings_found')));
    }

    return Column(
      children: [
        // Month Selector Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  final state = ref.read(prayerCalendarProvider);
                  int newMonth = state.selectedMonth - 1;
                  int newYear = state.selectedYear;
                  if (newMonth < 1) {
                    newMonth = 12;
                    newYear--;
                  }
                  ref.read(prayerCalendarProvider.notifier).changeMonth(newMonth, newYear);
                },
              ),
              Text(
                _formatMonthYear(context, ref.watch(prayerCalendarProvider).selectedMonth, ref.watch(prayerCalendarProvider).selectedYear),
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  final state = ref.read(prayerCalendarProvider);
                  int newMonth = state.selectedMonth + 1;
                  int newYear = state.selectedYear;
                  if (newMonth > 12) {
                    newMonth = 1;
                    newYear++;
                  }
                  ref.read(prayerCalendarProvider.notifier).changeMonth(newMonth, newYear);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: timings.length,
            itemBuilder: (context, index) {
              final timing = timings[index];
              final isToday = _isDateToday(timing.date);
              final dateParsed = _parseDateString(timing.date);
              final String dayName = dateParsed != null ? DateFormat('EEEE', localizations.locale.languageCode).format(dateParsed) : '';
              final String dateFormatted = dateParsed != null ? localizations.localizeDigits(DateFormat('d MMM yyyy', localizations.locale.languageCode).format(dateParsed)) : localizations.localizeDigits(timing.date);

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 8.0),
                color: isToday
                    ? (theme.brightness == Brightness.dark
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : theme.colorScheme.primary.withOpacity(0.04))
                    : theme.cardTheme.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isToday ? AppTheme.warmGold : theme.dividerColor.withOpacity(0.06),
                    width: isToday ? 1.2 : 1.0,
                  ),
                ),
                child: ListTile(
                  onTap: () => _showDayDetailBottomSheet(context, timing, localizations, theme),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Text(
                        dateFormatted,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.premiumGold,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            localizations.translate('state_active').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    timing.hijriDate.isNotEmpty ? localizations.formatHijriDate(timing.hijriDate) : dayName,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        localizations.translate('tap_view_details'),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          color: theme.brightness == Brightness.dark
                              ? AppTheme.warmGold.withOpacity(0.7)
                              : theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateTab(
    BuildContext context,
    PrayerCalendarState state,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final timing = state.dateTimings.isNotEmpty ? state.dateTimings.first : null;
    final dateParsed = _parseDateString(timing?.date ?? '');
    final String dateStr = dateParsed != null ? localizations.localizeDigits(DateFormat('EEEE, d MMMM yyyy', localizations.locale.languageCode).format(dateParsed)) : '';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.dividerColor.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: state.selectedDate,
                firstDate: DateTime(now.year, now.month, now.day),
                lastDate: now.add(const Duration(days: 365)),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      colorScheme: theme.colorScheme.copyWith(
                        primary: AppTheme.warmGold,
                        onPrimary: Colors.white,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                ref.read(prayerCalendarProvider.notifier).changeDate(pickedDate);
              }
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
                      Icons.calendar_today_rounded,
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
                          localizations.translate('tab_date'),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          localizations.localizeDigits(DateFormat('d MMMM yyyy', localizations.locale.languageCode).format(state.selectedDate)),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    localizations.translate('change'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark
                          ? AppTheme.warmGold
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (timing != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (timing.hijriDate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    localizations.formatHijriDate(timing.hijriDate),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          _DailyTimetableList(
            timing: timing,
            isToday: _isDateToday(timing.date),
            localizations: localizations,
            theme: theme,
            format12Hour: _formatTo12Hour,
            showHelpDialog: (title, body) => _showPrayerInfoDialog(context, localizations, title, body),
          ),
        ],
      ],
    );
  }

  void _showDayDetailBottomSheet(
    BuildContext context,
    PrayerTimes timing,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final dateParsed = _parseDateString(timing.date);
    final String dateStr = dateParsed != null ? localizations.localizeDigits(DateFormat('EEEE, d MMMM yyyy', localizations.locale.languageCode).format(dateParsed)) : localizations.localizeDigits(timing.date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (timing.hijriDate.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                           localizations.formatHijriDate(timing.hijriDate),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: SingleChildScrollView(
                  child: _DailyTimetableList(
                    timing: timing,
                    isToday: _isDateToday(timing.date),
                    localizations: localizations,
                    theme: theme,
                    format12Hour: _formatTo12Hour,
                    showHelpDialog: (title, body) => _showPrayerInfoDialog(context, localizations, title, body),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  bool _isDateToday(String dateStr) {
    final parsed = _parseDateString(dateStr);
    if (parsed == null) return false;
    final now = DateTime.now();
    return parsed.day == now.day && parsed.month == now.month && parsed.year == now.year;
  }

  DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return null;
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return null;
    }
  }

  String _formatMonthYear(BuildContext context, int month, int year) {
    final date = DateTime(year, month);
    final localizations = AppLocalizations.of(context);
    return localizations.localizeDigits(DateFormat('MMMM yyyy', localizations.locale.languageCode).format(date));
  }
}

class _WeeklyDayCard extends StatefulWidget {
  final PrayerTimes timing;
  final bool isToday;
  final AppLocalizations localizations;
  final ThemeData theme;
  final String Function(String) format12Hour;
  final Function(String, String) showHelpDialog;

  const _WeeklyDayCard({
    required this.timing,
    required this.isToday,
    required this.localizations,
    required this.theme,
    required this.format12Hour,
    required this.showHelpDialog,
  });

  @override
  State<_WeeklyDayCard> createState() => _WeeklyDayCardState();
}

class _WeeklyDayCardState extends State<_WeeklyDayCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return null;
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateParsed = _parseDateString(widget.timing.date);
    final String dayName = dateParsed != null ? DateFormat('EEEE', widget.localizations.locale.languageCode).format(dateParsed) : '';
    final String dateFormatted = dateParsed != null ? widget.localizations.localizeDigits(DateFormat('d MMMM yyyy', widget.localizations.locale.languageCode).format(dateParsed)) : widget.localizations.localizeDigits(widget.timing.date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12.0),
      color: widget.isToday
          ? (widget.theme.brightness == Brightness.dark
              ? widget.theme.colorScheme.primary.withOpacity(0.12)
              : widget.theme.colorScheme.primary.withOpacity(0.04))
          : widget.theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isToday ? AppTheme.warmGold : widget.theme.dividerColor.withOpacity(0.06),
          width: widget.isToday ? 1.5 : 1.0,
        ),
      ),
      child: Theme(
        data: widget.theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.isToday,
          onExpansionChanged: (val) {
            setState(() {
              _isExpanded = val;
            });
          },
          title: Row(
            children: [
              Text(
                widget.isToday ? widget.localizations.translate('today') : dayName,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.isToday
                      ? AppTheme.premiumGold
                      : widget.theme.colorScheme.onSurface,
                ),
              ),
              if (widget.isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.premiumGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.localizations.translate('state_active').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateFormatted,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (widget.timing.hijriDate.isNotEmpty) ...[
                const SizedBox(height: 1),
                Text(
                  widget.localizations.formatHijriDate(widget.timing.hijriDate),
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ],
          ),
          trailing: AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: Icon(
              Icons.expand_more_rounded,
              color: widget.isToday ? AppTheme.premiumGold : widget.theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
              child: _DailyTimetableList(
                timing: widget.timing,
                isToday: widget.isToday,
                localizations: widget.localizations,
                theme: widget.theme,
                format12Hour: widget.format12Hour,
                showHelpDialog: widget.showHelpDialog,
              ),
            ),
          ],
        ),
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

class _DailyTimetableList extends ConsumerWidget {
  final PrayerTimes timing;
  final bool isToday;
  final AppLocalizations localizations;
  final ThemeData theme;
  final String Function(String) format12Hour;
  final Function(String, String) showHelpDialog;

  const _DailyTimetableList({
    required this.timing,
    required this.isToday,
    required this.localizations,
    required this.theme,
    required this.format12Hour,
    required this.showHelpDialog,
  });

  DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length < 3) return null;
      return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parsed = _parseDateString(timing.date);
    final bool isFriday = parsed?.weekday == DateTime.friday;
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
    final String currentKey = isToday ? (countdown?.currentPrayerKey ?? '') : '';
    final String activeKey = isToday ? (countdown?.nextPrayerKey ?? '') : '';

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

        if (isToday) {
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
        }

        final Color textColor = isCurrent
            ? AppTheme.premiumGold
            : (isUpcoming
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface);

        final FontWeight textWeight = (isCurrent || isUpcoming) ? FontWeight.bold : FontWeight.w500;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? AppTheme.warmGold
                  : (isUpcoming
                      ? theme.colorScheme.primary.withOpacity(0.3)
                      : theme.dividerColor.withOpacity(0.04)),
              width: isCurrent ? 1.2 : (isUpcoming ? 1.0 : 0.8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    getPrayerIcon(item.key),
                    size: 18,
                    color: isCurrent
                        ? AppTheme.premiumGold
                        : (isUpcoming
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.55)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    localizations.translate((isFriday && item.key == 'dhuhr') ? 'jumah_prayer' : item.key),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: textWeight,
                      color: textColor,
                    ),
                  ),
                  if (isCurrent || isUpcoming) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.premiumGold : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        localizations.translate(isCurrent ? 'state_active' : 'state_upcoming').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (item.key == 'ishraq' || item.key == 'chasht_duha' || item.key == 'tahajjud_prayer') ...[
                    const SizedBox(width: 4),
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
                        size: 14,
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
                      fontSize: 12,
                      fontWeight: textWeight,
                      color: textColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 10,
                      color: isCurrent
                          ? AppTheme.warmGold
                          : theme.colorScheme.onSurface.withOpacity(0.25),
                    ),
                  ),
                  Text(
                    format12Hour(item.endTime),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
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
