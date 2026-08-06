import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/StoreCard.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// اختيار المغسلة — الشاشة الأولى في نموذج الوسيط.
///
/// ★ لماذا صارت أولاً ★
///
/// كان الزبون يملأ سلّته من كتالوج واحد ثم يختار المحل عند الدفع. وهذا
/// يستقيم حين تكون سليم هي من تغسل: سعر واحد لكل صنف. أمّا وقد صار كل
/// محل يضع أسعاره، فالسلّة قبل المحل بلا معنى — لا نعرف بأي سعر نحسبها،
/// ولا إن كان المحل يقدّم الصنف أصلاً.
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key, this.areaId, this.onStoreSelected});

  final int? areaId;

  /// يُنادى بعد اختيار المحل — الشاشة لا تعرف إلى أين تذهب بعده،
  /// فالتوجيه قرار من يستدعيها
  final void Function(Store store)? onStoreSelected;

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoresProvider>().load(areaId: widget.areaId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StoresProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              controller: _searchController,
              onSearch: p.setSearch,
            ),
            _FilterBar(
              sort: p.sort,
              favoritesOnly: p.favoritesOnly,
              onSort: p.setSort,
              onFavorites: p.setFavoritesOnly,
            ),
            Expanded(child: _Body(onStoreSelected: widget.onStoreSelected)),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final ValueChanged<String> onSearch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'اختر المغسلة',
            style: AppTextStyles.sfarabicBold.copyWith(
              fontSize: 22,
              color: AppColors.gray80,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'لكل مغسلة أسعارها وخدماتها',
            style: AppTextStyles.sfarabicRegular.copyWith(
              fontSize: 13,
              color: AppColors.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            onChanged: onSearch,
            textAlign: TextAlign.start,
            style: AppTextStyles.sfarabicRegular.copyWith(
              fontSize: 14,
              color: AppColors.gray80,
            ),
            decoration: InputDecoration(
              hintText: 'ابحث عن مغسلة…',
              hintStyle: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 14,
                color: AppColors.inactiveColor,
              ),
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.inactiveColor),
              filled: true,
              fillColor: AppColors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  static const _labels = {
    StoreSort.recommended: 'موصى به',
    StoreSort.rating: 'الأعلى تقييماً',
    StoreSort.priceLow: 'الأقلّ سعراً',
  };

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
          ..._labels.entries.expand((e) => [
                _Chip(
                  label: e.value,
                  selected: sort == e.key,
                  onTap: () => onSort(e.key),
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

class _Body extends StatelessWidget {
  const _Body({this.onStoreSelected});

  final void Function(Store store)? onStoreSelected;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<StoresProvider>();

    if (p.isLoading && p.stores.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    if (p.error != null && p.stores.isEmpty) {
      return _Empty(
        icon: Icons.wifi_off_rounded,
        title: p.error!,
        actionLabel: 'إعادة المحاولة',
        onAction: () => context.read<StoresProvider>().load(force: true),
      );
    }

    if (p.stores.isEmpty) {
      // التفريق بين «لا نتيجة للبحث» و«لا مغاسل» مقصود: الأول يُحلّ
      // بمسح البحث، والثاني لا حيلة للزبون فيه
      final searching = p.search.trim().isNotEmpty || p.favoritesOnly;
      return _Empty(
        icon: searching ? Icons.search_off : Icons.storefront_outlined,
        title: searching ? 'لا نتائج' : 'لا مغاسل في منطقتك بعد',
        subtitle: searching
            ? 'جرّب اسماً آخر أو امسح الفلاتر'
            : 'نعمل على إضافة مغاسل قريبة منك',
      );
    }

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () => context.read<StoresProvider>().load(force: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        itemCount: p.stores.length,
        itemBuilder: (_, i) {
          final store = p.stores[i];
          return StoreCard(
            store: store,
            onTap: () => onStoreSelected?.call(store),
            onFavoriteTap: () =>
                context.read<StoresProvider>().toggleFavorite(store.id),
          );
        },
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              style: AppTextStyles.sfarabicBold.copyWith(
                fontSize: 16,
                color: AppColors.gray80,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 13,
                  color: AppColors.secondaryTextColor,
                ),
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.sfarabicBold.copyWith(
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
