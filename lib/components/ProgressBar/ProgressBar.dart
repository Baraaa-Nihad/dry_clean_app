import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final int progressIndicator; // Add this parameter to the constructor

  const ProgressBar({Key? key, required this.progressIndicator})
      : super(key: key); // Initialize in the constructor

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      height: 2,
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 2,
            color: Color(0xFFE5EAF6),
          ),
          Container(
            width: (MediaQuery.of(context).size.width / 4) * progressIndicator,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: isRtl
                    ? [Color(0xFF01B5CF), Color(0xFF00E213)]
                    : [Color(0xFF00E213), Color(0xFF01B5CF)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
