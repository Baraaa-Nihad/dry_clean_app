import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/EmptyPage/EmptyPage.dart';
import 'package:saleem_dry_clean/components/Cards/AddressCard.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/services/Providers/AddressesProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';

class AddressSectionPage extends StatelessWidget {
  final double fem;
  final int? selectedAddressIndex;
  final Function(int) onAddressSelected;
  final VoidCallback onAddNew;
  final void Function(BuildContext, Map<String, dynamic>) onEdit;
  final void Function(BuildContext, Map<String, dynamic>) onSetDefault;
  final void Function(BuildContext, Map<String, dynamic>) onDelete;

  const AddressSectionPage({
    Key? key,
    required this.fem,
    this.selectedAddressIndex,
    required this.onAddressSelected,
    required this.onAddNew,
    required this.onEdit,
    required this.onSetDefault,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AddressesProvider, LanguageProvider>(
      builder: (context, addressesProvider, languageProvider, child) {
        final addresses = addressesProvider.addresses;
        final localizations = AppLocalizations.of(context);
        final languageCode = languageProvider.locale.languageCode;

        int defaultAddressIndex =
            addresses.indexWhere((address) => address['is_default'] == 1);

        if (addresses.isEmpty) {
          return EmptyPage(
            iconUrl: "assets/Icons/noAddress.svg",
            fem: fem,
            title: localizations.translate("no_address_added"),
            subtitle: localizations.translate("add_new_address"),
            showButton: true,
            buttonAction: onAddNew,
            buttonText: localizations.translate("add_new"),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: Container(
            color: AppColors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 80),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 14.0),
                      child: Text(
                        localizations.translate('Confirm_your_address'),
                        style: AppTextStyles.getFontFamily(
                          context,
                          AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              height: 0,
                              color: AppColors.gray50),
                        ),
                      ),
                    ),
                    ...addresses.map((address) {
                      final index = addresses.indexOf(address);
                      print(address);
                      final addressNameKey = 'addressName';
                      final areaNameKey =
                          address[addressNameKey] ?? address['id'].toString();

                      final governateNameKey = languageCode == 'ar'
                          ? 'governateName_ar'
                          : 'governateName_en';
                      final addressName = languageCode == 'ar'
                          ? address['addressName_ar'].toString()
                          : address['addressName_en'].toString();
                      final areaName = languageCode == 'ar'
                          ? address['areaName_ar'].toString()
                          : address['areaName_en'].toString();
                      print("addressName");
                      print(addressName);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: AddressCard(
                          isDeleteable: false,
                          isClickable: true,
                          areaName: areaName,
                          key: ValueKey(address['id']),
                          addressName: addressName,
                          governate: address[governateNameKey] ?? '',
                          street: address['street'] ?? '',
                          building: address['building'] ?? '',
                          extraInfo: address['extraInfo'] ?? '',
                          isDefault: (address['is_default'] == 1),
                          isSelected: selectedAddressIndex == index ||
                              (selectedAddressIndex == null &&
                                  index == defaultAddressIndex),
                          onSelect: () => onAddressSelected(index),
                          onEdit: () => onEdit(context, address),
                          onSetDefult: () => onSetDefault(context, address),
                          onDelete: () => onDelete(context, address),
                          fem: fem,
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 56),
                      child: SecondaryButton(
                        buttonWidth: "full",
                        fem: fem,
                        prefixIcon: SvgPicture.asset(
                          'assets/Icons/AddGradent.svg',
                          width: 24,
                          height: 24,
                        ),
                        text: localizations.translate('add_items_now'),
                        onPressed: onAddNew,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
