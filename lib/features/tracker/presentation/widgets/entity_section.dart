// Standard Flutter imports for UI components
import 'package:flutter/material.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

// ===== REUSABLE ENTITY SECTION COMPONENT =====
// This component provides a standardized UI pattern for displaying entity collections

/// A reusable widget that displays a standardized section for any entity type
///
/// This generic component provides consistent styling and behavior across all
/// entity types in the tracker feature. It handles:
/// - Unified visual design with shadows and rounded corners
/// - Loading, error, and empty state management
/// - Header with title and add button
/// - Scrollable list of items with custom item builders
/// - Consistent spacing and dividers
/// - Accessibility features like tooltips
///
/// The component is generic (`<T>`) allowing it to work with any entity type
/// including symptoms, medications, tasks, and habits while maintaining
/// type safety and consistent behavior.
///
/// Usage:
/// ```dart
/// EntitySection<TaskModel>(
///   title: "Tasks",
///   items: tasks,
///   onTap: (task) => editTask(task),
///   onAdd: () => addNewTask(),
///   itemBuilder: (task) => TaskListItem(task: task),
/// )
/// ```
class EntitySection<T> extends StatelessWidget {
  /// The display title for the section header
  final String title;

  /// List of entities to display in the section
  final List<T> items;

  /// Whether the section is currently loading data
  final bool isLoading;

  /// Error message to display if data loading failed
  final String? error;

  /// Callback function when an item is tapped for editing
  final void Function(T) onTap;

  /// Callback function when the add button is pressed
  final VoidCallback onAdd;

  /// Builder function that creates the UI for each item
  final Widget Function(T) itemBuilder;

  const EntitySection({
    super.key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.error,
    required this.onTap,
    required this.onAdd,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    // ===== THEME AND LOCALIZATION =====
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        // ===== CONSISTENT VISUAL DESIGN =====
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== SECTION HEADER =====
          _buildSectionHeader(context, theme, localizations),

          // ===== CONTENT AREA =====
          _buildContentArea(context, theme, localizations),
        ],
      ),
    );
  }

  /// Builds the section header with title and add button
  Widget _buildSectionHeader(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ===== SECTION TITLE =====
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis, // Handle long text gracefully
            ),
          ),

          // ===== ADD NEW ITEM BUTTON =====
          IconButton(
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.all(8),
            ),
            onPressed: onAdd,
            tooltip: localizations.addNew,
          ),
        ],
      ),
    );
  }

  /// Builds the main content area handling different states
  Widget _buildContentArea(
    BuildContext context,
    ThemeData theme,
    AppLocalizations localizations,
  ) {
    // ===== LOADING STATE =====
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // ===== ERROR STATE =====
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      );
    }

    // ===== EMPTY STATE =====
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            localizations.noItemsYet,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // ===== ITEMS LIST =====
    return _buildItemsList(context, theme);
  }

  /// Builds the scrollable list of items with dividers
  Widget _buildItemsList(BuildContext context, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== INTERACTIVE ITEM =====
            InkWell(
              onTap: () => onTap(items[index]),
              child: itemBuilder(items[index]),
            ),

            // ===== ITEM DIVIDER =====
            // Show divider between items but not after the last item
            if (index < items.length - 1)
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
          ],
        );
      },
    );
  }
}
