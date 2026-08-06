import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/AccountExtrasProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// إعدادات الإشعارات (٢.١.٨).
///
/// ★ لماذا مفاتيح منفصلة لا مفتاح واحد ★
///
/// الزبون يريد أن يعرف أين طلبه، ولا يريد إعلاناً كل يوم. ومفتاح واحد
/// يجعله يطفئ الاثنين معاً — فيفوته إشعار وصول السائق ويتصل بالدعم
/// يسأل عن غسيله.
///
/// والمفاتيح الثلاثة المعتمدة: حالة الطلب، العروض، رسائل الإدارة.
/// وقناتا الإرسال معها لأن من لا يريد إشعاراً أصلاً يطفئ القناة.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountExtrasProvider>().loadPrefs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AccountExtrasProvider>();
    final prefs = p.prefs;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          'إعدادات الإشعارات',
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 16.5, color: AppColors.gray80),
        ),
      ),
      body: p.isLoadingPrefs
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              children: [
                if (p.prefsError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorBackground,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.errorBorder),
                    ),
                    child: Text(
                      p.prefsError!,
                      style: AppTextStyles.sfarabicMedium
                          .copyWith(fontSize: 12.5, color: AppColors.red),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                _SectionTitle('ما الذي يصلك'),
                _Group(children: [
                  _PrefSwitch(
                    title: 'حالة الطلب',
                    subtitle: 'عند انتقال طلبك من مرحلة إلى أخرى',
                    value: prefs.orderUpdates,
                    onChanged: (v) => context
                        .read<AccountExtrasProvider>()
                        .togglePref('orderUpdates', v),
                  ),
                  _PrefSwitch(
                    title: 'حركة السائق',
                    subtitle: 'عند تعيين سائق أو خروجه إليك',
                    value: prefs.driverUpdates,
                    onChanged: (v) => context
                        .read<AccountExtrasProvider>()
                        .togglePref('driverUpdates', v),
                  ),
                  _PrefSwitch(
                    title: 'العروض والرسائل',
                    subtitle: 'خصومات المغاسل ورسائل إدارة سليم',
                    value: prefs.promotions,
                    onChanged: (v) => context
                        .read<AccountExtrasProvider>()
                        .togglePref('promotions', v),
                    isLast: true,
                  ),
                ]),

                const SizedBox(height: 22),
                _SectionTitle('كيف يصلك'),
                _Group(children: [
                  _PrefSwitch(
                    title: 'إشعارات التطبيق',
                    subtitle: 'تظهر على شاشة هاتفك',
                    value: prefs.pushEnabled,
                    onChanged: (v) => context
                        .read<AccountExtrasProvider>()
                        .togglePref('pushEnabled', v),
                  ),
                  _PrefSwitch(
                    title: 'رسائل نصّية',
                    subtitle: 'تصلك رسالة SMS — قد تُحتسب من رصيدك',
                    value: prefs.smsEnabled,
                    onChanged: (v) => context
                        .read<AccountExtrasProvider>()
                        .togglePref('smsEnabled', v),
                    isLast: true,
                  ),
                ]),
              ],
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: Text(
          text,
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 14, color: AppColors.gray70),
        ),
      );
}

class _Group extends StatelessWidget {
  const _Group({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: children),
      );
}

class _PrefSwitch extends StatelessWidget {
  const _PrefSwitch({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.green,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          title: Text(
            title,
            style: AppTextStyles.sfarabicMedium
                .copyWith(fontSize: 14.5, color: AppColors.gray80),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12, color: AppColors.secondaryTextColor),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: AppColors.stroke),
      ],
    );
  }
}
