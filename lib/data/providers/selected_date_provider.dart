// ===== CORE RIVERPOD IMPORTS =====
// State management framework for reactive date selection
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ===== SELECTED DATE PROVIDER =====
/// Global state provider for managing the currently selected date across the application
///
/// This provider maintains a single, shared date state that is used throughout the app
/// for filtering and displaying date-specific data. It serves as the single source of
/// truth for the user's currently selected date context.
///
/// Key characteristics:
/// - Initializes to today's date with time normalized to midnight (00:00:00)
/// - Provides mutable state that can be updated from any part of the app
/// - Automatically triggers rebuilds in all dependent widgets and providers
/// - Maintains date precision at the day level (strips time components)
///
/// Used primarily by:
/// - Calendar widgets for date selection and highlighting
/// - Reports and analytics for time range filtering
/// - Data providers that need to fetch date-specific content
/// - Navigation components that display current date context
/// - Any feature requiring date-based data filtering
///
/// The date is normalized to midnight to ensure consistent day-level comparisons
/// and to avoid issues with time-based filtering across different components.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  // ===== GET CURRENT SYSTEM DATE =====
  // Retrieve the current date and time from the system
  final rawNow = DateTime.now();

  // ===== NORMALIZE TO DAY PRECISION =====
  // Strip time components to create a clean date at midnight (00:00:00)
  // This ensures consistent day-level comparisons throughout the application
  // and prevents time-based filtering issues when comparing dates
  return DateTime(rawNow.year, rawNow.month, rawNow.day);
});
