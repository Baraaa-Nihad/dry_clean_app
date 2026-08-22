import 'dart:convert';
import 'package:saleem_dry_clean/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/GradientText.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/components/Modals/AddAddressModal.dart';
import 'package:saleem_dry_clean/components/Modals/BlankModal.dart';
import 'package:saleem_dry_clean/components/Modals/CustomModal.dart';
import 'package:saleem_dry_clean/components/Modals/SmallModal.dart';
import 'package:saleem_dry_clean/components/Modals/SuccessModal.dart';
import 'package:saleem_dry_clean/components/ProgressBar/ProgressBar.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/screens/Checkout/CheckoutDeliveryTime.dart';
import 'package:saleem_dry_clean/screens/OrderSummary/OrdersSummary.dart';
import 'package:saleem_dry_clean/screens/SignInPage/SignIn.dart';
import 'package:saleem_dry_clean/screens/main_navigation.dart';
import 'package:saleem_dry_clean/services/ApiClient/ApiClient.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/Models/CheckoutModel.dart';
import 'package:saleem_dry_clean/services/Models/DryClean.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/AddressesProvider.dart';
import 'package:saleem_dry_clean/services/Providers/DryCleanProvider.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/NavigationProvider.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/Providers/TimeSelectionProvider.dart';
import 'package:saleem_dry_clean/services/User/TokenService.dart';
import 'package:saleem_dry_clean/services/User/UserService.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/navigator_key.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'AddressSectionPage.dart';
import 'CheckoutPickupTime.dart';

class CheckoutAddress extends StatefulWidget {
  final double fem;

  const CheckoutAddress({Key? key, required this.fem}) : super(key: key);

  @override
  _CheckoutAddressState createState() => _CheckoutAddressState();
}

class _CheckoutAddressState extends State<CheckoutAddress>
    with WidgetsBindingObserver {
  int _currentStep = 0;
  bool isDisabledButton = true;
  int selectedAddressIndex = -1;
  String? selectedPickupDay;
  String? selectedPickupPeriod;
  String? selectedPickupTimeSlot;
  String? selectedDeliveryDay;
  String? selectedDeliveryPeriod;
  String? selectedDeliveryTimeSlot;
  DryClean? dryClean;
  final TokenService _tokenService = TokenService();
  bool _isLoading = false; // Manage loading state
  bool _isLoadingAddresses = true;
  bool _isPersistingDefaultAddress = false;
  bool _isRestoringCheckout = true;
  String? _errorMessage; // Store error messages
  List<Map<String, dynamic>> pickupDays = [];
  List<String> pickupPeriods = ["AM", "PM"];
  List<Map<String, String>> pickupTimeSlots = [];
  List<Map<String, dynamic>> deliveryDays = [];
  List<String> deliveryPeriods = ["AM", "PM"];
  List<Map<String, String>> deliveryTimeSlots = [];
  int orderId = 0;

  String _stringValue(
    Map<String, dynamic> data,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  List<Map<String, String>> _parseTimeSlots(dynamic rawSlots) {
    if (rawSlots is! List) return [];

    return rawSlots
        .whereType<Map>()
        .map(
          (timeSlot) => {
            "start_time": timeSlot["start_time"]?.toString() ?? '',
            "end_time": timeSlot["end_time"]?.toString() ?? '',
          },
        )
        .where(
          (timeSlot) =>
              timeSlot["start_time"]!.isNotEmpty &&
              timeSlot["end_time"]!.isNotEmpty,
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCheckout());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      Provider.of<OrderProvider>(context, listen: false).saveCartToSession();
    }
  }

  Future<void> _initializeCheckout() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.ready;
    if (!mounted) return;

    if (!orderProvider.checkoutActive) {
      orderProvider.startCheckout();
    }

    final restoredStep = _validatedRestoredStep(orderProvider);
    if (restoredStep != orderProvider.checkoutStep) {
      orderProvider.setCheckoutStep(restoredStep);
    }
    final pickupParts = _splitStoredTime(orderProvider.pickupTime);
    final deliveryParts = _splitStoredTime(orderProvider.deliveryTime);
    setState(() {
      _currentStep = restoredStep;
      selectedPickupDay = orderProvider.collectionDay;
      selectedPickupPeriod = pickupParts[0];
      selectedPickupTimeSlot = pickupParts[1];
      selectedDeliveryDay = orderProvider.deliveryDay;
      selectedDeliveryPeriod = deliveryParts[0];
      selectedDeliveryTimeSlot = deliveryParts[1];
      _isRestoringCheckout = false;
      if (_currentStep == 0) {
        isDisabledButton = true;
      } else if (_currentStep == 1) {
        isDisabledButton = selectedPickupTimeSlot == null;
      } else if (_currentStep == 2) {
        isDisabledButton = selectedDeliveryTimeSlot == null;
      } else {
        isDisabledButton = false;
      }
    });

    _initializeProviders();
    await _fetchAddresses();
    if (!mounted) return;
    await _restoreTimeOptions();
  }

  int _validatedRestoredStep(OrderProvider orderProvider) {
    final step = orderProvider.checkoutStep;
    if (step >= 1 && orderProvider.address == null) return 0;
    if (step >= 2 &&
        ((orderProvider.collectionDate ?? '').isEmpty ||
            (orderProvider.pickupTime ?? '').isEmpty)) {
      return 1;
    }
    if (step >= 3 &&
        ((orderProvider.deliveryDate ?? '').isEmpty ||
            (orderProvider.deliveryTime ?? '').isEmpty)) {
      return 2;
    }
    return step;
  }

  List<String?> _splitStoredTime(String? value) {
    if (value == null || value.trim().isEmpty) return [null, null];
    final match = RegExp(
      r'^(AM|PM)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(value.trim());
    if (match == null) return [null, value.trim()];
    return [match.group(1)?.toUpperCase(), match.group(2)];
  }

  void setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  void _initializeProviders() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final addressesProvider = Provider.of<AddressesProvider>(
      context,
      listen: false,
    );

    if (userProvider.user != null) {
      addressesProvider.initialize(userProvider.userAddresses);
      _selectDefaultAddress(addressesProvider.addresses);
    }
  }

  Future<void> _fetchAddresses() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isLoadingAddresses = true;
      });
    }
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressesProvider = Provider.of<AddressesProvider>(
        context,
        listen: false,
      );

      if (userProvider.user != null) {
        Locale currentLocale = Localizations.localeOf(context);
        await addressesProvider.fetchAddresses(
          userProvider.user!.id,
          currentLocale.languageCode,
        );

        _selectDefaultAddress(
          addressesProvider.addresses,
        ); // Select the default address if any
      }
    } catch (error) {
      print('Error fetching addresses: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingAddresses = false;
        });
      }
    }
  }

  void _selectDefaultAddress(List<Map<String, dynamic>> addresses) {
    if (addresses.isEmpty || !mounted) return;

    final savedAddressId = Provider.of<OrderProvider>(
      context,
      listen: false,
    ).address?['id']?.toString();
    final savedIndex = savedAddressId == null
        ? -1
        : addresses.indexWhere(
            (address) => address['id']?.toString() == savedAddressId,
          );
    int defaultIndex = addresses.indexWhere(
      (address) => address['is_default'] == 1,
    );
    final selectedIndex =
        savedIndex >= 0 ? savedIndex : (defaultIndex >= 0 ? defaultIndex : 0);
    final selectedAddress = addresses[selectedIndex];

    setState(() {
      selectedAddressIndex = selectedIndex;
      isDisabledButton = false;
    });
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).setAddress(selectedAddress);

    if (defaultIndex < 0 && addresses.length == 1) {
      _persistDefaultAddress(selectedAddress);
    }
  }

  Future<void> _restoreTimeOptions() async {
    if (_currentStep == 0 || selectedAddressIndex < 0) return;

    final addresses = Provider.of<AddressesProvider>(
      context,
      listen: false,
    ).addresses;
    if (selectedAddressIndex >= addresses.length) return;
    final areaId = int.tryParse(
      '${addresses[selectedAddressIndex]['area_id']}',
    );
    if (areaId == null) return;

    await _fetchDryCleanDetails(areaId);
    if (!mounted) return;
    if (_currentStep >= 2 &&
        (Provider.of<OrderProvider>(context, listen: false).collectionDate ??
                '')
            .isNotEmpty) {
      await _fetchDeliveryTimes();
    }
  }

  Future<void> _selectAddress(int index) async {
    final addressesProvider = Provider.of<AddressesProvider>(
      context,
      listen: false,
    );
    if (index < 0 || index >= addressesProvider.addresses.length) return;

    final selectedAddress = addressesProvider.addresses[index];
    setState(() {
      selectedAddressIndex = index;
      isDisabledButton = false;
    });
    Provider.of<OrderProvider>(
      context,
      listen: false,
    ).setAddress(selectedAddress);

    if (selectedAddress['is_default'] != 1) {
      await _persistDefaultAddress(selectedAddress);
    }
  }

  Future<void> _persistDefaultAddress(Map<String, dynamic> address) async {
    if (_isPersistingDefaultAddress) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.user == null) return;

    _isPersistingDefaultAddress = true;
    try {
      final addressesProvider = Provider.of<AddressesProvider>(
        context,
        listen: false,
      );
      await addressesProvider.setDefault(address, userProvider, context);

      if (!mounted) return;
      final refreshedIndex = addressesProvider.addresses.indexWhere(
        (item) => item['id'].toString() == address['id'].toString(),
      );
      if (refreshedIndex >= 0) {
        final refreshedAddress = addressesProvider.addresses[refreshedIndex];
        setState(() => selectedAddressIndex = refreshedIndex);
        Provider.of<OrderProvider>(
          context,
          listen: false,
        ).setAddress(refreshedAddress);
      }
    } finally {
      _isPersistingDefaultAddress = false;
    }
  }

  void _addNewAddress(BuildContext context) {
    CustomModal.show(
      context,
      mainTitle: 'Add Address Details',
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: NewAddressModal(
        item: {},
        fem: widget.fem,
        selectedIndex: -1,
        onItemSelected: (index) {
          setState(() {
            selectedAddressIndex = index;
          });
        },
        onAdd: (newItem) async {
          // Start loading state
          setLoading(true);

          try {
            Locale currentLocale = Localizations.localeOf(context);
            await Provider.of<AddressesProvider>(
              context,
              listen: false,
            ).addAddress(
              newItem,
              Provider.of<UserProvider>(context, listen: false),
              currentLocale.languageCode,
              context,
            );

            final addressesProvider = Provider.of<AddressesProvider>(
              context,
              listen: false,
            );
            final newAddressIndex = addressesProvider.addresses.length - 1;
            if (newAddressIndex >= 0) {
              await _selectAddress(newAddressIndex);
            }
          } catch (error) {
            // Handle any errors during address addition
            print('Error adding address: $error');
          } finally {
            // Stop loading state
            setLoading(false);

            // Close the modal
            // Navigator.pop(context);
          }
        },
        onUpdate: (updatedItem) {},
        isNewAddress: true,
      ),
    );
  }

  void handlePickupTimeSelected(String day, String period, String timeSlot) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    setState(() {
      selectedPickupDay = day;
      selectedPickupPeriod = period;
      selectedPickupTimeSlot = timeSlot;

      // Find the day that matches the selected day
      final selectedDayData = pickupDays.firstWhere(
        (dayItem) => dayItem['day'] == day,
        orElse: () => {},
      );

      if (selectedDayData.isNotEmpty &&
          selectedDayData.containsKey('pickupTimeSlots')) {
        // Assign the time slots for the selected day
        pickupTimeSlots = List<Map<String, String>>.from(
          selectedDayData['pickupTimeSlots'],
        );

        // Store the original date with the year in OrderProvider
        String collectionDate = selectedDayData['date'];
        print("setCollectionDate");
        print(collectionDate);
        orderProvider.setCollectionDate(collectionDate);
        // Store the original date with the year in OrderProvider
        String collectionDay = selectedDayData['day'];
        print("day");
        print(collectionDay);
        orderProvider.setCollectionDay(collectionDay);
      }
    });

    orderProvider.setPickupTime('$period $timeSlot');

    updateButtonState(true);
  }

  void handleDeliveryTimeSelected(String day, String period, String timeSlot) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    setState(() {
      selectedDeliveryDay = day;
      selectedDeliveryPeriod = period;
      selectedDeliveryTimeSlot = timeSlot;

      // Find the day that matches the selected day
      final selectedDayData = deliveryDays.firstWhere(
        (dayItem) => dayItem['day'] == day,
        orElse: () => {},
      );

      if (selectedDayData.isNotEmpty &&
          selectedDayData.containsKey('deliveryTimeSlots')) {
        // Assign the time slots for the selected day
        deliveryTimeSlots = List<Map<String, String>>.from(
          selectedDayData['deliveryTimeSlots'],
        );

        // Store the original date with the year in OrderProvider
        String deliveryDate = selectedDayData['date'];
        orderProvider.setDeliveryDate(deliveryDate);
        // Store the original date with the year in OrderProvider
        String deliveryDay = selectedDayData['day'];
        orderProvider.setDeliveryDay(deliveryDay);
      }
    });

    orderProvider.setDeliveryTime('$period $timeSlot');

    updateButtonState(true);
  }

  void updateButtonState(bool flag) {
    setState(() {
      if (_currentStep == 0) {
        isDisabledButton = selectedAddressIndex == -1;
      } else if (_currentStep == 1) {
        isDisabledButton =
            selectedPickupTimeSlot == null || selectedPickupTimeSlot == '';
      } else if (_currentStep == 2) {
        isDisabledButton =
            selectedDeliveryTimeSlot == null || selectedDeliveryTimeSlot == '';
      }
    });
  }

  void _showSetDefaultModal(
    BuildContext context,
    Map<String, dynamic> address,
  ) {
    final localizations = AppLocalizations.of(context);
    final isArabic = localizations?.locale.languageCode == 'ar';
    final addressName =
        isArabic ? address['addressName_ar'] : address['addressName_en'];

    // Fetch the localized message template
    String messageTemplate = localizations?.translate(
          'Are you sure that you want to set "{addressName}" as a default address?',
        ) ??
        'Are you sure that you want to set "{addressName}" as a default address?';

    // Replace the placeholder with the actual address name
    String message = messageTemplate.replaceAll('{addressName}', addressName);

    SmallModal.show(
      context,
      isLoading: false,
      prefixIconPath: 'assets/vectors/close_icon.svg',
      onPrefixIconTap: () => Navigator.of(context).pop(),
      fem: widget.fem,
      primaryButtonLable:
          localizations?.translate('Set as Default') ?? 'Set as Default',
      title: localizations?.translate('Set as Default') ?? 'Set as Default',
      message: message, // Use the modified message string here

      onPressed: () async {
        Navigator.of(context).pop();
        await Provider.of<AddressesProvider>(context, listen: false).setDefault(
          address,
          Provider.of<UserProvider>(context, listen: false),
          context,
        );
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _fetchDryCleanDetails(int areaId) async {
    final timeSelectionProvider = Provider.of<TimeSelectionProvider>(
      context,
      listen: false,
    );
    final dryCleanProvider = Provider.of<DryCleanProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final String lang = languageProvider.locale.languageCode;

    setLoading(true); // Start loading

    try {
      final data = await timeSelectionProvider.fetchDryCleanDetails(
        areaId,
        lang,
        // مواعيد المحل المختار لا مواعيد أوّل محل يخدم المنطقة
        drycleanId: Provider.of<OrderProvider>(context, listen: false).storeId,
      );
      if (data.isNotEmpty) {
        if (data['dryclean'] != null) {
          final dryClean = DryClean.fromJson(data['dryclean']);
          orderProvider.setDeliveryFees(dryClean.deliveryFees);
          dryCleanProvider.setDryClean(dryClean);
        }
        print(
          'pickupDayspickupDayspickupDayspickupDayspickupDayspickupDayspickupDayspickupDays',
        );
        print(data['pickup_days']);
        // Extract pickupDays and pickupTimeSlots
        if (data['pickup_days'] != null) {
          pickupDays = List<Map<String, dynamic>>.from(
            (data['pickup_days'] as List).whereType<Map>().map((rawDayItem) {
              final dayItem = Map<String, dynamic>.from(rawDayItem);
              final dayLabel = _stringValue(dayItem, [
                'formattedDay',
                'formatted_day',
                'day',
              ]);

              return {
                "id": _stringValue(dayItem, ["id"]),
                "day": dayLabel,
                "formattedDay": dayLabel,
                "date": _stringValue(dayItem, [
                  "date",
                  "formattedDate",
                  "formatted_date",
                ]),
                "pickupTimeSlots": _parseTimeSlots(
                  dayItem['pickup_time_slots'],
                ),
              };
            }).where((dayItem) => dayItem['day'].toString().isNotEmpty),
          );
        }
        print(
          'delivery_daysdelivery_daysdelivery_daysdelivery_daysdelivery_days',
        );
        print(data['delivery_days']);
        // Extract deliveryDays and deliveryTimeSlots
        if (data['delivery_days'] != null) {
          deliveryDays = List<Map<String, dynamic>>.from(
            (data['delivery_days'] as List).whereType<Map>().map((rawDayItem) {
              final dayItem = Map<String, dynamic>.from(rawDayItem);
              final dayLabel = _stringValue(dayItem, [
                'formattedDay',
                'formatted_day',
                'day',
              ]);

              return {
                "id": _stringValue(dayItem, ["id"]),
                "day": dayLabel,
                "formattedDay": dayLabel,
                "date": _stringValue(dayItem, [
                  "date",
                  "formattedDate",
                  "formatted_date",
                ]),
                "deliveryTimeSlots": _parseTimeSlots(
                  dayItem['delivery_time_slots'],
                ),
              };
            }).where((dayItem) => dayItem['day'].toString().isNotEmpty),
          );
        }
      } else {
        timeSelectionProvider.setErrorMessage('no_available_time_slots');
      }
    } catch (error) {
      print('Error fetching dry clean details: $error');
      timeSelectionProvider.setErrorMessage('time_slots_load_failed');
    } finally {
      setLoading(false); // Stop loading
    }
  }

  void _nextStep() async {
    if (_currentStep == 0 && selectedAddressIndex != -1) {
      final selectedAddress = Provider.of<AddressesProvider>(
        context,
        listen: false,
      ).addresses[selectedAddressIndex];
      final areaId = selectedAddress['area_id'];

      if (areaId != null) {
        await _fetchDryCleanDetails(areaId);
      } else {
        final timeSelectionProvider = Provider.of<TimeSelectionProvider>(
          context,
          listen: false,
        );
        timeSelectionProvider.setErrorMessage('address_area_missing');
      }
    }

    // When leaving pickup step, fetch delivery times based on chosen pickup
    if (_currentStep == 1 &&
        selectedPickupDay != null &&
        selectedPickupTimeSlot != null) {
      await _fetchDeliveryTimes();
    }

    // Move to the next step only if the current step is less than 3
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
      Provider.of<OrderProvider>(
        context,
        listen: false,
      ).setCheckoutStep(_currentStep);
      updateButtonState(
        false,
      ); // Ensure button state is reset for the next step
    }
  }

  /// Fetches available delivery days/slots based on the user's chosen pickup
  /// date + time and the dry-clean's operation time.
  Future<void> _fetchDeliveryTimes() async {
    final timeSelectionProvider = Provider.of<TimeSelectionProvider>(
      context,
      listen: false,
    );
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final addressesProvider = Provider.of<AddressesProvider>(
      context,
      listen: false,
    );

    final collectionDate = orderProvider.collectionDate;
    if (collectionDate == null || collectionDate.isEmpty) return;

    final pickupTime =
        '$selectedPickupPeriod $selectedPickupTimeSlot'; // e.g. "AM 9:00 - 10:00"
    final selectedAddress = addressesProvider.addresses[selectedAddressIndex];
    final areaId = selectedAddress['area_id'];
    if (areaId == null) return;

    final String lang = languageProvider.locale.languageCode;

    setLoading(true);
    try {
      final data = await timeSelectionProvider.fetchDeliveryTimes(
        areaId,
        lang,
        collectionDate,
        pickupTime,
        // مواعيد التسليم تُحسب من وقت معالجة المحل المختار
        drycleanId: Provider.of<OrderProvider>(context, listen: false).storeId,
      );

      if (data.isNotEmpty && data['delivery_days'] != null) {
        setState(() {
          deliveryDays = List<Map<String, dynamic>>.from(
            (data['delivery_days'] as List).whereType<Map>().map((rawDayItem) {
              final dayItem = Map<String, dynamic>.from(rawDayItem);
              final dayLabel = _stringValue(dayItem, [
                'formattedDay',
                'formatted_day',
                'day',
              ]);
              return {
                "id": _stringValue(dayItem, ["id"]),
                "day": dayLabel,
                "formattedDay": dayLabel,
                "date": _stringValue(dayItem, [
                  "date",
                  "formattedDate",
                  "formatted_date",
                ]),
                "deliveryTimeSlots": _parseTimeSlots(
                  dayItem['delivery_time_slots'],
                ),
              };
            }).where((d) => d['day'].toString().isNotEmpty),
          );
        });
      }
    } catch (error) {
      print('Error fetching delivery times: $error');
      timeSelectionProvider.setErrorMessage('delivery_times_load_failed');
    } finally {
      setLoading(false);
    }
  }

  void _previousStep() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      orderProvider.setCheckoutStep(_currentStep);
      updateButtonState(false);
    } else {
      orderProvider.endCheckout();
      orderProvider.saveCartToSession();
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      } else {
        NavigatorService.navigateToAndRemoveUntil(RouteNames.main);
      }
    }
  }

  void _goToMyOrders() {
    print("_handleOrdersTap");
    _handleOrdersTap(context);
  }

  void _goToOrderReceipt(int orderId) {
    print('_handleOrdersTap2');
    print(orderId);
    // Pass the order id to the receipt page
    NavigatorService.navigateToAndRemoveUntil(
      RouteNames.receipt,
      arguments: {'orderId': orderId}, // Pass the orderId as an argument
    );
  }

  void _showSuccessModal(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;
    print('isRtl');
    print(isRtl);
    BlankModal.show(
      context,

      isDismissible: false,
      widget.fem, // Pass fem as an argument if needed
      SuccessModal(
        isCloseable: false,
        isDismissible: false,
        title: 'Order success!',
        message: localizations.translate('order_success_message'),
        mainButton: PrimaryButton(
          fem: widget.fem, // Use widget.fem to access the passed fem value
          text: localizations.translate('Back To Home'),
          onPressed: () {
            _handleHomeTap(context);
          },
        ),
        secondaryButton: SecondaryButton(
          text: localizations.translate('go_to_my_orders'),
          fem: widget.fem,
          onPressed: () {
            _goToMyOrders();
          },
        ),
        customComponent: GestureDetector(
          onTap: () {
            // Navigate to the receipt page if needed
            _goToOrderReceipt(orderId);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GradientText(
                text: localizations.translate('Receipt'),
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.bold16Gradient(context).copyWith(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    height: 0,
                    color: AppColors.white,
                  ),
                ),
              ),
              if (isRtl)
                SvgPicture.asset(
                  "assets/Icons/LeftArrow.svg",
                  height: 24,
                  width: 24,
                ),
              if (!isRtl)
                SvgPicture.asset(
                  "assets/Icons/RightGradenatArrow.svg",
                  height: 24,
                  width: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle basket tap with navigation
  Future<void> _handleOrdersTap(BuildContext context) async {
    print('_handleOrdersTap2');
    NavigatorService.navigateToAndRemoveUntil(RouteNames.main);
    print('_handleOrdersTap3');
    Future.delayed(Duration(milliseconds: 100), () {
      Provider.of<NavigationProvider>(
        context,
        listen: false,
      ).navigateToOrders(); // Adjust based on your navigation logic
    });
  }

  /// Handle basket tap with navigation
  Future<void> _handleHomeTap(BuildContext context) async {
    print('_handleOrdersTap2');
    NavigatorService.navigateToAndRemoveUntil(RouteNames.main);
  }

  Future<void> _placeOrder(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
    setLoading(true); // Set loading state to true
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    try {
      // Prepare the order object
      final order = {
        'userFullName':
            '${userProvider.user?.firstName} ${userProvider.user?.lastName}',
        'userPhoneNumber': userProvider.user?.phoneNumber,
        'userId': userProvider.user?.id,
        'addressId': orderProvider.address?['id'], // Ensure this is not null
        'collectionDate':
            orderProvider.collectionDate, // Ensure this is not null
        'deliveryDate': orderProvider.deliveryDate, // Ensure this is not null
        'pickupTime': orderProvider.pickupTime, // Ensure this is not null
        'deliveryTime': orderProvider.deliveryTime, // Ensure this is not null
        // المحل الذي اختاره الزبون صراحةً.
        //
        // كان الخادم يشتقّه من منطقة العنوان — محل واحد لكل منطقة. وهذا
        // ينهار في نموذج الوسيط: عدّة محلات تخدم المنطقة نفسها، والزبون
        // اختار واحداً بعينه ورأى أسعاره. إرساله يمنع تسعير سلّته بأسعار
        // محل لم يرَه.
        //
        // ويبقى الاشتقاق في الخادم مسانداً لسلّة قديمة بلا ربط.
        if (orderProvider.storeId != null)
          'dry_clean_id': orderProvider.storeId,
        // الكود يُرسَل ولا تُرسَل قيمته: الخادم يعيد حسابها ويستهلك
        // الكود داخل معاملة الطلب. إرسال القيمة يعني أن تعديلها في
        // الطلب يخصم ما شاء
        if ((orderProvider.promoCode ?? '').isNotEmpty)
          'promoCode': orderProvider.promoCode,
        if (orderProvider.customerNote.trim().isNotEmpty)
          'customerNote': orderProvider.customerNote.trim(),
        'items': orderProvider.cart.map((item) => item.toJson()).toList(),
        'subtotal': orderProvider.subtotal,
        'deliveryFees': orderProvider.deliveryFees,
        'total': orderProvider.total,
        'paymentMethod': "cash on delivery",
      };

      // Ensure the necessary fields are filled out
      if (orderProvider.address == null ||
          orderProvider.collectionDate == null ||
          orderProvider.deliveryDate == null) {
        setLoading(false); // Stop loading state
        setState(() {
          _errorMessage = AppLocalizations.of(
            context,
          ).translate('checkout_complete_steps_error');
        });
        return;
      }

      // Send the order to the backend
      final url = Uri.parse('${Config.createOrder}');
      final client = ApiClient.createClient(_tokenService);
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order),
      );

      if (response.statusCode == 201) {
        // Clear cart after successful order placement
        orderProvider.clearCart();

        // Force clear cart from session storage
        await orderProvider.clearCartFromSession();
        final responseData = json.decode(response.body);

        final orderInfo = responseData['data'];
        // Correctly set the orderId
        setState(() {
          orderId = orderInfo['orderId'];
        });

        // Show success modal on order placement
        _showSuccessModal(context);
      } else {
        dynamic responseData;
        try {
          responseData = json.decode(response.body);
        } catch (_) {
          responseData = const <String, dynamic>{};
        }

        setState(() {
          _errorMessage = _localizedOrderError(
            responseData,
            response.statusCode,
          );
        });
      }
    } catch (error) {
      debugPrint('Error placing order: $error');
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        ).translate('server_connection_error');
      });
    } finally {
      setLoading(false); // Reset loading state
    }
  }

  String _localizedOrderError(dynamic responseData, int statusCode) {
    final localizations = AppLocalizations.of(context);
    final code = responseData is Map
        ? (responseData['code'] ?? '').toString().trim().toUpperCase()
        : '';
    const keysByCode = <String, String>{
      'MISSING_ORDER_DATA': 'order_missing_data',
      'ADDRESS_NOT_FOUND': 'order_address_not_found',
      'ADDRESS_NOT_YOURS': 'order_address_not_yours',
      'NO_DRYCLEAN_FOR_AREA': 'order_no_laundry_for_area',
      'DRYCLEAN_UNAVAILABLE': 'order_laundry_unavailable',
      'DRYCLEAN_NOT_IN_AREA': 'order_laundry_not_in_area',
      'PRODUCTS_UNAVAILABLE': 'order_items_unavailable',
      // ★ رموز القياس والدوام ★
      //
      // كانت تسقط في «تعذّر إرسال الطلب» — وهي رسالة لا تدلّ
      // على شيء: لا يعرف من يقرؤها أيّ تفصيلٍ يراجع، فيعيد المحاولة
      // ويفشل مرّةً بعد مرّة.
      'INVALID_DIMENSIONS': 'order_dimensions_invalid',
      'CUSTOM_SIZE_DISABLED': 'order_custom_size_disabled',
      'UNKNOWN_SIZE_DISABLED': 'order_unknown_size_disabled',
      'PRICE_PENDING_PROMO_DISABLED': 'order_promo_needs_final_price',
      'DRYCLEAN_CLOSED': 'order_laundry_closed',
      'INVALID_CODE': 'promo_code_invalid',
      'WRONG_STORE': 'promo_wrong_laundry',
      'BELOW_MINIMUM': 'promo_below_minimum',
      'CODE_EXHAUSTED': 'promo_usage_limit_reached',
      'ALREADY_USED': 'promo_already_used',
      'AUTH_REQUIRED': 'sign_in_required_to_continue',
      'UNAUTHORIZED': 'sign_in_required_to_continue',
    };
    final key = keysByCode[code] ??
        ((statusCode == 401 || statusCode == 403)
            ? 'sign_in_required_to_continue'
            : statusCode >= 500
                ? 'unexpected_error_try_again'
                : 'order_failed_try_again');
    return localizations.translate(key);
  }

  void _showSignInModal(BuildContext context) {
    SmallModal.show(
      context,
      fem: widget.fem,
      title: 'Sign in required',
      isLoading: false,
      message: 'Please sign in to checkout your orders.',
      primaryButtonLable: 'Sign In',
      prefixIconPath: 'assets/vectors/close_icon.svg',
      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      onPressed: () async {
        Navigator.pop(context);
        final userService = UserService();
        await userService.signOut();
        NavigatorService.navigateTo(RouteNames.signIn);
      },
      onCancel: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCurrentStepContent() {
    return Consumer2<AddressesProvider, TimeSelectionProvider>(
      builder: (context, addressesProvider, timeSelectionProvider, child) {
        if (_isRestoringCheckout ||
            (_currentStep == 0 && _isLoadingAddresses)) {
          return Center(child: LoadingDots(fem: widget.fem));
        }

        switch (_currentStep) {
          case 0:
            return AddressSectionPage(
              fem: widget.fem,
              selectedAddressIndex: selectedAddressIndex,
              onAddressSelected: _selectAddress,
              onAddNew: () {
                // Add new address logic here
                _addNewAddress(context);
              },
              onEdit: (context, address) {
                // Edit address logic here
              },
              onSetDefault: (context, address) {
                _showSetDefaultModal(context, address);
                // Set default address logic here
              },
              onDelete: (context, address) {
                // Delete address logic here
              },
            );
          case 1:
            return timeSelectionProvider.isLoading
                ? Center(child: LoadingDots(fem: widget.fem))
                : CheckoutPickupTime(
                    fem: widget.fem,
                    selectedDay: selectedPickupDay,
                    selectedPeriod: selectedPickupPeriod,
                    selectedTimeSlot: selectedPickupTimeSlot,
                    onTimeSelected: handlePickupTimeSelected,
                    onButtonStateChanged: updateButtonState,
                    days: pickupDays,
                    periods: pickupPeriods,
                    timeSlots: pickupTimeSlots,
                  );

          case 2:
            return timeSelectionProvider.isLoading
                ? Center(child: LoadingDots(fem: widget.fem))
                : CheckoutDeliveryTime(
                    fem: widget.fem,
                    selectedDay: selectedDeliveryDay,
                    selectedPeriod: selectedDeliveryPeriod,
                    selectedTimeSlot: selectedDeliveryTimeSlot,
                    onTimeSelected: handleDeliveryTimeSelected,
                    onButtonStateChanged: updateButtonState,
                    days: deliveryDays,
                    periods: deliveryPeriods,
                    timeSlots: deliveryTimeSlots,
                  );
          case 3:
            return OrdersSummary(
              EditLocationButton: () {
                setState(() {
                  _currentStep = 0;
                  isDisabledButton = selectedAddressIndex == -1;
                });
                Provider.of<OrderProvider>(
                  context,
                  listen: false,
                ).setCheckoutStep(0);
              },
              EditTimeButton: () {
                setState(() {
                  _currentStep = 1;
                  isDisabledButton = selectedPickupTimeSlot == null;
                });
                Provider.of<OrderProvider>(
                  context,
                  listen: false,
                ).setCheckoutStep(1);
              },
            );
          default:
            return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final addressesProvider = Provider.of<AddressesProvider>(context);
          final orderProvider = context.watch<OrderProvider>();
          final addresses = addressesProvider.addresses;
          final timeSelectionProvider = Provider.of<TimeSelectionProvider>(
            context,
          );
          final isInitialAddressLoading = _currentStep == 0 &&
              (_isRestoringCheckout || _isLoadingAddresses);
          final isAddressUpdating = _currentStep == 0 &&
              !isInitialAddressLoading &&
              (addressesProvider.isLoading ||
                  userProvider.isLoading ||
                  _isLoading);

          final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
          final actionBarHeight = keyboardVisible ? 72.0 : 124.0;
          final timeErrorKey = timeSelectionProvider.errorMessage;
          final visibleError = _errorMessage ??
              (timeErrorKey == null
                  ? null
                  : localizations.translate(timeErrorKey));

          return Scaffold(
            backgroundColor: AppColors.white,
            body: Stack(
              children: [
                AbsorbPointer(
                  absorbing: isAddressUpdating,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 116,
                          child: AppHeader(
                            quantityNumber: false,
                            prefixIcon: BackButtonWidget(onTap: _previousStep),
                            title: _currentStep == 3
                                ? 'OrderSummary'
                                : 'Checkout', // Updated title
                            fem: widget.fem,
                          ),
                        ),
                        ProgressBar(progressIndicator: _currentStep + 1),
                        Expanded(child: _buildCurrentStepContent()),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  top: 120,
                  child: IgnorePointer(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        reverseDuration: const Duration(milliseconds: 160),
                        transitionBuilder: (child, animation) {
                          final scale =
                              Tween<double>(begin: 0.92, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return FadeTransition(
                            opacity: animation,
                            child: ScaleTransition(scale: scale, child: child),
                          );
                        },
                        child: isAddressUpdating
                            ? KeyedSubtree(
                                key: const ValueKey('address-loading'),
                                child: LoadingDots(fem: widget.fem),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('address-idle'),
                              ),
                      ),
                    ),
                  ),
                ),
                if (visibleError != null)
                  Positioned(
                    bottom: actionBarHeight + 8,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        12,
                        9,
                        6,
                        9,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.errorBackground,
                        border: Border.all(color: AppColors.errorBorder),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 19,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              visibleError,
                              textAlign: TextAlign.start,
                              style: AppTextStyles.getFontFamily(
                                context,
                                AppTextStyles.sfarabicMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.red,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: AppColors.red,
                            ),
                            onPressed: () {
                              setState(() => _errorMessage = null);
                              timeSelectionProvider.clearErrorMessage();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    color: AppColors.white,
                    width: 428,
                    height: actionBarHeight,
                    padding: EdgeInsets.fromLTRB(
                      24,
                      keyboardVisible ? 8 : 0,
                      24,
                      keyboardVisible ? 8 : 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLoading) ...[
                          LoadingButton(
                            buttonWidth: "full",
                            fem: widget.fem,
                            buttonText: localizations.translate(
                              _currentStep == 3
                                  ? (orderProvider.hasPendingMeasurement
                                      ? 'place_order_price_pending'
                                      : 'place_order')
                                  : 'Next',
                            ),
                            isDisabled: isDisabledButton || isAddressUpdating,
                            onPressed: () {
                              if (_currentStep == 0 &&
                                  selectedAddressIndex != -1) {
                                final selectedAddress =
                                    addresses[selectedAddressIndex];
                                Provider.of<CheckoutModel>(
                                  context,
                                  listen: false,
                                ).setCustomerAddress(selectedAddress);
                                Provider.of<OrderProvider>(
                                  context,
                                  listen: false,
                                ).setAddress(selectedAddress);
                                _nextStep();
                              } else if (_currentStep == 1 &&
                                  selectedPickupTimeSlot != null) {
                                final pickupTime =
                                    '$selectedPickupPeriod $selectedPickupTimeSlot';
                                Provider.of<CheckoutModel>(
                                  context,
                                  listen: false,
                                ).setPickupData(selectedPickupDay!, pickupTime);
                                Provider.of<OrderProvider>(
                                  context,
                                  listen: false,
                                ).setPickupTime(pickupTime);
                                _nextStep();
                              } else if (_currentStep == 2 &&
                                  selectedDeliveryTimeSlot != null) {
                                final deliveryTime =
                                    '$selectedDeliveryPeriod $selectedDeliveryTimeSlot';
                                Provider.of<CheckoutModel>(
                                  context,
                                  listen: false,
                                ).setDeliveryData(
                                  selectedDeliveryDay!,
                                  deliveryTime,
                                );
                                Provider.of<OrderProvider>(
                                  context,
                                  listen: false,
                                ).setDeliveryTime(deliveryTime);
                                _nextStep();
                              } else if (_currentStep == 3) {
                                _placeOrder(context);
                              } else {
                                print('Please complete the current step');
                              }
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
