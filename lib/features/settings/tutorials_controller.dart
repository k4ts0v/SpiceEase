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
        return localizations.tutorialCategoryGettingStarted ??
            'Getting Started';
      case 'tutorialCategoryTasks':
        return localizations.tutorialCategoryTasks ?? 'Tasks';
      case 'tutorialCategoryHabits':
        return localizations.tutorialCategoryHabits ?? 'Habits';
      case 'tutorialCategoryHealth':
        return localizations.tutorialCategoryHealth ?? 'Health';
      case 'tutorialCategoryTimeManagement':
        return localizations.tutorialCategoryTimeManagement ??
            'Time Management';
      case 'tutorialCategoryReports':
        return localizations.tutorialCategoryReports ?? 'Reports';
      case 'tutorialCategorySettings':
        return localizations.tutorialCategorySettings ?? 'Settings';
      default:
        return categoryKey;
    }
  }

  String getTutorialTitle(String titleKey, AppLocalizations localizations) {
    switch (titleKey) {
      case 'tutorialUnderstandingIconGrid':
        return localizations.tutorialUnderstandingIconGrid ??
            'Understanding the Icon Grid';
      case 'tutorialUnderstandingListView':
        return localizations.tutorialUnderstandingListView ??
            'Understanding the List View';
      case 'tutorialCreatingFirstTask':
        return localizations.tutorialCreatingFirstTask ??
            'Creating Your First Task';
      case 'tutorialEditingDeletingTasks':
        return localizations.tutorialEditingDeletingTasks ??
            'Editing and Deleting Tasks';
      case 'tutorialWorkingWithSubtasks':
        return localizations.tutorialWorkingWithSubtasks ??
            'Working with Subtasks';
      case 'tutorialTaskEstimationTimePlanning':
        return localizations.tutorialTaskEstimationTimePlanning ??
            'Task Estimation and Time Planning';
      case 'tutorialSettingUpDailyHabits':
        return localizations.tutorialSettingUpDailyHabits ??
            'Setting Up Daily Habits';
      case 'tutorialManagingHabitStreaks':
        return localizations.tutorialManagingHabitStreaks ??
            'Managing Habit Streaks';
      case 'tutorialTrackingHealthSymptoms':
        return localizations.tutorialTrackingHealthSymptoms ??
            'Tracking Health Symptoms';
      case 'tutorialAddingMedicationTracking':
        return localizations.tutorialAddingMedicationTracking ??
            'Adding Medication Tracking';
      case 'tutorialRecordingMoodEntries':
        return localizations.tutorialRecordingMoodEntries ??
            'Recording Mood Entries';
      case 'tutorialRecordingEnergyEntries':
        return localizations.tutorialRecordingEnergyEntries ??
            'Recording Energy Entries';
      case 'tutorialUsingFlowmodoroTechnique':
        return localizations.tutorialUsingFlowmodoroTechnique ??
            'Using the Flowmodoro Technique';
      case 'tutorialManagingKanbanBoard':
        return localizations.tutorialManagingKanbanBoard ??
            'Managing Your Kanban Board';
      case 'tutorialSchedulingTimeBlocks':
        return localizations.tutorialSchedulingTimeBlocks ??
            'Scheduling with Time Blocks';
      case 'tutorialUnderstandingReportsCharts':
        return localizations.tutorialUnderstandingReportsCharts ??
            'Understanding Reports and Charts';
      case 'tutorialCustomizingReportViews':
        return localizations.tutorialCustomizingReportViews ??
            'Customizing Report Views';
      case 'tutorialPersonalizingSettings':
        return localizations.tutorialPersonalizingSettings ??
            'Personalizing Your Settings';
      case 'tutorialManagingAccount':
        return localizations.tutorialManagingAccount ?? 'Managing Your Account';
      default:
        return titleKey;
    }
  }

  String getDuration(String durationKey, AppLocalizations localizations) {
    switch (durationKey) {
      case 'tutorial2Min':
        return localizations.tutorial2Min ?? '2 min';
      case 'tutorial3Min':
        return localizations.tutorial3Min ?? '3 min';
      case 'tutorial4Min':
        return localizations.tutorial4Min ?? '4 min';
      case 'tutorial5Min':
        return localizations.tutorial5Min ?? '5 min';
      default:
        return durationKey;
    }
  }

  String getDifficulty(String difficultyKey, AppLocalizations localizations) {
    switch (difficultyKey) {
      case 'tutorialBeginner':
        return localizations.tutorialBeginner ?? 'Beginner';
      case 'tutorialIntermediate':
        return localizations.tutorialIntermediate ?? 'Intermediate';
      case 'tutorialAdvanced':
        return localizations.tutorialAdvanced ?? 'Advanced';
      default:
        return difficultyKey;
    }
  }

  String getStepText(String stepKey, AppLocalizations localizations) {
    switch (stepKey) {
      // Icon Grid Tutorial Steps
      case 'tutorialIconGridStep1':
        return localizations.tutorialIconGridStep1 ??
            'The main screen shows an icon grid with different categories';
      case 'tutorialIconGridStep2':
        return localizations.tutorialIconGridStep2 ??
            'Each icon represents a different type of data you can track';
      case 'tutorialIconGridStep3':
        return localizations.tutorialIconGridStep3 ??
            'Tap any icon to see your existing entries for that category';
      case 'tutorialIconGridStep4':
        return localizations.tutorialIconGridStep4 ??
            'Use the "+" button within each category to add new entries';
      case 'tutorialIconGridStep5':
        return localizations.tutorialIconGridStep5 ??
            'Alternatively, for habits, medications, tasks or symptoms, use the "Add [Item]" buttons for quick access';
      case 'tutorialIconGridStep6':
        return localizations.tutorialIconGridStep6 ??
            'The grid layout makes it easy to see all your tracking options';

      // List View Tutorial Steps
      case 'tutorialListViewStep1':
        return localizations.tutorialListViewStep1 ??
            'Tap the list icon in the bottom navigation to switch to list view';
      case 'tutorialListViewStep2':
        return localizations.tutorialListViewStep2 ??
            'The list shows all your items grouped by type (tasks, habits, etc.)';
      case 'tutorialListViewStep3':
        return localizations.tutorialListViewStep3 ??
            'Items are color-coded by category for easy identification';
      case 'tutorialListViewStep4':
        return localizations.tutorialListViewStep4 ??
            'You can see completion status and due dates at a glance';
      case 'tutorialListViewStep5':
        return localizations.tutorialListViewStep5 ??
            'Tap any item to view details or mark as complete';
      case 'tutorialListViewStep6':
        return localizations.tutorialListViewStep6 ??
            'Use the filter and sort options to organize your view';
      case 'tutorialListViewStep7':
        return localizations.tutorialListViewStep7 ??
            'Switch back to grid view anytime using the grid icon';

      // First Task Tutorial Steps
      case 'tutorialFirstTaskStep1':
        return localizations.tutorialFirstTaskStep1 ??
            'Go to the tracker screen';
      case 'tutorialFirstTaskStep2':
        return localizations.tutorialFirstTaskStep2 ??
            'Choose the task icon from the icon grid OR tap "Add Task" button';
      case 'tutorialFirstTaskStep3':
        return localizations.tutorialFirstTaskStep3 ??
            'If using icon grid: tap the "+" button in the top-right corner';
      case 'tutorialFirstTaskStep4':
        return localizations.tutorialFirstTaskStep4 ??
            'Enter a title and description for your task';
      case 'tutorialFirstTaskStep5':
        return localizations.tutorialFirstTaskStep5 ??
            'Set a due date if desired and a priority level';
      case 'tutorialFirstTaskStep6':
        return localizations.tutorialFirstTaskStep6 ??
            'Add subtasks if needed by pressing the "Divide into subtasks" button';
      case 'tutorialFirstTaskStep7':
        return localizations.tutorialFirstTaskStep7 ??
            'Tap "Save" to create your task';

      // Edit Task Tutorial Steps
      case 'tutorialEditTaskStep1':
        return localizations.tutorialEditTaskStep1 ??
            'Navigate to the task icon in the grid';
      case 'tutorialEditTaskStep2':
        return localizations.tutorialEditTaskStep2 ??
            'Tap on any existing task to open it';
      case 'tutorialEditTaskStep3':
        return localizations.tutorialEditTaskStep3 ??
            'To edit: tap the edit button and modify any field';
      case 'tutorialEditTaskStep4':
        return localizations.tutorialEditTaskStep4 ??
            'You can change title, description, due date or priority';
      case 'tutorialEditTaskStep5':
        return localizations.tutorialEditTaskStep5 ??
            'To delete: tap the delete button and confirm';
      case 'tutorialEditTaskStep6':
        return localizations.tutorialEditTaskStep6 ??
            'Save changes when editing';

      // Subtasks Tutorial Steps
      case 'tutorialSubtasksStep1':
        return localizations.tutorialSubtasksStep1 ??
            'When creating or editing a task, tap "Divide into subtasks"';
      case 'tutorialSubtasksStep2':
        return localizations.tutorialSubtasksStep2 ??
            'This generates a list of subtasks under the main task automatically';
      case 'tutorialSubtasksStep3':
        return localizations.tutorialSubtasksStep3 ??
            'Each subtask can be marked complete independently and has its own estimated time';
      case 'tutorialSubtasksStep4':
        return localizations.tutorialSubtasksStep4 ??
            'The main task shows progress based on completed subtasks';
      case 'tutorialSubtasksStep5':
        return localizations.tutorialSubtasksStep5 ??
            'Subtasks help break down complex tasks into manageable steps';
      case 'tutorialSubtasksStep6':
        return localizations.tutorialSubtasksStep6 ??
            'You can add, edit, or delete subtasks at any time';
      case 'tutorialSubtasksStep7':
        return localizations.tutorialSubtasksStep7 ??
            'The main task is completed when all subtasks are done';

      // Estimation Tutorial Steps
      case 'tutorialEstimationStep1':
        return localizations.tutorialEstimationStep1 ??
            'When creating or editing a task, look for the "Estimate task" button';
      case 'tutorialEstimationStep2':
        return localizations.tutorialEstimationStep2 ??
            'Your current energy level directly impacts task estimation';
      case 'tutorialEstimationStep3':
        return localizations.tutorialEstimationStep3 ??
            'Higher energy levels suggest shorter completion times and less subdivision needed';
      case 'tutorialEstimationStep4':
        return localizations.tutorialEstimationStep4 ??
            'Lower energy levels may require breaking tasks into smaller, more manageable chunks';
      case 'tutorialEstimationStep5':
        return localizations.tutorialEstimationStep5 ??
            'The app considers your energy patterns when suggesting time estimates';
      case 'tutorialEstimationStep6':
        return localizations.tutorialEstimationStep6 ??
            'Estimated times help with scheduling and time blocking';

      // Habits Tutorial Steps
      case 'tutorialHabitsStep1':
        return localizations.tutorialHabitsStep1 ?? 'Go to the tracker screen';
      case 'tutorialHabitsStep2':
        return localizations.tutorialHabitsStep2 ??
            'Choose the habit icon from the icon grid OR tap "Add Habit" button';
      case 'tutorialHabitsStep3':
        return localizations.tutorialHabitsStep3 ??
            'If using icon grid: tap the "+" button in the top-right corner';
      case 'tutorialHabitsStep4':
        return localizations.tutorialHabitsStep4 ??
            'Enter the habit name (e.g., "Drink 8 glasses of water")';
      case 'tutorialHabitsStep5':
        return localizations.tutorialHabitsStep5 ??
            'Choose the frequency: daily, weekly, or custom';
      case 'tutorialHabitsStep6':
        return localizations.tutorialHabitsStep6 ??
            'For custom frequency, select specific days of the week';
      case 'tutorialHabitsStep7':
        return localizations.tutorialHabitsStep7 ??
            'Set target times per day if applicable';
      case 'tutorialHabitsStep8':
        return localizations.tutorialHabitsStep8 ??
            'Add a description if desired';
      case 'tutorialHabitsStep9':
        return localizations.tutorialHabitsStep9 ??
            'Save your habit and mark it complete each day you do it';

      // Streaks Tutorial Steps
      case 'tutorialStreaksStep1':
        return localizations.tutorialStreaksStep1 ??
            'View your habits in the grid or list';
      case 'tutorialStreaksStep2':
        return localizations.tutorialStreaksStep2 ??
            'Each habit shows if it was completed today';
      case 'tutorialStreaksStep3':
        return localizations.tutorialStreaksStep3 ??
            'Tap a habit\'s checkbox to mark it complete for the day';
      case 'tutorialStreaksStep4':
        return localizations.tutorialStreaksStep4 ??
            'Mark habits complete daily to maintain streaks';
      case 'tutorialStreaksStep5':
        return localizations.tutorialStreaksStep5 ??
            'Streaks reset if you miss a day (based on your frequency)';
      case 'tutorialStreaksStep6':
        return localizations.tutorialStreaksStep6 ??
            'Use the reports screen to see your habit history';
      case 'tutorialStreaksStep7':
        return localizations.tutorialStreaksStep7 ??
            'Aim for consistency rather than perfection';
      case 'tutorialStreaksStep8':
        return localizations.tutorialStreaksStep8 ??
            'Celebrate milestone streaks to stay motivated';

      // Symptoms Tutorial Steps
      case 'tutorialSymptomsStep1':
        return localizations.tutorialSymptomsStep1 ??
            'Go to the tracker screen';
      case 'tutorialSymptomsStep2':
        return localizations.tutorialSymptomsStep2 ??
            'Choose the symptom icon from the icon grid OR tap "Add Symptom" button';
      case 'tutorialSymptomsStep3':
        return localizations.tutorialSymptomsStep3 ??
            'If using icon grid: tap the "+" button in the top-right corner';
      case 'tutorialSymptomsStep4':
        return localizations.tutorialSymptomsStep4 ??
            'Choose from common categories or add a custom one';
      case 'tutorialSymptomsStep5':
        return localizations.tutorialSymptomsStep5 ??
            'Rate the severity on a scale of 1-10 (use Mankoski scale if preferred)';
      case 'tutorialSymptomsStep6':
        return localizations.tutorialSymptomsStep6 ??
            'Add notes about triggers, context, or treatments tried';
      case 'tutorialSymptomsStep7':
        return localizations.tutorialSymptomsStep7 ??
            'Include location on body if applicable';
      case 'tutorialSymptomsStep8':
        return localizations.tutorialSymptomsStep8 ??
            'Save the entry to track patterns over time';

      // Medication Tutorial Steps
      case 'tutorialMedicationStep1':
        return localizations.tutorialMedicationStep1 ??
            'Go to the tracker screen';
      case 'tutorialMedicationStep2':
        return localizations.tutorialMedicationStep2 ??
            'Choose the medication icon from the icon grid';
      case 'tutorialMedicationStep3':
        return localizations.tutorialMedicationStep3 ??
            'Tap the "+" button in the top-right corner';
      case 'tutorialMedicationStep4':
        return localizations.tutorialMedicationStep4 ??
            'Enter the medication name and dosage amount';
      case 'tutorialMedicationStep5':
        return localizations.tutorialMedicationStep5 ??
            'Select the unit (mg, ml, tablets, etc.)';
      case 'tutorialMedicationStep6':
        return localizations.tutorialMedicationStep6 ??
            'Set the frequency: daily, weekly, as needed, or custom schedule';
      case 'tutorialMedicationStep7':
        return localizations.tutorialMedicationStep7 ??
            'Save the medication and mark as taken when you take your dose';

      // Mood Tutorial Steps
      case 'tutorialMoodStep1':
        return localizations.tutorialMoodStep1 ?? 'Go to the tracker screen';
      case 'tutorialMoodStep2':
        return localizations.tutorialMoodStep2 ??
            'Choose the mood icon from the icon grid';
      case 'tutorialMoodStep3':
        return localizations.tutorialMoodStep3 ??
            'Tap the "+" button in the top-right corner';
      case 'tutorialMoodStep4':
        return localizations.tutorialMoodStep4 ??
            'Select your current mood level on a scale of 1-10';
      case 'tutorialMoodStep5':
        return localizations.tutorialMoodStep5 ??
            'Add notes about what influenced your mood';
      case 'tutorialMoodStep6':
        return localizations.tutorialMoodStep6 ??
            'Include any relevant triggers, events, or circumstances';
      case 'tutorialMoodStep7':
        return localizations.tutorialMoodStep7 ??
            'Note any coping strategies used';
      case 'tutorialMoodStep8':
        return localizations.tutorialMoodStep8 ??
            'Save the mood entry to track patterns over time';

      // Energy Tutorial Steps
      case 'tutorialEnergyStep1':
        return localizations.tutorialEnergyStep1 ?? 'Go to the tracker screen';
      case 'tutorialEnergyStep2':
        return localizations.tutorialEnergyStep2 ??
            'Choose the energy icon from the icon grid';
      case 'tutorialEnergyStep3':
        return localizations.tutorialEnergyStep3 ??
            'Tap the "+" button in the top-right corner';
      case 'tutorialEnergyStep4':
        return localizations.tutorialEnergyStep4 ??
            'Select your current energy level on a scale of 1-10';
      case 'tutorialEnergyStep5':
        return localizations.tutorialEnergyStep5 ??
            'Add notes about what influenced your energy';
      case 'tutorialEnergyStep6':
        return localizations.tutorialEnergyStep6 ??
            'Include any relevant triggers, events, or circumstances';

      // Flowmodoro Tutorial Steps
      case 'tutorialFlowmodoroStep1':
        return localizations.tutorialFlowmodoroStep1 ??
            'Navigate to the Time Management page';
      case 'tutorialFlowmodoroStep2':
        return localizations.tutorialFlowmodoroStep2 ?? 'Tap on "Flowmodoro"';
      case 'tutorialFlowmodoroStep3':
        return localizations.tutorialFlowmodoroStep3 ??
            'Choose a task to work on from your task list';
      case 'tutorialFlowmodoroStep4':
        return localizations.tutorialFlowmodoroStep4 ??
            'Set your work duration (start with 25 minutes if unsure)';
      case 'tutorialFlowmodoroStep5':
        return localizations.tutorialFlowmodoroStep5 ??
            'Set your break duration (typically 5-15 minutes)';
      case 'tutorialFlowmodoroStep6':
        return localizations.tutorialFlowmodoroStep6 ??
            'Tap "Start" to begin the work timer';
      case 'tutorialFlowmodoroStep7':
        return localizations.tutorialFlowmodoroStep7 ??
            'Work focused on your task until the timer ends';
      case 'tutorialFlowmodoroStep8':
        return localizations.tutorialFlowmodoroStep8 ??
            'Take the break when prompted - step away from work';
      case 'tutorialFlowmodoroStep9':
        return localizations.tutorialFlowmodoroStep9 ??
            'After break, start another work session or finish';
      case 'tutorialFlowmodoroStep10':
        return localizations.tutorialFlowmodoroStep10 ??
            'Track your completed sessions for productivity insights';

      // Kanban Tutorial Steps
      case 'tutorialKanbanStep1':
        return localizations.tutorialKanbanStep1 ??
            'Go to Time Management and select "Kanban"';
      case 'tutorialKanbanStep2':
        return localizations.tutorialKanbanStep2 ??
            'Your tasks are organized in columns: To Do, In Progress, Done';
      case 'tutorialKanbanStep3':
        return localizations.tutorialKanbanStep3 ??
            'Drag tasks between columns to update their status';
      case 'tutorialKanbanStep4':
        return localizations.tutorialKanbanStep4 ??
            'Add new tasks directly to the To Do column';
      case 'tutorialKanbanStep5':
        return localizations.tutorialKanbanStep5 ??
            'Move tasks to In Progress when you start working on them';
      case 'tutorialKanbanStep6':
        return localizations.tutorialKanbanStep6 ??
            'Complete tasks by moving them to Done';
      case 'tutorialKanbanStep7':
        return localizations.tutorialKanbanStep7 ??
            'Use filters to show only specific categories or priorities';
      case 'tutorialKanbanStep8':
        return localizations.tutorialKanbanStep8 ??
            'Customize columns and workflow to match your needs';

      // Time Blocks Tutorial Steps
      case 'tutorialTimeBlocksStep1':
        return localizations.tutorialTimeBlocksStep1 ??
            'Navigate to Time Management and tap "Time Blocks"';
      case 'tutorialTimeBlocksStep2':
        return localizations.tutorialTimeBlocksStep2 ??
            'View your calendar with existing scheduled items';
      case 'tutorialTimeBlocksStep3':
        return localizations.tutorialTimeBlocksStep3 ??
            'To schedule a task: set a start time and an end time, or set a start time only if the task has a time estimate';
      case 'tutorialTimeBlocksStep4':
        return localizations.tutorialTimeBlocksStep4 ??
            'To unschedule: press the x button on top of the scheduled item';
      case 'tutorialTimeBlocksStep5':
        return localizations.tutorialTimeBlocksStep5 ??
            'Color coding helps distinguish the priorities of tasks';

      // Reports Tutorial Steps
      case 'tutorialReportsStep1':
        return localizations.tutorialReportsStep1 ??
            'Navigate to the Reports section';
      case 'tutorialReportsStep2':
        return localizations.tutorialReportsStep2 ??
            'Choose your time range: day, week, month or year';
      case 'tutorialReportsStep3':
        return localizations.tutorialReportsStep3 ??
            'If there is any data that you don\'t want to see, click it in the legend to hide it';
      case 'tutorialReportsStep4':
        return localizations.tutorialReportsStep4 ??
            'Charts automatically update based on your selections';
      case 'tutorialReportsStep5':
        return localizations.tutorialReportsStep5 ??
            'Hover or tap data points for detailed information';
      case 'tutorialReportsStep6':
        return localizations.tutorialReportsStep6 ??
            'Use charts to identify patterns and trends in your data';

      // Custom Reports Tutorial Steps
      case 'tutorialCustomReportsStep1':
        return localizations.tutorialCustomReportsStep1 ??
            'In the Reports section, look for the legend below charts';
      case 'tutorialCustomReportsStep2':
        return localizations.tutorialCustomReportsStep2 ??
            'Tap on any item in the legend to hide/show that data series';
      case 'tutorialCustomReportsStep3':
        return localizations.tutorialCustomReportsStep3 ??
            'Hidden items appear grayed out in the legend';
      case 'tutorialCustomReportsStep4':
        return localizations.tutorialCustomReportsStep4 ??
            'This lets you focus on specific data points';
      case 'tutorialCustomReportsStep5':
        return localizations.tutorialCustomReportsStep5 ??
            'For example, hide the habits to see other items more clearly';
      case 'tutorialCustomReportsStep6':
        return localizations.tutorialCustomReportsStep6 ??
            'Combine with date filters for precise analysis';

      // Settings Tutorial Steps
      case 'tutorialSettingsStep1':
        return localizations.tutorialSettingsStep1 ??
            'Navigate to Settings from the main menu';
      case 'tutorialSettingsStep2':
        return localizations.tutorialSettingsStep2 ??
            'Customize your theme (light, dark, or system)';
      case 'tutorialSettingsStep3':
        return localizations.tutorialSettingsStep3 ??
            'Set your preferred language and region';

      // Account Tutorial Steps
      case 'tutorialAccountStep1':
        return localizations.tutorialAccountStep1 ??
            'Go to Settings and tap "Account"';
      case 'tutorialAccountStep2':
        return localizations.tutorialAccountStep2 ??
            'View your account details and email address';
      case 'tutorialAccountStep3':
        return localizations.tutorialAccountStep3 ??
            'Change your or email password if needed';

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
