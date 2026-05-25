import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BannerImage extends StatelessWidget {
  final double fem;

  const BannerImage({Key? key, required this.fem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ensure the banner spans the full width
      height: 200 * fem,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16 * fem),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * fem),
        child: OverflowBox(
          maxWidth: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            'assets/images/banner_image.svg',
            fit: BoxFit.fill,
            width: MediaQuery.of(context).size.width,
          ),
        ),
      ),
    );
  }
}
