import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';

class ActionButtons extends StatelessWidget {
  final double fem;
  final VoidCallback onCancel;
  final VoidCallback onAdd;
  final bool isExpanded;
  final bool isFullWidth;

  const ActionButtons({
    Key? key,
    required this.fem,
    required this.onCancel,
    required this.onAdd,
    required this.isExpanded,
    required this.isFullWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: Duration(milliseconds: 100),
      firstChild: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: isExpanded ? 0 : double.infinity,
        child: SecondaryButton(
          buttonWidth: "full",
          fem: fem,
          text: 'Add Custom Size',
          onPressed: onAdd,
        ),
      ),
      secondChild: Row(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: SecondaryButton(
                buttonWidth: "small",
                fem: fem,
                text: 'Cancel',
                onPressed: onCancel,
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              curve: Curves.easeInOut,
              child: PrimaryButton(
                buttonWidth: "small",
                fem: fem,
                text: 'Add',
                onPressed: onAdd,
              ),
            ),
          ),
        ],
      ),
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
    );
  }
}
