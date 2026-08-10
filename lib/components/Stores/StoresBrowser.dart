import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/StoreCard.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';
import 'package:saleem_dry_clean/utils/store_favorite_action.dart';

/// تصفّح المغاسل: بحث وفلاتر وقائمة.
///
/// ★ لماذا ودجة مشتركة ★
///
/// الرئيسية صارت قائمة المغاسل (٢.١.١)، وشاشة «كل المغاسل» تعرض
/// القائمة نفسها. نسختان من البحث والفلاتر تنفردان عن بعضهما عند أول
/// تعديل — يُضاف فلتر هنا ويُنسى هناك.
///
/// و`header` تُمرَّر من فوق لأن الرئيسية تعلوها بانرات لا تخصّ الشاشة
/// الأخرى، والقائمة يجب أن تنزلق تحتها لا أن تُمرَّر منفصلة.
class StoresBrowser extends StatefulWidget {
  const StoresBrowser({
    super.key,
    this.header,
    this.title,
    this.subtitle,
  });

  /// محتوى يسبق البحث داخل نفس التمرير — البانرات في الرئيسية
  final Widget? header;
  final String? title;
  final String? subtitle;

  @override
  State<StoresBrowser> createState() => _StoresBrowserState();
}

class _StoresBrowserState extends State<StoresBrowser> {
  final _searchController = TextEditingController();
  bool _searchExpanded = false;
  String? _lastLanguage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_lastLanguage == language) return;
    _lastLanguage = language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StoresProvider>().load(lang: language, force: true);
      final location = context.read<LocationScopeProvider>();
      location.loadGovernates(lang: language);
      final governate = location.governate;
      if (governate != null) {
        location.loadAreas(governate.id, lang: language);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _open(Store store) {
    if (store.id < 0) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('stores_preview_message')),
        ),
      );
      return;
    }

    NavigatorService.navigateTo(
      RouteNames.storeCatalog,
      arguments: {'store': store},
    );
  }

  void _toggleSearch() {
    setState(() => _searchExpanded = !_searchExpanded);
  }

  void _clearSearch(StoresProvider provider) {
    _searchController.clear();
    provider.setSearch('');
    setState(() => _searchExpanded = false);
  }

  void _showFilters() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Consumer<StoresProvider>(
          builder: (_, provider, __) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.translate('stores_filter_title'),
                  style: AppTextStyles.sfarabicBold.copyWith(
                    fontSize: 17,
                    color: AppColors.gray80,
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: AppColors.gray10,
                  borderRadius: BorderRadius.circular(14),
                  child: SwitchListTile(
                    value: provider.favoritesOnly,
                    onChanged: provider.setFavoritesOnly,
                    activeThumbColor: AppColors.brandAccent,
                    secondary: Icon(
                      provider.favoritesOnly
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: provider.favoritesOnly
                          ? AppColors.red
                          : AppColors.gray60,
                    ),
                    title: Text(
                      l10n.translate('stores_favorites_only'),
                      style: AppTextStyles.sfarabicMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.gray80,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StoresProvider>();
    final language = Localizations.localeOf(context).languageCode;

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () =>
          context.read<StoresProvider>().load(lang: language, force: true),
      child: CustomScrollView(
        // التمرير دائماً ممكن: بدونه لا يعمل السحب للتحديث حين تكون
        // القائمة فارغة — وهي أكثر لحظة يحتاجها الزبون
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
          if (widget.title != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title!,
                      style: AppTextStyles.sfarabicBold
                          .copyWith(fontSize: 20, color: AppColors.gray80),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle!,
                        style: AppTextStyles.sfarabicRegular.copyWith(
                            fontSize: 12.5,
                            color: AppColors.secondaryTextColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          // المنطقة المختارة وزرّ تغييرها.
          //
          // الزبون ينتقل ويزور أهله ويطلب من مدينة أخرى، وقفل المنطقة
          // على اختيار أوّل مرّة يجعله يحذف التطبيق ليعيد السؤال.
          const SliverToBoxAdapter(child: _AreaBar()),
          SliverToBoxAdapter(
            child: _BrowseToolbar(
              controller: _searchController,
              searchExpanded: _searchExpanded,
              sort: p.sort,
              favoritesOnly: p.favoritesOnly,
              onSearchToggle: _toggleSearch,
              onSearchClear: () => _clearSearch(p),
              onSearchChanged: p.setSearch,
              onSort: p.setSort,
              onFiltersTap: _showFilters,
            ),
          ),
          if (p.isPreviewData)
            const SliverToBoxAdapter(child: _PreviewNotice()),
          _body(p),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _body(StoresProvider p) {
    final l10n = AppLocalizations.of(context);
    if (p.isLoading && p.stores.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child:
              Center(child: CircularProgressIndicator(color: AppColors.green)),
        ),
      );
    }

    if (p.error != null && p.stores.isEmpty) {
      return SliverToBoxAdapter(
        child: _Empty(
          icon: Icons.wifi_off_rounded,
          title: l10n.translate(p.error!),
          actionLabel: l10n.translate('retry'),
          onAction: () => context.read<StoresProvider>().load(force: true),
        ),
      );
    }

    if (p.stores.isEmpty) {
      // التفريق بين «لا نتيجة للبحث» و«لا مغاسل» مقصود: الأول يُحلّ
      // بمسح البحث، والثاني لا حيلة للزبون فيه
      final searching = p.search.trim().isNotEmpty || p.favoritesOnly;
      return SliverToBoxAdapter(
        child: _Empty(
          icon: searching ? Icons.search_off : Icons.storefront_outlined,
          title: searching
              ? (p.favoritesOnly
                  ? l10n.translate('stores_no_favorites')
                  : l10n.translate('stores_no_results'))
              : l10n.translate('stores_none_in_area'),
          subtitle: searching
              ? l10n.translate('stores_adjust_search')
              : l10n.translate('stores_coming_soon'),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final store = p.stores[i];
            return StoreCard(
              store: store,
              onTap: () => _open(store),
              onFavoriteTap: () => toggleStoreFavorite(
                context,
                storeId: store.id,
                currentValue: store.isFavorite,
              ),
            );
          },
          childCount: p.stores.length,
        ),
      ),
    );
  }
}

/// شريط المنطقة — يعرض المختارة ويفتح شاشة التغيير.
class _AreaBar extends StatelessWidget {
  const _AreaBar();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = context.watch<LocationScopeProvider>();
    final area = scope.area;
    if (area == null) return const SizedBox.shrink();

    final city = scope.governate?.name;
    final separator =
        Localizations.localeOf(context).languageCode == 'ar' ? '، ' : ', ';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => NavigatorService.navigateTo(RouteNames.locationScope),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 17, color: AppColors.gradientStart),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                city == null ? area.name : '${area.name}$separator$city',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 13, color: AppColors.gray70),
              ),
            ),
            Text(
              l10n.translate('location_scope_change'),
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 12.5, color: AppColors.gray80),
            ),
          ],
        ),
      ),
    );
  }
}

/// شريط التصفّح المضغوط: بحث وترتيب وفلاتر في صف واحد.
///
/// لا يظهر «الاستلام والتسليم» هنا لأن كتالوج المغاسل لا يعيد حالياً
/// مواعيد أو خياراً قابلاً للتصفية لكل مغسلة. إضافته قبل دعم الخادم
/// سيعطي الزبون زرّاً لا يغيّر النتائج فعلياً.
class _BrowseToolbar extends StatelessWidget {
  const _BrowseToolbar({
    required this.controller,
    required this.searchExpanded,
    required this.sort,
    required this.favoritesOnly,
    required this.onSearchToggle,
    required this.onSearchClear,
    required this.onSearchChanged,
    required this.onSort,
    required this.onFiltersTap,
  });

  final TextEditingController controller;
  final bool searchExpanded;
  final StoreSort sort;
  final bool favoritesOnly;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<StoreSort> onSort;
  final VoidCallback onFiltersTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray20),
        ),
      ),
      child: Row(
        children: [
          _FilterButton(
            selected: favoritesOnly,
            onTap: onFiltersTap,
          ),
          const SizedBox(width: 8),
          _SortButton(sort: sort, onSelected: onSort),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: searchExpanded
                    ? SizedBox(
                        key: const ValueKey('search-field'),
                        height: 38,
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          onChanged: onSearchChanged,
                          textAlign: TextAlign.start,
                          style: AppTextStyles.sfarabicRegular.copyWith(
                            fontSize: 12.5,
                            color: AppColors.gray80,
                          ),
                          decoration: InputDecoration(
                            hintText: l10n.translate('stores_search_hint'),
                            hintStyle: AppTextStyles.sfarabicRegular.copyWith(
                              fontSize: 12.5,
                              color: AppColors.inactiveColor,
                            ),
                            prefixIcon: const _GradientIcon(
                              Icons.search_rounded,
                              size: 19,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 35,
                              minHeight: 38,
                            ),
                            suffixIcon: IconButton(
                              tooltip: l10n.translate('stores_close_search'),
                              onPressed: onSearchClear,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 38,
                              ),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 17,
                                color: AppColors.gray50,
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 38,
                            ),
                            filled: true,
                            fillColor: AppColors.gray10,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(22),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      )
                    : IconButton(
                        key: const ValueKey('search-button'),
                        tooltip: l10n.translate('stores_search_tooltip'),
                        onPressed: onSearchToggle,
                        icon: const _GradientIcon(
                          Icons.search_rounded,
                          size: 25,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.blueCardBackgourd : AppColors.gray10,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const _GradientIcon(Icons.tune_rounded, size: 21),
              if (selected)
                const PositionedDirectional(
                  top: 7,
                  end: 9,
                  child: CircleAvatar(
                    radius: 3.5,
                    backgroundColor: AppColors.red,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.sort, required this.onSelected});

  final StoreSort sort;
  final ValueChanged<StoreSort> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<StoreSort>(
      tooltip: l10n.translate('stores_sort_tooltip'),
      initialValue: sort,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => StoreSort.values
          .map(
            (value) => PopupMenuItem<StoreSort>(
              value: value,
              child: Row(
                children: [
                  _GradientIcon(value.icon, size: 18),
                  const SizedBox(width: 9),
                  Text(
                    l10n.translate(value.translationKey),
                    style: AppTextStyles.sfarabicMedium.copyWith(
                      fontSize: 13,
                      color: value == sort
                          ? AppColors.brandAccent
                          : AppColors.gray80,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: AppColors.gray10,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.translate('stores_sort_button'),
              style: AppTextStyles.sfarabicMedium.copyWith(
                fontSize: 13,
                color: AppColors.gray80,
              ),
            ),
            const _GradientIcon(Icons.unfold_more_rounded, size: 21),
          ],
        ),
      ),
    );
  }
}

class _GradientIcon extends StatelessWidget {
  const _GradientIcon(this.icon, {required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppColors.brandGradient.createShader(bounds),
      child: Icon(icon, size: size, color: AppColors.white),
    );
  }
}

class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.blueCardBackgourd,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_outlined,
            size: 18,
            color: AppColors.blueCard,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.translate('stores_preview_notice'),
              style: AppTextStyles.sfarabicMedium.copyWith(
                fontSize: 11.5,
                color: AppColors.gray70,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: AppColors.blueCardBackgourd,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 46, color: AppColors.blueCard),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 16, color: AppColors.gray80),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: AppTextStyles.sfarabicRegular
                  .copyWith(fontSize: 13, color: AppColors.secondaryTextColor),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.sfarabicBold
                    .copyWith(color: AppColors.gradientStart),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
