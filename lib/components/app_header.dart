import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final String sectionName;

  const AppHeader({
    Key? key,
    required this.sectionName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = theme.textTheme.headlineSmall?.fontSize ?? 24.0;

    return Container(
      width: double.infinity, // Take full viewport width (100% vw)
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Allow the row to shrink
        children: [
          ImageIcon(
            const AssetImage('assets/icons/spiceease_logo.png'),
            color: theme.colorScheme.primary,
            size: iconSize,
          ),
          const SizedBox(width: 8),
          Flexible( // Make text flexible to prevent overflow
            child: Text(
              sectionName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}