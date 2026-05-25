import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class UserAvatar extends StatelessWidget {
  final String svgPath;
  final String userName;
  final double size;

  const UserAvatar({
    Key? key,
    required this.svgPath,
    required this.userName,
    this.size = 80.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract the initials from the user name
    List<String> nameParts = userName.split(' ');
    String initials = '';
    if (nameParts.isNotEmpty) {
      initials += nameParts[0][0]; // First character of the first name
      if (nameParts.length > 1) {
        initials +=
            '.${nameParts[1][0]}'; // Dot and first character of the last name
      }
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          svgPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
        Align(
          alignment: Alignment.center,
          child: Text(
            initials.toUpperCase(),
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  color: AppColors.white),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
