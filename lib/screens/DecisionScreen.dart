// lib/pages/decision_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/utils/KeyboardUtils/KeyboardUtils.dart';
import 'package:saleem_dry_clean/utils/OnboardingProvider.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DecisionScreen extends StatefulWidget {
  @override
  _DecisionScreenState createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Delay to show the loading indicator (optional)
    await Future.delayed(Duration(milliseconds: 500));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('hasCompletedOnboarding',false); //reset onboarding
    // Retrieve the onboarding completion status
    bool hasCompletedOnboarding =
        prefs.getBool('hasCompletedOnboarding') ?? false;

    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);
    onboardingProvider.setHasCompleted(hasCompletedOnboarding);

    if (onboardingProvider.isActive && !onboardingProvider.hasCompleted) {
      Navigator.of(context).pushReplacementNamed(RouteNames.onboarding);
    } else {
      Navigator.of(context).pushReplacementNamed(RouteNames.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate 'fem' if it's a scaling factor. Adjust the base width (e.g., 375) as needed.
    final fem = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      // Set the background color to gray10. Replace with your specific gray10 color.
      backgroundColor:
          Colors.grey[100], // Example: Light gray. Adjust as needed.
      body: Center(
        child: LoadingDots(fem: fem),
      ),
    );
  }
}
