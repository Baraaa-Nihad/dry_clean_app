import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CustomTabIndicator extends Decoration {
  final BoxPainter _painter;

  CustomTabIndicator() : _painter = _CustomPainter();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CustomPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final double indicatorWidth = 60;
    final double dx =
        offset.dx + (configuration.size!.width - indicatorWidth) / 2;
    final Rect rect =
        Rect.fromLTWH(dx, configuration.size!.height - 2, indicatorWidth, 2);

    final Paint paint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.gradientStart, AppColors.gradientEnd],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect)
      ..style = PaintingStyle.fill;

    final RRect rRect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    );

    canvas.drawRRect(rRect, paint);
  }
}
