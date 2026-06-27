import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adeen/core/database/database_service.dart';
import 'package:adeen/core/localization/app_localizations.dart';
import 'package:adeen/core/theme/app_theme.dart';
import 'package:adeen/features/dashboard/presentation/controllers/prayer_controller.dart';

class LanguageSetupDialog extends ConsumerStatefulWidget {
  const LanguageSetupDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSetupDialog(),
    );
  }

  @override
  ConsumerState<LanguageSetupDialog> createState() => _LanguageSetupDialogState();
}

class _LanguageSetupDialogState extends ConsumerState<LanguageSetupDialog> {
  String? _selectedCode;
  bool _userInteracted = false;

  final Map<String, _LanguageItem> _languages = {
    'en': _LanguageItem('English', 'English'),
    'ar': _LanguageItem('العربية', 'Arabic'),
    'bn': _LanguageItem('বাংলা', 'Bengali'),
    'hi': _LanguageItem('हिन्दी', 'Hindi'),
    'ur': _LanguageItem('اردو', 'Urdu'),
    'id': _LanguageItem('Bahasa Indonesia', 'Indonesian'),
    'ms': _LanguageItem('Bahasa Melayu', 'Malay'),
    'tr': _LanguageItem('Türkçe', 'Turkish'),
    'fr': _LanguageItem('Français', 'French'),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    // Listen to locale changes (background geo-detection might update it)
    final activeLocale = ref.watch(localeProvider);
    
    // Automatically select the active/detected locale if the user hasn't interacted
    if (!_userInteracted) {
      _selectedCode = activeLocale.languageCode;
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: MainAxisAlignmentScrollLimit(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header Icon & Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.warmGold.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: AppTheme.warmGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.translate('select_language'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: 'Playfair Display',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizations.translate('lang_detect_desc'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Languages Grid
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final code = _languages.keys.elementAt(index);
                  final item = _languages[code]!;
                  final isSelected = _selectedCode == code;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCode = code;
                        _userInteracted = true;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.06)
                            : theme.cardColor.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.grey.withOpacity(0.15),
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nativeName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.titleMedium?.color,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                item.englishName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: isSelected
                                      ? theme.colorScheme.primary.withOpacity(0.7)
                                      : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            ElevatedButton(
              onPressed: () async {
                if (_selectedCode != null) {
                  // Save preference immediately
                  await ref.read(localeProvider.notifier).setLocale(_selectedCode!);
                  await DatabaseService.saveLanguagePreferenceAsked(true);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: Text(
                    localizations.translate('confirm'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageItem {
  final String nativeName;
  final String englishName;
  const _LanguageItem(this.nativeName, this.englishName);
}

// A simple utility widget to restrict column spacing/height in flexible configurations
class MainAxisAlignmentScrollLimit extends StatelessWidget {
  final Widget child;
  const MainAxisAlignmentScrollLimit({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: child,
    );
  }
}
