import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Notification/QuantityIcon.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/utils/ImageLoader.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class BasketItem extends StatefulWidget {
  final String label;
  final String imagePath;
  final double price;
  final String unit;
  final int quantity;
  final String serviceType;
  final String subCategory;
  final double fem;
  final VoidCallback? onDelete; // Make onDelete optional
  final bool isDeletable; // Add flag to determine if the item is deletable

  const BasketItem({
    Key? key,
    required this.serviceType,
    required this.label,
    required this.imagePath,
    required this.subCategory,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.fem,
    this.onDelete, // Make onDelete optional
    this.isDeletable = true, // Default is true, meaning the item can be deleted
  }) : super(key: key);

  @override
  _BasketItemState createState() => _BasketItemState();
}

class _BasketItemState extends State<BasketItem> {
  double _dragExtent = 0.0;
  FocusNode _focusNode = FocusNode();
  int _quantity = 0; // Add quantity state variable

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity; // Initialize quantity state
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        if (_focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 8 * widget.fem),
        child: Focus(
          focusNode: _focusNode,
          child: GestureDetector(
            onHorizontalDragUpdate: widget.isDeletable
                ? (details) {
                    _focusNode.requestFocus();
                    setState(() {
                      _dragExtent += isRTL
                          ? details.primaryDelta!
                          : -details.primaryDelta!;
                      if (_dragExtent > 80 * widget.fem) {
                        _dragExtent = 80 * widget.fem;
                      } else if (_dragExtent < 0) {
                        _dragExtent = 0;
                      }
                    });
                  }
                : null,
            onHorizontalDragEnd: widget.isDeletable
                ? (details) {
                    if (_dragExtent > 40 * widget.fem) {
                      setState(() {
                        _dragExtent = 80;
                      });
                    } else {
                      setState(() {
                        _dragExtent = 0.0;
                      });
                    }
                  }
                : null,
            child: Stack(
              children: [
                if (widget.isDeletable)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _dragExtent = 0.0;
                        });
                        if (widget.onDelete != null) {
                          widget.onDelete!(); // Call onDelete if not null
                        }
                      },
                      child: Container(
                        height: 50 * widget.fem, // Adjust the height as needed
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(12 * widget.fem),
                        ),
                        alignment: isRTL
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Container(
                          width: 80 * widget.fem,
                          height: double.infinity,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/Icons/delete_icon.svg', // Path to your delete icon SVG file
                              width: 64 * widget.fem,
                              height: 48 * widget.fem,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 100),
                  transform: Matrix4.translationValues(
                      isRTL ? _dragExtent : -_dragExtent, 0, 0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12 * widget.fem),
                    border: Border.all(
                      color: AppColors
                          .gray20, // Set the color of the border to red
                      width: 0.5, // Set the width of the border
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16 * widget.fem),
                    child: Row(
                      children: [
                        // Use ImageLoader instead of directly loading the image
                        ImageLoader(
                          imageUrl:
                              widget.imagePath, // Image URL from BasketItem
                          height: 48 * widget.fem,
                          width: 48 * widget.fem,
                          borderRadius:
                              12 * widget.fem, // Use the desired border radius
                        ),
                        SizedBox(width: 12 * widget.fem),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${localizations?.translate(widget.label) ?? widget.label} ',
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray70(context)
                                      .copyWith(
                                          fontSize: 16.0 * widget.fem,
                                          fontWeight: FontWeight.w500),
                                ),
                              ),
                              SizedBox(height: 2 * widget.fem),
                              Row(
                                children: [
                                  Text(
                                    '₪',
                                    style: AppTextStyles.getFontFamily(
                                      context,
                                      AppTextStyles.regular16Gray60(context)
                                          .copyWith(
                                              fontSize: 14.0 * widget.fem,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '${widget.price} / ${localizations?.translate('${widget.unit}')}',
                                    style: AppTextStyles.getFontFamily(
                                      context,
                                      AppTextStyles.regular16Gray60(context)
                                          .copyWith(
                                              fontSize: 14.0 * widget.fem,
                                              fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16 * widget.fem),
                        QuantityIcon(
                          size: IconSize.normal,
                          quantity: _quantity, // Use the state variable
                          color: AppColors.gray80,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
