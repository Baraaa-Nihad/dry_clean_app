import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Cards/SlotCard.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CollectionTimeSelectionPage extends StatefulWidget {
  final String title;
  final double fem;
  final String? selectedDay;
  final String? selectedPeriod;
  final String? selectedTimeSlot;
  final Function(String, String, String) onTimeSelected;
  final Function(bool) onButtonStateChanged;
  final bool isPickup;
  final List<Map<String, dynamic>> days;
  final List<String> periods;
  final List<Map<String, String>> timeSlots;

  const CollectionTimeSelectionPage({
    Key? key,
    required this.title,
    required this.fem,
    this.selectedDay,
    this.selectedPeriod,
    this.selectedTimeSlot,
    required this.onTimeSelected,
    required this.onButtonStateChanged,
    required this.isPickup,
    required this.days,
    required this.periods,
    required this.timeSlots,
  }) : super(key: key);

  @override
  _CollectionTimeSelectionPageState createState() =>
      _CollectionTimeSelectionPageState();
}

class _CollectionTimeSelectionPageState
    extends State<CollectionTimeSelectionPage> {
  String? selectedDay;
  String? selectedPeriod;
  String? selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    selectedDay = widget.selectedDay;
    selectedPeriod = widget.selectedPeriod;
    selectedTimeSlot = widget.selectedTimeSlot;
  }

  void _selectDay(String day) {
    setState(() {
      selectedDay = day;
      selectedPeriod = null;
      selectedTimeSlot = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTimeSelected(day, '', '');
      widget.onButtonStateChanged(true);
    });
  }

  void _selectPeriod(String period) {
    setState(() {
      selectedPeriod = period;
      selectedTimeSlot = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTimeSelected(selectedDay ?? '', period, '');
      widget.onButtonStateChanged(true);
    });
  }

  void _selectTimeSlot(String timeSlot) {
    setState(() {
      selectedTimeSlot = timeSlot;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTimeSelected(selectedDay ?? '', selectedPeriod ?? '', timeSlot);
      widget.onButtonStateChanged(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final hasDays = widget.days.isNotEmpty;

    return Container(
      color: AppColors.white,
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(context, localizations),
            const SizedBox(height: 32),
            if (hasDays) ...[
              _buildDaySelection(context),
              if (selectedDay != null) ...[
                const SizedBox(height: 32),
                _buildPeriodSelection(context),
              ],
              if (selectedPeriod != null) ...[
                const SizedBox(height: 32),
                _buildTimeSlotSelection(context),
              ],
            ] else
              _buildEmptyState(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 95,
          height: 95,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x3301CE69),
                blurRadius: 50,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: SvgPicture.asset(
            "assets/Icons/timeIcon.svg",
            width: 95,
            height: 95,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate(widget.title),
          textAlign: TextAlign.center,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: AppColors.gray70),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate(widget.isPickup
              ? "Choose_best_collection_time"
              : "choose_best_delivery_time"),
          textAlign: TextAlign.center,
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.regular16Gray80(context).copyWith(
                fontSize: 13.0,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: AppColors.gray50),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray10,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray20),
      ),
      child: Text(
        localizations.translate(widget.isPickup
            ? 'no_available_collection_times'
            : 'no_available_delivery_times'),
        textAlign: TextAlign.center,
        style: AppTextStyles.getFontFamily(
          context,
          AppTextStyles.regular16Gray80(context).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: AppColors.gray60,
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelection(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final String lang = languageProvider.locale.languageCode;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Text(
              localizations.translate(widget.isPickup
                  ? "select_collection_day"
                  : "select_delivery_day"),

              // 'Select ${widget.isPickup ? 'collection' : 'delivery'} day',
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    height: 0,
                    color: AppColors.gray70),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: widget.days.map((day) {
                  return SlotCard(
                    type: 'day',
                    lang: lang,
                    label: day['day']!,
                    subtitle: day['date'],
                    isSelected: selectedDay == day['day'],
                    onTap: () => _selectDay(day['day']!),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelection(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final String lang = languageProvider.locale.languageCode;
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate("select_preferred_period"),
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  height: 0,
                  color: AppColors.gray70),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widget.periods.map((period) {
                return SlotCard(
                  lang: lang,
                  type: 'period',
                  label: period,
                  isSelected: selectedPeriod == period,
                  onTap: () => _selectPeriod(period),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotSelection(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    final String lang = languageProvider.locale.languageCode;
    final filteredTimeSlots = widget.timeSlots.where((slot) {
      final startTime = int.parse(slot['start_time']!.split(":")[0]);
      return selectedPeriod == "AM" ? startTime < 12 : startTime >= 12;
    }).toList();

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.translate("select_time_slot"),
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  height: 0,
                  color: AppColors.gray80),
            ),
          ),
          const SizedBox(height: 8),
          if (filteredTimeSlots.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gray10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                localizations.translate('no_available_time_slots'),
                textAlign: TextAlign.center,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray60,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: filteredTimeSlots.map((slot) {
                    final formattedStartTime =
                        ValidationUtils.formatTime(slot['start_time']!);
                    final formattedEndTime =
                        ValidationUtils.formatTime(slot['end_time']!);
                    return SlotCard(
                      type: 'time',
                      lang: lang,
                      label: '$formattedStartTime - $formattedEndTime',
                      isSelected: selectedTimeSlot ==
                          '$formattedStartTime - $formattedEndTime',
                      onTap: () => _selectTimeSlot(
                          '$formattedStartTime - $formattedEndTime'),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
