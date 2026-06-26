import 'package:flutter/material.dart';

import '../models/box_data.dart';

enum _BoxStatus { complete, partial, empty }

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

  _BoxStatus _statusFor(BoxData d) {
    if (d.isComplete) return _BoxStatus.complete;
    if (d.filledCount > 0) return _BoxStatus.partial;
    return _BoxStatus.empty;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = _statusFor(data);

    final Color statusColor = switch (status) {
      _BoxStatus.complete =>
        isDark ? Colors.green.shade300 : Colors.green.shade700,
      _BoxStatus.partial =>
        isDark ? Colors.amber.shade300 : Colors.amber.shade800,
      _BoxStatus.empty => theme.colorScheme.onSurfaceVariant,
    };

    final String statusLabel = switch (status) {
      _BoxStatus.complete => 'Собрано',
      _BoxStatus.partial => 'Частично',
      _BoxStatus.empty => 'Не собрано',
    };

    final String semanticLabel = switch (status) {
      _BoxStatus.complete => 'Box $boxNumber, collected',
      _BoxStatus.partial => 'Box $boxNumber, partially collected',
      _BoxStatus.empty => 'Box $boxNumber, not collected',
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          label: semanticLabel,
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
                    statusLabel,
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
