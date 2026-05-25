import 'package:flutter/widgets.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const GradientText({
    Key? key,
    required this.text,
    required this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        // Extend the gradient width by 2 pixels
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.gradientStart, AppColors.gradientEnd],
        ).createShader(
            Rect.fromLTWH(0.0, 0.0, bounds.width + 80, bounds.height));
      },
      child: Text(
        text,
        style: AppTextStyles.getFontFamily(
          context,
          AppTextStyles.regular16Gray80(context).copyWith(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              height: 0,
              color: AppColors
                  .white), // Set the default color (ignored by gradient)
        ),
      ),
    );
  }
}
