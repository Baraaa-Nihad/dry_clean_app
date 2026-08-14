import 'package:saleem_dry_clean/ui.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Filters/CategoryFilter.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/components/Modals/AddAddressNameModal.dart';
import 'package:saleem_dry_clean/components/Modals/CustomModal.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/services/Providers/AddressesProvider.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class NewAddressModal extends StatefulWidget {
  final Map<String, dynamic> item;
  final double fem;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<Map<String, dynamic>> onAdd;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final bool isNewAddress;

  const NewAddressModal({
    Key? key,
    required this.item,
    required this.fem,
    this.selectedIndex = -1,
    required this.onItemSelected,
    required this.onAdd,
    required this.onUpdate,
    this.isNewAddress = true,
  }) : super(key: key);

  @override
  _NewAddressModalState createState() => _NewAddressModalState();
}

class _NewAddressModalState extends State<NewAddressModal> {
  late int _selectedIndex;
  late TextEditingController _addressNameController;
  late TextEditingController _governateController;
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _areaController;
  late TextEditingController _extraInfoController;
  late FocusNode _addressNameFocusNode;
  late FocusNode _governateFocusNode;
  late FocusNode _streetFocusNode;
  late FocusNode _buildingFocusNode;
  late FocusNode _areaFocusNode;
  late FocusNode _extraInfoFocusNode;
  bool _isFirstTime = true;

  bool _isCustomName = false;
  bool _isFormValid = false;
  bool _isSubmitting = false;
  late List<Map<String, dynamic>> addressNames;

  @override
  void initState() {
    super.initState();

    _selectedIndex = widget.selectedIndex;
    _addressNameController = TextEditingController(
      text: widget.item['addressName'] ?? '',
    );
    _governateController = TextEditingController();
    _streetController = TextEditingController(
      text: widget.item['street'] ?? '',
    );
    _buildingController = TextEditingController(
      text: widget.item['building'] ?? '',
    );
    _extraInfoController = TextEditingController(
      text: widget.item['extraInfo'] ?? '',
    );
    _areaController = TextEditingController(text: widget.item['area'] ?? '');

    _addressNameFocusNode = FocusNode();
    _governateFocusNode = FocusNode();
    _streetFocusNode = FocusNode();
    _buildingFocusNode = FocusNode();
    _areaFocusNode = FocusNode();
    _extraInfoFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _hydrateSavedLocation();
      if (!mounted) return;
      await Provider.of<AddressesProvider>(
        context,
        listen: false,
      ).fetchAddressNames();
      if (mounted) _setSelectedCategory();
    });

    _validateForm();
    _addressNameController.addListener(_validateForm);
    _streetController.addListener(_validateForm);
    _buildingController.addListener(_validateForm);
    _extraInfoController.addListener(_validateForm);
    _areaController.addListener(_validateForm);
  }

  /// The city and area were chosen before registration/browsing and are kept
  /// by LocationScopeProvider. A new delivery address inherits both values so
  /// the user cannot accidentally create an address outside the active scope.
  Future<void> _hydrateSavedLocation() async {
    final scope = context.read<LocationScopeProvider>();
    if (!scope.isRestored) await scope.restore();
    if (!mounted) return;

    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selectedGovernate = scope.governate;
    final selectedArea = scope.area;

    final governateName = widget.isNewAddress && selectedGovernate != null
        ? selectedGovernate.name
        : (isRtl
                ? widget.item['governateName_ar']
                : widget.item['governateName_en']) ??
            widget.item['governate'] ??
            selectedGovernate?.name ??
            '';
    final areaName = widget.isNewAddress && selectedArea != null
        ? selectedArea.name
        : (isRtl ? widget.item['areaName_ar'] : widget.item['areaName_en']) ??
            widget.item['area'] ??
            selectedArea?.name ??
            '';

    setState(() {
      _governateController.text = governateName.toString();
      _areaController.text = areaName.toString();

      final governateId = widget.isNewAddress && selectedGovernate != null
          ? selectedGovernate.id
          : widget.item['governateId'] ??
              widget.item['governate_id'] ??
              selectedGovernate?.id;
      final areaId = widget.isNewAddress && selectedArea != null
          ? selectedArea.id
          : widget.item['areaId'] ?? widget.item['area_id'] ?? selectedArea?.id;

      if (governateId != null) {
        widget.item['governateId'] = governateId;
        widget.item['governate_id'] = governateId;
      }
      if (areaId != null) {
        widget.item['areaId'] = areaId;
        widget.item['area_id'] = areaId;
      }
      widget.item['governate'] = _governateController.text;
      widget.item['area'] = _areaController.text;
      widget.item[isRtl ? 'governateName_ar' : 'governateName_en'] =
          _governateController.text;
      widget.item[isRtl ? 'areaName_ar' : 'areaName_en'] = _areaController.text;
    });
    _validateForm();
  }

  void _setSelectedCategory() {
    final existingAddressName = widget.item['addressName'];
    final existingAreaId = widget.item['area_id'];

    if (existingAddressName != null) {
      for (int i = 0; i < addressNames.length; i++) {
        if (addressNames[i]['id'].toString() ==
            existingAddressName.toString()) {
          setState(() {
            _selectedIndex = i;
            _isCustomName = false;
          });
          break;
        }
      }
    } else {
      // Set custom name to true and assign its value to name_ar
      setState(() {
        _isCustomName = true;
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        _addressNameController.text = isRtl
            ? widget.item['addressName_ar'] ?? ''
            : widget.item['addressName_en'] ?? '';
        _selectedIndex = -1; // No selection from predefined categories
      });
    }

    // Set area name based on area_id
    if (existingAreaId != null) {
      setState(() {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        _areaController.text = isRtl
            ? widget.item['areaName_ar'] ?? ''
            : widget.item['areaName_en'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _addressNameController.dispose();
    _governateController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _extraInfoController.dispose();
    _areaController.dispose();
    _addressNameFocusNode.dispose();
    _governateFocusNode.dispose();
    _streetFocusNode.dispose();
    _buildingFocusNode.dispose();
    _extraInfoFocusNode.dispose();
    _areaFocusNode.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _addressNameController.text.isNotEmpty &&
          _governateController.text.isNotEmpty &&
          _areaController.text.isNotEmpty &&
          (widget.item['areaId'] ?? widget.item['area_id']) != null &&
          _streetController.text.isNotEmpty &&
          _buildingController.text.isNotEmpty;
    });
  }

  void _handleSubmit() {
    setState(() {
      _isSubmitting = true;
    });

    widget.item['addressName_ar'] = _addressNameController.text;
    widget.item['addressName_en'] = _addressNameController.text;
    widget.item['governate'] = _governateController.text;
    widget.item['street'] = _streetController.text;
    widget.item['building'] = _buildingController.text;
    widget.item['extraInfo'] = _extraInfoController.text;
    widget.item['area'] = _areaController.text;
    widget.item['governateId'] ??= widget.item['governate_id'];
    widget.item['areaId'] ??= widget.item['area_id'];

    if (_selectedIndex >= 0 && _selectedIndex < addressNames.length) {
      widget.item['addressNameId'] =
          addressNames[_selectedIndex]['id'].toString();
    }

    if (widget.isNewAddress) {
      widget.onAdd(widget.item);
    } else {
      widget.onUpdate(widget.item);
    }

    Navigator.of(context).pop();
  }

  void openNameModal() {
    final localizations = AppLocalizations.of(context);

    CustomModal.show(
      context,
      mainTitle: localizations.translate('add_address_details'),
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: AddAddressNameModal(
        fem: widget.fem,
        initialName: '',
        onNameEntered: (name) {
          setState(() {
            _addressNameController.text = name;
            _isCustomName = true;
            _isFirstTime = false;
            _selectedIndex = -1;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final addressesProvider = Provider.of<AddressesProvider>(context);

    // Safely extract and cast addressNames to List<Map<String, dynamic>>
    addressNames = addressesProvider.addressNames.isNotEmpty
        ? List<Map<String, dynamic>>.from(
            (addressesProvider.addressNames[0]['data'] as List<dynamic>).map(
              (item) => item as Map<String, dynamic>,
            ),
          )
        : <Map<String, dynamic>>[];

    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: addressesProvider.isLoading
          ? Center(child: LoadingDots(fem: widget.fem))
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Remove the padding from the CategoryFilter
                    if (addressNames.isNotEmpty)
                      CategoryFilter(
                        items: addressNames.map((name) {
                          return {
                            'label': isRtl
                                ? name['name_ar'] ?? ''
                                : name['name_en'] ?? '',
                            'id': name['id'] ?? '',
                            'icon': name['icon'] ?? '',
                          };
                        }).toList(),
                        fem: widget.fem,
                        selectedIndex: _selectedIndex,
                        onItemSelected: (index) {
                          setState(() {
                            _selectedIndex = index;
                            _addressNameController.text = addressNames[index]
                                    [isRtl ? 'name_ar' : 'name_en'] ??
                                '';
                            _isCustomName = false;
                            _validateForm();
                          });
                          widget.onItemSelected(index);
                        },
                      )
                    // ★ حالة الفراغ ★
                    //
                    // كانت هنا جملة إنجليزية ثابتة تظهر للزبون العربي كما
                    // هي، ثم أُبدلت بنصّ فارغ — وذلك أسوأ: الزبون يرى مساحة
                    // بيضاء بلا سبب، ولا يعرف أن عليه كتابة اسم بنفسه.
                    //
                    // فصارت رسالة مترجَمة تقول ما وقع وما العمل.
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 8 * widget.fem,
                        ),
                        child: Text(
                          localizations.translate('no_address_names_available'),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.getFontFamily(
                            context,
                            AppTextStyles.regular16Gray80(context).copyWith(
                              fontSize: 13.0 * widget.fem,
                              fontWeight: FontWeight.w500,
                              height: 1.5,
                              color: AppColors.gray50,
                            ),
                          ),
                        ),
                      ),

                    // Add padding for the rest of the content
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          SizedBox(height: 12 * widget.fem),
                          Text(
                            localizations.translate('fill_out_location_info'),
                            style: AppTextStyles.getFontFamily(
                              context,
                              AppTextStyles.regular16Gray80(context).copyWith(
                                fontSize: 13.0 * widget.fem,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                                color: AppColors.gray50,
                              ),
                            ),
                            textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          ),
                          SizedBox(height: 16 * widget.fem),
                          if (!_isCustomName)
                            GestureDetector(
                              onTap: openNameModal,
                              child: Text(
                                localizations.translate('or_enter_custom_name'),
                                textAlign: TextAlign.center,
                                style: AppTextStyles.getFontFamily(
                                  context,
                                  AppTextStyles.bold16Gradient(
                                    context,
                                  ).copyWith(
                                    fontSize: 16.0 * widget.fem,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          if (_isCustomName && !_isFirstTime)
                            TextCustomInput(
                              controller: _addressNameController,
                              focusNode: _addressNameFocusNode,
                              labelTextPrimary: localizations.translate(
                                'address_name',
                              ),
                              fem: widget.fem,
                              onInputChange: (isValid) {
                                widget.item['addressName'] =
                                    _addressNameController.text;
                                widget.onUpdate(widget.item);
                                _validateForm();
                              },
                            ),
                          SizedBox(height: 16 * widget.fem),
                          TextCustomInput(
                            controller: _governateController,
                            focusNode: _governateFocusNode,
                            labelTextPrimary: localizations.translate(
                              'governate',
                            ),
                            fem: widget.fem,
                            isDisabled: true,
                            onInputChange: (isValid) {},
                          ),
                          SizedBox(height: 16 * widget.fem),
                          TextCustomInput(
                            controller: _areaController,
                            focusNode: _areaFocusNode,
                            labelTextPrimary: localizations.translate(
                              'select_area',
                            ),
                            fem: widget.fem,
                            isDisabled: true,
                            onInputChange: (isValid) {},
                          ),
                          SizedBox(height: 16 * widget.fem),
                          TextCustomInput(
                            controller: _streetController,
                            focusNode: _streetFocusNode,
                            labelTextPrimary: localizations.translate('street'),
                            fem: widget.fem,
                            onInputChange: (isValid) {
                              widget.item['street'] = _streetController.text;
                              widget.onUpdate(widget.item);
                              _validateForm();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate(
                                  'please_enter_street',
                                );
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16 * widget.fem),
                          TextCustomInput(
                            controller: _buildingController,
                            focusNode: _buildingFocusNode,
                            labelTextPrimary: localizations.translate(
                              'building',
                            ),
                            fem: widget.fem,
                            onInputChange: (isValid) {
                              widget.item['building'] =
                                  _buildingController.text;
                              widget.onUpdate(widget.item);
                              _validateForm();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return localizations.translate(
                                  'please_enter_building',
                                );
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16 * widget.fem),
                          TextCustomInput(
                            textInputHeight: 104.0 * widget.fem,
                            controller: _extraInfoController,
                            focusNode: _extraInfoFocusNode,
                            labelTextPrimary: localizations.translate(
                              'extra_address_info',
                            ),
                            fem: widget.fem,
                            onInputChange: (isValid) {
                              widget.item['extraInfo'] =
                                  _extraInfoController.text;
                              widget.onUpdate(widget.item);
                              _validateForm();
                            },
                          ),
                          SizedBox(height: 16 * widget.fem),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  fem: widget.fem,
                                  buttonWidth: "medium",
                                  isDisabled: !_isFormValid || _isSubmitting,
                                  text: localizations.translate('add'),
                                  onPressed:
                                      _isFormValid ? _handleSubmit : null,
                                ),
                              ),
                              SizedBox(width: 16 * widget.fem),
                              Expanded(
                                child: SecondaryButton(
                                  fem: widget.fem,
                                  buttonWidth: "medium",
                                  isDisabled: false,
                                  text: localizations.translate('cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 60 * widget.fem),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
