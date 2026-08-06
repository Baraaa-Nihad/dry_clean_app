import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/StoreCard.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Navigator/navigator_service.dart';
import 'package:saleem_dry_clean/services/Providers/LocationScopeProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/route_names.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoresProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _open(Store store) => NavigatorService.navigateTo(
        RouteNames.storeCatalog,
        arguments: {'store': store},
      );

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StoresProvider>();

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () => context.read<StoresProvider>().load(force: true),
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _SearchField(
                controller: _searchController,
                onChanged: p.setSearch,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _FilterBar(
              sort: p.sort,
              favoritesOnly: p.favoritesOnly,
              onSort: p.setSort,
              onFavorites: p.setFavoritesOnly,
            ),
          ),
          _body(p),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _body(StoresProvider p) {
    if (p.isLoading && p.stores.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: Center(child: CircularProgressIndicator(color: AppColors.green)),
        ),
      );
    }

    if (p.error != null && p.stores.isEmpty) {
      return SliverToBoxAdapter(
        child: _Empty(
          icon: Icons.wifi_off_rounded,
          title: p.error!,
          actionLabel: 'إعادة المحاولة',
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
              ? (p.favoritesOnly ? 'لا مغاسل في مفضّلتك' : 'لا نتائج')
              : 'لا مغاسل في منطقتك بعد',
          subtitle: searching
              ? 'جرّب اسماً آخر أو امسح الفلاتر'
              : 'نعمل على إضافة مغاسل قريبة منك',
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
              onFavoriteTap: () =>
                  context.read<StoresProvider>().toggleFavorite(store.id),
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
    final scope = context.watch<LocationScopeProvider>();
    final area = scope.area;
    if (area == null) return const SizedBox.shrink();

    final city = scope.governate?.name;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => NavigatorService.navigateTo(RouteNames.locationScope),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                size: 17, color: AppColors.green),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                city == null ? area.name : '${area.name}، $city',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 13, color: AppColors.gray70),
              ),
            ),
            Text(
              'تغيير',
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 12.5, color: AppColors.green),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textAlign: TextAlign.start,
      style: AppTextStyles.sfarabicRegular
          .copyWith(fontSize: 14, color: AppColors.gray80),
      decoration: InputDecoration(
        hintText: 'ابحث عن مغسلة…',
        hintStyle: AppTextStyles.sfarabicRegular
            .copyWith(fontSize: 14, color: AppColors.inactiveColor),
        prefixIcon: const Icon(Icons.search, color: AppColors.inactiveColor),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// شريط الفلاتر — الأربعة التي تطلبها الوثيقة، والمفضّلة معها.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.sort,
    required this.favoritesOnly,
    required this.onSort,
    required this.onFavorites,
  });

  final StoreSort sort;
  final bool favoritesOnly;
  final ValueChanged<StoreSort> onSort;
  final ValueChanged<bool> onFavorites;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _Chip(
            label: 'المفضّلة',
            icon: Icons.favorite,
            selected: favoritesOnly,
            onTap: () => onFavorites(!favoritesOnly),
          ),
          const SizedBox(width: 8),
          ...StoreSort.values.expand((s) => [
                _Chip(
                  label: s.label,
                  selected: sort == s,
                  onTap: () => onSort(s),
                ),
                const SizedBox(width: 8),
              ]),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: selected ? AppColors.primaryColor : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon,
                      size: 14,
                      color: selected ? AppColors.white : AppColors.red),
                  const SizedBox(width: 5),
                ],
                Text(
                  label,
                  style: AppTextStyles.sfarabicMedium.copyWith(
                    fontSize: 12.5,
                    color: selected ? AppColors.white : AppColors.gray60,
                  ),
                ),
              ],
            ),
          ),
        ),
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
              style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 13, color: AppColors.secondaryTextColor),
            ),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.sfarabicBold
                    .copyWith(color: AppColors.green),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
