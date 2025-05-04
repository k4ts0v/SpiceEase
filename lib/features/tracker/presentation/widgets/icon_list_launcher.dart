import 'package:flutter/material.dart';
import 'package:spiceease/features/tracker/presentation/widgets/list_modal.dart';

class IconListLauncher<T> extends StatelessWidget {
  final String title;
  final Icon icon;
  final List<T> items;
  final String Function(T) itemBuilder;
  final String Function(T)? additionalTextBuilder;
  final VoidCallback onAdd;
  final Function(T) onTap;
  final Function(T) onDelete;
  final Function(T) onEdit;
  final String Function() statsLabelBuilder;

  const IconListLauncher({
    Key? key,
    required this.title,
    required this.icon,
    required this.items,
    required this.itemBuilder,
    this.additionalTextBuilder,
    required this.onAdd,
    required this.onTap,
    required this.onDelete,
    required this.onEdit,
    required this.statsLabelBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: icon,
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
              onPressed: () => _showListModal(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statsLabelBuilder(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showListModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => ListModal<T>(
        title: title,
        additionalText: '',
        items: items,
        onAdd: () {
          Navigator.of(context).pop();
          onAdd();
        },
        itemBuilder: (ctx, item) => _buildListItem(ctx, item),
      ),
    );
  }

  Widget _buildListItem(BuildContext context, T item) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        title: Text(
          itemBuilder(item),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: additionalTextBuilder != null
            ? Text(
                additionalTextBuilder!(item),
                style: const TextStyle(fontSize: 12),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.of(context).pop();
                onEdit(item);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(context, item),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, T item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${itemBuilder(item)}"?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              onDelete(item);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}