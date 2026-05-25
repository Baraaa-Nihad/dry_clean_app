import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/buttons/ActionButtons.dart';
import 'package:saleem_dry_clean/components/inputs/SizeInputFields.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class SizeInputCard extends StatelessWidget {
  final double fem;
  final TextEditingController heightController;
  final TextEditingController widthController;
  final FocusNode heightFocusNode;
  final FocusNode widthFocusNode;
  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final bool isFullWidth;
  final bool isExpanded;

  const SizeInputCard({
    Key? key,
    required this.fem,
    required this.heightController,
    required this.widthController,
    required this.heightFocusNode,
    required this.widthFocusNode,
    required this.onCancel,
    required this.onAdd,
    this.isFullWidth = false,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      height: 208,
      padding: const EdgeInsets.only(top: 16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.gray10,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: Color(0xFFE5EAF6)),
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedSlide(
                  offset: isExpanded ? Offset(0, 0) : Offset(-1, 0),
                  duration: Duration(milliseconds: 800),
                  child: Container(
                    width: 340,
                    height: 28,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Carpet Size',
                                textAlign: TextAlign.left,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                    height: 0,
                                    color: AppColors.gray70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                AnimatedSlide(
                  offset: isExpanded ? Offset(0, 0) : Offset(0, -3),
                  duration: Duration(milliseconds: 800),
                  child: SizeInputFields(
                    isExpanded: isExpanded,
                    heightController: heightController,
                    widthController: widthController,
                    heightFocusNode: heightFocusNode,
                    widthFocusNode: widthFocusNode,
                    fem: fem,
                  ),
                ),
                SizedBox(height: 16),
                ActionButtons(
                  fem: fem,
                  onCancel: onCancel,
                  onAdd: onAdd,
                  isExpanded: true,
                  isFullWidth: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
