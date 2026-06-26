import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';
import 'package:adeen/features/profile/presentation/screens/profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    final activeThemeMode = ref.watch(themeModeProvider);
    final activePreset = ref.watch(colorPresetProvider);
    final activeLocale = ref.watch(localeProvider);
    final activeMethod = ref.watch(calculationMethodProvider);
    final timingsState = ref.watch(prayerTimesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.translate('settings'),
          style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 0. User Profile Navigation Card
            _buildProfileCard(context, localizations, theme),
            const SizedBox(height: 16),

            // 1. Language Preference Card
            _buildLanguageCard(context, ref, activeLocale, localizations, theme),
            const SizedBox(height: 16),

            // 2. Theme Mode Selection Card
            _buildThemeModeCard(context, ref, activeThemeMode, localizations, theme),
            const SizedBox(height: 16),

            // 3. Color Preset Preset Selector
            _buildColorPresetCard(context, ref, activePreset, localizations, theme),
            const SizedBox(height: 16),

            // 4. Calculation Method Selector
            _buildCalculationMethodCard(context, ref, activeMethod, timingsState, localizations, theme),
          ],
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.warmGold.withOpacity(0.12),
          child: Icon(Icons.person, color: theme.colorScheme.primary),
        ),
        title: Text(
          localizations.translate('profile'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          localizations.translate('hub_profile_sub'),
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: theme.colorScheme.primary,
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

  Widget _buildLanguageCard(
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate, size: 20, color: AppTheme.warmGold),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('change_lang').split(' / ')[0],
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: locale.languageCode,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
              ),
              dropdownColor: theme.cardTheme.color,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.warmGold),
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
        ),
      ),
    );
  }

  Widget _buildThemeModeCard(
    BuildContext context,
    WidgetRef ref,
    ThemeMode themeMode,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined, size: 20, color: AppTheme.warmGold),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('theme_mode'),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildThemeOption(ref, ThemeMode.system, Icons.brightness_auto, localizations.translate('theme_system'), themeMode, theme),
                const SizedBox(width: 8),
                _buildThemeOption(ref, ThemeMode.light, Icons.light_mode_outlined, localizations.translate('theme_light'), themeMode, theme),
                const SizedBox(width: 8),
                _buildThemeOption(ref, ThemeMode.dark, Icons.dark_mode_outlined, localizations.translate('theme_dark'), themeMode, theme),
              ],
            ),
          ],
        ),
      ),
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
                  ? theme.colorScheme.primary
                  : Colors.grey.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
                size: 20,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorPresetCard(
    BuildContext context,
    WidgetRef ref,
    String activePreset,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    final presets = [
      _PresetItem('emerald', localizations.translate('color_emerald'), AppTheme.emeraldDeep, AppTheme.emeraldSage),
      _PresetItem('sapphire', localizations.translate('color_sapphire'), AppTheme.sapphireDeep, AppTheme.sapphireRoyal),
      _PresetItem('ruby', localizations.translate('color_ruby'), AppTheme.rubyDeep, AppTheme.rubyAmber),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.style_outlined, size: 20, color: AppTheme.warmGold),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('color_scheme'),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: presets.map((preset) {
                final isSelected = activePreset == preset.key;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => ref.read(colorPresetProvider.notifier).updatePreset(preset.key),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey.withOpacity(0.15),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    tileColor: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.04)
                        : Colors.transparent,
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Dual color preview swatch
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
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: theme.colorScheme.primary)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationMethodCard(
    BuildContext context,
    WidgetRef ref,
    int activeMethod,
    PrayerTimesState timingsState,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_suggest_outlined, size: 20, color: AppTheme.warmGold),
                const SizedBox(width: 8),
                Text(
                  localizations.translate('method'),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showCalculationMethodDialog(context, ref, activeMethod, methods, localizations, theme),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        methods[activeMethod] ?? 'Umm Al-Qura (Makkah)',
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppTheme.warmGold),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalculationMethodDialog(
    BuildContext context,
    WidgetRef ref,
    int activeMethod,
    Map<int, String> methods,
    AppLocalizations localizations,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            localizations.translate('method'),
            style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
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
                      ref.read(calculationMethodProvider.notifier).updateMethod(val);
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
            )
          ],
        );
      },
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
