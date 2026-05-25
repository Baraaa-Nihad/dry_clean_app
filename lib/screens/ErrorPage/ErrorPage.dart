// lib/screens/PageNotFound/page_not_found.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/EmptyPage/SystemEmptyPage.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;

  const ErrorPage({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    print('errorMessage');
    print(errorMessage);
    return Scaffold(
      backgroundColor: AppColors.white, // Optional: Set a background color
      body: Column(children: [
        SystemEmptyPage(
          fem: 1,
          iconUrl: 'assets/Icons/errorPageIcon.svg', // Ensure this asset exists
          title: localizations.translate("oops_something_wrong"),
          subtitle: localizations.translate("please_try_again"),
          showButton: true,
          enableRefresh: true,
          backgroundColor: AppColors.white,
          buttonAction: () {
            // Access the NavigationProvider instance
            final navigationProvider =
                Provider.of<NavigationProvider>(context, listen: false);

            // Use the NavigationProvider to navigate to the main page
            navigationProvider.navigateToHome();

            // Optionally, if you want to replace the current route so that users can't navigate back to this error page:
            // Navigator.of(context).pushReplacementNamed(RouteNames.main);
          },

          buttonText: localizations.translate("reload"),
        ),
      ]),
    );
  }
}
