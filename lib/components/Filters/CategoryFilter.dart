// lib/components/Filters/CategoryFilter.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';

class CategoryFilter extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double fem;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isLoading;
  final ScrollController? scrollController; // Make ScrollController optional

  const CategoryFilter({
    Key? key,
    required this.items,
    required this.fem,
    required this.selectedIndex,
    required this.onItemSelected,
    this.scrollController, // Optional ScrollController
    this.isLoading = false, // Default isLoading to false
  }) : super(key: key);

  // Enhanced shimmer effect to mimic category button layout
  Widget buildShimmer(double fem) {
    return Shimmer.fromColors(
      baseColor: AppColors.gray20!,
      highlightColor: AppColors.gray10!,
      child: Container(
        height: 44 * fem,
        margin: EdgeInsets.only(right: 8 * fem),
        padding: EdgeInsets.symmetric(horizontal: 16 * fem, vertical: 8 * fem),
        decoration: BoxDecoration(
          color: AppColors.gray20,
          borderRadius: BorderRadius.circular(12 * fem),
          border: Border.all(
            color: AppColors.gray20!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Circular placeholder for icon
            Container(
              width: 20 * fem,
              height: 20 * fem,
              decoration: BoxDecoration(
                color: AppColors.gray20,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8 * fem),
            // Rectangular placeholder for text
            Expanded(
              child: Container(
                height: 16 * fem,
                color: AppColors.gray20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48 * fem,
      child: SingleChildScrollView(
        controller: scrollController, // Use the passed ScrollController if any
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isLoading
              ? List.generate(
                  4, // Increased from 3 to 4 shimmer cards
                  (index) => buildShimmer(fem),
                )
              : [
                  ...items.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> item = entry.value;
                    bool isSelected = index == selectedIndex;

                    return GestureDetector(
                      onTap: () => onItemSelected(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        height: 44 * fem,
                        margin: EdgeInsets.only(right: 8 * fem),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16 * fem, vertical: 8 * fem),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? AppColors.gray80 : AppColors.white,
                          borderRadius: BorderRadius.circular(12 * fem),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Color(0xFFE5EAF6),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            children: [
                              if (item.containsKey('icon') &&
                                  item['icon'].isNotEmpty)
                                SvgPicture.asset(
                                  item['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : Color(0xFF033371),
                                  width: 20 * fem,
                                  height: 20 * fem,
                                ),
                              if (item.containsKey('icon') &&
                                  item['icon'].isNotEmpty)
                                SizedBox(width: 8 * fem),
                              Text(
                                item['label'],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.regular16Gray80(context)
                                      .copyWith(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                    height: 1,
                                    color: isSelected
                                        ? Colors.white
                                        : Color(0xFF033371),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(width: 16 * fem), // Extra padding at the end
                ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(84 * fem);
}
