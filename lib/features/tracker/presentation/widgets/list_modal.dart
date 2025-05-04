import 'package:flutter/material.dart';

class ListModal<T> extends StatelessWidget {
  final String title;
  final String additionalText;
  final List<T> items;
  final VoidCallback onAdd;
  final Widget Function(BuildContext, T) itemBuilder;

  const ListModal({
    Key? key,
    required this.title,
    required this.additionalText,
    required this.items,
    required this.onAdd,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            if (items.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No items yet',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) => itemBuilder(context, items[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}