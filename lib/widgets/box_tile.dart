import 'package:flutter/material.dart';

import '../models/box_data.dart';

class BoxTile extends StatelessWidget {
  const BoxTile({
    super.key,
    required this.boxNumber,
    required this.data,
    required this.onTap,
  });

  final int boxNumber;
  final BoxData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color statusColor = data.isComplete
        ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
        : theme.colorScheme.onSurfaceVariant;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: data.status,
          button: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    '$boxNumber',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data.status,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
