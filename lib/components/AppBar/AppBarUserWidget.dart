// lib/components/AppBar/AppBarUserWidget.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/screens/MorePage/UserAvatar.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class AppBarUserWidget extends StatelessWidget {
  final bool userSignedIn;
  final User? user; // Assuming you have a User model
  final VoidCallback? onTap;

  const AppBarUserWidget({
    Key? key,
    required this.userSignedIn,
    this.user,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(userSignedIn);
    print("user");
    print(user);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80,
        height: 80,
        child: userSignedIn && user != null
            ? UserAvatar(
                svgPath: "assets/Icons/userNameIcon.svg",
                userName: user!.fullName,
              )
            : SvgPicture.asset(
                'assets/Icons/notLoggedInIcon.svg',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
      ),
    );
  }
}
