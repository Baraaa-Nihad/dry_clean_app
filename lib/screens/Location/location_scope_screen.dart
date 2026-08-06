import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// اختيار المدينة ثم المنطقة.
///
/// ★ لماذا خطوتان لا شاشتان ★
///
/// الوثيقة (٢.١) تطلب «اختيار المدينة ثم اختيار المنطقة». وشاشتان
/// منفصلتان تعنيان زرّ رجوع ومسارين في الراوتر لخطوة تقع مرّة واحدة في
/// عمر التطبيق. والخطوتان داخل شاشة واحدة تُبقيان السياق: الزبون يرى
/// مدينته مختارة فوق قائمة المناطق.
///
/// وتُفتح قبل التسجيل — لذلك المسارات التي تناديها عامة.
class LocationScopeScreen extends StatefulWidget {
  const LocationScopeScreen({super.key, this.onDone});

  /// يُنادى بعد اختيار المنطقة — من يفتح الشاشة يقرّر إلى أين
  final VoidCallback? onDone;

  @override
  State<LocationScopeScreen> createState() => _LocationScopeScreenState();
}

class _LocationScopeScreenState extends State<LocationScopeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<LocationScopeProvider>();
      p.loadGovernates();
      // محافظة محفوظة من جلسة سابقة: نجلب مناطقها فوراً كي لا يعيد
      // الزبون اختيار مدينته ليصل إلى منطقته
      final g = p.governate;
      if (g != null) p.loadAreas(g.id);
    });
  }

  Future<void> _pickArea(LocationOption a) async {
    final p = context.read<LocationScopeProvider>();
    await p.selectArea(a);
    if (!mounted) return;

    // المغاسل تُرشَّح بالمنطقة فوراً — بلا هذا يرى الزبون مغاسل مدينة
    // أخرى في أول شاشة بعد اختياره
    context.read<StoresProvider>().setArea(a.id);
    widget.onDone?.call();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LocationScopeProvider>();
    final gov = p.governate;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: AppColors.greenCardBackgourd,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: AppColors.green, size: 26),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    gov == null ? 'أين تسكن؟' : 'في أي منطقة؟',
                    style: AppTextStyles.sfarabicBold
                        .copyWith(fontSize: 23, color: AppColors.gray80),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    gov == null
                        ? 'اختر مدينتك لنعرض لك المغاسل التي تخدمها'
                        : 'اختر منطقتك داخل ${gov.name}',
                    style: AppTextStyles.sfarabicRegular.copyWith(
                        fontSize: 13.5,
                        height: 1.5,
                        color: AppColors.secondaryTextColor),
                  ),
                ],
              ),
            ),

            if (gov != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                child: _ChosenCity(
                  name: gov.name,
                  onChange: () => context
                      .read<LocationScopeProvider>()
                      .selectGovernate(gov)
                      .then((_) => _clearCity()),
                ),
              ),

            const SizedBox(height: 14),
            Expanded(child: _body(p, gov)),
          ],
        ),
      ),
    );
  }

  /// «تغيير» يعيد الزبون إلى قائمة المدن بلا مسح ما حفظه فعلاً — لو
  /// تراجع بقي اختياره السابق كما هو.
  void _clearCity() {
    setState(() {});
  }

  Widget _body(LocationScopeProvider p, LocationOption? gov) {
    if (p.isLoading && (gov == null ? p.governates : p.areas).isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.green));
    }

    if (p.error != null) {
      return _Retry(
        message: p.error!,
        onRetry: () => gov == null
            ? context.read<LocationScopeProvider>().loadGovernates()
            : context.read<LocationScopeProvider>().loadAreas(gov.id),
      );
    }

    final items = gov == null ? p.governates : p.areas;

    if (items.isEmpty) {
      return _Retry(
        message: gov == null
            ? 'لا مدن متاحة بعد'
            : 'لا مناطق مسجَّلة في ${gov.name} بعد',
        onRetry: () => gov == null
            ? context.read<LocationScopeProvider>().loadGovernates()
            : context.read<LocationScopeProvider>().loadAreas(gov.id),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (_, i) {
        final o = items[i];
        final selected = gov != null && p.area?.id == o.id;
        return _OptionRow(
          label: o.name,
          selected: selected,
          onTap: () => gov == null
              ? context.read<LocationScopeProvider>().selectGovernate(o)
              : _pickArea(o),
        );
      },
    );
  }
}

class _ChosenCity extends StatelessWidget {
  const _ChosenCity({required this.name, required this.onChange});
  final String name;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_city_outlined,
                size: 19, color: AppColors.green),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                name,
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 14, color: AppColors.gray80),
              ),
            ),
            TextButton(
              onPressed: onChange,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'تغيير',
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 12.5, color: AppColors.green),
              ),
            ),
          ],
        ),
      );
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.greenCardBackgourd : AppColors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.sfarabicMedium
                        .copyWith(fontSize: 14.5, color: AppColors.gray80),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.chevron_left,
                  size: 20,
                  color: selected ? AppColors.green : AppColors.inactiveColor,
                ),
              ],
            ),
          ),
        ),
      );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_off_outlined,
                  size: 46, color: AppColors.inactiveColor),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 14, color: AppColors.gray80),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'إعادة المحاولة',
                  style: AppTextStyles.sfarabicBold
                      .copyWith(color: AppColors.green),
                ),
              ),
            ],
          ),
        ),
      );
}
