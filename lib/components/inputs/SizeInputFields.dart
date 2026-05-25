import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';

class SizeInputFields extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController widthController;
  final FocusNode heightFocusNode;
  final FocusNode widthFocusNode;
  final double fem;
  final bool isExpanded;

  const SizeInputFields({
    Key? key,
    required this.heightController,
    required this.widthController,
    required this.heightFocusNode,
    required this.widthFocusNode,
    required this.fem,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AnimatedSlide(
            offset: isExpanded ? Offset(0, 0) : Offset(0, -1),
            duration: Duration(milliseconds: 800),
            child: TextCustomInput(
              controller: heightController,
              focusNode: heightFocusNode,
              labelTextPrimary: 'Height',
              suffixIcon: SvgPicture.asset(
                'assets/vectors/meterIcon.svg',
                width: 24 * fem,
                height: 24 * fem,
              ),
              fem: fem,
              onInputChange: (isValid) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Height';
                }
                return null;
              },
            ),
          ),
        ),
        SizedBox(width: 16 * fem),
        Expanded(
          child: AnimatedSlide(
            offset: isExpanded ? Offset(0, 0) : Offset(0, -1),
            duration: Duration(milliseconds: 800),
            child: TextCustomInput(
              controller: widthController,
              focusNode: widthFocusNode,
              labelTextPrimary: 'Width',
              suffixIcon: SvgPicture.asset(
                'assets/vectors/meterIcon.svg',
                width: 24 * fem,
                height: 24 * fem,
              ),
              fem: fem,
              onInputChange: (isValid) {},
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Width';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }
}
