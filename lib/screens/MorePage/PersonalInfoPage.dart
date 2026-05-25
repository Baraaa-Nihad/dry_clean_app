import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/AppBar/AppHeader.dart';
import 'package:saleem_dry_clean/components/BackButtonWidget.dart';
import 'package:saleem_dry_clean/components/Cards/CustomCard.dart';
import 'package:saleem_dry_clean/components/Forms/EmailEditForm.dart';
import 'package:saleem_dry_clean/components/LoadingDots/LoadingDots.dart';
import 'package:saleem_dry_clean/components/Modals/CustomModal.dart';
import 'package:saleem_dry_clean/components/forms/NameEditForm.dart';
import 'package:saleem_dry_clean/services/Models/user.dart';
import 'package:saleem_dry_clean/services/Providers/UserProvider.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class PersonalInfoPage extends StatefulWidget {
  final double fem;
  final String userId;
  final VoidCallback onUserDataUpdated;

  const PersonalInfoPage({
    Key? key,
    required this.fem,
    required this.userId,
    required this.onUserDataUpdated,
  }) : super(key: key);

  @override
  _PersonalInfoPageState createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  late User user;
  late String emailValue;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final fetchedUser =
        await userProvider.fetchUserData(widget.userId, context);
    if (fetchedUser != null) {
      setState(() {
        user = fetchedUser;
        emailValue = user.email;
        isLoading = false;
      });
    } else {
      print('Failed to load user data');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _editEmail() {
    final emailController = TextEditingController(text: emailValue);
    final emailFocusNode = FocusNode();

    CustomModal.show(
      context,
      mainTitle: emailValue.isEmpty ? 'Add_email' : 'Edit_Your_Email',
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: EmailEditForm(
        emailController: emailController,
        emailValue: emailValue,
        emailFocusNode: emailFocusNode,
        onSave: () async {
          final newEmail = emailController.text;
          final emailRegex =
              RegExp(r"^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

          if (!emailRegex.hasMatch(newEmail)) {
            // Show an error message if the email is invalid

            return; // Cancel the save operation
          }

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          try {
            await userProvider.editUserEmail(
                newEmail, user.phoneNumber, context);
            // Refresh the user data after update
            await _loadUserData();
            // Trigger the callback to update the UI in the parent widget
            widget.onUserDataUpdated();
            Navigator.pop(context); // Close the modal
          } catch (error) {
            print('Failed to update email: $error');
            // Handle the error, e.g., show a snackbar with an error message
          }
        },
        onCancel: () {
          Navigator.pop(context);
        },
        fem: widget.fem,
      ),
    );
  }

  void _editUsername() {
    final firstNameController = TextEditingController(text: user.firstName);
    final lastNameController = TextEditingController(text: user.lastName);
    final firstNameFocusNode = FocusNode();
    final lastNameFocusNode = FocusNode();
    final localizations = AppLocalizations.of(context);

    CustomModal.show(
      context,
      mainTitle: localizations?.translate('Edit_Your_Name') ?? 'Edit Your Name',
      fem: widget.fem,
      isDisabledButton: false,
      onPrefixIconTap: () {
        Navigator.pop(context);
      },
      prefixIconPath: 'assets/vectors/close_icon.svg',
      content: NameEditForm(
        firstNameController: firstNameController,
        firstNameFocusNode: firstNameFocusNode,
        lastNameController: lastNameController,
        lastNameFocusNode: lastNameFocusNode,
        onSave: () async {
          final newFirstName = firstNameController.text;
          final newLastName = lastNameController.text;
          final phoneNumber = user.phoneNumber;

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          try {
            await userProvider.editUserName(
                newFirstName, newLastName, phoneNumber, context);
            await _loadUserData();
            widget.onUserDataUpdated();
            Navigator.pop(context);
          } catch (error) {
            print('Failed to update username: $error');
          }
        },
        onCancel: () {
          Navigator.pop(context);
        },
        fem: widget.fem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: AppColors.gray10,
      appBar: AppHeader(
        quantityNumber: false,
        prefixIcon: BackButtonWidget(
          onTap: () {
            Navigator.pop(
                context); // Correct: Passes a function that calls Navigator.pop when tapped
          },
        ),
        title: localizations?.translate('Personal_Information') ??
            'Personal Information',
        fem: widget.fem,
        onPrefixIconTap: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: LoadingDots(
                fem: widget.fem,
              ))
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomCard(
                        heightType: HeightType.big,
                        leadingIcon: true,
                        leadingIconPath: 'assets/Icons/Person.svg',
                        title: localizations?.translate('Full_name') ??
                            'Full name',
                        subtitle: '${user.firstName} ${user.lastName}',
                        trailingIcon: true,
                        trailingIconPath: 'assets/Icons/edit.svg',
                        onTap: _editUsername,
                        onTrailingIconTap: _editUsername,
                      ),
                      SizedBox(height: 16),
                      CustomCard(
                        heightType: HeightType.big,
                        leadingIcon: true,
                        leadingIconPath: 'assets/Icons/Gender.svg',
                        title: localizations?.translate('Gender') ?? 'Gender',
                        subtitle: user.gender,
                        trailingIcon: false,
                        trailingIconPath: 'assets/Icons/edit.svg',
                        onTap: () {},
                        onTrailingIconTap: () {},
                      ),
                      SizedBox(height: 16),
                      CustomCard(
                        heightType: HeightType.big,
                        leadingIcon: true,
                        leadingIconPath: 'assets/Icons/Calendar.svg',
                        title: localizations?.translate('Date_of_birth') ??
                            'Date of birth',
                        subtitle: user.dateOfBirth,
                        trailingIcon: false,
                        trailingIconPath: 'assets/Icons/edit.svg',
                        onTap: () {},
                        onTrailingIconTap: () {},
                      ),
                      SizedBox(height: 16),
                      CustomCard(
                        heightType: HeightType.big,
                        leadingIcon: true,
                        leadingIconPath: 'assets/Icons/sms.svg',
                        title: localizations?.translate('Email') ?? 'Email',
                        subtitle: emailValue.isEmpty
                            ? localizations?.translate('Add_email') ??
                                'Add email'
                            : emailValue,
                        trailingIcon: true,
                        trailingIconPath: emailValue.isEmpty
                            ? 'assets/Icons/Add.svg'
                            : 'assets/Icons/edit.svg',
                        onTap: _editEmail,
                        onTrailingIconTap: _editEmail,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
