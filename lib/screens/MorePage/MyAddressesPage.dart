import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/AddressCard.dart';
import 'package:saleem_dry_clean/components/Cards/EmptyAddressCard.dart';
import 'package:saleem_dry_clean/components/CustomRefreshIndicator/CustomRefreshIndicator.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/components/Modals/AddAddressModal.dart';
import 'package:saleem_dry_clean/components/Modals/CustomModal.dart';
import 'package:saleem_dry_clean/components/Modals/DeleteModal.dart';
import 'package:saleem_dry_clean/components/Modals/SmallModal.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/Providers/AddressesProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class MyAddressesPage extends StatefulWidget {
  final double fem;
  final User user;
  final Locale currentLocale;

  const MyAddressesPage({
    Key? key,
    required this.fem,
    required this.user,
    required this.currentLocale,
  }) : super(key: key);

  @override
  _MyAddressesPageState createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  Map<String, dynamic>? _selectedAddress;
  int selectedIndex = -1;
  late BuildContext _dialogContext; // Store the context reference

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dialogContext = context; // Store the context when it's safe to use
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAddresses();
    });
  }

  Future<void> _fetchAddresses() async {
    final addressesProvider = Provider.of<AddressesProvider>(
      _dialogContext,
      listen: false,
    );
    final userProvider = Provider.of<UserProvider>(
      _dialogContext,
      listen: false,
    );

    addressesProvider.setLoading(true);

    await userProvider.fetchUserAddress(
      widget.user.id,
      widget.currentLocale.languageCode,
      _dialogContext,
    );
    addressesProvider.initialize(userProvider.userAddresses);

    addressesProvider.setLoading(false);
  }

  void _showDeleteModal(
    BuildContext _dialogContext,
    Map<String, dynamic> address,
  ) {
    final localizations = AppLocalizations.of(_dialogContext);
    final addressName = widget.currentLocale.languageCode == 'ar'
        ? address['addressName_ar'] ?? ''
        : address['addressName_en'] ?? '';

    DeleteModal.show(
      _dialogContext,
      mainTitle: localizations.translate('delete_address'),
      richBody: addressName,
      body: ' ${localizations.translate('address_from_your_addresses_list')} ',
      prefixIconPath: 'assets/vectors/close_icon.svg',
      onPrefixIconTap: () => Navigator.of(_dialogContext).pop(),
      onDelete: () async {
        Navigator.of(_dialogContext).pop();
        await Provider.of<AddressesProvider>(
          _dialogContext,
          listen: false,
        ).deleteAddress(widget.user.id, address['id'].toString());
      },
      fem: widget.fem,
    );
  }

  void _showSetDefaultModal(
    BuildContext context,
    Map<String, dynamic> address,
  ) {
    final localizations = AppLocalizations.of(_dialogContext);
    final isArabic = localizations.locale.languageCode == 'ar';
    final addressName =
        (isArabic ? address['addressName_ar'] : address['addressName_en'])
            ?.toString() ??
        '';

    // Fetch the localized message template
    String messageTemplate = localizations.translate(
      'Are you sure that you want to set "{addressName}" as a default address?',
    );

    // Replace the placeholder with the actual address name
    String message = messageTemplate.replaceAll('{addressName}', addressName);

    SmallModal.show(
      isLoading: false,
      _dialogContext,
      prefixIconPath: 'assets/vectors/close_icon.svg',
      onPrefixIconTap: () => Navigator.of(_dialogContext).pop(),
      fem: widget.fem,
      primaryButtonLable: localizations.translate('Set as Default'),
      title: localizations.translate('Set as Default'),
      message: message,
      onPressed: () async {
        Navigator.of(_dialogContext).pop();
        await Provider.of<AddressesProvider>(
          _dialogContext,
          listen: false,
        ).setDefault(
          address,
          Provider.of<UserProvider>(_dialogContext, listen: false),
          _dialogContext,
        );
      },
      onCancel: () => Navigator.of(_dialogContext).pop(),
    );
  }

  void _showEditModal(
    BuildContext parentContext,
    Map<String, dynamic> address,
    int index,
  ) {
    final dialogContext = _dialogContext;
    CustomModal.show(
      dialogContext,
      mainTitle: 'edit_address_details',
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () => Navigator.pop(dialogContext),
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: NewAddressModal(
        item: address,
        fem: widget.fem,
        selectedIndex: _selectedAddress == address ? selectedIndex : -1,
        onItemSelected: (index) => setState(() => selectedIndex = index),
        onAdd: (newItem) {}, // No action for add in edit mode
        onUpdate: (updatedItem) async {
          if (!mounted) return;
          // Perform the update after closing the modal
          await Provider.of<AddressesProvider>(
            dialogContext,
            listen: false,
          ).updateAddress(
            updatedItem,
            Provider.of<UserProvider>(dialogContext, listen: false),
            widget.currentLocale.languageCode,
            _dialogContext,
          );

          if (mounted) {
            setState(() {
              _selectedAddress = updatedItem;
            });
          }
        },
        isNewAddress: false, // Indicate that this is an edit, not a new address
      ),
    );
  }

  void _addNewAddress(BuildContext context) {
    CustomModal.show(
      _dialogContext,
      mainTitle: 'add_address_details',
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () => Navigator.pop(_dialogContext),
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: NewAddressModal(
        item: {},
        fem: widget.fem,
        selectedIndex: -1,
        onItemSelected: (index) => setState(() => selectedIndex = index),
        onAdd: (newItem) async {
          await Provider.of<AddressesProvider>(
            _dialogContext,
            listen: false,
          ).addAddress(
            newItem,
            Provider.of<UserProvider>(_dialogContext, listen: false),
            widget.currentLocale.languageCode,
            _dialogContext,
          );
        },
        onUpdate: (updatedItem) {},
        isNewAddress: true,
      ),
    );
  }

  void _onAddressSelected(Map<String, dynamic> address) {
    setState(() => _selectedAddress = address);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(_dialogContext);
    final addressesProvider = Provider.of<AddressesProvider>(_dialogContext);
    final addresses = addressesProvider.addresses;
    final locale = widget.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.gray10,
      appBar: AppHeader(
        backgroundColor: AppColors.gray10,
        quantityNumber: false,
        prefixIcon: BackButtonWidget(
          onTap: () {
            Navigator.pop(
              _dialogContext,
            ); // Correct: Passes a function that calls Navigator.pop when tapped
          },
        ),
        title: localizations.translate('My_Addresses'),
        fem: widget.fem,
        onPrefixIconTap: () => Navigator.pop(_dialogContext),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              Expanded(
                child: addressesProvider.isLoading
                    ? Center(child: LoadingDots(fem: widget.fem))
                    : addresses.isEmpty
                    ? Center(
                        child: CustomRefreshIndicator(
                          onRefresh: _fetchAddresses,
                          child: EmptyAddressCard(
                            onAddNew: () => _addNewAddress(_dialogContext),
                          ),
                        ),
                      )
                    : CustomRefreshIndicator(
                        onRefresh: _fetchAddresses,
                        child: ListView.builder(
                          itemCount:
                              addresses.length + 1, // Extra item for the button
                          itemBuilder: (_dialogContext, index) {
                            if (index == addresses.length) {
                              // Add Address button at the end of the list
                              return Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: SecondaryButton(
                                  prefixIcon: SvgPicture.asset(
                                    "assets/Icons/AddGradent.svg",
                                    height: 24,
                                    width: 24,
                                  ),
                                  buttonWidth: "full",
                                  text: localizations.translate('add_address'),
                                  fem: widget.fem,
                                  onPressed: () =>
                                      _addNewAddress(_dialogContext),
                                ),
                              );
                            }

                            final address = addresses[index];
                            print("address['is_default']");
                            print(address['is_default']);
                            final addressName = locale == 'ar'
                                ? address['addressName_ar'] ?? ''
                                : address['addressName_en'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: AddressCard(
                                isDeleteable: true,
                                isClickable: false,
                                key: ValueKey(addressName),
                                addressName: addressName,
                                governate: locale == 'ar'
                                    ? address['governateName_ar'] ?? ''
                                    : address['governateName_en'] ?? '',
                                areaName: address['governateName_en'] ?? '',
                                street: address['street'] ?? '',
                                building: address['building'] ?? '',
                                extraInfo: addressName ?? '',
                                isDefault: (address['is_default'] ?? 0) == 1,
                                isSelected: _selectedAddress == address,
                                onSelect: () => _onAddressSelected(address),
                                onEdit: () => _showEditModal(
                                  _dialogContext,
                                  address,
                                  index,
                                ),
                                onSetDefult: () => _showSetDefaultModal(
                                  _dialogContext,
                                  address,
                                ),
                                onDelete: () =>
                                    _showDeleteModal(_dialogContext, address),
                                fem: widget.fem,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
