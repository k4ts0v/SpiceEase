import 'package:flutter/material.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.all(8),
                  ),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(child: Text(error!))
          else if (items.isEmpty)
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
            ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) => InkWell(
                onTap: () => onTap(items[index]),
                child: itemBuilder(items[index]),
              ),
            ),
        ],
      ),
    );
  }
}