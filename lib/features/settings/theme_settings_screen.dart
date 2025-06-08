import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/theme_settings_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeSettingsControllerProvider);
    final controller = ref.read(themeSettingsControllerProvider.notifier);
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.theme),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Mode Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    localizations.themeMode,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...ThemeMode.values.map((mode) => RadioListTile<ThemeMode>(
                      title: Text(
                          controller.getThemeModeTitle(mode, localizations)),
                      subtitle: Text(
                          controller.getThemeModeSubtitle(mode, localizations)),
                      value: mode,
                      groupValue: themeState.currentThemeMode,
                      onChanged: (value) {
                        if (value != null) {
                          controller.setThemeMode(value);
                        }
                      },
                    )),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Accent Color Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    localizations.accentColor,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: themeState.availableColors.map((colorOption) {
                      final isSelected =
                          controller.isAccentColorSelected(colorOption.color);

                      return GestureDetector(
                        onTap: () =>
                            controller.setAccentColor(colorOption.color),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorOption.color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.outline.withValues(alpha: 0.3),
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: controller.getIconColorForBackground(
                                      colorOption.color),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
