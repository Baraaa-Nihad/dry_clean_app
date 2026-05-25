// lib/screens/PageNotFound/page_not_found.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/EmptyPage/SystemEmptyPage.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class PageNotFound extends StatelessWidget {
  const PageNotFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white, // Optional: Set a background color
      body: SystemEmptyPage(
        fem: 1,
        iconUrl: 'assets/Icons/PageNotFound.svg', // Ensure this asset exists
        title: localizations.translate("page_not_found_title"),
        subtitle: localizations.translate("page_not_found_subtitle"),
        showButton: true,
        enableRefresh: true,
        backgroundColor: AppColors.white,
        buttonAction: () {
          // Navigate to the 'home' route
          Navigator.of(context).pushNamed('/');

          // If you want to replace the current route so that users can't navigate back to the 404 page:
          // Navigator.of(context).pushReplacementNamed('home');
        },
        buttonText: localizations.translate("go_home"),
      ),
    );
  }
}
