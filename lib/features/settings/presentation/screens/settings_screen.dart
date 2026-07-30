import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/profile/presentation/screens/profile_screen.dart';
import 'package:adeen/features/dashboard/presentation/screens/calculation_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final activeThemeMode = ref.watch(themeModeProvider);
    final activePreset = ref.watch(colorPresetProvider);
    final activeLocale = ref.watch(localeProvider);
    final activeMethod = ref.watch(calculationMethodProvider);

    // Get localized active method name
    final methods = {
      0: localizations.translate('method_jafari'),
      1: localizations.translate('method_karachi'),
      2: localizations.translate('method_isna'),
      3: localizations.translate('method_mwl'),
      4: localizations.translate('method_umm_al_qura'),
      5: localizations.translate('method_egyptian'),
      7: localizations.translate('method_tehran'),
      8: localizations.translate('method_gulf'),
      9: localizations.translate('method_kuwait'),
      10: localizations.translate('method_qatar'),
      11: localizations.translate('method_singapore'),
      12: localizations.translate('method_france'),
      13: localizations.translate('method_turkey'),
      14: localizations.translate('method_russia'),
      15: localizations.translate('method_moonsighting'),
      16: localizations.translate('method_dubai'),
      17: localizations.translate('method_jakim'),
      18: localizations.translate('method_tunisia'),
      19: localizations.translate('method_algeria'),
      20: localizations.translate('method_kemenag'),
      21: localizations.translate('method_morocco'),
      22: localizations.translate('method_portugal'),
      23: localizations.translate('method_jordan'),
    };
    final activeMethodName = methods[activeMethod] ?? 'Umm Al-Qura';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          localizations.translate('settings'),
          style: TextStyle(
            fontFamily: theme.appBarTheme.titleTextStyle?.fontFamily,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.warmGold : theme.colorScheme.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          children: [
            // ── SECTION: ACCOUNT ──
            _buildSectionHeader(localizations.translate('profile').toUpperCase(), theme),
            const SizedBox(height: 8),
            _buildProfileCard(context, localizations, theme),

            const SizedBox(height: 24),

            // ── SECTION: LANGUAGE ──
            _buildSectionHeader(localizations.translate('change_lang').split(' / ')[0].toUpperCase(), theme),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildLanguageDropdown(context, ref, activeLocale, localizations, theme),
              ),
            ),

            const SizedBox(height: 24),

            // ── SECTION: THEME & STYLE (Combined Theme Mode & Color Scheme) ──
            _buildSectionHeader(localizations.translate('theme_mode').toUpperCase(), theme),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.08), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThemeModeRow(context, ref, activeThemeMode, localizations, theme),
                    const SizedBox(height: 16),
                    Divider(color: theme.dividerColor.withOpacity(0.12), height: 1),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 18, color: Theme.of(context).colorScheme.tertiary),
                        const SizedBox(width: 8),
                        Text(
                          localizations.translate('color_scheme'),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildColorPresetList(context, ref, activePreset, localizations, theme),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── SECTION: CALCULATIONS ──
            _buildSectionHeader(localizations.translate('calculation_settings').toUpperCase(), theme),
            const SizedBox(height: 8),
            Card(
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
                      builder: (context) => const CalculationSettingsScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                        child: Icon(Icons.settings_suggest_outlined, color: Theme.of(context).colorScheme.tertiary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localizations.translate('calculation_settings'),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeMethodName,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildProfileCard(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.12),
          child: Icon(Icons.person, color: theme.colorScheme.primary),
        ),
        title: Text(
          localizations.translate('profile'),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          localizations.translate('hub_profile_sub'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLanguageDropdown(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final languages = {
      'en': 'English (LTR)',
      'ar': 'العربية (RTL)',
      'bn': 'বাংলা (Bengali)',
      'hi': 'हिन्दी (Hindi)',
      'ur': 'اردو (Urdu - RTL)',
      'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
      'tr': 'Türkçe (Turkish)',
      'fr': 'Français (French)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.translate_rounded, size: 18, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(width: 8),
            Text(
              localizations.translate('change_lang').split(' / ')[0],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: locale.languageCode,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.12)),
            ),
          ),
          dropdownColor: theme.cardTheme.color,
          icon: Icon(Icons.arrow_drop_down_rounded, color: Theme.of(context).colorScheme.tertiary),
          style: TextStyle(
            fontFamily: 'Poppins',
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
          ),
          items: languages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) {
              ref.read(localeProvider.notifier).setLocale(val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildThemeModeRow(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.palette_outlined, size: 18, color: Theme.of(context).colorScheme.tertiary),
            const SizedBox(width: 8),
            Text(
              localizations.translate('theme_mode'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildThemeOption(ref, ThemeMode.system, Icons.brightness_auto_rounded, localizations.translate('theme_system'), themeMode, theme),
            const SizedBox(width: 8),
            _buildThemeOption(ref, ThemeMode.light, Icons.light_mode_rounded, localizations.translate('theme_light'), themeMode, theme),
            const SizedBox(width: 8),
            _buildThemeOption(ref, ThemeMode.dark, Icons.dark_mode_rounded, localizations.translate('theme_dark'), themeMode, theme),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    WidgetRef ref,
    ThemeMode targetMode,
    IconData icon,
    String label,
    ThemeMode currentMode,
    ThemeData theme,
  ) {
    final isSelected = currentMode == targetMode;
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(themeModeProvider.notifier).updateThemeMode(targetMode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? (isDark ? theme.colorScheme.primary : Colors.transparent)
                  : theme.dividerColor.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4),
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPresetList(
    BuildContext context,
    WidgetRef ref,
    String activePreset,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final presets = [
      _PresetItem('emerald', localizations.translate('color_emerald'), AppTheme.emeraldDeep, AppTheme.emeraldSage),
      _PresetItem('sapphire', localizations.translate('color_sapphire'), AppTheme.sapphireDeep, AppTheme.sapphireRoyal),
      _PresetItem('ruby', localizations.translate('color_ruby'), AppTheme.rubyDeep, AppTheme.rubyAmber),
    ];

    return Column(
      children: presets.map((preset) {
        final isSelected = activePreset == preset.key;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            onTap: () => ref.read(colorPresetProvider.notifier).updatePreset(preset.key),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected
                    ? (isDark ? theme.colorScheme.primary : Colors.transparent)
                    : theme.dividerColor.withOpacity(0.15),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            tileColor: isSelected
                ? theme.colorScheme.primary.withOpacity(0.04)
                : Colors.transparent,
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 14,
                  height: 24,
                  decoration: BoxDecoration(
                    color: preset.color1,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                  ),
                ),
                Container(
                  width: 14,
                  height: 24,
                  decoration: BoxDecoration(
                    color: preset.color2,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                  ),
                ),
              ],
            ),
            title: Text(
              preset.label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _PresetItem {
  final String key;
  final String label;
  final Color color1;
  final Color color2;
  _PresetItem(this.key, this.label, this.color1, this.color2);
}
