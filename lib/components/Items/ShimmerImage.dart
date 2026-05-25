import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/utils/ImageLoader.dart';

class ShimmerImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerImage({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ImageLoader(
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: borderRadius.topLeft.x,
    );
  }
}
