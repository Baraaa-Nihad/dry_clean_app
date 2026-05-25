import 'package:flutter/material.dart';
import 'CollectionTimeSelectionPage.dart';

class CheckoutDeliveryTime extends StatelessWidget {
  final double fem;
  final String? selectedDay;
  final String? selectedPeriod;
  final String? selectedTimeSlot;
  final Function(String, String, String) onTimeSelected;
  final Function(bool) onButtonStateChanged;
  final List<Map<String, dynamic>> days;
  final List<String> periods;
  final List<Map<String, String>> timeSlots;

  const CheckoutDeliveryTime({
    Key? key,
    required this.fem,
    this.selectedDay,
    this.selectedPeriod,
    this.selectedTimeSlot,
    required this.onTimeSelected,
    required this.onButtonStateChanged,
    required this.days,
    required this.periods,
    required this.timeSlots,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Delivery Days: $days');
    print('Delivery Time Slots: $timeSlots');

    return CollectionTimeSelectionPage(
      title: 'Choose_best_delivery_time_title',
      fem: fem,
      selectedDay: selectedDay,
      selectedPeriod: selectedPeriod,
      selectedTimeSlot: selectedTimeSlot,
      onTimeSelected: onTimeSelected,
      onButtonStateChanged: onButtonStateChanged,
      isPickup: false,
      days: days,
      periods: periods,
      timeSlots: timeSlots,
    );
  }
}
