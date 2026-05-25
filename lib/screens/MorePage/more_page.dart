import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppBarUserWidget.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/Cards/BirdieLogo.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDotsPrimary.dart';
import 'package:saleem_dry_clean/components/MorePageSections/AccountSettingsSection.dart';
import 'package:saleem_dry_clean/components/MorePageSections/OtherSettingsSection.dart';
import 'package:saleem_dry_clean/components/buttons/LogoutButton.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/screens/MorePage/UserAvatar.dart';
import 'package:saleem_dry_clean/screens/SignInPage/SignIn.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

class MorePage extends StatefulWidget {
  final double fem;

  const MorePage({
    Key? key,
    required this.fem,
  }) : super(key: key);

  @override
  _MorePageState createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  void _refreshUserData() {
    print("_refreshUserData");
    setState(() {
      // Trigger UI refresh
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final currentLocale = languageProvider.locale;

    return Scaffold(
      backgroundColor: AppColors.gray10,
      appBar: AppHeader(
        quantityNumber: false,
        title: localizations?.translate('account') ?? 'Account',
        fem: widget.fem,
        suffixIcon: AppBarUserWidget(
          userSignedIn: userProvider.userSignedIn, // Pass appropriate value
          user: userProvider.user, // Pass the current user instance or null
        ),
        onSuffixIconTap: () {
          // Optionally, handle tap if needed
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: userProvider.isLoading
              ? Center(
                  child: LoadingDotsPrimary(fem: widget.fem),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (userProvider.userSignedIn &&
                          userProvider.user != null)
                        AccountSettingsSection(
                          fem: widget.fem,
                          user: userProvider.user!,
                          currentLocale: currentLocale,
                          onUserDataUpdated: _refreshUserData,
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 20),
                            PrimaryButton(
                              fem: widget.fem,
                              isLoading: false,
                              text: localizations?.translate('log_in') ??
                                  'Log in',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignIn(
                                      fem: widget.fem,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      SizedBox(height: 32),
                      OtherSettingsSection(
                        fem: widget.fem,
                        setLocale: languageProvider.setLocale,
                        userSignedIn: userProvider.userSignedIn,
                        currentLocale: currentLocale,
                      ),
                      if (userProvider.userSignedIn)
                        Column(
                          children: [
                            SizedBox(height: 16),
                            LogoutButton(
                              iconPath: 'assets/Icons/logout.svg',
                              fem: widget.fem,
                              setLocale: languageProvider.setLocale,
                              currentLocale: currentLocale,
                            ),
                          ],
                        ),
                      BirdieLogo(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
