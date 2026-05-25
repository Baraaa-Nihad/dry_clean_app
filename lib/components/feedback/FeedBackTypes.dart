import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class FeedBackTypes extends StatelessWidget implements PreferredSizeWidget {
  final List<Map<String, dynamic>> items;
  final double fem;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FeedBackTypes({
    Key? key,
    required this.items,
    required this.fem,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48 * fem,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: items.map((item) {
            int index = items.indexOf(item);
            bool isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () {
                onItemSelected(index); // Callback to parent widget
              },
              child: Container(
                height: 44 * fem,
                margin: EdgeInsets.only(right: 8 * fem),
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24 * fem,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Color(0xFFF9F9FF) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFE5EAF6),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          item['label'],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 16.0,
                              color: isSelected
                                  ? AppColors.gray80
                                  : AppColors.gray60,
                              fontWeight: FontWeight.w500,
                              height: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Color(0xFF01B5CF), Color(0xFF00E213)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(48 * fem);
}
