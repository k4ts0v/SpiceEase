import 'package:flutter/material.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class EntitySection<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final bool isLoading;
  final String? error;
  final void Function(T) onTap;
  final VoidCallback onAdd;
  final Widget Function(T) itemBuilder;

  const EntitySection({
    Key? key,
    required this.title,
    required this.items,
    required this.isLoading,
    required this.error,
    required this.onTap,
    required this.onAdd,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded( // Wrap the Text widget with Expanded
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis, // Handle long text gracefully
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: onAdd,
                  tooltip: localizations.addNew,
                ),
              ],
            ),
          ),
          if (isLoading)
            Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ))
          else if (error != null)
            Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ))
          else if (items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  localizations.noItemsYet,
                  style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ),
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => onTap(items[index]),
                      child: itemBuilder(items[index]),
                    ),
                    if (index < items.length - 1)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}