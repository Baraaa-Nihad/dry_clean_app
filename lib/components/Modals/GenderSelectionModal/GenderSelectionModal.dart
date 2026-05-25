import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class GenderSelectionModal extends StatelessWidget {
  final double fem;
  final String selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelectionModal({
    Key? key,
    required this.fem,
    required this.selectedGender,
    required this.onGenderSelected,
  }) : super(key: key);

  static void show(BuildContext context, double fem, String selectedGender,
      Function(String) onGenderSelected) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => GenderSelectionModal(
        fem: fem,
        selectedGender: selectedGender,
        onGenderSelected: onGenderSelected,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final List<String> genders = [
      localizations?.translate('male') ?? 'Male',
      localizations?.translate('female') ?? 'Female',
    ];

    return Container(
      padding: EdgeInsets.all(16.0 * fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0 * fem)),
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2.0 * fem),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56 * fem,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/vectors/close_icon.svg',
                  width: 48.0 * fem,
                  height: 48.0 * fem,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
              Text(
                localizations?.translate('gender') ?? 'Gender',
                style: AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray80,
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
          SizedBox(height: 16.0 * fem),
          Expanded(
            child: ListView.builder(
              itemCount: genders.length,
              itemBuilder: (context, index) {
                final gender = genders[index];
                final isSelected = gender == selectedGender;
                return GestureDetector(
                  onTap: () {
                    onGenderSelected(gender);
                    Navigator.pop(context);
                  },
                  child: _buildGenderItem(context, gender, isSelected),
                );
              },
            ),
          ),
          SizedBox(height: 16.0 * fem),
        ],
      ),
    );
  }

  Widget _buildGenderItem(
      BuildContext context, String gender, bool isSelected) {
    return Container(
      height: 48.0 * fem,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.stroke, width: 1.0 * fem),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0 * fem),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              gender,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.bold16Gray70(context).copyWith(
                  fontSize: 16.0 * fem,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          isSelected
              ? SvgPicture.asset(
                  'assets/Icons/checked_box.svg',
                  width: 24.0 * fem,
                  height: 24.0 * fem,
                )
              : SvgPicture.asset(
                  'assets/Icons/Check_box.svg',
                  width: 24.0 * fem,
                  height: 24.0 * fem,
                ),
        ],
      ),
    );
  }
}
