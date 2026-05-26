import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/services/Providers/AreaProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/Models/Area.dart';

class AreaSelectionModal extends StatelessWidget {
  final double fem;
  final String selectedAreaId;
  final Function(Area) onAreaSelected;

  const AreaSelectionModal({
    Key? key,
    required this.fem,
    required this.selectedAreaId,
    required this.onAreaSelected,
  }) : super(key: key);

  static void show(BuildContext context, double fem, String selectedAreaId,
      Function(Area) onAreaSelected) {
    final localizations = AppLocalizations.of(context);

    // Use the GLOBAL AreaProvider registered in main.dart — creating a local
    // provider here caused "used after being disposed" crashes because the
    // local instance was disposed by Flutter when the sheet closed while
    // fetchAreas was still in-flight.
    Provider.of<AreaProvider>(context, listen: false)
        .fetchAreas(localizations.locale.languageCode, '1');

    showModalBottomSheet(
      context: context,
      builder: (context) => AreaSelectionModal(
        fem: fem,
        selectedAreaId: selectedAreaId,
        onAreaSelected: onAreaSelected,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final provider = Provider.of<AreaProvider>(context);
    print(selectedAreaId);
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
                localizations?.translate('select_area') ?? 'Select Area',
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray80,
                  ),
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
          SizedBox(height: 16.0 * fem),
          Expanded(
              child: provider.isLoading
                  ? Center(
                      child: LoadingDots(
                      fem: fem,
                    ))
                  : provider.errorMessage != null
                      ? Center(child: Text(provider.errorMessage!))
                      : ListView.builder(
                          itemCount: provider.areas.length,
                          itemBuilder: (context, index) {
                            final area = provider.areas[index];
                            final isSelected =
                                area.id.toString() == selectedAreaId;
                            return GestureDetector(
                              onTap: () {
                                onAreaSelected(
                                    area); // Pass the selected area back
                                Navigator.pop(context); // Close the modal
                              },
                              child: _buildAreaItem(
                                context,
                                area,
                                isSelected,
                              ),
                            );
                          },
                        )),
          SizedBox(height: 16.0 * fem),
        ],
      ),
    );
  }

  Widget _buildAreaItem(BuildContext context, Area area, bool isSelected) {
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
              area.name,
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
