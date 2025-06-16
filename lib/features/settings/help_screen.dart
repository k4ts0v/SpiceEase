import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/features/settings/help_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final helpState = ref.watch(helpControllerProvider);
    final controller = ref.read(helpControllerProvider.notifier);
    print('Test Provider Hash: ${helpControllerProvider.hashCode}');

    // Set context in controller for navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setContext(context);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.help),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: helpState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                for (int sectionIndex = 0; sectionIndex < helpState.sections.length; sectionIndex++) ...[
                  SettingsSection(
                    title: helpState.sections[sectionIndex].title,
                    children: helpState.sections[sectionIndex].options.map((option) {
                      return SettingsOptionTile(
                        icon: option.icon,
                        title: controller.getOptionTitle(option.titleKey, localizations),
                        subtitle: controller.getOptionSubtitle(option.subtitleKey, localizations),
                        onTap: option.onTap,
                      );
                    }).toList(),
                  ),
                  if (sectionIndex < helpState.sections.length - 1)
                    const SizedBox(height: 24),
                ],
              ],
            ),
    );
  }
}