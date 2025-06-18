// Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Localized strings for internationalization
import 'package:spiceease/l10n/app_localizations.dart';

// ===== GENERIC LIST MODAL COMPONENT =====
// This section provides a reusable modal dialog for displaying lists of items

/// A generic modal dialog for displaying a list of items with an option to add new items
///
/// This widget is designed to be reusable across different types of items (e.g., moods, tasks, habits, etc.),
/// providing a consistent UI pattern throughout the app. It displays a list of items with:
/// - A header with title and add button
/// - Optional additional descriptive text
/// - A scrollable list of items or empty state message
/// - Consistent styling and behavior
///
/// Generic Type Parameter:
/// - T: The type of items being displayed in the list
///
/// Key Features:
/// - Only shown when there are items of that type to display
/// - Flexible item rendering through itemBuilder function
/// - Consistent add button placement and behavior
/// - Responsive layout that adapts to content size
/// - Empty state handling with localized messaging
class ListModal<T> extends ConsumerWidget {
  /// The title displayed at the top of the modal
  final String title;

  /// Additional descriptive text shown below the title (optional)
  final String additionalText;

  /// The list of items to display in the modal
  final List<T> items;

  /// Callback function triggered when the add button is pressed
  final VoidCallback onAdd;

  /// Function that builds the UI for each individual item in the list
  /// This allows for flexible rendering of different item types
  final Widget Function(BuildContext, T) itemBuilder;

  const ListModal({
    super.key,
    required this.title,
    required this.additionalText,
    required this.items,
    required this.onAdd,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== MODAL HEADER =====
            // Contains the title and add button in a consistent layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Modal title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Add new item button
                // Positioned on the right side for easy access
                IconButton(
                  key: const Key('add_new_button'),
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAdd,
                ),
              ],
            ),

            // ===== ADDITIONAL TEXT SECTION =====
            // Optional descriptive text that provides context about the list
            if (additionalText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(additionalText),
            ],

            const SizedBox(height: 16),

            // ===== CONTENT AREA =====
            // Displays either the list of items or an empty state message
            if (items.isEmpty)
              // ===== EMPTY STATE =====
              // Shown when there are no items to display
              // Provides clear feedback to users about the empty state
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    localizations.noItemsYet,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
              )
            else
              // ===== ITEMS LIST =====
              // Scrollable list that displays all items using the provided itemBuilder
              // Uses Flexible to allow the list to take only the space it needs
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true, // Only take the space needed for items
                  itemCount: items.length, // Total number of items to display
                  itemBuilder: (context, index) =>
                      itemBuilder(context, items[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
