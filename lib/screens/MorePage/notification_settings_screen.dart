import 'package:saleem_dry_clean/ui.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/AccountExtrasProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

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
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          localizations.translate('notification_settings'),
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.sfarabicBold.copyWith(
              fontSize: 16.5,
              color: AppColors.gray80,
            ),
          ),
        ),
      ),
      body: p.isLoadingPrefs
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green),
            )
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
                      localizations.translate(p.prefsError!),
                      style: AppTextStyles.getFontFamily(
                        context,
                        AppTextStyles.sfarabicMedium.copyWith(
                          fontSize: 12.5,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                _SectionTitle(localizations.translate('more_what_reaches_you')),
                _Group(
                  children: [
                    _PrefSwitch(
                      title: localizations.translate('more_order_status'),
                      subtitle: localizations.translate(
                        'more_order_status_hint',
                      ),
                      value: prefs.orderUpdates,
                      onChanged: (v) => context
                          .read<AccountExtrasProvider>()
                          .togglePref('orderUpdates', v),
                    ),
                    _PrefSwitch(
                      title: localizations.translate('more_driver_updates'),
                      subtitle: localizations.translate(
                        'more_driver_updates_hint',
                      ),
                      value: prefs.driverUpdates,
                      onChanged: (v) => context
                          .read<AccountExtrasProvider>()
                          .togglePref('driverUpdates', v),
                    ),
                    _PrefSwitch(
                      title: localizations.translate('more_offers_messages'),
                      subtitle: localizations.translate(
                        'more_offers_messages_hint',
                      ),
                      value: prefs.promotions,
                      onChanged: (v) => context
                          .read<AccountExtrasProvider>()
                          .togglePref('promotions', v),
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                _SectionTitle(
                  localizations.translate('more_how_it_reaches_you'),
                ),
                _Group(
                  children: [
                    _PrefSwitch(
                      title: localizations.translate('more_push_notifications'),
                      subtitle: localizations.translate(
                        'more_push_notifications_hint',
                      ),
                      value: prefs.pushEnabled,
                      onChanged: (v) => context
                          .read<AccountExtrasProvider>()
                          .togglePref('pushEnabled', v),
                    ),
                    _PrefSwitch(
                      title: localizations.translate('more_sms_messages'),
                      subtitle: localizations.translate(
                        'more_sms_messages_hint',
                      ),
                      value: prefs.smsEnabled,
                      onChanged: (v) => context
                          .read<AccountExtrasProvider>()
                          .togglePref('smsEnabled', v),
                      isLast: true,
                    ),
                  ],
                ),
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
    padding: const EdgeInsetsDirectional.only(bottom: 10, start: 4),
    child: Text(
      text,
      style: AppTextStyles.getFontFamily(
        context,
        AppTextStyles.sfarabicBold.copyWith(
          fontSize: 14,
          color: AppColors.gray70,
        ),
      ),
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
          activeThumbColor: AppColors.green,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          title: Text(
            title,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.sfarabicMedium.copyWith(
                fontSize: 14.5,
                color: AppColors.gray80,
              ),
            ),
          ),
          subtitle: Text(
            subtitle,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, thickness: 1, color: AppColors.stroke),
      ],
    );
  }
}
