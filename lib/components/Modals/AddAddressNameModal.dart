import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/components/buttons/PrimaryButton.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/TextCustomInput.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class AddAddressNameModal extends StatefulWidget {
  final double fem;
  final String initialName;
  final ValueChanged<String> onNameEntered;

  const AddAddressNameModal({
    Key? key,
    required this.fem,
    required this.initialName,
    required this.onNameEntered,
  }) : super(key: key);

  @override
  _AddAddressNameModalState createState() => _AddAddressNameModalState();
}

class _AddAddressNameModalState extends State<AddAddressNameModal> {
  late TextEditingController _addressnameController;
  late FocusNode _addressnameFocusNode;

  @override
  void initState() {
    super.initState();
    _addressnameController = TextEditingController(text: widget.initialName);
    _addressnameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _addressnameController.dispose();
    _addressnameFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    widget.onNameEntered(_addressnameController.text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              TextCustomInput(
                controller: _addressnameController,
                focusNode: _addressnameFocusNode,
                labelTextPrimary:
                    localizations.translate('address_name') ?? 'Address Name',
                fem: widget.fem,
                isDisabled: false,
                onInputChange: (isValid) {},
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        fem: widget.fem,
                        buttonWidth: "medium",
                        isDisabled: false,
                        text: localizations.translate('add') ?? 'Add',
                        onPressed: _handleSubmit,
                      ),
                    ),
                    SizedBox(width: 16 * widget.fem),
                    Expanded(
                      child: SecondaryButton(
                        fem: widget.fem,
                        buttonWidth: "medium",
                        isDisabled: false,
                        text: localizations.translate('Cancel') ?? 'Cancel',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
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

void showAddAddressNameModal(BuildContext context, double fem,
    String initialName, ValueChanged<String> onNameEntered) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AddAddressNameModal(
        fem: fem,
        initialName: initialName,
        onNameEntered: onNameEntered,
      ),
    ),
  );
}
