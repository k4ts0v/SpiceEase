import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/language_settings_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageState = ref.watch(languageSettingsControllerProvider);
    final controller = ref.read(languageSettingsControllerProvider.notifier);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.language),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: languageState.availableLanguages.map((languageOption) {
                controller.isLanguageSelected(languageOption.locale);

                return RadioListTile<Locale>(
                  title: Text(languageOption.englishName),
                  subtitle: Text(languageOption.nativeName),
                  value: languageOption.locale,
                  groupValue: languageState.currentLocale,
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLanguage(value);
                      _showLanguageChangedSnackBar(
                        context,
                        localizations,
                        controller.getLanguageDisplayName(value),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageChangedSnackBar(
    BuildContext context,
    AppLocalizations localizations,
    String languageName,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${localizations.languageChangedTo} $languageName',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
