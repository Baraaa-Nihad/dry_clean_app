import 'package:saleem_dry_clean/ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/damage_claim_sheet.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/delivery_confirmation_dialog.dart';
import 'package:saleem_dry_clean/screens/OrdersPage/rating_sheet.dart';
import 'package:saleem_dry_clean/services/Models/OrderTracking.dart';
import 'package:saleem_dry_clean/services/Providers/OrderTrackingProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/theme/AppIcons.dart';
import 'package:url_launcher/url_launcher.dart';

/// تتبّع الطلب — أين وصل، ومتى، وماذا بقي.
///
/// ★ لماذا خطّ زمني لا حالة واحدة ★
///
/// كانت الشاشة تعرض الحالة الحالية وحدها، والزبون يسأل «متى استُلم؟»
/// فلا يجد جواباً. والخطّ الزمني يجيب سؤالين معاً: أين الطلب الآن، وكم
/// استغرقت كل مرحلة — وهذا ما يخفّف مكالمات الدعم.
///
/// والمراحل تأتي من الخادم بتسمية الزبون: نفس الحالة اسمها عند المحل
/// شيء وعند السائق شيء آخر.
class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.orderNumber,
    this.storeName,
    this.total,
    this.pricePending = false,
  });

  final int orderId;

  /// رقم الطلب المعروض للزبون — قد يختلف عن المعرّف الداخلي
  final String? orderNumber;

  /// يظهران في حوار تأكيد الاستلام كي يعرف الزبون أي طلب يؤكّد
  final String? storeName;
  final double? total;
  final bool pricePending;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  /// يُطرح مرّة واحدة في عمر الشاشة — لا عند كل إعادة بناء
  bool _askedToConfirm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<OrderTrackingProvider>().load(widget.orderId);
      _maybeAskConfirmation();
    });
  }

  /// سؤال «هل استلمت طلبك؟».
  ///
  /// ★ لماذا يُطرح هنا ★
  ///
  /// القرار المعتمد: إشعار + بوب أب بزرّين. والإشعار يقود إلى هذه
  /// الشاشة، فهي مكان السؤال. ولمن لا يجيب مهلة أربع وعشرين ساعة ثم
  /// تأكيد تلقائي من مهمة خلفية — فالسؤال فرصة اعتراض لا بوّابة إجبار.
  Future<void> _maybeAskConfirmation() async {
    if (_askedToConfirm || !mounted) return;

    final t = context.read<OrderTrackingProvider>().trackingOf(widget.orderId);
    if (t == null || !t.needsConfirmation) return;

    _askedToConfirm = true;

    final answered = await showDeliveryConfirmationDialog(
      context,
      orderId: widget.orderId,
      orderNumber: widget.orderNumber,
      storeName: widget.storeName,
      total: widget.total,
      pricePending: widget.pricePending,
    );

    // أجاب ⇐ نعيد الجلب: التقييم يفتح بعد التأكيد، والحالة تغيّرت
    if (answered != null && mounted) {
      await context
          .read<OrderTrackingProvider>()
          .load(widget.orderId, force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderTrackingProvider>();
    final tracking = p.trackingOf(widget.orderId);
    final loading = p.isLoading(widget.orderId);
    final error = p.errorOf(widget.orderId);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          widget.orderNumber == null
              ? 'تتبّع الطلب'
              : 'الطلب ${widget.orderNumber}',
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 16.5, color: AppColors.gray80),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.green,
        onRefresh: () => context
            .read<OrderTrackingProvider>()
            .load(widget.orderId, force: true),
        child: _buildBody(tracking, loading, error),
      ),
    );
  }

  Widget _buildBody(OrderTracking? t, bool loading, String? error) {
    if (loading && t == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.green));
    }

    if (t == null) {
      // ListView لا Center: RefreshIndicator يحتاج ابناً قابلاً للتمرير
      // كي يعمل السحب للتحديث في حالة الخطأ أيضاً
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 80),
          Icon(Icons.error_outline,
              size: 54, color: AppColors.secondaryTextColor),
          const SizedBox(height: 14),
          Text(
            error ?? 'تعذّر جلب حالة الطلب',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 15, color: AppColors.gray80),
          ),
          const SizedBox(height: 6),
          Text(
            'اسحب للأسفل لإعادة المحاولة',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12.5, color: AppColors.secondaryTextColor),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _CurrentCard(tracking: t),
        // بطاقة السائق (٢.١.٥) — تحت الحالة مباشرة لأنها جواب السؤال
        // الثاني بعد «أين طلبي»: «مين جاي؟»
        if (t.driver != null) ...[
          const SizedBox(height: 12),
          _DriverCard(driver: t.driver!),
        ],
        const SizedBox(height: 18),
        if (t.history.isNotEmpty) ...[
          Text(
            'مسار الطلب',
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 15, color: AppColors.gray80),
          ),
          const SizedBox(height: 12),
          _Timeline(steps: t.history, cancelled: t.isCancelled),
        ],
        if (t.isFinished && !t.isCancelled) ...[
          const SizedBox(height: 20),
          _AfterDeliveryActions(orderId: widget.orderId),
        ],
      ],
    );
  }
}

/// بطاقة الحالة الحالية — أكبر عنصر في الشاشة لأنه جواب السؤال الأول.
class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.tracking});
  final OrderTracking tracking;

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(tracking.current.color) ?? AppColors.green;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              // لون الحالة بشفافية بدل لون ثابت: الإدارة تضبط ألوان
              // الحالات، فتتبعها الشاشة بدل أن تخالفها
              color: color.withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconFor(tracking.current.code), color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'حالة الطلب الآن',
                  style: AppTextStyles.sfarabicRegular.copyWith(
                      fontSize: 12, color: AppColors.secondaryTextColor),
                ),
                const SizedBox(height: 3),
                Text(
                  tracking.current.name,
                  style: AppTextStyles.sfarabicBold
                      .copyWith(fontSize: 17, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة السائق: اسمه وتقييمه وزرّ اتصال وموقعه على الخريطة.
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver});
  final TrackingDriver driver;

  Future<void> _call(BuildContext context) async {
    final phone = driver.phone;
    if (phone == null || phone.isEmpty) return;

    final uri = Uri(scheme: 'tel', path: phone);
    // canLaunchUrl قبل النداء: جهاز بلا تطبيق اتصال (جهاز لوحي) يرمي
    // استثناءً لا يفهمه الزبون
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'رقم السائق: $phone',
            style: AppTextStyles.sfarabicMedium.copyWith(color: AppColors.white),
          ),
        ),
      );
    }
  }

  Future<void> _openMap() async {
    if (!driver.hasLocation) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${driver.latitude},${driver.longitude}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.blueCardBackgourd,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.blueCard, size: 24),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      driver.isPickup
                          ? 'سائق الاستلام'
                          : 'سائق التوصيل',
                      style: AppTextStyles.sfarabicRegular.copyWith(
                          fontSize: 11.5,
                          color: AppColors.secondaryTextColor),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            driver.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.sfarabicBold.copyWith(
                                fontSize: 15.5, color: AppColors.gray80),
                          ),
                        ),
                        if (driver.rating != null && driver.rating! > 0) ...[
                          const SizedBox(width: 7),
                          SvgPicture.asset(AppIcons.ratingStar,
                              width: 15, height: 15),
                          const SizedBox(width: 2),
                          Text(
                            driver.rating!.toStringAsFixed(1),
                            style: AppTextStyles.poppinsMedium.copyWith(
                                fontSize: 12.5, color: AppColors.gray60),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if ((driver.phone ?? '').isNotEmpty)
                Material(
                  color: AppColors.green,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => _call(context),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.call,
                          size: 20, color: AppColors.white),
                    ),
                  ),
                ),
            ],
          ),
          if (driver.hasLocation) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 1, color: AppColors.stroke),
            const SizedBox(height: 6),
            InkWell(
              onTap: _openMap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.my_location,
                        size: 17, color: AppColors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تتبّع موقع السائق',
                        style: AppTextStyles.sfarabicMedium.copyWith(
                            fontSize: 13.5, color: AppColors.green),
                      ),
                    ),
                    // عمر التحديث معروض: «منذ ٤ دقائق» تجعل الزبون
                    // يفهم لماذا لم تتحرّك النقطة
                    Text(
                      _ageLabel(driver.locationAgeSeconds),
                      style: AppTextStyles.sfarabicRegular.copyWith(
                          fontSize: 11,
                          color: AppColors.secondaryTextColor),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _ageLabel(int? seconds) {
    if (seconds == null) return '';
    if (seconds < 60) return 'الآن';
    final m = (seconds / 60).round();
    return 'منذ $m ${m == 1 ? "دقيقة" : "دقائق"}';
  }
}

/// الخطّ الزمني — دائرة لكل مرحلة يصلها خطّ رأسي.
class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps, required this.cancelled});

  final List<TrackingStep> steps;
  final bool cancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;
          // آخر مرحلة في طلب ملغى تُلوَّن بالأحمر: الأخضر على «أُلغي»
          // يقرأ كنجاح
          final color = isLast && cancelled
              ? AppColors.red
              : (_parseColor(step.color) ?? AppColors.green);

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 3),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withAlpha(60), width: 3),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          color: AppColors.stroke,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 12 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.name,
                          style: AppTextStyles.sfarabicMedium.copyWith(
                              fontSize: 14, color: AppColors.gray80),
                        ),
                        if (step.at != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            _formatAt(step.at!),
                            style: AppTextStyles.sfarabicRegular.copyWith(
                              fontSize: 11.5,
                              color: AppColors.secondaryTextColor,
                            ),
                          ),
                        ],
                        if (step.by != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'بواسطة ${step.by}',
                            style: AppTextStyles.sfarabicRegular.copyWith(
                              fontSize: 11,
                              color: AppColors.inactiveColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// ما بعد التسليم: التقييم والإبلاغ عن تلف.
///
/// لا يظهران قبل الاستلام — تقييم طلب لم يصل بلا معنى، ومطالبة تلف على
/// غسيل لم يُسلَّم لا يمكن فحصها.
class _AfterDeliveryActions extends StatelessWidget {
  const _AfterDeliveryActions({required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<OrderTrackingProvider>();
    final ratable = p.ratableOf(orderId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ratable != null && ratable.targets.isNotEmpty) ...[
          Text(
            'تقييمك',
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 15, color: AppColors.gray80),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < ratable.targets.length; i++) ...[
                  if (i > 0)
                    const Divider(
                        height: 1, thickness: 1, color: AppColors.stroke),
                  _RatableRow(
                    orderId: orderId,
                    target: ratable.targets[i],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        OutlinedButton.icon(
          onPressed: () => showDamageClaimSheet(context, orderId: orderId),
          icon: const Icon(Icons.report_gmailerrorred_outlined,
              size: 19, color: AppColors.red),
          label: Text(
            'الإبلاغ عن تلف أو فقدان',
            style: AppTextStyles.sfarabicMedium
                .copyWith(fontSize: 13.5, color: AppColors.red),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: AppColors.red),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13)),
          ),
        ),
      ],
    );
  }
}

class _RatableRow extends StatelessWidget {
  const _RatableRow({required this.orderId, required this.target});

  final int orderId;
  final RatableTarget target;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        target.type == 'dryclean'
            ? Icons.local_laundry_service_outlined
            : Icons.delivery_dining_outlined,
        color: target.rated ? AppColors.green : AppColors.secondaryTextColor,
      ),
      title: Text(
        target.label,
        style: AppTextStyles.sfarabicMedium
            .copyWith(fontSize: 14, color: AppColors.gray80),
      ),
      subtitle: Text(
        target.rated ? 'شكراً، تقييمك مسجّل' : target.question,
        style: AppTextStyles.sfarabicRegular.copyWith(
          fontSize: 11.5,
          color: target.rated
              ? AppColors.green
              : AppColors.secondaryTextColor,
        ),
      ),
      trailing: target.rated
          ? const Icon(Icons.check_circle, color: AppColors.green, size: 21)
          : const Icon(Icons.chevron_left, color: AppColors.inactiveColor),
      // الجهة المقيَّمة لا تُفتح ثانية: الخادم يرفض التكرار، وفتح الشاشة
      // ثم رفض الإرسال إحباط بلا سبب
      onTap: target.rated
          ? null
          : () => showRatingSheet(context, orderId: orderId, target: target),
    );
  }
}

// ── مساعدات مشتركة ────────────────────────────────────────────────

/// لون الحالة من الخادم — `#RRGGBB` أو `#AARRGGBB`.
///
/// يعيد null عند أي شكل غير متوقّع بدل أن يرمي: لون خاطئ في قاعدة
/// البيانات لا يجوز أن يُسقط شاشة التتبّع كلها.
Color? _parseColor(String? hex) {
  if (hex == null) return null;
  var h = hex.trim().replaceAll('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

IconData _iconFor(String code) {
  switch (code) {
    case 'pending':
      return Icons.schedule;
    case 'assigned_pickup':
    case 'on_the_way_pickup':
      return Icons.directions_car_outlined;
    case 'picked_up':
    case 'received_at_store':
      return Icons.inventory_2_outlined;
    case 'processing':
    case 'in_progress':
      return Icons.local_laundry_service_outlined;
    case 'ready':
      return Icons.check_circle_outline;
    case 'assigned_delivery':
    case 'on_the_way_delivery':
      return Icons.delivery_dining_outlined;
    case 'delivered':
      return Icons.done_all;
    case 'cancelled':
    case 'undelivered':
      return Icons.cancel_outlined;
    default:
      return Icons.info_outline;
  }
}

String _formatAt(DateTime at) {
  final local = at.toLocal();
  final date = DateFormat('d MMMM', 'ar').format(local);
  final time = DateFormat('h:mm a', 'ar').format(local);
  return '$date · $time';
}
