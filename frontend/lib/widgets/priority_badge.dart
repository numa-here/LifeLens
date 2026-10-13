import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final norm = priority.toLowerCase();

    Color bgColor;
    Color textColor;
    String label;

    switch (norm) {
      case 'urgent':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = l10n.priorityUrgent;
        break;
      case 'high':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFE65100);
        label = l10n.priorityHigh;
        break;
      case 'medium':
        bgColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1565C0);
        label = l10n.priorityMedium;
        break;
      case 'low':
      default:
        bgColor = const Color(0xFFECEFF1);
        textColor = const Color(0xFF455A64);
        label = l10n.priorityLow;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
