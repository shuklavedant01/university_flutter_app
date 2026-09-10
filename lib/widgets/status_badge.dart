import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum BadgeType {
  admitted,
  pending,
  urgent,
  institutional,
  info,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = BadgeType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    BorderSide border;

    switch (type) {
      case BadgeType.admitted:
        bg = AppColors.successContainer;
        text = AppColors.success;
        border = BorderSide(color: AppColors.success.withOpacity(0.3));
        break;
      case BadgeType.pending:
        bg = AppColors.warningContainer;
        text = AppColors.warning;
        border = BorderSide(color: AppColors.warning.withOpacity(0.3));
        break;
      case BadgeType.urgent:
        bg = AppColors.errorContainer;
        text = AppColors.urgentCrimson;
        border = BorderSide(color: AppColors.urgentCrimson.withOpacity(0.3));
        break;
      case BadgeType.institutional:
        bg = AppColors.primaryContainer;
        text = AppColors.tertiaryFixedDim;
        border = BorderSide(color: AppColors.tertiaryFixedDim.withOpacity(0.3));
        break;
      case BadgeType.info:
      default:
        bg = AppColors.surfaceContainer;
        text = AppColors.onSurface;
        border = BorderSide(color: AppColors.outlineVariant);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.fromBorderSide(border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: text,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
