import 'package:flutter/material.dart';

class GradientCircle extends StatelessWidget {
  final double width;
  final double height;
  final List<Color> colors;

  const GradientCircle({
    Key? key,
    required this.width,
    required this.height,
    required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.5,
          colors: colors,
          stops: [0.5, 1.0],
        ),
        shape: OvalBorder(),
      ),
    );
  }
}
