import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class CountryCodeModal extends StatelessWidget {
  final double fem;
  final Function(String) onSelect;
  final String selectedCode;

  const CountryCodeModal({
    Key? key,
    required this.fem,
    required this.onSelect,
    required this.selectedCode,
  }) : super(key: key);

  static final List<Map<String, String>> _countryCodes = [
    {'key': 'palestine', 'code': '+970'},
    {'key': 'jerusalem_1948', 'code': '+972'},
    // Add more country codes here
  ];

  static void show(BuildContext context, double fem, String selectedCode,
      Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CountryCodeModal(
        fem: fem,
        onSelect: onSelect,
        selectedCode: selectedCode,
      ),
      isScrollControlled: true, // Allow full-screen height
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
                localizations?.translate('select_code') ?? 'Select code',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 18.0 * fem,
                      fontWeight: FontWeight.w600,
                      height: 0,
                      color: AppColors.gray80),
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
          SizedBox(height: 16.0 * fem),
          Expanded(
            child: ListView.builder(
              itemCount: _countryCodes.length,
              itemBuilder: (context, index) {
                final country = _countryCodes[index];
                final isSelected = country['code'] == selectedCode;
                return GestureDetector(
                  onTap: () {
                    onSelect(country['code']!);
                    Navigator.pop(context); // Close the modal
                  },
                  child: _buildCountryCodeItem(
                    context,
                    localizations?.translate(country['key']!) ??
                        country['key']!,
                    country['code']!,
                    isSelected,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryCodeItem(
      BuildContext context, String country, String code, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0 * fem),
      height: 48.0 * fem,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.stroke, width: 1.0 * fem),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    country,
                    style: AppTextStyles.getFontFamily(
                      context,
                      AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0 * fem,
                          fontWeight: FontWeight.w500,
                          height: 0,
                          color: AppColors.gray50),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8.0 * fem),
                Text(
                  code,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                        fontSize: 16.0 * fem,
                        fontWeight: FontWeight.w600,
                        height: 0,
                        color: AppColors.gray70),
                  ),
                ),
              ],
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
