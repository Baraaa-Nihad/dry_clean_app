import 'package:flutter/material.dart';
import 'CollectionTimeSelectionPage.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CheckoutPickupTime extends StatelessWidget {
  final double fem;
  final String? selectedDay;
  final String? selectedPeriod;
  final String? selectedTimeSlot;
  final Function(String, String, String) onTimeSelected;
  final Function(bool) onButtonStateChanged;
  final List<Map<String, dynamic>> days;
  final List<String> periods;
  final List<Map<String, String>> timeSlots;

  const CheckoutPickupTime({
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
    final localizations = AppLocalizations.of(context);

    print("timeSlotstimeSlotstimeSlotstimeSlotstimeSlotstimeSlots");
    print(days);
    return CollectionTimeSelectionPage(
      title: localizations.translate('Choose_best_collection_time_title'),
      fem: fem,
      selectedDay: selectedDay,
      selectedPeriod: selectedPeriod,
      selectedTimeSlot: selectedTimeSlot,
      onTimeSelected: onTimeSelected,
      onButtonStateChanged: onButtonStateChanged,
      isPickup: true,
      days: days,
      periods: periods,
      timeSlots: timeSlots,
    );
  }
}
