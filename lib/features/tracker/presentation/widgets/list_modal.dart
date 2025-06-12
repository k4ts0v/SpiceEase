import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiceease/l10n/app_localizations.dart';

class ListModal<T> extends ConsumerWidget {
  final String title;
  final String additionalText;
  final List<T> items;
  final VoidCallback onAdd;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  key: const Key('add_new_button'),
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: onAdd,
                ),
              ],
            ),
            if (additionalText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(additionalText),
            ],
            const SizedBox(height: 16),
            // FIX: Use items instead of moods
            if (items.isEmpty)
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
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount:
                      items.length, // Use items.length instead of moods.length
                  itemBuilder: (context, index) => itemBuilder(context,
                      items[index]), // Use items[index] instead of moods[index]
                ),
              ),
          ],
        ),
      ),
    );
  }
}
