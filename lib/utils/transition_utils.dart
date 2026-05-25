import 'package:flutter/material.dart';

class TransitionUtils {
  static Widget buildTransition(BuildContext context, Widget child) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Determine the direction based on RTL or LTR
        Offset enterOffset = isRtl ? const Offset(1, 0) : const Offset(-1, 0);
        Offset exitOffset = isRtl ? const Offset(-1, 0) : const Offset(1, 0);

        // Slide in the new child
        Widget enterAnimation = SlideTransition(
          position: Tween<Offset>(
            begin: enterOffset,
            end: Offset(0, 0),
          ).animate(animation),
          child: child,
        );

        // Slide out the old child
        Widget exitAnimation = SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0),
            end: exitOffset,
          ).animate(animation),
          child: child,
        );

        return Stack(
          children: <Widget>[
            exitAnimation,
            enterAnimation,
          ],
        );
      },
      child: child,
    );
  }
}
