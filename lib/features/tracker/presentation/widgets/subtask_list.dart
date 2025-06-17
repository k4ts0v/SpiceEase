import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/data/models/subtask_model.dart';
import 'package:spiceease/data/models/task_model.dart';
import 'package:spiceease/data/providers/subtask_provider.dart';
import 'package:spiceease/features/tracker/presentation/widgets/modals.dart';
import 'package:spiceease/features/tracker/presentation/tracker_controller.dart';
import 'package:spiceease/l10n/app_localizations.dart';

/// SubtaskList widget displays and manages subtasks for a parent task
/// with optimistic updates and no rebuilds on completion changes.
class SubtaskList extends ConsumerStatefulWidget {
  final String parentTaskId;
  final TaskModel parentTask;

  const SubtaskList({
    super.key,
    required this.parentTaskId,
    required this.parentTask,
  });

  @override
  ConsumerState<SubtaskList> createState() => _SubtaskListState();
}

class _SubtaskListState extends ConsumerState<SubtaskList> {
  // Local state for optimistic updates
  final Map<String, bool> _localCompletion = {};
  final Map<String, String> _localStatus = {};
  final Set<String> _pendingOps = {};

  bool _effectiveComplete(SubtaskModel s) =>
      _localCompletion[s.id] ?? s.completed;

  String _effectiveStatus(SubtaskModel s) =>
      _localStatus[s.id] ?? s.status ?? 'todo';

      // Helper method to get localized status text
  String _getLocalizedStatus(String status, AppLocalizations localizations) {
    switch (status.toLowerCase()) {
      case 'done':
        return localizations.done;
      case 'in_progress':
        return localizations.inProgress;
      case 'todo':
      default:
        return localizations.todo;
    }
  }

  Future<void> _toggleComplete(SubtaskModel s, bool newComp) async {
    if (!mounted) return;

    final oldComp = _effectiveComplete(s);
    final oldStatus = _effectiveStatus(s);
    final newStatus = newComp
        ? 'done'
        : (oldStatus.toLowerCase() == 'done' ? 'in_progress' : oldStatus);

    // Update local state immediately
    setState(() {
      _localCompletion[s.id] = newComp;
      _pendingOps.add('done_${s.id}');
      if (newStatus != oldStatus) {
        _localStatus[s.id] = newStatus;
      }
    });

    // Backend update with delay to prevent rebuilds
    Future.delayed(const Duration(milliseconds: 100), () async {
      if (!mounted) return;

      try {
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

        if (mounted) {
          setState(() => _pendingOps.remove('done_${s.id}'));
        }
      } catch (e) {
        // Revert local state on error
        if (mounted) {
          setState(() {
            _localCompletion[s.id] = oldComp;
            _localStatus[s.id] = oldStatus;
            _pendingOps.remove('done_${s.id}');
          });
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      }
    });
  }

  void _showAddDialog(BuildContext ctx, AppLocalizations loc, ThemeData th,
      List<SubtaskModel> current) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (dctx) => AlertDialog(
        backgroundColor: th.colorScheme.surface,
        title: Text(loc.addNewSubtask,
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: loc.title),
          autofocus: true,
          onSubmitted: (v) {
            if (v.trim().isNotEmpty) {
              Navigator.pop(dctx);
              _create(v.trim(), current);
            }
          },
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx), child: Text(loc.cancel)),
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

  Future<void> _create(String title, List<SubtaskModel> current) async {
    if (!mounted) return;

    try {
      final next = current.isEmpty
          ? 0
          : current.map((s) => s.order).reduce((a, b) => a > b ? a : b) + 1;
      await ref.read(trackerControllerProvider).createSubtask(
            widget.parentTaskId,
            title,
            '',
            next,
          );

      // Force refresh after creating
      if (mounted) {
        ref.invalidate(subtaskStateNotifierProvider(widget.parentTaskId));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Create failed: $e')));
      }
    }
  }

  Widget _item(SubtaskModel s, AppLocalizations loc, ThemeData th) {
    final comp = _effectiveComplete(s);
    final status = _effectiveStatus(s);
    final updating = _pendingOps.contains('done_${s.id}');

    return ListTile(
      leading: const Icon(Icons.task_alt, size: 20),
      title: Text(s.title,
          style: TextStyle(
              decoration: comp ? TextDecoration.lineThrough : null,
              color: comp
                  ? th.colorScheme.onSurface.withOpacity(0.6)
                  : th.colorScheme.onSurface)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${loc.status}: ${_getLocalizedStatus(status, loc)}',
              style: TextStyle(
                  fontSize: 12, color: th.colorScheme.onSurfaceVariant)),
          Text(
              s.rawTimeValue?.isNotEmpty == true
                  ? '${loc.estimatedTimeLabel}: ${s.rawTimeValue}'
                  : '${loc.estimatedTimeLabel}: ${loc.noTimeEstimate}',
              style: TextStyle(
                  fontSize: 12, color: th.colorScheme.onSurfaceVariant)),
        ],
      ),
      trailing: Checkbox(
        value: comp,
        onChanged: updating ? null : (v) => _toggleComplete(s, v ?? false),
      ),
      onTap: () async {
        await showDialog(
            context: context,
            builder: (_) => SubtaskEditorModal(
                ref: ref, parentTask: widget.parentTask, subtask: s));

        // Refresh after editing
        if (mounted) {
          ref.invalidate(subtaskStateNotifierProvider(widget.parentTaskId));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final th = Theme.of(context);

    // Watch the provider normally to get the subtasks
    final subtasksAsync = ref.watch(subtaskStateNotifierProvider(widget.parentTaskId));

    // Get the current list of subtasks
    final list = subtasksAsync.when(
      data: (subtasks) => List<SubtaskModel>.from(subtasks)
        ..sort((a, b) => a.order.compareTo(b.order)),
      loading: () => <SubtaskModel>[],
      error: (_, __) => <SubtaskModel>[],
    );

    final widgets = <Widget>[
      for (var s in list) _item(s, loc, th),
      if (list.isEmpty && !subtasksAsync.isLoading)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(loc.noSubtasks,
              style: TextStyle(
                  color: th.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic)),
        ),
      if (subtasksAsync.isLoading)
        const Padding(
          padding: EdgeInsets.all(8),
          child: Center(child: CircularProgressIndicator()),
        ),
      TextButton.icon(
        icon: const Icon(Icons.add, size: 14),
        label: Text(loc.addNew),
        onPressed: () => _showAddDialog(context, loc, th, list),
      ),
    ];

    return Column(children: widgets);
  }
}