import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CustomIndicator extends StatefulWidget {
  final int activeIndex;
  final int count;
  final double fem;

  const CustomIndicator({
    Key? key,
    required this.activeIndex,
    required this.count,
    required this.fem,
  }) : super(key: key);

  @override
  _CustomIndicatorState createState() => _CustomIndicatorState();
}

class _CustomIndicatorState extends State<CustomIndicator> {
  int _prevActiveIndex = -1;

  @override
  void didUpdateWidget(CustomIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != oldWidget.activeIndex) {
      _prevActiveIndex = oldWidget.activeIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRtl
          ? TextDirection.ltr
          : TextDirection.rtl, // Set RTL directionality
      child: Container(
        width: widget.count *
            15 *
            widget.fem, // Adjust width based on the number of dots and spacing
        height: 10 * widget.fem,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(widget.count, (index) {
            bool isActive = index == widget.activeIndex;
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 2.5 * widget.fem), // Adjust spacing between dots
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 10 * widget.fem,
                height: 10 * widget.fem,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30 * widget.fem),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!isActive)
                        BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                          child: Container(
                            color: AppColors.gray80.withOpacity(0.15),
                          ),
                        ),
                      Container(
                        decoration: ShapeDecoration(
                          color: isActive
                              ? AppColors.transparent
                              : AppColors.gray80.withOpacity(0.15),
                          shape: RoundedRectangleBorder(
                            side: isActive
                                ? BorderSide(
                                    width: 1.5 * widget.fem,
                                    color: AppColors.gray80)
                                : BorderSide.none,
                            borderRadius:
                                BorderRadius.circular(30 * widget.fem),
                          ),
                        ),
                        child: isActive
                            ? AnimatedOpacity(
                                opacity: 1.0,
                                duration: Duration(milliseconds: 300),
                                child: Center(
                                  child: Container(
                                    width: 4 * widget.fem,
                                    height: 4 * widget.fem,
                                    decoration: ShapeDecoration(
                                      color: AppColors.gray80,
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                              )
                            : AnimatedOpacity(
                                opacity: 0.0,
                                duration: Duration(
                                    milliseconds:
                                        0), // No duration for fading out
                                child: Center(
                                  child: Container(
                                    width: 4 * widget.fem,
                                    height: 4 * widget.fem,
                                    decoration: ShapeDecoration(
                                      color: AppColors.gray80,
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
