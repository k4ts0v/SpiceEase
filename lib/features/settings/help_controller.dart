import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/features/settings/faq_screen.dart';
import 'package:spiceease/features/settings/tips_screen.dart';
import 'package:spiceease/features/settings/troubleshooting_screen.dart';
import 'package:spiceease/features/settings/tutorials_screen.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

// Data models
class HelpOption {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final VoidCallback onTap;

  const HelpOption({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.onTap,
  });
}

class HelpSection {
  final String title;
  final List<HelpOption> options;

  const HelpSection({
    required this.title,
    required this.options,
  });
}

// Controller state
class HelpState {
  final List<HelpSection> sections;
  final bool isLoading;

  const HelpState({
    required this.sections,
    this.isLoading = false,
  });

  HelpState copyWith({
    List<HelpSection>? sections,
    bool? isLoading,
  }) {
    return HelpState(
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Controller
class HelpController extends StateNotifier<HelpState> {
  HelpController() : super(const HelpState(sections: [])) {
    _initializeSections();
  }

  void _initializeSections() {
    final sections = [
      HelpSection(
        title: 'Getting Started',
        options: [
          HelpOption(
            icon: Icons.school_outlined,
            titleKey: 'tutorials',
            subtitleKey: 'tutorialsSubtitle',
            onTap: () => _navigateToTutorials(),
          ),
          HelpOption(
            icon: Icons.tips_and_updates_outlined,
            titleKey: 'tips',
            subtitleKey: 'tipsSubtitle',
            onTap: () => _navigateToTips(),
          ),
        ],
      ),
      HelpSection(
        title: 'Support',
        options: [
          HelpOption(
            icon: Icons.help_outline,
            titleKey: 'frequentlyAskedQuestions',
            subtitleKey: 'frequentlyAskedQuestionsSubtitle',
            onTap: () => _navigateToFAQ(),
          ),
          HelpOption(
            icon: Icons.build_outlined,
            titleKey: 'troubleshooting',
            subtitleKey: 'troubleshootingSubtitle',
            onTap: () => _navigateToTroubleshooting(),
          ),
          HelpOption(
            icon: Icons.support_agent_outlined,
            titleKey: 'contactSupport',
            subtitleKey: 'contactSupportSubtitle',
            onTap: () => _contactSupport(),
          ),
          HelpOption(
            icon: Icons.feedback_outlined,
            titleKey: 'sendFeedback',
            subtitleKey: 'sendFeedbackSubtitle',
            onTap: () => _sendFeedback(),
          ),
        ],
      ),
    ];

    state = state.copyWith(sections: sections);
  }

  // Navigation methods
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void _navigateToTutorials() {
    if (_context != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => const TutorialsScreen(),
        ),
      );
    }
  }

  void _navigateToTips() {
    if (_context != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => const TipsScreen(),
        ),
      );
    }
  }

  void _navigateToFAQ() {
    if (_context != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => const FAQScreen(),
        ),
      );
    }
  }

  void _navigateToTroubleshooting() {
    if (_context != null) {
      Navigator.of(_context!).push(
        MaterialPageRoute(
          builder: (context) => const TroubleshootingScreen(),
        ),
      );
    }
  }

  void _showEmailDialog(String email, String subject) {
    if (_context != null) {
      showDialog(
        context: _context!,
        builder: (context) => AlertDialog(
          title: const Text('Contact Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Please send an email to:'),
              const SizedBox(height: 16),
              SelectableText(
                email,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text('Subject: $subject'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: email));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Email copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Email'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _contactSupport() async {
    debugPrint('Contact support called');
    const email = 'support@spiceease.com';
    const subject = 'SpiceEase Support Request';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showEmailDialog(email, subject);
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      _showEmailDialog(email, subject);
    }
  }

  void _sendFeedback() async {
    debugPrint('Send feedback called');
    const email = 'feedback@spiceease.com';
    const subject = 'SpiceEase Feedback';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=$subject',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _showEmailDialog(email, subject);
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      _showEmailDialog(email, subject);
    }
  }

  // Getters
  List<HelpSection> get sections => state.sections;
  bool get isLoading => state.isLoading;

  String getOptionTitle(String titleKey, AppLocalizations localizations) {
    switch (titleKey) {
      case 'tutorials':
        return localizations.tutorials;
      case 'tips':
        return localizations.tips;
      case 'frequentlyAskedQuestions':
        return localizations.frequentlyAskedQuestions;
      case 'troubleshooting':
        return localizations.troubleshooting;
      case 'contactSupport':
        return localizations.contactSupport;
      case 'sendFeedback':
        return localizations.sendFeedback;
      default:
        return titleKey;
    }
  }

  String getOptionSubtitle(String subtitleKey, AppLocalizations localizations) {
    switch (subtitleKey) {
      case 'tutorialsSubtitle':
        return localizations.tutorialsSubtitle;
      case 'tipsSubtitle':
        return localizations.tipsSubtitle;
      case 'frequentlyAskedQuestionsSubtitle':
        return localizations.frequentlyAskedQuestionsSubtitle;
      case 'troubleshootingSubtitle':
        return localizations.troubleshootingSubtitle;
      case 'contactSupportSubtitle':
        return localizations.contactSupportSubtitle;
      case 'sendFeedbackSubtitle':
        return localizations.sendFeedbackSubtitle;
      default:
        return subtitleKey;
    }
  }
}

// Provider
final helpControllerProvider =
    StateNotifierProvider<HelpController, HelpState>((ref) {
  return HelpController();
});