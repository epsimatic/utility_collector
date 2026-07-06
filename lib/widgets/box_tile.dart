import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../locator.dart';
import '../models/box_data.dart';
import '../state/app_settings.dart';

class BoxTile extends WatchingWidget {
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
    watchPropertyValue((AppSettings s) => s.metricsStartWith1);
    final metricLabel = getIt<AppSettings>().metricLabel;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color statusColor = data.isComplete
        ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
        : theme.colorScheme.onSurfaceVariant;

    final status = data.status(metricLabel);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: status,
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
                    status,
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
