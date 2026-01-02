import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusIndicator extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData? icon;

  const StatusIndicator({
    super.key,
    required this.label,
    required this.isActive,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.successGreen : AppTheme.errorRed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? (isActive ? Icons.check_circle : Icons.cancel),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
