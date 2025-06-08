import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/l10n/app_localizations.dart';

// Data models
class FAQ {
  final String _questionKey;
  final String _answerKey;

  const FAQ({
    required String questionKey,
    required String answerKey,
  })  : _questionKey = questionKey,
        _answerKey = answerKey;

  String get questionKey => _questionKey;
  String get answerKey => _answerKey;
}

class FAQCategory {
  final String _categoryKey;
  final List<FAQ> _questions;

  const FAQCategory({
    required String categoryKey,
    required List<FAQ> questions,
  })  : _categoryKey = categoryKey,
        _questions = questions;

  String get categoryKey => _categoryKey;
  List<FAQ> get questions => _questions;

  // For backwards compatibility if needed
  String get category => _categoryKey;
}

// Controller state
class FAQState {
  final List<FAQCategory> _categories;
  final String _searchQuery;

  const FAQState({
    required List<FAQCategory> categories,
    String searchQuery = '',
  })  : _categories = categories,
        _searchQuery = searchQuery;

  List<FAQCategory> get categories => _categories;
  String get searchQuery => _searchQuery;

  FAQState copyWith({
    List<FAQCategory>? categories,
    String? searchQuery,
  }) {
    return FAQState(
      categories: categories ?? _categories,
      searchQuery: searchQuery ?? _searchQuery,
    );
  }
}

// Controller
class FAQController extends StateNotifier<FAQState> {
  FAQController() : super(FAQState(categories: _createFAQCategories()));

  static List<FAQCategory> _createFAQCategories() {
    return [
      const FAQCategory(
        categoryKey: 'faqCategoryGettingStarted',
        questions: [
          FAQ(
            questionKey: 'faqHowCreateFirstTask',
            answerKey: 'faqHowCreateFirstTaskAnswer',
          ),
          FAQ(
            questionKey: 'faqDifferenceTasksHabits',
            answerKey: 'faqDifferenceTasksHabitsAnswer',
          ),
          FAQ(
            questionKey: 'faqEnergyTrackingTasks',
            answerKey: 'faqEnergyTrackingTasksAnswer',
          ),
          FAQ(
            questionKey: 'faqTaskEstimatesEnergy',
            answerKey: 'faqTaskEstimatesEnergyAnswer',
          ),
        ],
      ),
      const FAQCategory(
        categoryKey: 'faqCategoryTimeManagement',
        questions: [
          FAQ(
            questionKey: 'faqWhatIsFlowmodoro',
            answerKey: 'faqWhatIsFlowmodoroAnswer',
          ),
          FAQ(
            questionKey: 'faqKanbanBoards',
            answerKey: 'faqKanbanBoardsAnswer',
          ),
          FAQ(
            questionKey: 'faqTimeBlocks',
            answerKey: 'faqTimeBlocksAnswer',
          ),
          FAQ(
            questionKey: 'faqCustomizeTimers',
            answerKey: 'faqCustomizeTimersAnswer',
          ),
          FAQ(
            questionKey: 'faqEnergyTaskScheduling',
            answerKey: 'faqEnergyTaskSchedulingAnswer',
          ),
        ],
      ),
      const FAQCategory(
        categoryKey: 'faqCategoryHealthTracking',
        questions: [
          FAQ(
            questionKey: 'faqSymptomRatingsAccuracy',
            answerKey: 'faqSymptomRatingsAccuracyAnswer',
          ),
          FAQ(
            questionKey: 'faqCustomSymptoms',
            answerKey: 'faqCustomSymptomsAnswer',
          ),
        ],
      ),
      const FAQCategory(
        categoryKey: 'faqCategoryDataPrivacy',
        questions: [
          FAQ(
            questionKey: 'faqDataStorage',
            answerKey: 'faqDataStorageAnswer',
          ),
          FAQ(
            questionKey: 'faqMultipleDevices',
            answerKey: 'faqMultipleDevicesAnswer',
          ),
          FAQ(
            questionKey: 'faqDeleteApp',
            answerKey: 'faqDeleteAppAnswer',
          ),
        ],
      ),
      const FAQCategory(
        categoryKey: 'faqCategoryTroubleshooting',
        questions: [
          FAQ(
            questionKey: 'faqDataMissing',
            answerKey: 'faqDataMissingAnswer',
          ),
          FAQ(
            questionKey: 'faqAppSlow',
            answerKey: 'faqAppSlowAnswer',
          ),
          FAQ(
            questionKey: 'faqFeatureMissing',
            answerKey: 'faqFeatureMissingAnswer',
          ),
        ],
      ),
    ];
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  List<FAQCategory> getFilteredFAQs(AppLocalizations localizations) {
    if (state.searchQuery.isEmpty) {
      return state.categories;
    }

    return state.categories
        .map((category) {
          final filteredQuestions = category.questions.where((faq) {
            final question =
                getQuestionText(faq.questionKey, localizations).toLowerCase();
            final answer =
                getAnswerText(faq.answerKey, localizations).toLowerCase();
            final searchQuery = state.searchQuery.toLowerCase();
            return question.contains(searchQuery) ||
                answer.contains(searchQuery);
          }).toList();

          return FAQCategory(
            categoryKey: category.categoryKey,
            questions: filteredQuestions,
          );
        })
        .where((category) => category.questions.isNotEmpty)
        .toList();
  }

  IconData getCategoryIcon(String categoryKey) {
    switch (categoryKey) {
      case 'faqCategoryGettingStarted':
        return Icons.play_circle_outline;
      case 'faqCategoryTimeManagement':
        return Icons.schedule;
      case 'faqCategoryHealthTracking':
        return Icons.health_and_safety;
      case 'faqCategoryDataPrivacy':
        return Icons.security;
      case 'faqCategoryTroubleshooting':
        return Icons.build;
      default:
        return Icons.help_outline;
    }
  }

  String getCategoryTitle(String categoryKey, AppLocalizations localizations) {
    switch (categoryKey) {
      case 'faqCategoryGettingStarted':
        return localizations.faqCategoryGettingStarted;
      case 'faqCategoryTimeManagement':
        return localizations.faqCategoryTimeManagement;
      case 'faqCategoryHealthTracking':
        return localizations.faqCategoryHealthTracking;
      case 'faqCategoryDataPrivacy':
        return localizations.faqCategoryDataPrivacy;
      case 'faqCategoryTroubleshooting':
        return localizations.faqCategoryTroubleshooting;
      default:
        return categoryKey;
    }
  }

  String getQuestionText(String questionKey, AppLocalizations localizations) {
    switch (questionKey) {
      case 'faqHowCreateFirstTask':
        return localizations.faqHowCreateFirstTask;
      case 'faqDifferenceTasksHabits':
        return localizations.faqDifferenceTasksHabits;
      case 'faqEnergyTrackingTasks':
        return localizations.faqEnergyTrackingTasks;
      case 'faqTaskEstimatesEnergy':
        return localizations.faqTaskEstimatesEnergy;
      case 'faqWhatIsFlowmodoro':
        return localizations.faqWhatIsFlowmodoro;
      case 'faqKanbanBoards':
        return localizations.faqKanbanBoards;
      case 'faqTimeBlocks':
        return localizations.faqTimeBlocks;
      case 'faqCustomizeTimers':
        return localizations.faqCustomizeTimers;
      case 'faqEnergyTaskScheduling':
        return localizations.faqEnergyTaskScheduling;
      case 'faqSymptomRatingsAccuracy':
        return localizations.faqSymptomRatingsAccuracy;
      case 'faqCustomSymptoms':
        return localizations.faqCustomSymptoms;
      case 'faqDataStorage':
        return localizations.faqDataStorage;
      case 'faqMultipleDevices':
        return localizations.faqMultipleDevices;
      case 'faqDeleteApp':
        return localizations.faqDeleteApp;
      case 'faqDataMissing':
        return localizations.faqDataMissing;
      case 'faqAppSlow':
        return localizations.faqAppSlow;
      case 'faqFeatureMissing':
        return localizations.faqFeatureMissing;
      default:
        return questionKey;
    }
  }

  String getAnswerText(String answerKey, AppLocalizations localizations) {
    switch (answerKey) {
      case 'faqHowCreateFirstTaskAnswer':
        return localizations.faqHowCreateFirstTaskAnswer;
      case 'faqDifferenceTasksHabitsAnswer':
        return localizations.faqDifferenceTasksHabitsAnswer;
      case 'faqEnergyTrackingTasksAnswer':
        return localizations.faqEnergyTrackingTasksAnswer;
      case 'faqTaskEstimatesEnergyAnswer':
        return localizations.faqTaskEstimatesEnergyAnswer;
      case 'faqWhatIsFlowmodoroAnswer':
        return localizations.faqWhatIsFlowmodoroAnswer;
      case 'faqKanbanBoardsAnswer':
        return localizations.faqKanbanBoardsAnswer;
      case 'faqTimeBlocksAnswer':
        return localizations.faqTimeBlocksAnswer;
      case 'faqCustomizeTimersAnswer':
        return localizations.faqCustomizeTimersAnswer;
      case 'faqEnergyTaskSchedulingAnswer':
        return localizations.faqEnergyTaskSchedulingAnswer;
      case 'faqSymptomRatingsAccuracyAnswer':
        return localizations.faqSymptomRatingsAccuracyAnswer;
      case 'faqCustomSymptomsAnswer':
        return localizations.faqCustomSymptomsAnswer;
      case 'faqDataStorageAnswer':
        return localizations.faqDataStorageAnswer;
      case 'faqMultipleDevicesAnswer':
        return localizations.faqMultipleDevicesAnswer;
      case 'faqDeleteAppAnswer':
        return localizations.faqDeleteAppAnswer;
      case 'faqDataMissingAnswer':
        return localizations.faqDataMissingAnswer;
      case 'faqAppSlowAnswer':
        return localizations.faqAppSlowAnswer;
      case 'faqFeatureMissingAnswer':
        return localizations.faqFeatureMissingAnswer;
      default:
        return answerKey;
    }
  }
}

// Provider
final faqControllerProvider = StateNotifierProvider<FAQController, FAQState>((ref) {
  return FAQController();
});
