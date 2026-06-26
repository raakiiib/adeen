class PrayerTimes {
  final String date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String imsak;
  final String method;

  PrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.imsak,
    required this.method,
  });

  Map<String, String> toJson() {
    return {
      'date': date,
      'fajr': fajr,
      'sunrise': sunrise,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
      'imsak': imsak,
      'method': method,
    };
  }

  factory PrayerTimes.fromJson(Map<dynamic, dynamic> json) {
    return PrayerTimes(
      date: json['date'] as String? ?? '',
      fajr: json['fajr'] as String? ?? '00:00',
      sunrise: json['sunrise'] as String? ?? '00:00',
      dhuhr: json['dhuhr'] as String? ?? '00:00',
      asr: json['asr'] as String? ?? '00:00',
      maghrib: json['maghrib'] as String? ?? '00:00',
      isha: json['isha'] as String? ?? '00:00',
      imsak: json['imsak'] as String? ?? '00:00',
      method: json['method'] as String? ?? 'Umm Al-Qura',
    );
  }

  /// Converts timings to direct DateTime objects for calculations.
  /// date is in 'dd-MM-yyyy' format. time is in 'HH:mm' (24h) format.
  DateTime getPrayerDateTime(String timeString) {
    final dateParts = date.split('-');
    if (dateParts.length != 3) return DateTime.now();
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final timeParts = timeString.split(' ')[0].split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    return DateTime(year, month, day, hour, minute);
  }

  // Sunrise Forbidden: sunrise to sunrise + 15 minutes
  DateTime get sunriseForbiddenStart => getPrayerDateTime(sunrise);
  DateTime get sunriseForbiddenEnd => getPrayerDateTime(sunrise).add(const Duration(minutes: 15));

  // Midday Forbidden (Zawal): dhuhr - 10 minutes to dhuhr
  DateTime get zawalForbiddenStart => getPrayerDateTime(dhuhr).subtract(const Duration(minutes: 10));
  DateTime get zawalForbiddenEnd => getPrayerDateTime(dhuhr);

  // Sunset Forbidden: maghrib - 15 minutes to maghrib
  DateTime get sunsetForbiddenStart => getPrayerDateTime(maghrib).subtract(const Duration(minutes: 15));
  DateTime get sunsetForbiddenEnd => getPrayerDateTime(maghrib);

  // Ishraq: sunrise + 15 minutes to sunrise + 45 minutes
  DateTime get ishraqStart => getPrayerDateTime(sunrise).add(const Duration(minutes: 15));
  DateTime get ishraqEnd => getPrayerDateTime(sunrise).add(const Duration(minutes: 45));

  // Tahajjud Start: overall window is Isha to Fajr next day
  DateTime get tahajjudStart => getPrayerDateTime(isha);
  
  // Tahajjud End: Fajr of next day (requires passing tomorrow's Fajr, or we can approximate)
  DateTime getTahajjudEnd(PrayerTimes? tomorrow) {
    if (tomorrow != null) {
      return tomorrow.getPrayerDateTime(tomorrow.fajr);
    }
    // Fallback: today's Fajr plus 24 hours
    return getPrayerDateTime(fajr).add(const Duration(days: 1));
  }

  // Tahajjud Best (Last Third of Night):
  // Islamic night is from Sunset (Maghrib) to Dawn (Fajr of next day).
  DateTime getTahajjudBestStart(PrayerTimes? tomorrow) {
    final nightStart = getPrayerDateTime(maghrib);
    final nightEnd = getTahajjudEnd(tomorrow);
    final nightDuration = nightEnd.difference(nightStart);
    // 2/3 of the night duration added to night start
    return nightStart.add(Duration(milliseconds: (nightDuration.inMilliseconds * 2) ~/ 3));
  }

  // Checks if a given time is in any forbidden period, returning the description key of the active forbidden period if so.
  String? getActiveForbiddenPeriodKey(DateTime time) {
    if ((time.isAfter(sunriseForbiddenStart) || time.isAtSameMomentAs(sunriseForbiddenStart)) &&
        (time.isBefore(sunriseForbiddenEnd) || time.isAtSameMomentAs(sunriseForbiddenEnd))) {
      return 'forbidden_sunrise';
    }
    if ((time.isAfter(zawalForbiddenStart) || time.isAtSameMomentAs(zawalForbiddenStart)) &&
        (time.isBefore(zawalForbiddenEnd) || time.isAtSameMomentAs(zawalForbiddenEnd))) {
      return 'forbidden_zawal';
    }
    if ((time.isAfter(sunsetForbiddenStart) || time.isAtSameMomentAs(sunsetForbiddenStart)) &&
        (time.isBefore(sunsetForbiddenEnd) || time.isAtSameMomentAs(sunsetForbiddenEnd))) {
      return 'forbidden_sunset';
    }
    return null;
  }
}

class TrackerLog {
  final String date;
  final Map<String, bool> completedPrayers;
  final Map<String, int> qazaCounts;
  final bool fastedToday;

  TrackerLog({
    required this.date,
    required this.completedPrayers,
    required this.qazaCounts,
    required this.fastedToday,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'completedPrayers': completedPrayers,
      'qazaCounts': qazaCounts,
      'fastedToday': fastedToday,
    };
  }

  factory TrackerLog.fromJson(Map<dynamic, dynamic> json) {
    // Safely cast maps
    final completedMap = <String, bool>{};
    if (json['completedPrayers'] != null) {
      (json['completedPrayers'] as Map).forEach((k, v) {
        completedMap[k.toString()] = v as bool;
      });
    }

    final qazaMap = <String, int>{};
    if (json['qazaCounts'] != null) {
      (json['qazaCounts'] as Map).forEach((k, v) {
        qazaMap[k.toString()] = (v as num).toInt();
      });
    }

    return TrackerLog(
      date: json['date'] as String? ?? '',
      completedPrayers: completedMap,
      qazaCounts: qazaMap,
      fastedToday: json['fastedToday'] as bool? ?? false,
    );
  }

  factory TrackerLog.empty(String date) {
    return TrackerLog(
      date: date,
      completedPrayers: {
        'Fajr': false,
        'Dhuhr': false,
        'Asr': false,
        'Maghrib': false,
        'Isha': false,
      },
      qazaCounts: {
        'Fajr': 0,
        'Dhuhr': 0,
        'Asr': 0,
        'Maghrib': 0,
        'Isha': 0,
      },
      fastedToday: false,
    );
  }

  TrackerLog copyWith({
    Map<String, bool>? completedPrayers,
    Map<String, int>? qazaCounts,
    bool? fastedToday,
  }) {
    return TrackerLog(
      date: date,
      completedPrayers: completedPrayers ?? Map.from(this.completedPrayers),
      qazaCounts: qazaCounts ?? Map.from(this.qazaCounts),
      fastedToday: fastedToday ?? this.fastedToday,
    );
  }
}
