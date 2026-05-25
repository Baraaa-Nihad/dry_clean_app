import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class ShimmerMainCard extends StatelessWidget {
  final double fem;

  const ShimmerMainCard({
    Key? key,
    required this.fem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * fem),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12 * fem),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shimmer for the title section
              Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 20 * fem,
                  end: 20 * fem,
                  top: 8 * fem,
                ),
                child: Container(
                  height: 24,
                  width: 150, // Simulate title width
                  color: Colors.grey[300],
                ),
              ),
              Divider(
                color: AppColors.gray20,
                thickness: 0.5,
                height: 0.5,
              ),
              Padding(
                padding: EdgeInsets.all(16 * fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(3, (index) {
                    return Column(
                      children: [
                        // Shimmer for the product image and label
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8 * fem),
                          child: Row(
                            children: [
                              // Shimmer effect for the image
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12 * fem),
                                  color: Colors.grey[300],
                                ),
                              ),
                              SizedBox(width: 16 * fem),

                              // Shimmer effect for the product name
                              Expanded(
                                child: Container(
                                  height: 24,
                                  color: Colors.grey[300],
                                ),
                              ),

                              // // Shimmer for the plus icon
                              // Container(
                              //   width: 48 * fem,
                              //   height: 48 * fem,
                              //   decoration: BoxDecoration(
                              //     color: Colors.grey[300],
                              //     borderRadius: BorderRadius.circular(12 * fem),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        // Divider between the items
                        if (index != 2)
                          Container(
                            margin: EdgeInsetsDirectional.only(start: 64 * fem),
                            child: Divider(
                              color: AppColors.gray20,
                              thickness: 0.5,
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
