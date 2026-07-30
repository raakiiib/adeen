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

    final accentColor = Theme.of(context).colorScheme.tertiary;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final headerBgColor = isDark
        ? theme.colorScheme.surface
        : theme.colorScheme.primary.withOpacity(0.04);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Elegant Medallion Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                color: headerBgColor,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withOpacity(0.08),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 15,
                      color: primaryColor.withOpacity(0.85),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.translate('bismillah'),
                    style: TextStyle(
                      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
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
                  _buildSectionHeader(context, localizations.translate('home').toUpperCase()),

                  // Dashboard
                  _buildDrawerItem(
                    context: context,
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    title: localizations.translate('home'),
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

                  _buildSectionHeader(context, localizations.translate('prayer_tracker').split(' ')[0].toUpperCase()),

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

                  _buildSectionHeader(context, localizations.translate('settings').split(' ')[0].toUpperCase()),

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

            // Footer Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Text(
                    'v1.0.0 • Offline First',
                    style: TextStyle(
                      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Made with devotion',
                    style: TextStyle(
                      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                      fontSize: 9,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.25),
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

  Widget _buildSectionHeader(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: theme.textTheme.bodyMedium?.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
          letterSpacing: 1.2,
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
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? primaryColor : theme.colorScheme.onSurface.withOpacity(0.55),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: theme.textTheme.bodyMedium?.fontFamily,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? primaryColor : theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        trailing: showTrailingChevron
            ? Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              )
            : null,
        selected: isSelected,
        selectedTileColor: primaryColor.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
