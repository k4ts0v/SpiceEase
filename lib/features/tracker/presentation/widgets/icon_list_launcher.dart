// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';

// Internationalization support for multi-language strings
import 'package:spiceease/l10n/app_localizations.dart';

// Custom reusable list modal component
import 'package:spiceease/features/tracker/presentation/widgets/list_modal.dart';

// ===== ICON-BASED LIST LAUNCHER COMPONENT =====
// This section provides a clickable icon widget that displays lists and handles item management

/// A versatile widget that presents a clickable icon with stats for launching item lists
///
/// This component serves as a launcher for different types of trackable items (moods, habits, tasks, etc.).
/// It displays:
/// - A themed icon button that users can tap
/// - A title label identifying the item type
/// - A stats badge showing current count or status
/// - Modal dialogs for listing and managing items
///
/// Key Features:
/// - Generic type support for different item types
/// - Handles both empty and populated item states
/// - Provides consistent UI/UX across different trackers
/// - Integrates edit, delete, and add functionality
/// - Responsive design with theme-aware styling
///
/// Behavior:
/// - When items exist: Opens a modal list for browsing/managing items
/// - When empty: Either opens add dialog directly or shows empty state modal
/// - Special handling for mood tracking with dedicated empty state behavior
class IconListLauncher<T> extends StatelessWidget {
  /// The display title shown below the icon
  final String title;

  /// The icon displayed in the circular button
  final Icon icon;

  /// List of items of type T to display in the modal
  final List<T> items;

  /// Function to convert an item to its display string
  final String Function(T) itemBuilder;

  /// Optional function to provide additional text for each item (e.g., timestamps, details)
  final String Function(T)? additionalTextBuilder;

  /// Callback triggered when the add button is pressed in the modal
  /// Also used as fallback when icon is tapped and items are empty (if onAddEmpty is null)
  final VoidCallback? onAdd;

  /// Specific callback for when the icon is tapped and no items exist
  /// Allows different behavior for empty state vs. normal add operations
  final VoidCallback? onAddEmpty;

  /// Callback when an item is tapped in the list (typically for viewing details)
  final Function(T) onTap;

  /// Callback for deleting an item from the list
  final Function(T) onDelete;

  /// Callback for editing an existing item
  final Function(T) onEdit;

  /// Function that generates the stats text displayed in the badge
  /// Examples: "3 today", "2/5 done", "Last: 8/10"
  final String Function() statsLabelBuilder;

  /// Flag to identify mood launchers for special empty state handling
  /// Mood tracking often requires immediate input when empty
  final bool isMoodLauncher;

  const IconListLauncher({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.itemBuilder,
    this.additionalTextBuilder,
    required this.onAdd,
    this.onAddEmpty,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.statsLabelBuilder,
    this.isMoodLauncher = false, // Default to false for non-mood trackers
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 100, // Fixed width for consistent grid layout
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== MAIN ICON BUTTON =====
          // Circular button with primary color background that launches the appropriate modal
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: icon,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                // ===== ICON PRESS LOGIC =====
                // Determines whether to show list modal or add dialog based on item state
                debugPrint(
                    "[APP CODE IconListLauncher] IconButton onPressed. title: $title, items.length: ${items.length}, isMoodLauncher: $isMoodLauncher");

                if (items.isNotEmpty) {
                  // ===== SHOW LIST MODAL =====
                  // When items exist, display them in a scrollable modal for management
                  debugPrint(
                      "[APP CODE IconListLauncher] items.isNotEmpty is TRUE. Calling _showListModal for '$title'.");
                  try {
                    _showListModal(context);
                    debugPrint(
                        "[APP CODE IconListLauncher] _showListModal for '$title' was called (it uses showDialog).");
                  } catch (e, s) {
                    debugPrint(
                        "[APP CODE IconListLauncher] ERROR calling _showListModal for '$title': $e\n$s");
                  }
                } else {
                  // ===== HANDLE EMPTY STATE =====
                  // Different behaviors based on launcher type and available callbacks
                  debugPrint(
                      "[APP CODE IconListLauncher] items.isNotEmpty is FALSE for '$title'. Handling empty case.");

                  if (isMoodLauncher && onAddEmpty != null) {
                    // Mood launchers with custom empty handling
                    debugPrint(
                        "[APP CODE IconListLauncher] MoodLauncher ('$title') with onAddEmpty. Calling onAddEmpty.");
                    try {
                      onAddEmpty!();
                      debugPrint(
                          "[APP CODE IconListLauncher] onAddEmpty (for mood '$title') called successfully.");
                    } catch (e, s) {
                      debugPrint(
                          "[APP CODE IconListLauncher] ERROR in onAddEmpty (for mood '$title'): $e\n$s");
                    }
                  } else if (!isMoodLauncher && onAddEmpty != null) {
                    // Non-mood launchers with custom empty handling
                    debugPrint(
                        "[APP CODE IconListLauncher] Not MoodLauncher ('$title'), with onAddEmpty. Calling onAddEmpty.");
                    try {
                      onAddEmpty!();
                      debugPrint(
                          "[APP CODE IconListLauncher] onAddEmpty (not mood '$title') called successfully.");
                    } catch (e, s) {
                      debugPrint(
                          "[APP CODE IconListLauncher] ERROR in onAddEmpty (not mood '$title'): $e\n$s");
                    }
                  } else {
                    // Fallback to general add functionality
                    debugPrint(
                        "[APP CODE IconListLauncher] Fallback for '$title': Calling general onAdd.");
                    try {
                      if (onAdd != null) {
                        onAdd!();
                      }
                      debugPrint(
                          "[APP CODE IconListLauncher] General onAdd for '$title' called successfully.");
                    } catch (e, s) {
                      debugPrint(
                          "[APP CODE IconListLauncher] ERROR in general onAdd for '$title': $e\n$s");
                    }
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 8),

          // ===== TITLE LABEL =====
          // Displays the type of items this launcher manages
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // ===== STATS BADGE =====
          // Displays current status or count in a colored badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statsLabelBuilder(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Displays a modal dialog containing the list of items for management
  ///
  /// This method creates and shows a ListModal with the current items,
  /// allowing users to view, edit, delete, or add new items.
  void _showListModal(BuildContext context) {
    debugPrint(
        "[APP CODE IconListLauncher] _showListModal called for $title. onAdd is ${onAdd != null ? 'NOT NULL' : 'NULL'}");

    showDialog(
      context: context,
      builder: (context) {
        return ListModal<T>(
          title: title,
          items: items,
          // ===== ADD BUTTON CALLBACK =====
          // Handles the add button press from within the modal
          onAdd: onAdd != null
              ? () {
                  debugPrint(
                      "[APP CODE IconListLauncher] onAdd callback triggered from ListModal for $title");
                  Navigator.of(context).pop(); // Close the modal first
                  onAdd!(); // Then trigger the add functionality
                }
              : () {}, // Provide empty callback instead of null to prevent errors
          additionalText: '', // No additional text needed for this modal
          itemBuilder: (context, item) => _buildListItem(context, item),
        );
      },
    );
  }

  /// Builds an individual list item widget for display in the modal
  ///
  /// Each item is rendered as a Card with:
  /// - Main content from itemBuilder
  /// - Optional subtitle from additionalTextBuilder
  /// - Edit and delete action buttons
  /// - Tap gesture for viewing/interacting with the item
  Widget _buildListItem(BuildContext listModalItemContext, T item) {
    final theme = Theme.of(listModalItemContext);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        // ===== ITEM TITLE =====
        // Primary text content for the item
        title: Text(
          itemBuilder(item),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        // ===== ITEM SUBTITLE =====
        // Optional additional information (timestamps, details, etc.)
        subtitle: additionalTextBuilder != null
            ? Text(
                additionalTextBuilder!(item),
                style: theme.textTheme.bodySmall,
              )
            : null,
        // ===== ITEM TAP HANDLER =====
        // Closes modal and triggers item interaction
        onTap: () {
          Navigator.of(listModalItemContext).pop(); // Close ListModal
          onTap(item); // Trigger item-specific action
        },
        // ===== ACTION BUTTONS =====
        // Edit and delete buttons for item management
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== EDIT BUTTON =====
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                Navigator.of(listModalItemContext).pop(); // Close ListModal
                onEdit(item); // Open editor for this item
              },
            ),
            // ===== DELETE BUTTON =====
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              onPressed: () =>
                  _showDeleteConfirmation(listModalItemContext, item),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting an item
  ///
  /// This method displays an AlertDialog to confirm the delete operation.
  /// It handles the modal stack properly by:
  /// 1. Showing confirmation dialog over the list modal
  /// 2. Closing confirmation dialog on cancel/confirm
  /// 3. Closing list modal only after successful deletion
  /// 4. Keeping list modal open if deletion fails
  void _showDeleteConfirmation(BuildContext listModalContext, T item) {
    final localizations = AppLocalizations.of(listModalContext)!;
    final theme = Theme.of(listModalContext);

    showDialog(
      context:
          listModalContext, // Show AlertDialog using ListModal's context as parent
      builder: (alertDialogContext) => AlertDialog(
        // ===== CONFIRMATION DIALOG CONTENT =====
        title: Text(localizations.confirmDelete),
        content:
            Text(localizations.deleteConfirmationMessage(itemBuilder(item))),
        actions: [
          // ===== CANCEL BUTTON =====
          // Closes confirmation dialog without deleting
          TextButton(
            child: Text(localizations.cancel),
            onPressed: () =>
                Navigator.of(alertDialogContext).pop(), // Pop only AlertDialog
          ),
          // ===== CONFIRM DELETE BUTTON =====
          // Performs the deletion and handles success/failure states
          TextButton(
            child: Text(
              localizations.delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onPressed: () async {
              Navigator.of(alertDialogContext).pop(); // Pop AlertDialog first
              try {
                await onDelete(item); // Perform delete action
                // ===== SUCCESS: CLOSE LIST MODAL =====
                // Only close the list modal if deletion was successful
                if (listModalContext.mounted) {
                  Navigator.of(listModalContext).pop();
                }
              } catch (e) {
                // ===== FAILURE: KEEP LIST MODAL OPEN =====
                // Show error message and keep the list modal open for retry
                if (listModalContext.mounted) {
                  ScaffoldMessenger.of(listModalContext).showSnackBar(
                    SnackBar(
                        content: Text(localizations.failedToDeleteItem(title
                            .toLowerCase()))), // Use title for context-specific error
                  );
                }
                debugPrint("Delete failed: $e");
              }
            },
          ),
        ],
      ),
    );
  }
}
