import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/ServiceTypeProvider.dart';

class CustomSearchBar extends StatefulWidget {
  final double fem;
  final String serviceTypeId;
  final ValueChanged<bool> onSearchStatusChanged; // Add this callback

  const CustomSearchBar({
    Key? key,
    required this.fem,
    required this.serviceTypeId,
    required this.onSearchStatusChanged, // Add this required parameter
  }) : super(key: key);

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    // Delay execution by 500 milliseconds (0.5 seconds)
    _debounce = Timer(Duration(milliseconds: 500), () {
      final serviceTypeProvider =
          Provider.of<ServiceTypeProvider>(context, listen: false);

      if (query.isEmpty) {
        // If the search bar is cleared, fetch all data and set search state to false
        widget.onSearchStatusChanged(false); // Notify no search is active
        serviceTypeProvider.fetchServiceTypes(widget.serviceTypeId);
      } else if (query.length >= 3) {
        // Start search when query has 3 or more characters
        widget.onSearchStatusChanged(true); // Notify search is active
        serviceTypeProvider.searchProducts(query);
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      height: 56, // Set the height to 56

      padding: EdgeInsets.symmetric(
          horizontal: 16 * widget.fem, vertical: 8 * widget.fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * widget.fem),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: AppTextStyles.getFontFamily(
                context,
                AppTextStyles.bold16Gray80(context).copyWith(
                  fontSize: 14.0 * widget.fem,
                ),
              ),
              onChanged: _onSearchChanged,
              textAlignVertical:
                  TextAlignVertical.center, // Align the text vertically

              decoration: InputDecoration(
                hintText: localizations.translate('search'),
                border: InputBorder.none,
                hintStyle: AppTextStyles.regular16Gray80(context).copyWith(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray50,
                ),
              ),
            ),
          ),
          SizedBox(width: 8 * widget.fem),
          SvgPicture.asset(
            'assets/Icons/Search.svg',
            width: 24 * widget.fem,
            height: 24 * widget.fem,
            color: AppColors.gray70,
          ),
        ],
      ),
    );
  }
}
