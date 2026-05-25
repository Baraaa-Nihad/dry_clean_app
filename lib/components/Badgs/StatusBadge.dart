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
      case 'completed':
        return Color(0xFF49C00F); // Green
      case 'waiting for collection':
        return Color(0xFFFFA500); // Orange
      case 'processing':
        return Color(0xFF01B5CF); // Cyan
      case 'in delivery':
        return Color(0xFF2477E1); // Blue
      case 'picked up':
        return Color(0xFF7B1FA2); // Purple
      case 'pending':
        return Color(0xFFFFA500); // Orange
      case 'postponed pick up':
        return Color(0xFFFB8C00); // Darker Orange
      case 'postponed for delivery':
        return Color(0xFFFB8C00); // Darker Orange
      case 'cancelled':
        return Color(0xFFE53935); // Red
      case 'waiting for delivery':
        return Color(0xFFFB8C00); // Darker Orange
      default:
        return Colors.grey; // Default grey color for unknown statuses
    }
  }

  String _getStatusText(BuildContext context, String status) {
    final localizations = AppLocalizations.of(context);
    switch (status.toLowerCase()) {
      case 'completed':
        return localizations.translate('completed');
      case 'waiting for collection':
        return localizations.translate('waiting_for_collection');
      case 'processing':
        return localizations.translate('processing');
      case 'in delivery':
        return localizations.translate('in_delivery');
      case 'picked up':
        return localizations.translate('picked_up');
      case 'pending':
        return localizations.translate('pending');
      case 'postponed pick up':
        return localizations.translate('postponed_pick_up');
      case 'postponed for delivery':
        return localizations.translate('postponed_for_delivery');
      case 'cancelled':
        return localizations.translate('cancelled');
      case 'waiting for delivery':
        return localizations.translate('waiting_for_delivery');
      default:
        return localizations
            .translate('unknown'); // Default for unknown statuses
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
