import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/components/settings/settings_option_tile.dart';
import 'package:spiceease/components/settings/settings_section.dart';
import 'package:spiceease/features/settings/about_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final packageInfoState = ref.watch(aboutControllerProvider);
    final controller = ref.read(aboutControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.about),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // App Info Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ImageIcon(
                    const AssetImage('assets/icons/spiceease_logo.png'),
                    color: theme.colorScheme.primary,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SpiceEase',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  packageInfoState.when(
                    data: (packageInfo) => packageInfo != null
                        ? Column(
                            children: [
                              Text(
                                '${localizations.version}: ${packageInfo.version}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              Text(
                                '${localizations.buildNumber}: ${packageInfo.buildNumber}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, _) => Text(
                      localizations.unableToLoadVersionInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // App Information Section
          SettingsSection(
            title: localizations.appInfo,
            children: [
              SettingsOptionTile(
                icon: Icons.person_outline,
                title: localizations.developer,
                subtitle: 'Lucas Villa',
                onTap: () => _launchUrl(
                  context,
                  controller,
                  'https://github.com/k4ts0v/',
                ),
              ),
              SettingsOptionTile(
                icon: Icons.code_outlined,
                title: localizations.sourceCode,
                subtitle: localizations.viewOnGitHub,
                onTap: () => _launchUrl(
                  context,
                  controller,
                  'https://github.com/k4ts0v/spiceease',
                ),
              ),
              SettingsOptionTile(
                icon: Icons.description_outlined,
                title: localizations.licenses,
                subtitle: localizations.openSourceLicenses,
                onTap: () => _showLicensePage(context, packageInfoState.value),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Contact Section
          SettingsSection(
            title: localizations.contact,
            children: [
              SettingsOptionTile(
                icon: Icons.bug_report_outlined,
                title: localizations.reportBug,
                subtitle: localizations.reportBugsOnGitHub,
                onTap: () =>
                    _launchGitHubIssue(context, controller, "bugReport"),
              ),
              SettingsOptionTile(
                icon: Icons.lightbulb_outline,
                title: localizations.requestFeature,
                subtitle: localizations.suggestFeaturesOnGitHub,
                onTap: () =>
                    _launchGitHubIssue(context, controller, "featureRequest"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(
    BuildContext context,
    AboutController controller,
    String url,
  ) async {
    final launched = await controller.launchUrlExternal(url);

    if (!launched && context.mounted) {
      _showUrlDialog(context, controller, url);
    }
  }

  Future<void> _launchGitHubIssue(
    BuildContext context,
    AboutController controller,
    String issueType,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final launched =
        await controller.launchGitHubIssue(issueType, localizations);

    if (!launched && context.mounted) {
      final issueUrl =
          controller.createGitHubIssueUrl(issueType, localizations);
      _showGitHubIssueDialog(context, controller, issueType, issueUrl);
    }
  }

  void _showGitHubIssueDialog(
    BuildContext context,
    AboutController controller,
    String issueType,
    String url,
  ) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.bug_report,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text('${localizations.create} $issueType')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.unableToOpenGitHubAutomatically(issueType)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: SelectableText(
                url,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
          FilledButton.icon(
            onPressed: () {
              controller.copyToClipboard(url);
              Navigator.pop(context);
              _showSnackBar(context, localizations.gitHubIssueUrlCopied);
            },
            icon: const Icon(Icons.copy),
            label: Text(localizations.copyUrl),
          ),
        ],
      ),
    );
  }

  void _showUrlDialog(
    BuildContext context,
    AboutController controller,
    String url,
  ) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.open_in_browser,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(localizations.openLink)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.unableToOpenLinkAutomatically),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: SelectableText(
                url,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.close),
          ),
          FilledButton.icon(
            onPressed: () {
              controller.copyToClipboard(url);
              Navigator.pop(context);
              _showSnackBar(context, localizations.urlCopied);
            },
            icon: const Icon(Icons.copy),
            label: Text(localizations.copyUrl),
          ),
        ],
      ),
    );
  }

  void _showLicensePage(BuildContext context, packageInfo) {
    final localizations = AppLocalizations.of(context)!;

    try {
      showLicensePage(
        context: context,
        applicationName: 'SpiceEase',
        applicationVersion: packageInfo?.version ?? '1.0.0',
        applicationIcon: ImageIcon(
          const AssetImage('assets/icons/spiceease_logo.png'),
          color: Theme.of(context).colorScheme.primary,
          size: 48,
        ),
      );
    } catch (e) {
      debugPrint('Error showing license page: $e');
      _showSnackBar(context, localizations.unableToShowLicenses);
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: localizations.ok,
          onPressed: () {},
        ),
      ),
    );
  }
}
