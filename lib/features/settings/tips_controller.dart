import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data models
class Tip {
  final String title;
  final String content;

  const Tip({
    required this.title,
    required this.content,
  });
}

class TipCategory {
  final String category;
  final IconData icon;
  final List<Tip> tips;

  const TipCategory({
    required this.category,
    required this.icon,
    required this.tips,
  });
}

// Controller state
class TipsState {
  final List<TipCategory> categories;

  const TipsState({
    required this.categories,
  });

  TipsState copyWith({
    List<TipCategory>? categories,
  }) {
    return TipsState(
      categories: categories ?? this.categories,
    );
  }
}

// Controller
class TipsController extends StateNotifier<TipsState> {
  TipsController() : super(TipsState(categories: _createTipCategories()));

  static List<TipCategory> _createTipCategories() {
    return [
      const TipCategory(
        category: 'Productivity',
        icon: Icons.trending_up,
        tips: [
          Tip(
            title: 'Use the 2-Minute Rule',
            content: 'If a task takes less than 2 minutes, do it immediately instead of adding it to your task list.',
          ),
          Tip(
            title: 'Time Block Your Calendar',
            content: 'Assign specific time blocks for different types of tasks. This helps maintain focus and reduces context switching.',
          ),
          Tip(
            title: 'Review Weekly',
            content: 'Spend 15 minutes each week reviewing completed tasks and planning the next week. This helps identify patterns and improve planning.',
          ),
          Tip(
            title: 'Batch Similar Tasks',
            content: 'Group similar activities together (like answering emails or making phone calls) to maintain momentum.',
          ),
        ],
      ),
      const TipCategory(
        category: 'Habit Building',
        icon: Icons.auto_awesome,
        tips: [
          Tip(
            title: 'Start Small',
            content: 'Begin with tiny habits that are almost impossible to fail. Want to exercise daily? Start with just 5 push-ups.',
          ),
          Tip(
            title: 'Stack Habits',
            content: 'Link new habits to existing ones. "After I brush my teeth, I will meditate for 2 minutes."',
          ),
          Tip(
            title: 'Track Streaks',
            content: 'Use the reports to visualize your streaks. The satisfaction of maintaining a streak is a powerful motivator.',
          ),
          Tip(
            title: 'Prepare Your Environment',
            content: 'Make good habits easier by setting up your environment. Put your workout clothes by your bed.',
          ),
        ],
      ),
      const TipCategory(
        category: 'Health Tracking',
        icon: Icons.favorite,
        tips: [
          Tip(
            title: 'Be Consistent with Timing',
            content: 'Record symptoms and medications at the same time each day for more accurate patterns.',
          ),
          Tip(
            title: 'Note Context',
            content: 'Include environmental factors: weather, stress levels, sleep quality, or dietary changes.',
          ),
          Tip(
            title: 'Use the Notes Field',
            content: 'Add details about what might have triggered symptoms or what helped relieve them.',
          ),
          Tip(
            title: 'Review Trends Monthly',
            content: 'Look for patterns in your health data. This can help you make better decisions.',
          ),
        ],
      ),
      const TipCategory(
        category: 'Time Management',
        icon: Icons.schedule,
        tips: [
          Tip(
            title: 'Use the Flowmodoro Technique',
            content: 'Work in focused sessions and take breaks proportional to your work time. This maintains high productivity while preventing burnout.',
          ),
          Tip(
            title: 'Plan Your Most Important Task',
            content: 'Identify your most important task (MIT) for the day and tackle it when your energy is highest.',
          ),
          Tip(
            title: 'Limit Work in Progress',
            content: 'Focus on completing tasks rather than starting new ones. Aim to have no more than 3 tasks "in progress" at once.',
          ),
        ],
      ),
      const TipCategory(
        category: 'Mindfulness & Wellness',
        icon: Icons.self_improvement,
        tips: [
          Tip(
            title: 'Practice the 5-4-3-2-1 Technique',
            content: 'When feeling overwhelmed, identify 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you taste.',
          ),
          Tip(
            title: 'Set Energy-Based Goals',
            content: 'Match your tasks to your energy levels. Do creative work when energized, administrative tasks when tired.',
          ),
          Tip(
            title: 'Take Regular Breaks',
            content: 'Schedule short breaks every 25-50 minutes. Use this time to stretch, breathe, or step outside.',
          ),
        ],
      ),
    ];
  }

  List<TipCategory> get categories => state.categories;

  int get totalTipsCount =>
      state.categories.fold(0, (sum, category) => sum + category.tips.length);

  List<Tip> getAllTips() {
    return state.categories
        .expand((category) => category.tips)
        .toList();
  }

  TipCategory? getCategoryByName(String categoryName) {
    try {
      return state.categories.firstWhere(
        (category) => category.category.toLowerCase() == categoryName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  List<Tip> getTipsByCategory(String categoryName) {
    final category = getCategoryByName(categoryName);
    return category?.tips ?? [];
  }
}

// Provider
final tipsControllerProvider = StateNotifierProvider<TipsController, TipsState>((ref) {
  return TipsController();
});