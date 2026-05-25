import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

class ServiceRow extends StatefulWidget {
  final String serviceName;
  final double price;
  final String pricePerUnit;
  final double fem;
  final void Function(int, String) onValueChange;

  const ServiceRow({
    Key? key,
    required this.serviceName,
    required this.price,
    required this.pricePerUnit,
    required this.fem,
    required this.onValueChange,
  }) : super(key: key);

  @override
  _ServiceRowState createState() => _ServiceRowState();
}

class _ServiceRowState extends State<ServiceRow> {
  int quantity = 0;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Simulate data loading process
  void _loadData() async {
    // Simulating a data load with a Future, you can replace this with your actual data fetching logic
    await Future.delayed(Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isDataLoaded = true;
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      quantity++;
      widget.onValueChange(1, widget.serviceName);
    });
  }

  void _decrementQuantity() {
    if (quantity > 0) {
      setState(() {
        quantity--;
        widget.onValueChange(-1, widget.serviceName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return _isDataLoaded
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceName,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray70,
                        ),
                      ),
                    ),
                    Text(
                      '₪${widget.price} / ${localizations.translate(widget.pricePerUnit)}',
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                          height: 2.1,
                          color: AppColors.gray60,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr, // Force LTR
                child: Row(
                  children: [
                    IconButton(
                      onPressed: quantity > 0 ? _decrementQuantity : null,
                      icon: SvgPicture.asset(
                        quantity > 0
                            ? 'assets/vectors/decrease_icon_active.svg'
                            : 'assets/vectors/decrease_icon.svg',
                        width: 40 * widget.fem,
                        height: 40 * widget.fem,
                      ),
                      color: quantity > 0 ? AppColors.gray70 : AppColors.gray40,
                    ),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Color(0xFFE5EAF6)),
                      ),
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Center(
                            child: Text(
                              quantity.toString(),
                              style: AppTextStyles.getFontFamily(
                                context,
                                AppTextStyles.regular16Gray40(context).copyWith(
                                  color: quantity > 0
                                      ? AppColors.gray70
                                      : AppColors.gray40,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _incrementQuantity,
                      icon: SvgPicture.asset(
                        'assets/vectors/increase_icon.svg',
                        width: 40 * widget.fem,
                        height: 40 * widget.fem,
                      ),
                      color: AppColors.gray70,
                    ),
                  ],
                ),
              )
            ],
          )
        : Shimmer.fromColors(
            baseColor: AppColors.gray10!,
            highlightColor: AppColors.gray20!,
            child: Container(
              height: 56, // Set the height of the shimmer row
              width: double.infinity, // Span the full width
              margin: EdgeInsets.symmetric(vertical: 8.0), // Optional spacing
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
  }
}
