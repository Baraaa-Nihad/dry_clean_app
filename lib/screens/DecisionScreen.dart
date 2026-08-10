import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Navigator/startup_router.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

/// Compatibility route for older navigation calls.
///
/// New startup flows resolve their destination before navigating and never
/// show this screen. If an old call reaches it, the Saleem gradient is kept on
/// screen instead of exposing a white loading page.
class DecisionScreen extends StatefulWidget {
  const DecisionScreen({super.key});

  @override
  State<DecisionScreen> createState() => _DecisionScreenState();
}

class _DecisionScreenState extends State<DecisionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _navigate());
  }

  Future<void> _navigate() async {
    try {
      final destination = await StartupRouter.resolve(context);
      if (!mounted) return;
      NavigatorService.navigateToAndRemoveUntil(destination);
    } catch (error) {
      debugPrint('DecisionScreen: startup failed: $error');
      if (!mounted) return;
      NavigatorService.navigateToAndRemoveUntil(RouteNames.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00B4DB),
              Color(0xFF00CDB5),
              Color(0xFF00E28A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
