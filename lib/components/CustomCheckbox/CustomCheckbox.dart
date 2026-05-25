import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final Function(bool?) onChanged;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24.0,
        height: 24.0,
        child: SvgPicture.asset(
          value ? 'assets/Icons/checked_box.svg' : 'assets/Icons/Check_box.svg',
        ),
      ),
    );
  }
}
