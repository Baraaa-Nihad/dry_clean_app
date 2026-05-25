// lib/widgets/OrderItems.dart

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/Notification/QuantityIcon.dart';
import 'package:saleem_dry_clean/services/Models/OrderItem.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ThumbnailImageLoader.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrderItems extends StatelessWidget {
  final Map<String, List<OrderItem>> items;

  const OrderItems({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Removed isRtl variable as it's no longer needed
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate sizes based on available width
        double containerSize = 50.0;
        double iconSize = 16.0;
        double overlapOffset = 6.0;

        // Adjust sizes for larger screens
        if (constraints.maxWidth > 400) {
          containerSize = 60.0;
          iconSize = 20.0;
          overlapOffset = 8.0;
        }

        return Container(
          height: 82.0,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.entries.length,
            itemBuilder: (context, index) {
              final entry = items.entries.elementAt(index);
              final List<OrderItem> serviceItems = entry.value;

              return Row(
                children: serviceItems.map((item) {
                  String imageUrl = (item.imagePath?.isNotEmpty == true)
                      ? item.imagePath!
                      : 'assets/images/placeholder.jpg'; // Placeholder image
                  int quantity = item.quantity;
                  print("imageUrl");
                  print(imageUrl);
                  return Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Container(
                      key: ValueKey(imageUrl), // Unique key for each image
                      width: containerSize,
                      height: containerSize,
                      child: Stack(
                        clipBehavior:
                            Clip.none, // Allow QuantityIcon to overflow
                        children: [
                          // Use the updated ThumbnailImageLoader without animations
                          ThumbnailImageLoader(
                            imageUrl: imageUrl,
                            size: containerSize,
                            borderRadius: 16.0, // Adjust as needed
                          ),
                          // QuantityIcon Positioned Above the Image on the Top-Right
                          _buildQuantityIcon(
                            quantity,
                            iconSize,
                            overlapOffset,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        );
      },
    );
  }

  /// Builds the QuantityIcon widget positioned above the image.
  Widget _buildQuantityIcon(
      int quantity, double iconSize, double overlapOffset) {
    return Positioned(
      top:
          -overlapOffset, // Negative offset to overlap the icon above the image
      right: -overlapOffset, // Always position on the right side
      child: QuantityIcon(
        size: IconSize.normal,
        quantity: quantity,
        color: AppColors.gray80,
        // Removed 'fem' parameter as it's no longer used
      ),
    );
  }
}
