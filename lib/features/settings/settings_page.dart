// import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/components/app_header.dart';
import 'package:spiceease/core/auth/auth_provider.dart';
import 'package:spiceease/features/settings/settings_controller.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/l10n/app_localizations.dart';
// Import the AppHeader widget

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(settingsControllerProvider);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).value;

    return Scaffold(
      body: SafeArea(
        // Added SafeArea for content below AppHeader
        child: Column(
          // Wrap body content in a Column
          children: [
            AppHeader(sectionName: localizations.settings), // Add AppHeader
            Expanded(
              // Make ListView take remaining space
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Account Section (only show if user is signed in)
                  SettingsSection(
                    title: localizations.account ?? 'Account',
                    children: [
                      SettingsOptionTile(
                        icon: Icons.account_circle_outlined,
                        title:
                            localizations.accountSettings ?? 'Account Settings',
                        subtitle: localizations.manageAccountInfo ??
                            'Manage your account information',
                        onTap: () =>
                            controller.navigateToAccountSettings(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Appearance Section
                  SettingsSection(
                    title: localizations.appearance,
                    children: [
                      SettingsOptionTile(
                        icon: Icons.palette_outlined,
                        title: localizations.theme,
                        subtitle: _getThemeSubtitle(
                            controller.currentThemeMode, localizations),
                        onTap: () =>
                            controller.navigateToThemeSettings(context),
                      ),
                      SettingsOptionTile(
                        icon: Icons.color_lens_outlined,
                        title: localizations.accentColor,
                        subtitle: localizations.customizeAppColors,
                        trailing: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: controller.currentAccentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        onTap: () =>
                            controller.navigateToThemeSettings(context),
                      ),
                      SettingsOptionTile(
                        icon: Icons.dark_mode_outlined,
                        title: localizations.darkMode,
                        subtitle: localizations.toggleDarkMode,
                        trailing: Switch(
                          value: controller.isDarkMode,
                          onChanged: (_) => controller.toggleDarkMode(),
                        ),
                        onTap: () => controller.toggleDarkMode(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Language & Region Section
                  SettingsSection(
                    title: localizations.languageAndRegion,
                    children: [
                      SettingsOptionTile(
                        icon: Icons.language_outlined,
                        title: localizations.language,
                        subtitle: _getLanguageSubtitle(
                            controller.currentLocale, localizations),
                        onTap: () =>
                            controller.navigateToLanguageSettings(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Support & Information Section
                  SettingsSection(
                    title: localizations.supportAndInfo,
                    children: [
                      SettingsOptionTile(
                        icon: Icons.help_outline,
                        title: localizations.help,
                        subtitle: localizations.faqAndSupport,
                        onTap: () => controller.navigateToHelp(context),
                      ),
                      SettingsOptionTile(
                        icon: Icons.info_outline,
                        title: localizations.about,
                        subtitle: localizations.appInfo,
                        onTap: () => controller.navigateToAbout(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeSubtitle(
      ThemeMode themeMode, AppLocalizations localizations) {
    switch (themeMode) {
      case ThemeMode.light:
        return localizations.lightTheme;
      case ThemeMode.dark:
        return localizations.darkTheme;
      case ThemeMode.system:
        return localizations.systemTheme;
    }
  }

  String _getLanguageSubtitle(Locale? locale, AppLocalizations localizations) {
    if (locale == null) return localizations.systemDefault;

    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
