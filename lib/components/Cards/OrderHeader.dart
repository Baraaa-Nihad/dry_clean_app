import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/orderService/OrderData.dart';
import 'package:saleem_dry_clean/components/Badgs/StatusBadge.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/ValidationUtils.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart'; // Import the localization utility

class OrderHeader extends StatelessWidget {
  final OrderData order;
  final bool isDelayed;

  const OrderHeader({
    Key? key,
    required this.order,
    this.isDelayed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Container(
      height: 62,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: AppColors.gray20),
        ),
      ),
      child: Row(
        children: [
          // اللون من الخادم — والشارة تسقط إلى جدولها المحلي إن غاب
          StatusBadge(status: order.status, serverColor: order.statusColor),
          const SizedBox(width: 12),
          if (isDelayed)
            Expanded(
              child: Text(
                localizations.translate('delayed'),
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.regular16Gray80(context).copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.orangeCard),
                ),
              ),
            ),
          // اسم المغسلة (٢.١.٥).
          //
          // الزبون قد يكون له ثلاثة طلبات من ثلاث مغاسل في وقت واحد،
          // وبلا الاسم لا شيء على البطاقة يميّزها — يفتح التفاصيل ليعرف
          // أيّها من أين.
          if (!isDelayed && (order.drycleanName ?? '').isNotEmpty)
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined,
                      size: 15, color: AppColors.secondaryTextColor),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      order.drycleanName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.regular16Gray80(context).copyWith(
                          fontSize: 12.5,
                          color: AppColors.secondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Spacer(),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              NavigatorService.navigateToAndRemoveUntil(
                RouteNames.BasketDetails,
                arguments: {'order': order},
              );
            },
            child: SvgPicture.asset('assets/Icons/Details.svg'),
          ),
        ],
      ),
    );
  }
}
