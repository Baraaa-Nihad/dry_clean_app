import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/LanguageProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

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
  String? _loadedLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = context.read<LanguageProvider>().locale.languageCode;
    if (_loadedLanguage == lang) return;
    _loadedLanguage = lang;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = context.read<LocationScopeProvider>();
      p.loadGovernates(lang: lang);
      // محافظة محفوظة من جلسة سابقة: نجلب مناطقها فوراً كي لا يعيد
      // الزبون اختيار مدينته ليصل إلى منطقته
      final g = p.governate;
      if (g != null) p.loadAreas(g.id, lang: lang);
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

  String _translate(
    AppLocalizations localizations,
    String key, {
    required String arabic,
    required String english,
    Map<String, String>? params,
  }) {
    // LanguageProvider is the source of truth for this flow. Using it here
    // avoids showing Arabic while MaterialApp is still rebuilding its
    // localization delegate after a language switch.
    final fallback =
        context.read<LanguageProvider>().locale.languageCode == 'ar'
            ? arabic
            : english;
    if (params == null) return fallback;
    return params.entries.fold(
      fallback,
      (value, entry) => value.replaceAll('{${entry.key}}', entry.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LocationScopeProvider>();
    final gov = p.governate;
    final localizations = AppLocalizations.of(context);
    final lang = context.watch<LanguageProvider>().locale.languageCode;
    final isRtl = lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 8),
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
                      gov == null
                          ? _translate(
                              localizations, 'location_scope_city_title',
                              arabic: 'أين تسكن؟',
                              english: 'Where do you live?')
                          : _translate(
                              localizations, 'location_scope_area_title',
                              arabic: 'في أي منطقة؟',
                              english: 'Which area are you in?'),
                      style: AppTextStyles.sfarabicBold
                          .copyWith(fontSize: 23, color: AppColors.gray80),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gov == null
                          ? _translate(
                              localizations,
                              'location_scope_city_subtitle',
                              arabic:
                                  'اختر مدينتك لنعرض لك المغاسل التي تخدمها',
                              english:
                                  'Choose your city to see the dry cleaners that serve you.',
                            )
                          : _translate(
                              localizations,
                              'location_scope_area_subtitle',
                              arabic: 'اختر منطقتك داخل {city}',
                              english: 'Choose your area in {city}',
                              params: {'city': gov.name},
                            ),
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
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 0),
                  child: _ChosenCity(
                    name: gov.name,
                    onChange: () =>
                        context.read<LocationScopeProvider>().clearGovernate(),
                  ),
                ),
              const SizedBox(height: 14),
              Expanded(child: _body(p, gov, localizations, lang)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(
    LocationScopeProvider p,
    LocationOption? gov,
    AppLocalizations localizations,
    String lang,
  ) {
    if (p.isLoading && (gov == null ? p.governates : p.areas).isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.green));
    }

    if (p.error != null) {
      return _Retry(
        message: p.error!,
        onRetry: () => gov == null
            ? context.read<LocationScopeProvider>().loadGovernates(lang: lang)
            : context
                .read<LocationScopeProvider>()
                .loadAreas(gov.id, lang: lang),
      );
    }

    final items = gov == null ? p.governates : p.areas;

    if (items.isEmpty) {
      return _Retry(
        message: gov == null
            ? _translate(
                localizations,
                'location_scope_no_cities',
                arabic: 'لا مدن متاحة بعد',
                english: 'No cities are available yet.',
              )
            : _translate(
                localizations,
                'location_scope_no_areas',
                arabic: 'لا مناطق مسجَّلة في {city} بعد',
                english: 'No areas are registered in {city} yet.',
                params: {'city': gov.name},
              ),
        onRetry: () => gov == null
            ? context.read<LocationScopeProvider>().loadGovernates(lang: lang)
            : context
                .read<LocationScopeProvider>()
                .loadAreas(gov.id, lang: lang),
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
              ? context
                  .read<LocationScopeProvider>()
                  .selectGovernate(o, lang: lang)
              : _pickArea(o),
        );
      },
    );
  }
}

class _ChosenCity extends StatelessWidget {
  const _ChosenCity({
    required this.name,
    required this.onChange,
  });
  final String name;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: onChange,
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 22,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
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
                  selected
                      ? Icons.check_circle
                      : Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left
                          : Icons.chevron_right,
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
  const _Retry({
    required this.message,
    required this.onRetry,
  });
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
                child: const Icon(
                  Icons.autorenew_rounded,
                  color: AppColors.green,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      );
}
