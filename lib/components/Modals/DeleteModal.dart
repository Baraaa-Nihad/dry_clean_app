import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/DeleteButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class DeleteModal extends StatefulWidget {
  final String mainTitle;
  final String richBody;
  final String? body;

  // final String serviceType; // Added serviceType
  // final int quantity; // Added quantity
  // final String subCategory; // Added subCategory
  final String? prefixIconPath;
  final VoidCallback? onPrefixIconTap;
  final VoidCallback? onDelete;

  final double fem;

  const DeleteModal({
    Key? key,
    required this.mainTitle,
    required this.richBody,
    this.body,
    // required this.quantity,
    // required this.subCategory,
    this.prefixIconPath,
    this.onPrefixIconTap,
    this.onDelete,
    required this.fem,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String mainTitle,
    required String richBody,
    String body = '',
    // required int quantity,
    // required String subCategory,
    String? prefixIconPath,
    VoidCallback? onPrefixIconTap,
    VoidCallback? onDelete,
    required double fem,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) => DeleteModal(
        mainTitle: mainTitle,
        richBody: richBody,
        body: body,

        // quantity: quantity,
        // subCategory: subCategory,
        prefixIconPath: prefixIconPath,
        onPrefixIconTap: onPrefixIconTap,
        onDelete: onDelete,
        fem: fem,
      ),
    );
  }

  @override
  _DeleteModalState createState() => _DeleteModalState();
}

class _DeleteModalState extends State<DeleteModal> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 322 * widget.fem,
      padding: EdgeInsets.symmetric(horizontal: 24 * widget.fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2),
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16 * widget.fem),
          Container(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: SvgPicture.asset(widget.prefixIconPath!),
                onPressed: widget.onPrefixIconTap,
              ),
            ),
          ),
          Text(widget.mainTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 20.0,
                    color: AppColors.gray80,
                    fontWeight: FontWeight.w700),
              )),
          SizedBox(height: 8 * widget.fem),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 13.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray50,
                ),
              ),
              children: [
                TextSpan(text: '${localizations.translate('are_you_sure')} '),
                TextSpan(
                  text: widget.richBody.toString(),
                  style: AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray50,
                    height: 1.2,
                  ),
                ),
                TextSpan(text: widget.body.toString()),
              ],
            ),
          ),
          SizedBox(height: 40 * widget.fem),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: DeleteButton(
                    fem: widget.fem,
                    buttonWidth: "medium",
                    isDisabled: false,
                    text: localizations.translate('delete'),
                    onPressed: widget.onDelete,
                  ),
                ),
                SizedBox(width: 16 * widget.fem),
                Expanded(
                  child: SecondaryButton(
                    fem: widget.fem,
                    buttonWidth: "medium",
                    isDisabled: false,
                    text: localizations.translate('cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 60 * widget.fem), // Space from the bottom
        ],
      ),
    );
  }
}
