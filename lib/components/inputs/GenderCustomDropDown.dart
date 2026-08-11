import 'package:saleem_dry_clean/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class GenderCustomDropDown extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isRequired;
  final bool isDisabled;
  final bool hasError;
  final double fem;
  final Function(bool) onInputChange;
  final String? Function(String?)? validator;

  const GenderCustomDropDown({
    Key? key,
    required this.fem,
    this.hasError = false,
    required this.controller,
    required this.focusNode,
    this.isRequired = false,
    this.isDisabled = false,
    required this.onInputChange,
    this.validator,
  }) : super(key: key);

  @override
  State<GenderCustomDropDown> createState() =>
      _GenderCustomDropDownState();
}

class _GenderCustomDropDownState extends State<GenderCustomDropDown> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleValueChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleValueChanged);
    super.dispose();
  }

  void _handleValueChanged() {
    final value = widget.controller.text;
    final isValid = widget.validator?.call(value) == null;
    if (mounted) setState(() {});
    widget.onInputChange(isValid);
  }

  bool _isSelected(String key, String translatedValue) {
    final value = widget.controller.text.trim().toLowerCase();
    return value == key ||
        value == translatedValue.toLowerCase() ||
        (key == 'male' && value == 'ذكر') ||
        (key == 'female' && value == 'أنثى');
  }

  void _select(String value) {
    if (widget.isDisabled) return;
    widget.controller.text = value;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final male = localizations.translate('male');
    final female = localizations.translate('female');

    return Focus(
      focusNode: widget.focusNode,
      child: SizedBox(
        width: 380 * widget.fem,
        height: 32 * widget.fem,
        child: Row(
          children: [
            Text(
              localizations.translate('gender'),
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 16 * widget.fem,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray50,
                ),
              ),
            ),
            const Spacer(),
            _buildChoice(
              context,
              value: 'male',
              label: male,
              selected: _isSelected('male', male),
            ),
            SizedBox(width: 22 * widget.fem),
            _buildChoice(
              context,
              value: 'female',
              label: female,
              selected: _isSelected('female', female),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoice(
    BuildContext context, {
    required String value,
    required String label,
    required bool selected,
  }) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.isDisabled ? null : () => _select(value),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 4 * widget.fem),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                selected
                    ? 'assets/Icons/checked_box.svg'
                    : 'assets/Icons/Check_box.svg',
                width: 22 * widget.fem,
                height: 22 * widget.fem,
              ),
              SizedBox(width: 8 * widget.fem),
              Text(
                label,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.bold16Gray70(context).copyWith(
                    fontSize: 16 * widget.fem,
                    fontWeight: FontWeight.w600,
                    color: widget.isDisabled
                        ? AppColors.inActiveColor
                        : AppColors.gray70,
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
