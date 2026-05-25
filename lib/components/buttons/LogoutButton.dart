import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:provider/provider.dart'; // To access the UserProvider
import 'package:saleem_dry_clean/components/Modals/SmallModal.dart';
import 'package:saleem_dry_clean/utils/localization.dart'; // Ensure this import is correct

class LogoutButton extends StatefulWidget {
  final String iconPath;
  final double fem;
  final Function(Locale) setLocale;
  final Locale currentLocale;

  const LogoutButton({
    Key? key,
    required this.iconPath,
    required this.fem,
    required this.setLocale,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _LogoutButtonState createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  bool _isLoading = false;

  void _showLogoutConfirmation(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final navigationProvider =
        Provider.of<NavigationProvider>(context, listen: false);

    SmallModal.show(
      context,
      primaryButtonLable: localizations?.translate('Log out') ?? 'Log out',
      prefixIconPath: 'assets/vectors/close_icon.svg',
      isLoading: _isLoading, // Pass the loading state to the modal

      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      onPressed: () async {
        if (mounted) {
          setState(() {
            _isLoading = true; // Start loading
          });
        }

        // Use addPostFrameCallback to ensure navigation happens after the current frame
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Simulate loading for 1 second
          await Future.delayed(const Duration(seconds: 1));

          // Perform the logout process
          await _performLogout(context, userProvider);

          if (mounted) {
            setState(() {
              _isLoading = false; // Stop loading after the logout process
            });
          }
        });

        Navigator.pop(context); // Close the modal

        // Navigate to the home page using the instance of NavigationProvider
        navigationProvider.navigateToHome();
      },

      onCancel: () {
        Navigator.pop(context);
      },
      fem: widget.fem,
      title: localizations?.translate('Log out?') ?? 'Log out?',
      message: localizations?.translate('Are you sure you want to log out?') ??
          'Are you sure you want to log out?',
    );
  }

  Future<void> _performLogout(
      BuildContext context, UserProvider userProvider) async {
    // Get the device token
    String? deviceToken = await FirebaseMessaging.instance.getToken();
    print('Device Token: $deviceToken');

    if (deviceToken != null) {
      await userProvider.signOut(context, deviceToken);
    } else {
      print('Failed to retrieve device token');
      await userProvider.signOut(context, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => _showLogoutConfirmation(context),
      child: Container(
        width: 428,
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              widget.iconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 10),
            Text(
              localizations?.translate('Logout') ?? 'Logout',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
