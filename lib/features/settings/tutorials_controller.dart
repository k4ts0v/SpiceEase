import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Data models
class Tutorial {
  final String titleKey;
  final String durationKey;
  final String difficultyKey;
  final IconData icon;
  final String categoryKey;
  final List<String> stepKeys;

  const Tutorial({
    required this.titleKey,
    required this.durationKey,
    required this.difficultyKey,
    required this.icon,
    required this.categoryKey,
    required this.stepKeys,
  });
}

// Controller state
class TutorialsState {
  final List<Tutorial> tutorials;
  final Map<String, List<Tutorial>> groupedTutorials;
  final bool isLoading;

  const TutorialsState({
    required this.tutorials,
    required this.groupedTutorials,
    this.isLoading = false,
  });

  TutorialsState copyWith({
    List<Tutorial>? tutorials,
    Map<String, List<Tutorial>>? groupedTutorials,
    bool? isLoading,
  }) {
    return TutorialsState(
      tutorials: tutorials ?? this.tutorials,
      groupedTutorials: groupedTutorials ?? this.groupedTutorials,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Controller
class TutorialsController extends StateNotifier<TutorialsState> {
  TutorialsController()
      : super(const TutorialsState(tutorials: [], groupedTutorials: {})) {
    _initializeTutorials();
  }

  void _initializeTutorials() {
    final tutorials = _createTutorials();
    final groupedTutorials = _groupTutorialsByCategory(tutorials);

    state = state.copyWith(
      tutorials: tutorials,
      groupedTutorials: groupedTutorials,
    );
  }

  static List<Tutorial> _createTutorials() {
    return [
      // Getting Started
      const Tutorial(
        titleKey: 'tutorialUnderstandingIconGrid',
        durationKey: 'tutorial2Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.grid_view,
        categoryKey: 'tutorialCategoryGettingStarted',
        stepKeys: [
          'tutorialIconGridStep1',
          'tutorialIconGridStep2',
          'tutorialIconGridStep3',
          'tutorialIconGridStep4',
          'tutorialIconGridStep5',
          'tutorialIconGridStep6',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialUnderstandingListView',
        durationKey: 'tutorial2Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.list,
        categoryKey: 'tutorialCategoryGettingStarted',
        stepKeys: [
          'tutorialListViewStep1',
          'tutorialListViewStep2',
          'tutorialListViewStep3',
          'tutorialListViewStep4',
          'tutorialListViewStep5',
          'tutorialListViewStep6',
          'tutorialListViewStep7',
        ],
      ),

      // Tasks
      const Tutorial(
        titleKey: 'tutorialCreatingFirstTask',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.task_alt,
        categoryKey: 'tutorialCategoryTasks',
        stepKeys: [
          'tutorialFirstTaskStep1',
          'tutorialFirstTaskStep2',
          'tutorialFirstTaskStep3',
          'tutorialFirstTaskStep4',
          'tutorialFirstTaskStep5',
          'tutorialFirstTaskStep6',
          'tutorialFirstTaskStep7',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialEditingDeletingTasks',
        durationKey: 'tutorial2Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.edit,
        categoryKey: 'tutorialCategoryTasks',
        stepKeys: [
          'tutorialEditTaskStep1',
          'tutorialEditTaskStep2',
          'tutorialEditTaskStep3',
          'tutorialEditTaskStep4',
          'tutorialEditTaskStep5',
          'tutorialEditTaskStep6',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialWorkingWithSubtasks',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialIntermediate',
        icon: Icons.account_tree,
        categoryKey: 'tutorialCategoryTasks',
        stepKeys: [
          'tutorialSubtasksStep1',
          'tutorialSubtasksStep2',
          'tutorialSubtasksStep3',
          'tutorialSubtasksStep4',
          'tutorialSubtasksStep5',
          'tutorialSubtasksStep6',
          'tutorialSubtasksStep7',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialTaskEstimationTimePlanning',
        durationKey: 'tutorial4Min',
        difficultyKey: 'tutorialIntermediate',
        icon: Icons.timer_outlined,
        categoryKey: 'tutorialCategoryTasks',
        stepKeys: [
          'tutorialEstimationStep1',
          'tutorialEstimationStep2',
          'tutorialEstimationStep3',
          'tutorialEstimationStep4',
          'tutorialEstimationStep5',
          'tutorialEstimationStep6',
        ],
      ),

      // Habits
      const Tutorial(
        titleKey: 'tutorialSettingUpDailyHabits',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.repeat,
        categoryKey: 'tutorialCategoryHabits',
        stepKeys: [
          'tutorialHabitsStep1',
          'tutorialHabitsStep2',
          'tutorialHabitsStep3',
          'tutorialHabitsStep4',
          'tutorialHabitsStep5',
          'tutorialHabitsStep6',
          'tutorialHabitsStep7',
          'tutorialHabitsStep8',
          'tutorialHabitsStep9',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialManagingHabitStreaks',
        durationKey: 'tutorial2Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.local_fire_department,
        categoryKey: 'tutorialCategoryHabits',
        stepKeys: [
          'tutorialStreaksStep1',
          'tutorialStreaksStep2',
          'tutorialStreaksStep3',
          'tutorialStreaksStep4',
          'tutorialStreaksStep5',
          'tutorialStreaksStep6',
          'tutorialStreaksStep7',
          'tutorialStreaksStep8',
        ],
      ),

      // Health Tracking
      const Tutorial(
        titleKey: 'tutorialTrackingHealthSymptoms',
        durationKey: 'tutorial4Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.health_and_safety,
        categoryKey: 'tutorialCategoryHealth',
        stepKeys: [
          'tutorialSymptomsStep1',
          'tutorialSymptomsStep2',
          'tutorialSymptomsStep3',
          'tutorialSymptomsStep4',
          'tutorialSymptomsStep5',
          'tutorialSymptomsStep6',
          'tutorialSymptomsStep7',
          'tutorialSymptomsStep8',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialAddingMedicationTracking',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.medication,
        categoryKey: 'tutorialCategoryHealth',
        stepKeys: [
          'tutorialMedicationStep1',
          'tutorialMedicationStep2',
          'tutorialMedicationStep3',
          'tutorialMedicationStep4',
          'tutorialMedicationStep5',
          'tutorialMedicationStep6',
          'tutorialMedicationStep7',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialRecordingMoodEntries',
        durationKey: 'tutorial2Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.sentiment_satisfied,
        categoryKey: 'tutorialCategoryHealth',
        stepKeys: [
          'tutorialMoodStep1',
          'tutorialMoodStep2',
          'tutorialMoodStep3',
          'tutorialMoodStep4',
          'tutorialMoodStep5',
          'tutorialMoodStep6',
          'tutorialMoodStep7',
          'tutorialMoodStep8',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialRecordingEnergyEntries',
        durationKey: 'tutorial2Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.sentiment_satisfied,
        categoryKey: 'tutorialCategoryHealth',
        stepKeys: [
          'tutorialEnergyStep1',
          'tutorialEnergyStep2',
          'tutorialEnergyStep3',
          'tutorialEnergyStep4',
          'tutorialEnergyStep5',
          'tutorialEnergyStep6',
        ],
      ),

      // Time Management
      const Tutorial(
        titleKey: 'tutorialUsingFlowmodoroTechnique',
        durationKey: 'tutorial5Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.timer,
        categoryKey: 'tutorialCategoryTimeManagement',
        stepKeys: [
          'tutorialFlowmodoroStep1',
          'tutorialFlowmodoroStep2',
          'tutorialFlowmodoroStep3',
          'tutorialFlowmodoroStep4',
          'tutorialFlowmodoroStep5',
          'tutorialFlowmodoroStep6',
          'tutorialFlowmodoroStep7',
          'tutorialFlowmodoroStep8',
          'tutorialFlowmodoroStep9',
          'tutorialFlowmodoroStep10',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialManagingKanbanBoard',
        durationKey: 'tutorial4Min',
        difficultyKey: 'tutorialIntermediate',
        icon: Icons.view_column,
        categoryKey: 'tutorialCategoryTimeManagement',
        stepKeys: [
          'tutorialKanbanStep1',
          'tutorialKanbanStep2',
          'tutorialKanbanStep3',
          'tutorialKanbanStep4',
          'tutorialKanbanStep5',
          'tutorialKanbanStep6',
          'tutorialKanbanStep7',
          'tutorialKanbanStep8',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialSchedulingTimeBlocks',
        durationKey: 'tutorial4Min',
        difficultyKey: 'tutorialIntermediate',
        icon: Icons.schedule,
        categoryKey: 'tutorialCategoryTimeManagement',
        stepKeys: [
          'tutorialTimeBlocksStep1',
          'tutorialTimeBlocksStep2',
          'tutorialTimeBlocksStep3',
          'tutorialTimeBlocksStep4',
          'tutorialTimeBlocksStep5',
        ],
      ),

      // Reports & Analytics
      const Tutorial(
        titleKey: 'tutorialUnderstandingReportsCharts',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.analytics,
        categoryKey: 'tutorialCategoryReports',
        stepKeys: [
          'tutorialReportsStep1',
          'tutorialReportsStep2',
          'tutorialReportsStep3',
          'tutorialReportsStep4',
          'tutorialReportsStep5',
          'tutorialReportsStep6',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialCustomizingReportViews',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialIntermediate',
        icon: Icons.tune,
        categoryKey: 'tutorialCategoryReports',
        stepKeys: [
          'tutorialCustomReportsStep1',
          'tutorialCustomReportsStep2',
          'tutorialCustomReportsStep3',
          'tutorialCustomReportsStep4',
          'tutorialCustomReportsStep5',
          'tutorialCustomReportsStep6',
        ],
      ),

      // Settings & Customization
      const Tutorial(
        titleKey: 'tutorialPersonalizingSettings',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.settings,
        categoryKey: 'tutorialCategorySettings',
        stepKeys: [
          'tutorialSettingsStep1',
          'tutorialSettingsStep2',
          'tutorialSettingsStep3',
        ],
      ),
      const Tutorial(
        titleKey: 'tutorialManagingAccount',
        durationKey: 'tutorial3Min',
        difficultyKey: 'tutorialBeginner',
        icon: Icons.account_circle,
        categoryKey: 'tutorialCategorySettings',
        stepKeys: [
          'tutorialAccountStep1',
          'tutorialAccountStep2',
          'tutorialAccountStep3',
        ],
      ),
    ];
  }

  static Map<String, List<Tutorial>> _groupTutorialsByCategory(
      List<Tutorial> tutorials) {
    final grouped = <String, List<Tutorial>>{};
    for (final tutorial in tutorials) {
      grouped.putIfAbsent(tutorial.categoryKey, () => []).add(tutorial);
    }
    return grouped;
  }

  // Getters
  List<Tutorial> get tutorials => state.tutorials;
  Map<String, List<Tutorial>> get groupedTutorials => state.groupedTutorials;
  bool get isLoading => state.isLoading;

  Color getDifficultyColor(String difficultyKey, ThemeData theme) {
    switch (difficultyKey) {
      case 'tutorialBeginner':
        return Colors.green;
      case 'tutorialIntermediate':
        return Colors.orange;
      case 'tutorialAdvanced':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  String getCategoryTitle(String categoryKey, AppLocalizations localizations) {
    switch (categoryKey) {
      case 'tutorialCategoryGettingStarted':
        return localizations.tutorialCategoryGettingStarted;
      case 'tutorialCategoryTasks':
        return localizations.tutorialCategoryTasks;
      case 'tutorialCategoryHabits':
        return localizations.tutorialCategoryHabits;
      case 'tutorialCategoryHealth':
        return localizations.tutorialCategoryHealth;
      case 'tutorialCategoryTimeManagement':
        return localizations.tutorialCategoryTimeManagement;
      case 'tutorialCategoryReports':
        return localizations.tutorialCategoryReports;
      case 'tutorialCategorySettings':
        return localizations.tutorialCategorySettings;
      default:
        return categoryKey;
    }
  }

  String getTutorialTitle(String titleKey, AppLocalizations localizations) {
    switch (titleKey) {
      case 'tutorialUnderstandingIconGrid':
        return localizations.tutorialUnderstandingIconGrid;
      case 'tutorialUnderstandingListView':
        return localizations.tutorialUnderstandingListView;
      case 'tutorialCreatingFirstTask':
        return localizations.tutorialCreatingFirstTask;
      case 'tutorialEditingDeletingTasks':
        return localizations.tutorialEditingDeletingTasks;
      case 'tutorialWorkingWithSubtasks':
        return localizations.tutorialWorkingWithSubtasks;
      case 'tutorialTaskEstimationTimePlanning':
        return localizations.tutorialTaskEstimationTimePlanning;
      case 'tutorialSettingUpDailyHabits':
        return localizations.tutorialSettingUpDailyHabits;
      case 'tutorialManagingHabitStreaks':
        return localizations.tutorialManagingHabitStreaks;
      case 'tutorialTrackingHealthSymptoms':
        return localizations.tutorialTrackingHealthSymptoms;
      case 'tutorialAddingMedicationTracking':
        return localizations.tutorialAddingMedicationTracking;
      case 'tutorialRecordingMoodEntries':
        return localizations.tutorialRecordingMoodEntries;
      case 'tutorialRecordingEnergyEntries':
        return localizations.tutorialRecordingEnergyEntries;
      case 'tutorialUsingFlowmodoroTechnique':
        return localizations.tutorialUsingFlowmodoroTechnique;
      case 'tutorialManagingKanbanBoard':
        return localizations.tutorialManagingKanbanBoard;
      case 'tutorialSchedulingTimeBlocks':
        return localizations.tutorialSchedulingTimeBlocks;
      case 'tutorialUnderstandingReportsCharts':
        return localizations.tutorialUnderstandingReportsCharts;
      case 'tutorialCustomizingReportViews':
        return localizations.tutorialCustomizingReportViews;
      case 'tutorialPersonalizingSettings':
        return localizations.tutorialPersonalizingSettings;
      case 'tutorialManagingAccount':
        return localizations.tutorialManagingAccount;
      default:
        return titleKey;
    }
  }

  String getDuration(String durationKey, AppLocalizations localizations) {
    switch (durationKey) {
      case 'tutorial2Min':
        return localizations.tutorial2Min;
      case 'tutorial3Min':
        return localizations.tutorial3Min;
      case 'tutorial4Min':
        return localizations.tutorial4Min;
      case 'tutorial5Min':
        return localizations.tutorial5Min;
      default:
        return durationKey;
    }
  }

  String getDifficulty(String difficultyKey, AppLocalizations localizations) {
    switch (difficultyKey) {
      case 'tutorialBeginner':
        return localizations.tutorialBeginner;
      case 'tutorialIntermediate':
        return localizations.tutorialIntermediate;
      case 'tutorialAdvanced':
        return localizations.tutorialAdvanced;
      default:
        return difficultyKey;
    }
  }

  String getStepText(String stepKey, AppLocalizations localizations) {
    switch (stepKey) {
      // Icon Grid Tutorial Steps
      case 'tutorialIconGridStep1':
        return localizations.tutorialIconGridStep1;
      case 'tutorialIconGridStep2':
        return localizations.tutorialIconGridStep2;
      case 'tutorialIconGridStep3':
        return localizations.tutorialIconGridStep3;
      case 'tutorialIconGridStep4':
        return localizations.tutorialIconGridStep4;
      case 'tutorialIconGridStep5':
        return localizations.tutorialIconGridStep5;
      case 'tutorialIconGridStep6':
        return localizations.tutorialIconGridStep6;

      // List View Tutorial Steps
      case 'tutorialListViewStep1':
        return localizations.tutorialListViewStep1;
      case 'tutorialListViewStep2':
        return localizations.tutorialListViewStep2;
      case 'tutorialListViewStep3':
        return localizations.tutorialListViewStep3;
      case 'tutorialListViewStep4':
        return localizations.tutorialListViewStep4;
      case 'tutorialListViewStep5':
        return localizations.tutorialListViewStep5;
      case 'tutorialListViewStep6':
        return localizations.tutorialListViewStep6;
      case 'tutorialListViewStep7':
        return localizations.tutorialListViewStep7;

      // First Task Tutorial Steps
      case 'tutorialFirstTaskStep1':
        return localizations.tutorialFirstTaskStep1;
      case 'tutorialFirstTaskStep2':
        return localizations.tutorialFirstTaskStep2;
      case 'tutorialFirstTaskStep3':
        return localizations.tutorialFirstTaskStep3;
      case 'tutorialFirstTaskStep4':
        return localizations.tutorialFirstTaskStep4;
      case 'tutorialFirstTaskStep5':
        return localizations.tutorialFirstTaskStep5;
      case 'tutorialFirstTaskStep6':
        return localizations.tutorialFirstTaskStep6;
      case 'tutorialFirstTaskStep7':
        return localizations.tutorialFirstTaskStep7;

      // Edit Task Tutorial Steps
      case 'tutorialEditTaskStep1':
        return localizations.tutorialEditTaskStep1;
      case 'tutorialEditTaskStep2':
        return localizations.tutorialEditTaskStep2;
      case 'tutorialEditTaskStep3':
        return localizations.tutorialEditTaskStep3;
      case 'tutorialEditTaskStep4':
        return localizations.tutorialEditTaskStep4;
      case 'tutorialEditTaskStep5':
        return localizations.tutorialEditTaskStep5;
      case 'tutorialEditTaskStep6':
        return localizations.tutorialEditTaskStep6;

      // Subtasks Tutorial Steps
      case 'tutorialSubtasksStep1':
        return localizations.tutorialSubtasksStep1;
      case 'tutorialSubtasksStep2':
        return localizations.tutorialSubtasksStep2;
      case 'tutorialSubtasksStep3':
        return localizations.tutorialSubtasksStep3;
      case 'tutorialSubtasksStep4':
        return localizations.tutorialSubtasksStep4;
      case 'tutorialSubtasksStep5':
        return localizations.tutorialSubtasksStep5;
      case 'tutorialSubtasksStep6':
        return localizations.tutorialSubtasksStep6;
      case 'tutorialSubtasksStep7':
        return localizations.tutorialSubtasksStep7;

      // Estimation Tutorial Steps
      case 'tutorialEstimationStep1':
        return localizations.tutorialEstimationStep1;
      case 'tutorialEstimationStep2':
        return localizations.tutorialEstimationStep2;
      case 'tutorialEstimationStep3':
        return localizations.tutorialEstimationStep3;
      case 'tutorialEstimationStep4':
        return localizations.tutorialEstimationStep4;
      case 'tutorialEstimationStep5':
        return localizations.tutorialEstimationStep5;
      case 'tutorialEstimationStep6':
        return localizations.tutorialEstimationStep6;

      // Habits Tutorial Steps
      case 'tutorialHabitsStep1':
        return localizations.tutorialHabitsStep1;
      case 'tutorialHabitsStep2':
        return localizations.tutorialHabitsStep2;
      case 'tutorialHabitsStep3':
        return localizations.tutorialHabitsStep3;
      case 'tutorialHabitsStep4':
        return localizations.tutorialHabitsStep4;
      case 'tutorialHabitsStep5':
        return localizations.tutorialHabitsStep5;
      case 'tutorialHabitsStep6':
        return localizations.tutorialHabitsStep6;
      case 'tutorialHabitsStep7':
        return localizations.tutorialHabitsStep7;
      case 'tutorialHabitsStep8':
        return localizations.tutorialHabitsStep8;
      case 'tutorialHabitsStep9':
        return localizations.tutorialHabitsStep9;

      // Streaks Tutorial Steps
      case 'tutorialStreaksStep1':
        return localizations.tutorialStreaksStep1;
      case 'tutorialStreaksStep2':
        return localizations.tutorialStreaksStep2;
      case 'tutorialStreaksStep3':
        return localizations.tutorialStreaksStep3;
      case 'tutorialStreaksStep4':
        return localizations.tutorialStreaksStep4;
      case 'tutorialStreaksStep5':
        return localizations.tutorialStreaksStep5;
      case 'tutorialStreaksStep6':
        return localizations.tutorialStreaksStep6;
      case 'tutorialStreaksStep7':
        return localizations.tutorialStreaksStep7;
      case 'tutorialStreaksStep8':
        return localizations.tutorialStreaksStep8;

      // Symptoms Tutorial Steps
      case 'tutorialSymptomsStep1':
        return localizations.tutorialSymptomsStep1;
      case 'tutorialSymptomsStep2':
        return localizations.tutorialSymptomsStep2;
      case 'tutorialSymptomsStep3':
        return localizations.tutorialSymptomsStep3;
      case 'tutorialSymptomsStep4':
        return localizations.tutorialSymptomsStep4;
      case 'tutorialSymptomsStep5':
        return localizations.tutorialSymptomsStep5;
      case 'tutorialSymptomsStep6':
        return localizations.tutorialSymptomsStep6;
      case 'tutorialSymptomsStep7':
        return localizations.tutorialSymptomsStep7;
      case 'tutorialSymptomsStep8':
        return localizations.tutorialSymptomsStep8;

      // Medication Tutorial Steps
      case 'tutorialMedicationStep1':
        return localizations.tutorialMedicationStep1;
      case 'tutorialMedicationStep2':
        return localizations.tutorialMedicationStep2;
      case 'tutorialMedicationStep3':
        return localizations.tutorialMedicationStep3;
      case 'tutorialMedicationStep4':
        return localizations.tutorialMedicationStep4;
      case 'tutorialMedicationStep5':
        return localizations.tutorialMedicationStep5;
      case 'tutorialMedicationStep6':
        return localizations.tutorialMedicationStep6;
      case 'tutorialMedicationStep7':
        return localizations.tutorialMedicationStep7;

      // Mood Tutorial Steps
      case 'tutorialMoodStep1':
        return localizations.tutorialMoodStep1;
      case 'tutorialMoodStep2':
        return localizations.tutorialMoodStep2;
      case 'tutorialMoodStep3':
        return localizations.tutorialMoodStep3;
      case 'tutorialMoodStep4':
        return localizations.tutorialMoodStep4;
      case 'tutorialMoodStep5':
        return localizations.tutorialMoodStep5;
      case 'tutorialMoodStep6':
        return localizations.tutorialMoodStep6;
      case 'tutorialMoodStep7':
        return localizations.tutorialMoodStep7;
      case 'tutorialMoodStep8':
        return localizations.tutorialMoodStep8;

      // Energy Tutorial Steps
      case 'tutorialEnergyStep1':
        return localizations.tutorialEnergyStep1;
      case 'tutorialEnergyStep2':
        return localizations.tutorialEnergyStep2;
      case 'tutorialEnergyStep3':
        return localizations.tutorialEnergyStep3;
      case 'tutorialEnergyStep4':
        return localizations.tutorialEnergyStep4;
      case 'tutorialEnergyStep5':
        return localizations.tutorialEnergyStep5;
      case 'tutorialEnergyStep6':
        return localizations.tutorialEnergyStep6;

      // Flowmodoro Tutorial Steps
      case 'tutorialFlowmodoroStep1':
        return localizations.tutorialFlowmodoroStep1;
      case 'tutorialFlowmodoroStep2':
        return localizations.tutorialFlowmodoroStep2;
      case 'tutorialFlowmodoroStep3':
        return localizations.tutorialFlowmodoroStep3;
      case 'tutorialFlowmodoroStep4':
        return localizations.tutorialFlowmodoroStep4;
      case 'tutorialFlowmodoroStep5':
        return localizations.tutorialFlowmodoroStep5;
      case 'tutorialFlowmodoroStep6':
        return localizations.tutorialFlowmodoroStep6;
      case 'tutorialFlowmodoroStep7':
        return localizations.tutorialFlowmodoroStep7;
      case 'tutorialFlowmodoroStep8':
        return localizations.tutorialFlowmodoroStep8;
      case 'tutorialFlowmodoroStep9':
        return localizations.tutorialFlowmodoroStep9;
      case 'tutorialFlowmodoroStep10':
        return localizations.tutorialFlowmodoroStep10;

      // Kanban Tutorial Steps
      case 'tutorialKanbanStep1':
        return localizations.tutorialKanbanStep1;
      case 'tutorialKanbanStep2':
        return localizations.tutorialKanbanStep2;
      case 'tutorialKanbanStep3':
        return localizations.tutorialKanbanStep3;
      case 'tutorialKanbanStep4':
        return localizations.tutorialKanbanStep4;
      case 'tutorialKanbanStep5':
        return localizations.tutorialKanbanStep5;
      case 'tutorialKanbanStep6':
        return localizations.tutorialKanbanStep6;
      case 'tutorialKanbanStep7':
        return localizations.tutorialKanbanStep7;
      case 'tutorialKanbanStep8':
        return localizations.tutorialKanbanStep8;

      // Time Blocks Tutorial Steps
      case 'tutorialTimeBlocksStep1':
        return localizations.tutorialTimeBlocksStep1;
      case 'tutorialTimeBlocksStep2':
        return localizations.tutorialTimeBlocksStep2;
      case 'tutorialTimeBlocksStep3':
        return localizations.tutorialTimeBlocksStep3;
      case 'tutorialTimeBlocksStep4':
        return localizations.tutorialTimeBlocksStep4;
      case 'tutorialTimeBlocksStep5':
        return localizations.tutorialTimeBlocksStep5;

      // Reports Tutorial Steps
      case 'tutorialReportsStep1':
        return localizations.tutorialReportsStep1;
      case 'tutorialReportsStep2':
        return localizations.tutorialReportsStep2;
      case 'tutorialReportsStep3':
        return localizations.tutorialReportsStep3;
      case 'tutorialReportsStep4':
        return localizations.tutorialReportsStep4;
      case 'tutorialReportsStep5':
        return localizations.tutorialReportsStep5;
      case 'tutorialReportsStep6':
        return localizations.tutorialReportsStep6;

      // Custom Reports Tutorial Steps
      case 'tutorialCustomReportsStep1':
        return localizations.tutorialCustomReportsStep1;
      case 'tutorialCustomReportsStep2':
        return localizations.tutorialCustomReportsStep2;
      case 'tutorialCustomReportsStep3':
        return localizations.tutorialCustomReportsStep3;
      case 'tutorialCustomReportsStep4':
        return localizations.tutorialCustomReportsStep4;
      case 'tutorialCustomReportsStep5':
        return localizations.tutorialCustomReportsStep5;
      case 'tutorialCustomReportsStep6':
        return localizations.tutorialCustomReportsStep6;

      // Settings Tutorial Steps
      case 'tutorialSettingsStep1':
        return localizations.tutorialSettingsStep1;
      case 'tutorialSettingsStep2':
        return localizations.tutorialSettingsStep2;
      case 'tutorialSettingsStep3':
        return localizations.tutorialSettingsStep3;

      // Account Tutorial Steps
      case 'tutorialAccountStep1':
        return localizations.tutorialAccountStep1;
      case 'tutorialAccountStep2':
        return localizations.tutorialAccountStep2;
      case 'tutorialAccountStep3':
        return localizations.tutorialAccountStep3;

      default:
        return stepKey;
    }
  }
}

// Provider
final tutorialsControllerProvider =
    StateNotifierProvider<TutorialsController, TutorialsState>((ref) {
  return TutorialsController();
});
