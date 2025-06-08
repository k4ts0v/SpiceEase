import 'package:flutter/material.dart';
import 'package:spiceease/l10n/app_localizations.dart';
import 'package:spiceease/features/tracker/presentation/widgets/list_modal.dart';

class IconListLauncher<T> extends StatelessWidget {
  final String title;
  final Icon icon;
  final List<T> items;
  final String Function(T) itemBuilder;
  final String Function(T)? additionalTextBuilder;
  final VoidCallback?
      onAdd; // Called by ListModal's add button, or if icon tapped when empty & onAddEmpty is null
  final VoidCallback?
      onAddEmpty; // Specifically for icon tap when items are empty
  final Function(T) onTap;
  final Function(T) onDelete;
  final Function(T) onEdit;
  final String Function() statsLabelBuilder;
  final bool isMoodLauncher; // Flag to identify if this is the mood launcher

  const IconListLauncher({
    Key? key,
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
    this.isMoodLauncher = false, // Default to false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: icon,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () {
                // ---- START DEBUG CODE ----
                debugPrint(
                    "[APP CODE IconListLauncher] IconButton onPressed. title: $title, items.length: ${items.length}, isMoodLauncher: $isMoodLauncher");
                if (items.isNotEmpty) {
                  debugPrint(
                      "[APP CODE IconListLauncher] items.isNotEmpty is TRUE. Calling _showListModal for '$title'.");
                  try {
                    _showListModal(context); // This uses showDialog
                    debugPrint(
                        "[APP CODE IconListLauncher] _showListModal for '$title' was called (it uses showDialog).");
                  } catch (e, s) {
                    debugPrint(
                        "[APP CODE IconListLauncher] ERROR calling _showListModal for '$title': $e\n$s");
                  }
                } else {
                  debugPrint(
                      "[APP CODE IconListLauncher] items.isNotEmpty is FALSE for '$title'. Handling empty case.");
                  // Items are empty
                  if (isMoodLauncher && onAddEmpty != null) {
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
                // ---- END DEBUG CODE ----
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
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

  void _showListModal(BuildContext context) {
    debugPrint("[APP CODE IconListLauncher] _showListModal called for $title. onAdd is ${onAdd != null ? 'NOT NULL' : 'NULL'}");
    showDialog(
      context: context,
      builder: (context) {
        return ListModal<T>(
          title: title,
          items: items,
          onAdd: onAdd != null ? () {
            // Provide the onAdd callback
            debugPrint("[APP CODE IconListLauncher] onAdd callback triggered from ListModal for $title");
            Navigator.of(context).pop();
            onAdd!();
          } : () {}, // Provide empty callback instead of null
          additionalText: '',
          itemBuilder: (context, item) => _buildListItem(context, item),
        );
      },
    );
  }

  Widget _buildListItem(BuildContext listModalItemContext, T item) {
    // 'listModalItemContext' is the BuildContext from within the ListModal, for this specific item.
    // It can be used to pop the ListModal.
    final localizations = AppLocalizations.of(listModalItemContext)!;
    final theme = Theme.of(listModalItemContext);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(
          itemBuilder(item),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: additionalTextBuilder != null
            ? Text(
                additionalTextBuilder!(item),
                style: theme.textTheme.bodySmall,
              )
            : null,
        onTap: () {
          Navigator.of(listModalItemContext).pop(); // Close ListModal
          onTap(item);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () {
                Navigator.of(listModalItemContext).pop(); // Close ListModal
                onEdit(item); // Open editor
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.error,
              ),
              // Pass listModalItemContext to _showDeleteConfirmation.
              // This context will be used to pop ListModal after delete confirmation.
              onPressed: () =>
                  _showDeleteConfirmation(listModalItemContext, item),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext listModalContext, T item) {
    // 'listModalContext' is the context of the ListModal, passed from _buildListItem.
    // It will be used to pop the ListModal.
    final localizations = AppLocalizations.of(listModalContext)!;
    final theme = Theme.of(listModalContext);

    showDialog(
      context:
          listModalContext, // Show AlertDialog using ListModal's context as parent
      builder: (alertDialogContext) => AlertDialog(
        // alertDialogContext is for the AlertDialog itself
        title: Text(localizations.confirmDelete),
        content:
            Text(localizations.deleteConfirmationMessage(itemBuilder(item))),
        actions: [
          TextButton(
            child: Text(localizations.cancel),
            onPressed: () =>
                Navigator.of(alertDialogContext).pop(), // Pop only AlertDialog
          ),
          TextButton(
            child: Text(
              localizations.delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onPressed: () async {
              // Make this async
              Navigator.of(alertDialogContext).pop(); // Pop AlertDialog first
              try {
                await onDelete(item); // Perform delete action
                // Pop ListModal only on success
                if (listModalContext.mounted) {
                  Navigator.of(listModalContext).pop();
                }
              } catch (e) {
                // If delete fails, ListModal remains open.
                // A SnackBar can be shown from the ListModal or its parent
                // if the controller/service that onDelete calls handles showing it.
                // For now, we ensure ListModal doesn't pop.
                if (listModalContext.mounted) {
                  ScaffoldMessenger.of(listModalContext).showSnackBar(
                    SnackBar(
                        content: Text(localizations.failedToDeleteItem(title
                            .toLowerCase()))), // Assuming title is like "Mood"
                  );
                }
                print("Delete failed: $e");
              }
            },
          ),
        ],
      ),
    );
  }
}
