import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Import the localization utility

class StatusBadge extends StatelessWidget {
  final String status; // General text for the badge
  final Color color; // Color for the badge
  final bool isStatus; // Whether it's a predefined status badge

  const StatusBadge({
    Key? key,
    required this.status,
    this.color = Colors.grey, // Default color is grey if not provided
    this.isStatus = true, // Default isStatus is true for backward compatibility
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      // ── Current DB values (users_status.status_en) ───────────────────────
      case 'order placed':
        return const Color(0xFF030107);
      case 'awaiting collection':
        return const Color(0xFFFF8C00);
      case 'picked up':
        return const Color(0xFF0061FF);
      case 'order confirmed':
        return const Color(0xFF00B36B);
      case 'processing':
        return const Color(0xFF01B5CF);
      case 'ready for delivery':
        return const Color(0xFFEDB89A);
      case 'out for delivery':
        return const Color(0xFF17A2B8);
      case 'undelivered':
        return const Color(0xFFFF8C00);
      case 'completed':
        return const Color(0xFF84CC16);
      case 'cancelled':
        return const Color(0xFFDC2627);
      // ── Legacy / backward-compat strings ────────────────────────────────
      case 'pending':
        return const Color(0xFF030107);
      case 'waiting for collection':
        return const Color(0xFFFF8C00);
      case 'in delivery':
        return const Color(0xFF17A2B8);
      case 'waiting for delivery':
        return const Color(0xFFEDB89A);
      case 'postponed pick up':
        return const Color(0xFFFB8C00);
      case 'postponed for delivery':
        return const Color(0xFFFB8C00);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BuildContext context, String status) {
    final localizations = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      // ── Current DB values ────────────────────────────────────────────────
      case 'order placed':
      case 'pending':
        return localizations.translate('order_placed');
      case 'awaiting collection':
      case 'waiting for collection':
        return localizations.translate('awaiting_collection');
      case 'picked up':
        return localizations.translate('picked_up');
      case 'order confirmed':
        return localizations.translate('order_confirmed');
      case 'processing':
        return localizations.translate('processing');
      case 'ready for delivery':
      case 'waiting for delivery':
        return localizations.translate('ready_for_delivery');
      case 'out for delivery':
      case 'in delivery':
        return localizations.translate('out_for_delivery');
      case 'undelivered':
        return localizations.translate('undelivered');
      case 'completed':
        return localizations.translate('completed');
      case 'cancelled':
        return localizations.translate('cancelled');
      case 'postponed pick up':
        return localizations.translate('postponed_pick_up');
      case 'postponed for delivery':
        return localizations.translate('postponed_for_delivery');
      default:
        return localizations.translate('unknown');
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor =
        isStatus ? _getStatusColor(status) : color; // Determine color
    final badgeText =
        isStatus ? _getStatusText(context, status) : status; // Determine text

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: ShapeDecoration(
        color: badgeColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      alignment: Alignment.center,
      child: Center(
        child: Text(
          badgeText,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              height: 0,
              color: AppColors.white,
            ),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
