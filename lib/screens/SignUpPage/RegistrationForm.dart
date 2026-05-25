import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/buttons/LoadingButton.dart';
import 'package:saleem_dry_clean/components/inputs/CustomDropDown.dart';
import 'package:saleem_dry_clean/components/inputs/GenderCustomDropDown.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/services/Providers/sign_up_provider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({Key? key}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool isButtonDisabled = true;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _dobController =
      TextEditingController(); // Date of birth controller
  final TextEditingController _genderController =
      TextEditingController(); // Gender controller

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _areaFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _repeatPasswordFocusNode = FocusNode();
  final FocusNode _dobFocusNode = FocusNode(); // Date of birth focus node
  final FocusNode _genderFocusNode = FocusNode(); // Gender focus node

  String? _selectedAreaId; // Store the selected area ID

  late ScrollController _scrollController;
  bool _isScrolled = false;
  bool _isPasswordVisible = false;
  bool _isRepeatPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _areaController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _repeatPasswordController.addListener(_validateForm);
    _dobController.addListener(_validateForm); // Add listener for date of birth
    _genderController.addListener(_validateForm); // Add listener for gender

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (!_isScrolled) {
          setState(() {
            _isScrolled = true;
          });
        }
      } else {
        if (_isScrolled) {
          setState(() {
            _isScrolled = false;
          });
        }
      }
    });

    _loadMobileNumber();
  }

  Future<void> _loadMobileNumber() async {
    final prefs = await SharedPreferences.getInstance();
    String mobileNumber = prefs.getString('mobileNumber') ?? '';
    if (!mobileNumber.startsWith('+')) {
      mobileNumber = '+$mobileNumber';
    }
    setState(() {
      _mobileController.text = mobileNumber;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _areaController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _dobController.dispose(); // Dispose date of birth controller
    _genderController.dispose(); // Dispose gender controller
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _areaFocusNode.dispose();
    _passwordFocusNode.dispose();
    _repeatPasswordFocusNode.dispose();
    _dobFocusNode.dispose(); // Dispose date of birth focus node
    _genderFocusNode.dispose(); // Dispose gender focus node
    _scrollController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isButtonDisabled = _firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _repeatPasswordController.text.isEmpty ||
          _passwordController.text != _repeatPasswordController.text ||
          _passwordController.text.length < 8 ||
          _dobController.text.isEmpty ||
          _genderController
              .text.isEmpty; // Validate date of birth and gender fields
    });
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      final formData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'area': _selectedAreaId ?? '', // Use the area ID here
        'mobile': _mobileController.text,
        'password': _passwordController.text,
        'dob': _dobController.text,
        'gender': _genderController.text,
      };
      final provider = Provider.of<SignUpProvider>(context, listen: false);
      final language = Localizations.localeOf(context).languageCode;

      await provider.submitRegistrationForm(formData, language, context);
    }
  }

  void _unfocusAll() {
    _firstNameFocusNode.unfocus();
    _lastNameFocusNode.unfocus();
    _areaFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _repeatPasswordFocusNode.unfocus();
    _dobFocusNode.unfocus(); // Unfocus date of birth focus node
    _genderFocusNode.unfocus(); // Unfocus gender focus node
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    double fem = MediaQuery.of(context).size.width / 428;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: _unfocusAll,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SafeArea(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 24 * fem,
                            right: 24 * fem,
                            bottom: 24 * fem,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 116), // Space for the app bar
                                Text(
                                  localizations
                                          ?.translate('enter_your_details') ??
                                      'Enter your details',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.bold16Gray80(context)
                                        .copyWith(
                                      fontSize: 24.0 * fem,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8 * fem),
                                Text(
                                  localizations?.translate(
                                          'better_laundry_experience') ??
                                      'Enter your details for better laundry experience!',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray50(context)
                                        .copyWith(
                                      fontSize: 13.0 * fem,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40 * fem), // Increased gap
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: isRtl
                                              ? 0.0
                                              : 6.0, // Half of the desired padding
                                          left: isRtl
                                              ? 6.0
                                              : 0.0, // Half of the desired padding
                                        ),
                                        child: TextCustomInput(
                                          controller: _firstNameController,
                                          focusNode: _firstNameFocusNode,
                                          labelTextPrimary: localizations
                                                  ?.translate('first_name') ??
                                              'First name',
                                          fem: fem,
                                          onInputChange: (isValid) {
                                            _validateForm();
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return localizations?.translate(
                                                      'please_enter_first_name') ??
                                                  'Please enter your first name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: isRtl
                                              ? 0.0
                                              : 6.0, // Half of the desired padding
                                          right: isRtl
                                              ? 6.0
                                              : 0.0, // Half of the desired padding
                                        ),
                                        child: TextCustomInput(
                                          controller: _lastNameController,
                                          focusNode: _lastNameFocusNode,
                                          labelTextPrimary: localizations
                                                  ?.translate('last_name') ??
                                              'Last name',
                                          fem: fem,
                                          onInputChange: (isValid) {
                                            _validateForm();
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return localizations?.translate(
                                                      'please_enter_last_name') ??
                                                  'Please enter your last name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16 * fem),
                                TextCustomInput(
                                  controller: TextEditingController(
                                    text: localizations
                                            ?.translate('Ramallah&Al-Bireh') ??
                                        'Ramallah & Al-Bireh',
                                  ),
                                  focusNode: FocusNode(),
                                  labelTextPrimary:
                                      localizations?.translate('governate') ??
                                          'Governate',
                                  fem: fem,
                                  isDisabled: true,
                                  onInputChange: (isValid) {},
                                ),
                                SizedBox(height: 16 * fem),
                                CustomDropDown(
                                  fem: 1.0,
                                  controller: _areaController,
                                  focusNode: _areaFocusNode,
                                  onInputChange: (isValid) {
                                    // Handle input change
                                  },
                                  onAreaIdChange: (areaId) {
                                    _selectedAreaId = areaId;
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations?.translate(
                                              'please_select_area') ??
                                          'Please select an area';
                                    }
                                    return null;
                                  },
                                ),
                                // SizedBox(height: 16 * fem),
                                // TextCustomInput(
                                //   controller: _mobileController,
                                //   focusNode: FocusNode(),
                                //   labelTextPrimary: localizations
                                //           ?.translate('mobile_number') ??
                                //       'Mobile Number',
                                //   fem: fem,
                                //   isDisabled: true,
                                //   onInputChange: (isValid) {},
                                // ),
                                SizedBox(height: 16 * fem),
                                GenderCustomDropDown(
                                  fem: fem,
                                  controller: _genderController,
                                  focusNode: _genderFocusNode,
                                  onInputChange: (isValid) {
                                    _validateForm();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations?.translate(
                                              'please_select_gender') ??
                                          'Please select your gender';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16 * fem),
                                TextCustomInput(
                                  controller: _dobController,
                                  focusNode: _dobFocusNode,
                                  labelTextPrimary: localizations
                                          ?.translate('date_of_birth') ??
                                      'Date of Birth',
                                  fem: fem,
                                  inputType: InputType.date,
                                  onInputChange: (isValid) {
                                    _validateForm();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations
                                              ?.translate('please_enter_dob') ??
                                          'Please enter your date of birth';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16 * fem),
                                TextCustomInput(
                                  controller: _passwordController,
                                  focusNode: _passwordFocusNode,
                                  labelTextPrimary:
                                      localizations?.translate('password') ??
                                          'Password',
                                  fem: fem,
                                  inputType: _isPasswordVisible
                                      ? InputType.text
                                      : InputType.password,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      _isPasswordVisible
                                          ? 'assets/vectors/textPassword.svg'
                                          : 'assets/vectors/showPassword.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  onInputChange: (isValid) {
                                    _validateForm();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations?.translate(
                                              'please_enter_password') ??
                                          'Please enter a password';
                                    } else if (value.length < 8) {
                                      return localizations
                                              ?.translate('password_length') ??
                                          'Password must be at least 8 characters';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16 * fem),
                                TextCustomInput(
                                  controller: _repeatPasswordController,
                                  focusNode: _repeatPasswordFocusNode,
                                  inputType: _isRepeatPasswordVisible
                                      ? InputType.text
                                      : InputType.password,
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isRepeatPasswordVisible =
                                            !_isRepeatPasswordVisible;
                                      });
                                    },
                                    child: SvgPicture.asset(
                                      _isRepeatPasswordVisible
                                          ? 'assets/vectors/textPassword.svg'
                                          : 'assets/vectors/showPassword.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                  labelTextPrimary: localizations
                                          ?.translate('repeat_password') ??
                                      'Repeat password',
                                  fem: fem,
                                  onInputChange: (isValid) {
                                    _validateForm();
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return localizations?.translate(
                                              'please_repeat_password') ??
                                          'Please repeat your password';
                                    } else if (value !=
                                        _passwordController.text) {
                                      return localizations?.translate(
                                              'passwords_do_not_match') ??
                                          'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 8 * fem),
                                Align(
                                  alignment: isRtl
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Directionality(
                                    textDirection: isRtl
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: Text(
                                      localizations?.translate(
                                              'password_requirement') ??
                                          '• Password must be at least 8 characters',
                                      style: AppTextStyles.getFontFamily(
                                        context,
                                        AppTextStyles.regular16Gray80(context)
                                            .copyWith(
                                          fontSize: 14.0 * fem,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  color: AppColors
                                      .transparent, // Make the background transparent
                                  child: Column(
                                    children: [
                                      SizedBox(height: 60 * fem),
                                      Container(
                                        width: double.infinity,
                                        child: LoadingButton(
                                          fem: fem,
                                          buttonText: localizations?.translate(
                                                  'create_account') ??
                                              'Create account',
                                          onPressed: isButtonDisabled
                                              ? null
                                              : _handleContinue,
                                          isDisabled: isButtonDisabled,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: -245 * fem,
              right: -161 * fem,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 428 * fem,
                  height: 428 * fem,
                  decoration: ShapeDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [AppColors.green, AppColors.blue.withOpacity(0)],
                      stops: [0.5, 1.0],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              top: _isScrolled ? -80.0 : 56.0,
              left: isRtl ? null : 0,
              right: isRtl ? 0 : null,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.transparent,
                ),
                child: IconButton(
                  icon: SvgPicture.asset(
                    isRtl
                        ? 'assets/vectors/backRightArrow.svg'
                        : 'assets/vectors/backLeftArrow.svg',
                    width: 80,
                    height: 80,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Positioned(
              bottom: -20 * fem,
              left: -20 * fem,
              child: Opacity(
                opacity: 0.05,
                child: Container(
                  width: 104 * fem,
                  height: 104,
                  decoration: ShapeDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.5,
                      colors: [AppColors.green, AppColors.blue.withOpacity(0)],
                      stops: [0.5, 1.0],
                    ),
                    shape: OvalBorder(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
