import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutController extends StateNotifier<AsyncValue<PackageInfo?>> {
  AboutController() : super(const AsyncValue.loading()) {
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      state = AsyncValue.data(info);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<bool> launchUrlExternal(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      bool launched = false;

      try {
        launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } on PlatformException catch (e) {
        debugPrint('Platform exception when checking/launching URL: $e');
        try {
          launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e2) {
          debugPrint('Failed to launch URL directly: $e2');
        }
      } catch (e) {
        debugPrint('Other error when launching URL: $e');
      }

      return launched;
    } catch (e) {
      debugPrint('Error parsing or launching URL: $e');
      return false;
    }
  }

  String createGitHubIssueUrl(
      String issueType, AppLocalizations localizations) {
    final packageInfo = state.value;
    String template = '';
    String title = '';

    switch (issueType.toLowerCase()) {
      case 'bugreport':
        title = '${localizations.bugReportTitle}: ';
        template = '''
**${localizations.describeTheBug}**
${localizations.bugDescription}

**${localizations.toReproduce}**
${localizations.stepsToReproduce}:
1. ${localizations.stepGoTo}
2. ${localizations.stepClickOn}
3. ${localizations.stepScrollTo}
4. ${localizations.stepSeeError}

**${localizations.expectedBehavior}**
${localizations.expectedBehaviorDescription}

**${localizations.screenshots}**
${localizations.screenshotsDescription}

**${localizations.deviceInformation}:**
- ${localizations.device}: [e.g. iPhone 12, Samsung Galaxy S21]
- ${localizations.operatingSystem}: [e.g. iOS 15.0, Android 12]
- ${localizations.appVersion}: ${packageInfo?.version ?? localizations.unknown}

**${localizations.additionalContext}**
${localizations.additionalContextDescription}
''';
        break;
      case 'featurerequest':
        title = '${localizations.featureRequestTitle}: ';
        template = '''
**${localizations.featureRequestProblem}**
${localizations.featureRequestProblemDescription}

**${localizations.describeSolution}**
${localizations.describeSolutionDescription}

**${localizations.describeAlternatives}**
${localizations.describeAlternativesDescription}

**${localizations.additionalContext}**
${localizations.featureAdditionalContext}

**${localizations.useCase}**
${localizations.useCaseDescription}
''';
        break;
    }

    final String encodedTitle = Uri.encodeComponent(title);
    final String encodedTemplate = Uri.encodeComponent(template);
    return 'https://github.com/k4ts0v/spiceease/issues/new?title=$encodedTitle&body=$encodedTemplate';
  }

  Future<bool> launchGitHubIssue(
      String issueType, AppLocalizations localizations) async {
    try {
      final String issueUrl = createGitHubIssueUrl(issueType, localizations);
      return await launchUrlExternal(issueUrl);
    } catch (e) {
      debugPrint('Error creating GitHub issue URL: $e');
      return false;
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}

final aboutControllerProvider =
    StateNotifierProvider<AboutController, AsyncValue<PackageInfo?>>((ref) {
  return AboutController();
});
