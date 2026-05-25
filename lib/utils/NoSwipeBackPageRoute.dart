import 'package:flutter/material.dart';

class NoSwipeBackPageRoute<T> extends MaterialPageRoute<T> {
  NoSwipeBackPageRoute(
      {required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back navigation
      },
      child: super.buildPage(context, animation, secondaryAnimation),
    );
  }

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is NoSwipeBackPageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is NoSwipeBackPageRoute;
  }
}
