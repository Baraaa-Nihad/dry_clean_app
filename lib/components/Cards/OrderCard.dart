// lib/widgets/OrderCard.dart

import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/services/Models/OrderItem.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart'; // Import intl package for DateFormat
import 'package:saleem_dry_clean/components/Cards/OrderDetails.dart';
import 'package:saleem_dry_clean/components/Cards/OrderFooter.dart';
import 'package:saleem_dry_clean/components/Cards/OrderHeader.dart';
import 'package:saleem_dry_clean/components/Cards/OrderItems.dart';
import 'package:saleem_dry_clean/components/Cards/ShimmerOrderHeader.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderDetails.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderFooter.dart';
import 'package:saleem_dry_clean/components/Cards/SkeletonOrderItems.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';

class OrderCard extends StatelessWidget {
  final OrderData? order;
  final bool isLoadingItems;
  final bool isOrderLoading;

  const OrderCard({
    Key? key,
    this.order,
    this.isLoadingItems = true,
    this.isOrderLoading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the order is delayed
    bool isDelayed = false;
    if (order != null) {
      final DateTime now = DateTime.now().toLocal(); // Current local time
      final DateTime createdAt =
          order!.createdAt.toLocal(); // Order creation time

      // Check against both current DB values and legacy strings
      if (order!.status == "Awaiting Collection" ||
          order!.status == "Waiting for collection") {
        DateTime? pickupEndTime =
            _parseEndTime(order!.collectionTime, createdAt);
        if (pickupEndTime != null && now.isAfter(pickupEndTime)) {
          isDelayed = true;
        }
      } else if (order!.status == "Out for Delivery" ||
          order!.status == "Waiting for Delivery") {
        DateTime? deliveryEndTime =
            _parseEndTime(order!.deliveryTime, createdAt);
        if (deliveryEndTime != null && now.isAfter(deliveryEndTime)) {
          isDelayed = true;
        }
      }
    }

    return Container(
      key: ValueKey(order?.orderId ?? 'loading'), // Unique and stable key
      width: double.infinity, // Flexible width for responsiveness
      // Removed fixed height to allow content to dictate size
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppColors.gray20),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          isOrderLoading
              ? ShimmerOrderHeader()
              : OrderHeader(
                  order: order!,
                  isDelayed: isDelayed,
                ),

          // Items Section
          isOrderLoading
              ? const SkeletonOrderItems()
              : isLoadingItems
                  ? const SkeletonOrderItems()
                  : OrderItems(
                      items: _groupItemsByServiceType(order!.items),
                    ),

          // Divider
          Divider(color: AppColors.gray20, thickness: 1, height: 1),

          // Details Section
          isOrderLoading
              ? const SkeletonOrderDetails()
              : isLoadingItems
                  ? const SkeletonOrderDetails()
                  : OrderDetails(order: order!),

          // Footer Section
          isOrderLoading
              ? const SkeletonOrderFooter()
              : isLoadingItems
                  ? const SkeletonOrderFooter()
                  : OrderFooter(order: order!),
        ],
      ),
    );
  }

  /// Parses the end time from a time range string and combines it with the base date.
  ///
  /// [timeRange]: The time range string, e.g., "AM 9:00 - 10:00"
  /// [baseDate]: The date to associate with the parsed time.
  ///
  /// Returns a [DateTime] object representing the end time, or null if parsing fails.
  DateTime? _parseEndTime(String? timeRange, DateTime createdAt) {
    if (timeRange == null || timeRange.isEmpty) {
      return null;
    }
    try {
      final List<String> times = timeRange.split(' - ');
      if (times.length != 2) throw FormatException("Invalid time range format");

      final String endTimeStr = times[1]; // e.g. '9:00' from 'AM 8:00 - 9:00'
      final String amPmPrefix = times[0].split(' ')[0]; // 'AM' or 'PM'
      final String formattedEndTime = '$amPmPrefix $endTimeStr';

      final DateFormat timeFormat = DateFormat('a h:mm');
      final DateTime parsedEndTime = timeFormat.parse(formattedEndTime);

      return DateTime(createdAt.year, createdAt.month, createdAt.day,
          parsedEndTime.hour, parsedEndTime.minute);
    } catch (e) {
      return null;
    }
  }

  /// Groups a list of [OrderItem]s by their service type.
  ///
  /// [items]: The list of order items to group.
  ///
  /// Returns a [Map] where the key is the service type and the value is a list of [OrderItem]s.
  Map<String, List<OrderItem>> _groupItemsByServiceType(List<OrderItem> items) {
    final Map<String, List<OrderItem>> groupedItems = {};
    for (var item in items) {
      if (!groupedItems.containsKey(item.serviceType)) {
        groupedItems[item.serviceType] = [];
      }
      groupedItems[item.serviceType]!.add(item);
    }
    return groupedItems;
  }
}
