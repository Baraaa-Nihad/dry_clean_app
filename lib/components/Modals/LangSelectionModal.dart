import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class LangSelectionModal extends StatefulWidget {
  final double fem;
  final List<String> languages;
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const LangSelectionModal({
    Key? key,
    required this.fem,
    required this.languages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  }) : super(key: key);

  static void show(BuildContext context, double fem, String selectedLanguage,
      Function(String) onLanguageSelected) {
    final localizations = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => LangSelectionModal(
        fem: fem,
        languages: [
          'en', // English
          'ar', // Arabic
          // Add more languages as needed
        ],
        selectedLanguage: selectedLanguage,
        onLanguageSelected: onLanguageSelected,
      ),
      isScrollControlled: true, // Allow full-screen height
    );
  }

  @override
  _LangSelectionModalState createState() => _LangSelectionModalState();
}

class _LangSelectionModalState extends State<LangSelectionModal> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.selectedLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(24.0 * widget.fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16.0 * widget.fem)),
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2.0 * widget.fem),
        ),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56 * widget.fem,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  'assets/vectors/close_icon.svg',
                  width: 48.0 * widget.fem,
                  height: 48.0 * widget.fem,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Spacer(),
              Text(localizations?.translate('app_language') ?? 'App Language',
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray70,
                    ),
                  )),
              Spacer(flex: 2),
            ],
          ),
          SizedBox(height: 16.0 * widget.fem),
          Expanded(
            child: ListView.builder(
              itemCount: widget.languages.length,
              itemBuilder: (context, index) {
                final language = widget.languages[index];
                final isSelected = language == _selectedLanguage;
                final languageName = language == 'ar' ? 'العربية' : 'English';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    widget.onLanguageSelected(language);
                  },
                  child: _buildLanguageItem(
                    context,
                    languageName,
                    isSelected,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16.0 * widget.fem),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(
      BuildContext context, String language, bool isSelected) {
    return Container(
      height: 48.0 * widget.fem,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.stroke, width: 1.0 * widget.fem),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0 * widget.fem),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              language,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.bold16Gray70(context).copyWith(
                  fontSize: 16.0 * widget.fem,
                ),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          isSelected
              ? SvgPicture.asset(
                  'assets/Icons/checked_box.svg',
                  width: 24.0 * widget.fem,
                  height: 24.0 * widget.fem,
                )
              : SvgPicture.asset(
                  'assets/Icons/Check_box.svg',
                  width: 24.0 * widget.fem,
                  height: 24.0 * widget.fem,
                ),
        ],
      ),
    );
  }
}
