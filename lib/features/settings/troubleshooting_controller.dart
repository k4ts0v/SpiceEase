import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Data models
class TroubleshootingIssue {
  final String titleKey;
  final IconData icon;
  final String descriptionKey;
  final List<String> solutionKeys;

  const TroubleshootingIssue({
    required this.titleKey,
    required this.icon,
    required this.descriptionKey,
    required this.solutionKeys,
  });
}

// Controller state
class TroubleshootingState {
  final List<TroubleshootingIssue> issues;
  final bool isLoading;

  const TroubleshootingState({
    required this.issues,
    this.isLoading = false,
  });

  TroubleshootingState copyWith({
    List<TroubleshootingIssue>? issues,
    bool? isLoading,
  }) {
    return TroubleshootingState(
      issues: issues ?? this.issues,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Controller
class TroubleshootingController extends StateNotifier<TroubleshootingState> {
  TroubleshootingController() : super(TroubleshootingState(issues: _createIssues()));

  static List<TroubleshootingIssue> _createIssues() {
    return [
      const TroubleshootingIssue(
        titleKey: 'appCrashesOrFreezes',
        icon: Icons.error_outline,
        descriptionKey: 'appCrashesDescription',
        solutionKeys: [
          'forceCloseRestart',
          'restartDevice',
          'checkStorageSpace',
          'updateApp',
          'clearAppCache',
          'uninstallReinstall',
        ],
      ),
      const TroubleshootingIssue(
        titleKey: 'dataSyncIssues',
        icon: Icons.sync_problem,
        descriptionKey: 'dataSyncDescription',
        solutionKeys: [
          'checkInternetConnection',
          'checkCorrectDate',
          'ensureNoFilters',
          'forceCloseReopen',
          'tryLoggingAgain',
        ],
      ),
      const TroubleshootingIssue(
        titleKey: 'performanceIssues',
        icon: Icons.speed,
        descriptionKey: 'performanceDescription',
        solutionKeys: [
          'closeBackgroundApps',
          'restartDevice',
          'clearOldData',
          'checkAvailableStorage',
          'updateApp',
        ],
      ),
    ];
  }

  // Getters
  List<TroubleshootingIssue> get issues => state.issues;
  bool get isLoading => state.isLoading;

  String getIssueTitle(String titleKey, AppLocalizations localizations) {
    switch (titleKey) {
      case 'appCrashesOrFreezes':
        return localizations.appCrashesOrFreezes;
      case 'dataSyncIssues':
        return localizations.dataSyncIssues;
      case 'performanceIssues':
        return localizations.performanceIssues;
      default:
        return titleKey;
    }
  }

  String getIssueDescription(String descriptionKey, AppLocalizations localizations) {
    switch (descriptionKey) {
      case 'appCrashesDescription':
        return localizations.appCrashesDescription;
      case 'dataSyncDescription':
        return localizations.dataSyncDescription;
      case 'performanceDescription':
        return localizations.performanceDescription;
      default:
        return descriptionKey;
    }
  }

  String getSolutionText(String solutionKey, AppLocalizations localizations) {
    switch (solutionKey) {
      case 'forceCloseRestart':
        return localizations.forceCloseRestart;
      case 'restartDevice':
        return localizations.restartDevice;
      case 'checkStorageSpace':
        return localizations.checkStorageSpace;
      case 'updateApp':
        return localizations.updateApp;
      case 'clearAppCache':
        return localizations.clearAppCache;
      case 'uninstallReinstall':
        return localizations.uninstallReinstall;
      case 'checkInternetConnection':
        return localizations.checkInternetConnection;
      case 'checkCorrectDate':
        return localizations.checkCorrectDate;
      case 'ensureNoFilters':
        return localizations.ensureNoFilters;
      case 'forceCloseReopen':
        return localizations.forceCloseReopen;
      case 'tryLoggingAgain':
        return localizations.tryLoggingAgain;
      case 'closeBackgroundApps':
        return localizations.closeBackgroundApps;
      case 'clearOldData':
        return localizations.clearOldData;
      case 'checkAvailableStorage':
        return localizations.checkAvailableStorage;
      default:
        return solutionKey;
    }
  }
}

// Provider
final troubleshootingControllerProvider = StateNotifierProvider<TroubleshootingController, TroubleshootingState>((ref) {
  return TroubleshootingController();
});