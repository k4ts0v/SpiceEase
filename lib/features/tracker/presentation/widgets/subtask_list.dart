// Standard Flutter imports for UI components and state management
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Custom model classes that define the data structure
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';

// Provider that manages subtask data across the app
import 'package:spiceease/data/providers/subtask_provider.dart';

// Modal dialogs for editing subtasks
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';

// Controller that handles business logic and API calls
import 'package:spiceease/features/tracker/presentation/controllers/tracker_controller.dart';

// Internationalization for multi-language support
import 'package:spiceease/l10n/app_localizations.dart';

/// SubtaskList widget displays and manages subtasks for a parent task
/// with optimistic updates and no rebuilds on completion changes.
///
/// This widget is designed to provide a smooth user experience by:
/// 1. Showing immediate feedback when checking/unchecking subtasks
/// 2. Preventing the list from rebuilding and causing visual glitches
/// 3. Handling errors gracefully by reverting to previous state
class SubtaskList extends ConsumerStatefulWidget {
  // Required parameters passed from parent widget
  final String parentTaskId; // ID of the task that owns these subtasks
  final TaskModel parentTask; // Full task object for additional context

  const SubtaskList({
    super.key,
    required this.parentTaskId,
    required this.parentTask,
  });

  @override
  ConsumerState<SubtaskList> createState() => _SubtaskListState();
}

class _SubtaskListState extends ConsumerState<SubtaskList> {
  // ===== OPTIMISTIC UI STATE =====
  // These maps store temporary local changes before they're confirmed by the server
  // This allows the UI to update immediately while the backend processes the request

  // Stores temporary completion status (checked/unchecked) for each subtask
  final Map<String, bool> _localCompletion = {};

  // Stores temporary status changes (todo/in_progress/done) for each subtask
  final Map<String, String> _localStatus = {};

  // Tracks which subtasks are currently being updated (prevents double-clicks)
  final Set<String> _pendingOps = {};

  // ===== HELPER METHODS =====

  /// Gets the effective completion status for a subtask
  /// First checks local state (optimistic updates), then falls back to server data
  bool _effectiveComplete(SubtaskModel s) =>
      _localCompletion[s.id] ?? s.completed;

  /// Gets the effective status for a subtask
  /// First checks local state, then server data.
  String _effectiveStatus(SubtaskModel s) =>
      _localStatus[s.id] ?? s.status;

  /// Converts internal status strings to user-friendly localized text
  /// This ensures the UI shows "To Do" instead of "todo", etc.
  String _getLocalizedStatus(String status, AppLocalizations localizations) {
    switch (status.toLowerCase()) {
      case 'done':
        return localizations.done; // Shows "Done"
      case 'in_progress':
        return localizations.inProgress; // Shows "In Progress"
      case 'todo':
      default:
        return localizations.todo; // Shows "To Do"
    }
  }

  /// Handles checking/unchecking a subtask with optimistic updates
  /// This is the core method that provides immediate feedback
  Future<void> _toggleComplete(SubtaskModel s, bool newComp) async {
    // Safety check: don't proceed if widget is no longer mounted
    if (!mounted) return;

    // Store current values for potential rollback on error
    final oldComp = _effectiveComplete(s);
    final oldStatus = _effectiveStatus(s);

    // Determine new status based on completion
    // When checked: always "done"
    // When unchecked: "in_progress" if it was "done", otherwise keep current status
    final newStatus = newComp
        ? 'done'
        : (oldStatus.toLowerCase() == 'done' ? 'in_progress' : oldStatus);

    // ===== OPTIMISTIC UPDATE =====
    // Update local state immediately - this makes the UI respond instantly
    setState(() {
      _localCompletion[s.id] = newComp; // Update completion status
      _pendingOps.add('done_${s.id}'); // Mark as updating (disables checkbox)
      if (newStatus != oldStatus) {
        _localStatus[s.id] = newStatus; // Update status if it changed
      }
    });

    // ===== BACKEND UPDATE =====
    // Small delay prevents immediate rebuilds while still updating the server quickly
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!mounted) return; // Safety check again

      try {
        // Call the backend to save changes
        await ref.read(trackerControllerProvider).updateSubtask(
              widget.parentTask.id,
              s,
              s.title,
              newComp,
              newStatus,
              s.rawTimeValue ?? '',
              s.startTime,
              s.endTime,
            );

        // Success: remove the pending operation marker
        if (mounted) {
          setState(() => _pendingOps.remove('done_${s.id}'));
        }
      } catch (e) {
        // ===== ERROR HANDLING =====
        // If backend fails, revert all local changes to show the true state
        if (mounted) {
          setState(() {
            _localCompletion[s.id] = oldComp; // Revert completion
            _localStatus[s.id] = oldStatus; // Revert status
            _pendingOps.remove('done_${s.id}'); // Remove pending marker
          });
          // Show user-friendly error message
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    });
  }

  /// Shows a dialog to add a new subtask
  /// Uses a simple text input with submit handling
  void _showAddDialog(BuildContext ctx, AppLocalizations loc, ThemeData th,
      List<SubtaskModel> current) {
    final ctrl = TextEditingController(); // Controls the text input

    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: th.colorScheme.surface, // Use theme colors
        title: Text(loc.addNewSubtask,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: loc.title),
          autofocus: true, // Automatically focus for immediate typing
          // Handle Enter key press
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              Navigator.pop(dctx); // Close dialog
              _create(v.trim(), current); // Create subtask
            }
          },
        ),
        actions: [
          // Cancel button
          TextButton(
              onPressed: () => Navigator.pop(dctx), child: Text(loc.cancel)),
          // Add button
          TextButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  Navigator.pop(dctx);
                  _create(ctrl.text.trim(), current);
                }
              },
              child: Text(loc.addNewSubtask)),
        ],
      ),
    );
  }

  /// Creates a new subtask in the backend
  Future<void> _create(String title, List<SubtaskModel> current) async {
    if (!mounted) return;

    try {
      // Calculate the next order number (for sorting subtasks)
      // If no subtasks exist, start at 0; otherwise, use max + 1
      final next = current.isEmpty
          ? 0
          : current.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1;

      // Call backend to create the subtask
      await ref.read(trackerControllerProvider).createSubtask(
            widget.parentTaskId,
            title,
            '', // Empty description
            next, // Order number
          );

      // Force refresh to show the new subtask
      // This is necessary because we're adding new data, not just updating existing
      if (mounted) {
        ref.invalidate(subtaskStateNotifierProvider(widget.parentTaskId));
      }
    } catch (e) {
      // Show error message if creation fails
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Create failed: $e')));
      }
    }
  }

  /// Builds a single subtask list item
  /// This method creates the visual representation of each subtask
  Widget _item(SubtaskModel s, AppLocalizations loc, ThemeData th) {
    // Get current state (combining local optimistic updates with server data)
    final comp = _effectiveComplete(s);
    final status = _effectiveStatus(s);
    final updating =
        _pendingOps.contains('done_${s.id}'); // Is it being updated?

    return ListTile(
      // Small task icon on the left
      leading: const Icon(Icons.task_alt, size: 20),

      // Subtask title with conditional styling
      title: Text(s.title,
          style: TextStyle(
              // Strike through text if completed
              decoration: comp ? TextDecoration.lineThrough : null,
              // Fade color if completed
              color: comp
                  ? th.colorScheme.onSurface.withValues(alpha: 0.6)
                  : th.colorScheme.onSurface)),

      // Status and time information below the title
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status line (e.g., "Status: In Progress")
          Text('${loc.status}: ${_getLocalizedStatus(status, loc)}',
              style: TextStyle(
                  fontSize: 12, color: th.colorScheme.onSurfaceVariant)),
          // Time estimate line
          Text(
              s.rawTimeValue?.isNotEmpty == true
                  ? '${loc.estimatedTimeLabel}: ${s.rawTimeValue}'
                  : '${loc.estimatedTimeLabel}: ${loc.noTimeEstimate}',
              style: TextStyle(
                  fontSize: 12, color: th.colorScheme.onSurfaceVariant)),
        ],
      ),

      // Checkbox on the right for completion toggle
      trailing: Checkbox(
        value: comp,
        // Disable checkbox while updating to prevent double-clicks
        onChanged: updating ? null : (v) => _toggleComplete(s, v ?? false),
      ),

      // Tap anywhere to edit the subtask
      onTap: () async {
        await showDialog(
            context: context,
            builder: (_) => SubtaskEditorModal(
                ref: ref, parentTask: widget.parentTask, subtask: s));

        // Refresh after editing to show any changes
        if (mounted) {
          ref.invalidate(subtaskStateNotifierProvider(widget.parentTaskId));
        }
      },
    );
  }

  /// Main build method - constructs the entire widget tree
  @override
  Widget build(BuildContext context) {
    // Get localization and theme objects
    final loc = AppLocalizations.of(context)!;
    final th = Theme.of(context);

    // ===== DATA LOADING =====
    // Watch the subtask provider to get live data updates
    // This creates a stream of data that rebuilds the widget when subtasks change
    final subtasksAsync =
        ref.watch(subtaskStateNotifierProvider(widget.parentTaskId));

    // Handle the async data (loading, success, error states)
    final list = subtasksAsync.when(
      // Success: we have data
      data: (subtasks) => List<SubtaskModel>.from(subtasks)
        ..sort((a, b) => a.order.compareTo(b.order)), // Sort by order field
      // Loading: show empty list (loading indicator shown separately)
      loading: () => <SubtaskModel>[],
      // Error: show empty list (could show error message instead)
      error: (_, __) => <SubtaskModel>[],
    );

    // ===== BUILD UI COMPONENTS =====
    final widgets = <Widget>[
      // Generate a list item for each subtask
      for (var s in list) _item(s, loc, th),

      // Show "no subtasks" message when list is empty and not loading
      if (list.isEmpty && !subtasksAsync.isLoading)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(loc.noSubtasks,
              style: TextStyle(
                  color: th.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic)),
        ),

      // Show loading spinner while fetching data
      if (subtasksAsync.isLoading)
        const Padding(
          padding: EdgeInsets.all(8),
          child: Center(child: CircularProgressIndicator()),
        ),

      // Add new subtask button at the bottom
      TextButton.icon(
        icon: const Icon(Icons.add, size: 14),
        label: Text(loc.addNew),
        onPressed: () => _showAddDialog(context, loc, th, list),
      ),
    ];

    // Return a column containing all the widgets
    // Column arranges children vertically
    return Column(children: widgets);
  }
}
