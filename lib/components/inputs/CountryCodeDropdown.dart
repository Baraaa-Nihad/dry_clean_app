import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/Modals/CountryCodeModal.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class CountryCodeDropdown extends StatelessWidget {
  final String selectedCountryCode;
  final List<String> countryCodes;
  final ValueChanged<String> onChanged;
  final double fem;

  const CountryCodeDropdown({
    Key? key,
    required this.selectedCountryCode,
    required this.countryCodes,
    required this.onChanged,
    required this.fem,
  }) : super(key: key);

  void _showCountryCodeModal(BuildContext context) {
    CountryCodeModal.show(
      context,
      fem,
      selectedCountryCode,
      onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: () => _showCountryCodeModal(context),
      child: Container(
        height: 32,
        width: 78,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isRtl ? 0 : 16.0),
            bottomLeft: Radius.circular(isRtl ? 0 : 16.0),
            topRight: Radius.circular(isRtl ? 16.0 : 0),
            bottomRight: Radius.circular(isRtl ? 16.0 : 0),
          ),
          border: Border(
            right: isRtl
                ? BorderSide.none
                : BorderSide(color: AppColors.stroke, width: 1.0),
            left: isRtl
                ? BorderSide(color: AppColors.stroke, width: 1.0)
                : BorderSide.none,
          ),
        ),
        padding: EdgeInsetsDirectional.only(start: 10),
        child: Row(
          children: [
            Text(
              selectedCountryCode,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    height: 0,
                    color: AppColors.gray70),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: isRtl ? 0.0 : 8.0, right: isRtl ? 8.0 : 0.0),
              child: SvgPicture.asset(
                'assets/vectors/down_arrow.svg',
                width: 2,
                height: 9,
                color: AppColors.gray30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
