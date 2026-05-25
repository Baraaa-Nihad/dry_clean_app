import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class MessageContainer extends StatelessWidget {
  final String? message;
  final MessageType type;

  const MessageContainer({
    Key? key,
    this.message, // Message can be null and will be overridden in case of error type
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the color and icon based on message type
    Color backgroundColor;
    Color borderColor;
    String iconPath;
    Color iconColor;

    // Set default message if type is error
    String displayedMessage = message ?? ''; // Initialize the message

    switch (type) {
      case MessageType.error:
        backgroundColor = AppColors.errorBackground;
        borderColor = AppColors.errorBorder;
        iconPath = 'assets/Icons/error.svg'; // Path to your error SVG icon
        iconColor = AppColors.errorIconColor;
        displayedMessage =
            AppLocalizations.of(context).translate('error_message');
        break;

      case MessageType.warning:
        backgroundColor = AppColors.warningBackground;
        borderColor = AppColors.warningBorder;
        iconPath = 'assets/Icons/warning.svg'; // Path to your warning SVG icon
        iconColor = AppColors.warningIconColor;
        displayedMessage = message ?? ''; // Use provided message
        break;

      case MessageType.success:
        backgroundColor = AppColors.successBackground;
        borderColor = AppColors.successBorder;
        iconPath = 'assets/Icons/success.svg'; // Path to your success SVG icon
        iconColor = AppColors.successIconColor;
        displayedMessage = message ?? ''; // Use provided message
        break;

      default:
        backgroundColor = AppColors.infoBackground;
        borderColor = AppColors.infoBorder;
        iconPath = 'assets/Icons/info.svg'; // Path to your info SVG icon
        iconColor = AppColors.infoIconColor;
        displayedMessage = message ?? ''; // Use provided message
        break;
    }

    // Check if the language is Arabic (RTL)
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      constraints: BoxConstraints(
        minHeight: 48, // Set minimum height to 48
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ), // Symmetric padding
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: borderColor),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isRtl ? 16 : 2),
            bottomRight: Radius.circular(isRtl ? 2 : 16),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center, // Align the icon at the top
        children: [
          SvgPicture.asset(
            iconPath,
            color: iconColor,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12), // Spacing between icon and text
          Expanded(
            child: Text(
              displayedMessage, // Display the final message
              textAlign: isRtl
                  ? TextAlign.right
                  : TextAlign.left, // Align text based on RTL/LTR
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum MessageType {
  error,
  warning,
  success,
  info,
}
