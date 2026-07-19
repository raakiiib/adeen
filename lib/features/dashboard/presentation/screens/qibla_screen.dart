import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

// Kaaba coordinates
const double _meccaLat = 21.4225;
const double _meccaLng = 39.8262;

/// Calculate the bearing (degrees from North) from [userLat]/[userLng] to Mecca.
double _calcQiblaBearing(double userLat, double userLng) {
  final lat1 = userLat * math.pi / 180;
  final lat2 = _meccaLat * math.pi / 180;
  final dLng = (_meccaLng - userLng) * math.pi / 180;
  final y = math.sin(dLng) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(dLng);
  final bearing = math.atan2(y, x) * 180 / math.pi;
  return (bearing + 360) % 360;
}

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locationState = ref.watch(locationProvider);

    Widget bodyWidget;

    if (locationState.status == 'loading') {
      bodyWidget = _buildLoading(context, localizations);
    } else if (locationState.status == 'denied') {
      bodyWidget = _buildStatusMessage(
        context,
        icon: Icons.location_off_rounded,
        message: localizations.translate('qibla_error'),
        isError: true,
        action: TextButton.icon(
          onPressed: () => Geolocator.openAppSettings(),
          icon: const Icon(Icons.settings_outlined, size: 18),
          label: const Text('Open Settings'),
        ),
      );
    } else if (locationState.status == 'error') {
      bodyWidget = _buildStatusMessage(
        context,
        icon: Icons.location_searching_rounded,
        message: 'Could not determine location. Please try again.',
        isError: true,
        action: TextButton.icon(
          onPressed: () => ref.read(locationProvider.notifier).determinePosition(),
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retry'),
        ),
      );
    } else {
      // locationState.status == 'loaded'
      final qiblaBearing = _calcQiblaBearing(locationState.latitude, locationState.longitude);
      bodyWidget = _buildCompassStream(
        context,
        localizations,
        theme,
        isDark,
        qiblaBearing,
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('qibla_finder'),
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
        ),
      ),
      body: bodyWidget,
    );
  }

  Widget _buildLoading(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.warmGold),
          const SizedBox(height: 16),
          Text(
            localizations.translate('qibla_searching'),
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(
    BuildContext context, {
    required IconData icon,
    required String message,
    bool isError = false,
    Widget? action,
  }) {
    final theme = Theme.of(context);
    final color = isError ? theme.colorScheme.error : AppTheme.warmGold;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: color,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// The compass stream only requires the magnetometer — no GPS needed here.
  Widget _buildCompassStream(
    BuildContext context,
    AppLocalizations localizations,
    ThemeData theme,
    bool isDark,
    double qiblaBearing,
  ) {
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      return _buildStatusMessage(
        context,
        icon: Icons.sensors_off_rounded,
        message: localizations.translate('qibla_sensor_unavailable'),
        isError: true,
      );
    }

    return StreamBuilder<CompassEvent>(
      stream: compassStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading(context, localizations);
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.heading == null) {
          return _buildStatusMessage(
            context,
            icon: Icons.sensors_off_rounded,
            message: localizations.translate('qibla_sensor_unavailable'),
            isError: true,
          );
        }

        final double heading = snapshot.data!.heading!;
        // Needle should rotate to offset (qiblaBearing - deviceHeading) from screen top
        final double needleTurns = (qiblaBearing - heading) / 360.0;

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ── Direction info card ──
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.warmGold.withOpacity(0.08)
                        : theme.colorScheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.warmGold.withOpacity(0.18)
                          : theme.colorScheme.primary.withOpacity(0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.explore_outlined,
                        color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('qibla_direction'),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppTheme.warmGold.withOpacity(0.7)
                                    : theme.colorScheme.primary.withOpacity(0.7),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              localizations.localizeDigits(
                                '${qiblaBearing.toStringAsFixed(1)}°',
                              ),
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.warmGold
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Compass ──
                Center(
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer ring
                        Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                isDark ? const Color(0xFF1E1E2E) : Colors.white,
                                isDark ? const Color(0xFF13131F) : const Color(0xFFF5F5F8),
                              ],
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.warmGold.withOpacity(0.25)
                                  : theme.colorScheme.primary.withOpacity(0.15),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.08),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                        ),

                        // Cardinal labels (fixed — don't rotate with needle)
                        ..._buildCardinalLabels(theme, isDark),

                        // Tick marks
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: _CompassTickPainter(
                            color: isDark
                                ? Colors.white.withOpacity(0.12)
                                : Colors.black.withOpacity(0.08),
                          ),
                        ),

                        // Rotating needle
                        AnimatedRotation(
                          turns: needleTurns,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          child: CustomPaint(
                            size: const Size(240, 240),
                            painter: _QiblaNeedlePainter(
                              goldColor: AppTheme.warmGold,
                              isDark: isDark,
                            ),
                          ),
                        ),

                        // Centre jewel
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.warmGold,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.warmGold.withOpacity(0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Kaaba label ──
                Column(
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Icon(
                        Icons.mosque_rounded,
                        size: 40,
                        color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'الكعبة المشرفة',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Makkah al-Mukarramah',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Calibration tip ──
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'For best accuracy, move your device in a figure-8 pattern to calibrate the compass.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildCardinalLabels(ThemeData theme, bool isDark) {
    final labelColor = isDark
        ? Colors.white.withOpacity(0.6)
        : theme.colorScheme.onSurface.withOpacity(0.5);
    const double radius = 128;
    const labels = ['N', 'E', 'S', 'W'];
    const angles = [math.pi * 1.5, 0.0, math.pi * 0.5, math.pi];

    return List.generate(labels.length, (i) {
      final dx = math.cos(angles[i]) * radius;
      final dy = math.sin(angles[i]) * radius;
      return Positioned(
        left: 150 + dx - 10,
        top: 150 + dy - 10,
        child: SizedBox(
          width: 20,
          height: 20,
          child: Center(
            child: Text(
              labels[i],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: labels[i] == 'N'
                    ? (isDark ? AppTheme.warmGold : theme.colorScheme.primary)
                    : labelColor,
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ── Custom Painters ──

class _CompassTickPainter extends CustomPainter {
  final Color color;
  _CompassTickPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    for (int i = 0; i < 72; i++) {
      final angle = (i * 5) * math.pi / 180;
      final isMajor = i % 9 == 0;
      final innerRadius = outerRadius - (isMajor ? 12 : 6);
      final p1 = center +
          Offset(math.cos(angle - math.pi / 2) * outerRadius,
              math.sin(angle - math.pi / 2) * outerRadius);
      final p2 = center +
          Offset(math.cos(angle - math.pi / 2) * innerRadius,
              math.sin(angle - math.pi / 2) * innerRadius);
      paint.strokeWidth = isMajor ? 1.5 : 0.8;
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(_CompassTickPainter old) => old.color != color;
}

class _QiblaNeedlePainter extends CustomPainter {
  final Color goldColor;
  final bool isDark;
  _QiblaNeedlePainter({required this.goldColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLen = size.height / 2 - 22;

    final needlePath = Path()
      ..moveTo(center.dx, center.dy - needleLen)
      ..lineTo(center.dx - 8, center.dy + 20)
      ..lineTo(center.dx, center.dy + 8)
      ..lineTo(center.dx + 8, center.dy + 20)
      ..close();

    canvas.drawPath(
      needlePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [goldColor, goldColor.withOpacity(0.6)],
        ).createShader(
          Rect.fromCenter(center: center, width: 20, height: needleLen),
        )
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      needlePath,
      Paint()
        ..color = goldColor.withOpacity(0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
        ..style = PaintingStyle.fill,
    );

    final counterPath = Path()
      ..moveTo(center.dx, center.dy + needleLen)
      ..lineTo(center.dx - 6, center.dy - 14)
      ..lineTo(center.dx, center.dy - 4)
      ..lineTo(center.dx + 6, center.dy - 14)
      ..close();

    canvas.drawPath(
      counterPath,
      Paint()
        ..color = isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_QiblaNeedlePainter old) =>
      old.goldColor != goldColor || old.isDark != isDark;
}
