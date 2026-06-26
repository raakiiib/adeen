import 'package:flutter/material.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/screens/prayer_tracker_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/qaza_tracker_screen.dart';
import 'package:adeen/features/profile/presentation/screens/profile_screen.dart';
import 'package:adeen/features/settings/presentation/screens/settings_screen.dart';
import 'package:adeen/features/quiz/presentation/screens/quiz_session_screen.dart';
import 'package:adeen/features/mosque_map/presentation/screens/mosque_map_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentTab;
  final ValueChanged<int> onTabSelected;

  const AppDrawer({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Premium dynamic header gradient depending on Light/Dark themes
    final headerGradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.cardTheme.color ?? const Color(0xFF1E2622),
              (theme.cardTheme.color ?? const Color(0xFF1E2622)).withOpacity(0.85),
            ],
          )
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.85),
            ],
          );

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: true, // Forces drawer contents to start BELOW status bar/notch
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Elegant Drawer Header Container
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: headerGradient,
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.warmGold.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 16,
                      color: AppTheme.warmGold.withOpacity(0.85),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Adeen • عدين',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.warmGold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    localizations.translate('bismillah'),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.grey[400] : Colors.white.withOpacity(0.75),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable list items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  // 1. Section Header: NAVIGATION
                  _buildSectionHeader(
                    theme,
                    localizations.translate('app_title').split(' • ')[0].toUpperCase(),
                  ),

                  // Dashboard
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    title: localizations.translate('app_title').split(' • ')[0],
                    isSelected: currentTab == 0,
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),

                  // Nearby Mosques
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.map_outlined,
                    activeIcon: Icons.map,
                    title: localizations.translate('mosques'),
                    isSelected: false,
                    showTrailingChevron: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MosqueMapScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 2. Section Header: SPIRITUAL TOOLS
                  _buildSectionHeader(
                    theme,
                    localizations.translate('prayer_tracker').split(' ')[0].toUpperCase(),
                  ),

                  // Prayer Tracker Screen
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.task_alt_outlined,
                    activeIcon: Icons.task_alt,
                    title: localizations.translate('prayer_tracker'),
                    isSelected: false,
                    showTrailingChevron: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrayerTrackerScreen(),
                        ),
                      );
                    },
                  ),

                  // Qaza Tracker Screen
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.history_outlined,
                    activeIcon: Icons.history,
                    title: localizations.translate('qaza_tracker'),
                    isSelected: false,
                    showTrailingChevron: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QazaTrackerScreen(),
                        ),
                      );
                    },
                  ),

                  // Quranic Quiz Screen
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.quiz_outlined,
                    activeIcon: Icons.quiz,
                    title: localizations.translate('quiz'),
                    isSelected: false,
                    showTrailingChevron: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizSessionScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 3. Section Header: PREFERENCES
                  _buildSectionHeader(
                    theme,
                    localizations.translate('settings').split(' ')[0].toUpperCase(),
                  ),

                  // Profile
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    title: localizations.translate('profile').split(' & ')[0],
                    isSelected: false,
                    showTrailingChevron: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),

                  // Settings
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    title: localizations.translate('settings').split(' & ')[0],
                    isSelected: false,
                    showTrailingChevron: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'v1.0.0 • Offline First',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: theme.brightness == Brightness.dark
              ? AppTheme.warmGold.withOpacity(0.4)
              : theme.colorScheme.primary.withOpacity(0.4),
          letterSpacing: 1.3,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    bool showTrailingChevron = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visual gold indicator bar on selected item
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 3.5,
              height: isSelected ? 22 : 0,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isSelected) const SizedBox(width: 8) else const SizedBox(width: 11),
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
              size: 22,
            ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.9),
          ),
        ),
        trailing: showTrailingChevron
            ? Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.35),
              )
            : null,
        selected: isSelected,
        selectedTileColor: isDark
            ? theme.colorScheme.primary.withOpacity(0.12)
            : theme.colorScheme.primary.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
    );
  }
}
