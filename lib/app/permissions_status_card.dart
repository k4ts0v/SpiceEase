import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PermissionStatusCard extends ConsumerStatefulWidget {
  const PermissionStatusCard({super.key});

  @override
  ConsumerState<PermissionStatusCard> createState() =>
      _PermissionStatusCardState();
}

class _PermissionStatusCardState extends ConsumerState<PermissionStatusCard> {
  final Map<String, bool> _permissionStatus = {};
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'App Permissions',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPermissionRow(
              'Notifications',
              _permissionStatus['notifications'] ?? false,
              Icons.notifications,
              'Required for medication and habit reminders',
            ),
            _buildPermissionRow(
              'Battery Optimization',
              _permissionStatus['batteryOptimization'] ?? false,
              Icons.battery_saver,
              'Prevents Android from stopping notifications',
            ),
            _buildPermissionRow(
              'Exact Alarms',
              _permissionStatus['exactAlarms'] ?? false,
              Icons.alarm,
              'Ensures precise timing for critical reminders',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
      String title, bool granted, IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: granted ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Icon(
            granted ? Icons.check_circle : Icons.warning,
            color: granted ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }
}
