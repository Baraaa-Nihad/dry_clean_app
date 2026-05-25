import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Badgs/StatusBadge.dart';
import 'package:saleem_dry_clean/components/Cards/VerifiedBadge.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Ensure you have this import

class AddressCard extends StatefulWidget {
  final String addressName;
  final String governate;
  final String building;
  final String extraInfo;
  final String areaName;
  final bool isDefault;
  final String street;
  final bool isSelected;
  final bool isClickable;
  final bool isDeleteable;
  final VoidCallback onEdit;
  final VoidCallback onSetDefult;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final double fem;

  const AddressCard({
    Key? key,
    required this.addressName,
    required this.governate,
    required this.street,
    required this.areaName,
    required this.building,
    required this.extraInfo,
    required this.isDefault,
    required this.onEdit,
    required this.onSetDefult,
    required this.onDelete,
    required this.onSelect,
    required this.isSelected,
    required this.isClickable,
    required this.isDeleteable,
    required this.fem,
  }) : super(key: key);

  @override
  _AddressCardState createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  String _truncate(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: widget.isClickable ? widget.onSelect : null,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Container(
            width: 380 * widget.fem,
            padding: EdgeInsets.all(16 * widget.fem),
            decoration: ShapeDecoration(
              color: widget.isSelected
                  ? AppColors.gray10
                  : Colors.white, // Set gray10 when selected
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: 1,
                  color: Color(0xFFE5EAF6),
                ),
                borderRadius: BorderRadius.circular(16 * widget.fem),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24 * widget.fem,
                      height: 24 * widget.fem,
                      child: SvgPicture.asset(
                        'assets/Icons/locationGradent.svg',
                      ),
                    ),
                    SizedBox(width: 16 * widget.fem),
                    Expanded(
                      child: Text(
                        _truncate(widget.addressName, 60),
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 16.0 * widget.fem,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gray80),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isDefault) SizedBox(width: 8),
                    StatusBadge(
                        status:
                            localizations?.translate('default') ?? 'default',
                        isStatus: false,
                        color: AppColors.gray40)
                  ],
                ),
                SizedBox(height: 12 * widget.fem),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 40 *
                            widget.fem), // Adjust spacing to align with icon
                    Expanded(
                      child: Text(
                        '${widget.governate}, ${widget.areaName}, ${widget.building}, ${widget.street}',
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 16.0 * widget.fem,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray60),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4 * widget.fem),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        width: 40 *
                            widget.fem), // Adjust spacing to align with icon
                    Expanded(
                      child: Text(
                        widget.extraInfo, // No _truncate
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 14.0 * widget.fem,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray50),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * widget.fem),
                if (!widget.isDefault)
                  Divider(
                    color: AppColors.gray20,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!widget.isDefault)
                      GestureDetector(
                        onTap: widget.onSetDefult,
                        child: Text(
                          localizations?.translate('Set as Default') ??
                              'Set as default',
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                height: 0,
                                color: AppColors.cta),
                          ),
                        ),
                      ),
                    Spacer(),
                    // GestureDetector(
                    //   onTap: widget.onEdit,
                    //   child: Text(
                    //     localizations?.translate('edit') ?? 'Edit',
                    //     style: AppTextStyles.getFontFamily(
                    //       context,
                    //       AppTextStyles.regular16Gray80(context).copyWith(
                    //           fontSize: 16.0,
                    //           fontWeight: FontWeight.w500,
                    //           height: 0,
                    //           color: AppColors.cta),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(width: 12 * widget.fem),
                    if (widget.isDeleteable && !widget.isDefault)
                      GestureDetector(
                        onTap: widget.onDelete,
                        child: Text(
                          localizations.translate('delete') ?? 'Delete',
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                height: 0,
                                color: AppColors.red),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.isSelected)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [AppColors.green, AppColors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * widget.fem),
                        side: BorderSide(
                          width: 1,
                          color: Colors
                              .white, // This color won't be visible due to shader
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
