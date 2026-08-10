import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/screens/Stores/product_size_sheet.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Models/Service.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoreCatalogProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';
import 'package:saleem_dry_clean/utils/store_localization.dart';

String _catalogText(
  BuildContext context,
  String key, {
  required String ar,
  required String en,
  Map<String, String>? params,
}) {
  final l10n = AppLocalizations.of(context);
  final translated = l10n.translate(key, params: params);
  if (translated != key) return translated;
  var fallback = Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
  params?.forEach((name, value) {
    fallback = fallback.replaceAll('{$name}', value);
  });
  return fallback;
}

/// Product-first laundry catalogue.
///
/// The compact store header scrolls away. Once it leaves the viewport, a
/// horizontally scrollable category bar is revealed and stays pinned. Its
/// active tab follows the visible section and tapping a tab scrolls directly
/// to that category.
class StoreCatalogScreen extends StatefulWidget {
  const StoreCatalogScreen({super.key, required this.store, this.onCheckout});

  final Store store;
  final VoidCallback? onCheckout;

  @override
  State<StoreCatalogScreen> createState() => _StoreCatalogScreenState();
}

class _StoreCatalogScreenState extends State<StoreCatalogScreen> {
  static const double _stickyHeight = 66;
  static const double _stickyRevealOffset = 72;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _tabScrollController = ScrollController();
  final Map<String, GlobalKey> _groupKeys = {};
  final Map<String, GlobalKey> _tabKeys = {};

  String? _lastLanguage;
  String? _activeGroup;
  bool _showStickyTabs = false;
  bool _sectionCheckScheduled = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final language = Localizations.localeOf(context).languageCode;
    if (_lastLanguage == language) return;
    _lastLanguage = language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StoreCatalogProvider>().load(
            widget.store.id,
            lang: language,
            force: true,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final show = _scrollController.hasClients &&
        _scrollController.offset > _stickyRevealOffset;
    if (show != _showStickyTabs && mounted) {
      setState(() => _showStickyTabs = show);
    }
    _scheduleSectionCheck();
  }

  void _scheduleSectionCheck() {
    if (_sectionCheckScheduled) return;
    _sectionCheckScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sectionCheckScheduled = false;
      if (mounted) _syncActiveGroupToScroll();
    });
  }

  void _ensureSectionKeys(Iterable<String> groups) {
    final names = groups.toSet();
    _groupKeys.removeWhere((name, _) => !names.contains(name));
    _tabKeys.removeWhere((name, _) => !names.contains(name));
    for (final name in groups) {
      _groupKeys.putIfAbsent(name, GlobalKey.new);
      _tabKeys.putIfAbsent(name, GlobalKey.new);
    }
    if (_activeGroup == null || !names.contains(_activeGroup)) {
      _activeGroup = names.isEmpty ? null : groups.first;
    }
  }

  void _syncActiveGroupToScroll() {
    if (_groupKeys.isEmpty) return;
    final anchor = MediaQuery.paddingOf(context).top + _stickyHeight + 12;
    String? candidate = _groupKeys.keys.first;
    for (final entry in _groupKeys.entries) {
      final renderObject = entry.value.currentContext?.findRenderObject();
      if (renderObject is! RenderBox || !renderObject.attached) continue;
      final top = renderObject.localToGlobal(Offset.zero).dy;
      if (top <= anchor) candidate = entry.key;
    }
    if (candidate == null || candidate == _activeGroup) return;
    setState(() => _activeGroup = candidate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _revealActiveTab(candidate!);
    });
  }

  void _revealActiveTab(String name) {
    if (!_tabScrollController.hasClients) return;
    final tabBox = _tabKeys[name]?.currentContext?.findRenderObject();
    final listBox =
        _tabScrollController.position.context.storageContext.findRenderObject();
    if (tabBox is! RenderBox || listBox is! RenderBox) return;

    final tabStart = tabBox.localToGlobal(Offset.zero).dx;
    final tabEnd = tabStart + tabBox.size.width;
    final listStart = listBox.localToGlobal(Offset.zero).dx + 12;
    final listEnd = listStart + listBox.size.width - 24;
    var delta = 0.0;
    if (tabStart < listStart) delta = tabStart - listStart;
    if (tabEnd > listEnd) delta = tabEnd - listEnd;
    if (delta == 0) return;

    final position = _tabScrollController.position;
    final scrollDelta =
        position.axisDirection == AxisDirection.left ? -delta : delta;
    final target = (_tabScrollController.offset + scrollDelta)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    _tabScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _jumpToGroup(String name) async {
    final renderObject = _groupKeys[name]?.currentContext?.findRenderObject();
    if (renderObject == null || !_scrollController.hasClients) return;
    final viewport = RenderAbstractViewport.of(renderObject);
    final reveal = viewport.getOffsetToReveal(renderObject, 0).offset;
    final position = _scrollController.position;
    final target = (reveal - _stickyHeight - 6)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    setState(() {
      _activeGroup = name;
      _showStickyTabs = true;
    });
    _revealActiveTab(name);
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<bool?> _confirmSwitch(Store store) {
    final l10n = AppLocalizations.of(context);
    final order = context.read<OrderProvider>();
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.translate('cart_other_store_title'),
          style: AppTextStyles.sfarabicBold.copyWith(
            fontSize: 17,
            color: AppColors.gray80,
          ),
        ),
        content: Text(
          order.storeName == null
              ? l10n.translate('cart_other_store_empty')
              : l10n.translate(
                  'cart_other_store_named',
                  params: {'current': order.storeName!, 'next': store.name},
                ),
          style: AppTextStyles.sfarabicRegular.copyWith(
            fontSize: 13.5,
            height: 1.6,
            color: AppColors.secondaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              l10n.translate('cart_keep'),
              style: AppTextStyles.sfarabicMedium.copyWith(
                color: AppColors.gray60,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.translate('cart_clear_continue'),
              style: AppTextStyles.sfarabicBold.copyWith(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProduct(CatalogProduct product, Store store) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _ProductServicesPage(
          product: product,
          store: store,
          confirmStoreSwitch: () => _confirmSwitch(store),
        ),
      ),
    );
    _scheduleSectionCheck();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<StoreCatalogProvider>();
    final store = catalog.store ?? widget.store;
    final groups = catalog.visibleGroups;
    _ensureSectionKeys(groups.keys);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scheduleSectionCheck();
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: _CompactHeader(
                    store: store,
                    onBasket: widget.onCheckout,
                  ),
                ),
                SliverToBoxAdapter(child: _StoreSummary(store: store)),
                SliverToBoxAdapter(
                  child: _SearchField(
                    controller: _searchController,
                    onChanged: catalog.setSearch,
                  ),
                ),
                ..._buildCatalogue(catalog, groups, store),
                const SliverToBoxAdapter(child: SizedBox(height: 112)),
              ],
            ),
            AnimatedPositionedDirectional(
              duration: const Duration(milliseconds: 190),
              curve: Curves.easeOutCubic,
              top: _showStickyTabs ? 0 : -_stickyHeight - 10,
              start: 0,
              end: 0,
              height: _stickyHeight,
              child: IgnorePointer(
                ignoring: !_showStickyTabs,
                child: AnimatedOpacity(
                  opacity: _showStickyTabs ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: _StickyCategoryBar(
                    groups: groups.keys.toList(),
                    activeGroup: _activeGroup,
                    controller: _tabScrollController,
                    tabKeys: _tabKeys,
                    onSelected: _jumpToGroup,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BasketBar(
        storeId: store.id,
        onCheckout: widget.onCheckout,
      ),
    );
  }

  List<Widget> _buildCatalogue(
    StoreCatalogProvider catalog,
    Map<String, List<CatalogProduct>> groups,
    Store store,
  ) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    if (catalog.isLoading && catalog.services.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.brandAccent),
          ),
        ),
      ];
    }

    if (catalog.error != null && catalog.services.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CatalogEmpty(
            icon: Icons.wifi_off_rounded,
            title: l10n.translate(catalog.error!),
            actionLabel: l10n.translate('retry'),
            onAction: () => context.read<StoreCatalogProvider>().load(
                  widget.store.id,
                  lang: language,
                  force: true,
                ),
          ),
        ),
      ];
    }

    if (groups.isEmpty) {
      final searching = catalog.search.trim().isNotEmpty;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CatalogEmpty(
            icon: searching ? Icons.search_off : Icons.inventory_2_outlined,
            title: searching
                ? l10n.translate('catalog_no_product_search')
                : _catalogText(
                    context,
                    'catalog_no_products',
                    ar: 'لم تضف هذه المغسلة أصنافًا بعد',
                    en: 'This laundry has not added any items yet',
                  ),
            subtitle: searching
                ? l10n.translate('catalog_try_another')
                : l10n.translate('catalog_no_products_subtitle'),
          ),
        ),
      ];
    }

    return groups.entries
        .map(
          (entry) => SliverToBoxAdapter(
            child: _CatalogGroup(
              key: _groupKeys[entry.key],
              title: entry.key,
              products: entry.value,
              storeId: store.id,
              onProductTap: (product) => _openProduct(product, store),
            ),
          ),
        )
        .toList();
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({required this.store, this.onBasket});

  final Store store;
  final VoidCallback? onBasket;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final order = context.watch<OrderProvider>();
    final count = order.storeId == store.id ? order.totalQuantity : 0;
    return Container(
      height: 64,
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          _HeaderButton(
            onTap: () => Navigator.maybePop(context),
            child: Icon(
              rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
              size: 21,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              store.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.sfarabicBold.copyWith(
                fontSize: 16,
                color: AppColors.gray80,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Stack(
            clipBehavior: Clip.none,
            children: [
              _HeaderButton(
                onTap: onBasket,
                light: true,
                child: const Icon(
                  Icons.shopping_basket_outlined,
                  size: 22,
                  color: AppColors.gray80,
                ),
              ),
              if (count > 0)
                PositionedDirectional(
                  top: -4,
                  end: -5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: AppTextStyles.poppinsSemiBold.copyWith(
                        fontSize: 9,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.child, this.onTap, this.light = false});

  final Widget child;
  final VoidCallback? onTap;
  final bool light;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: light ? null : AppColors.brandGradient,
          color: light ? AppColors.backgroundColor : null,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(width: 42, height: 42, child: Center(child: child)),
          ),
        ),
      );
}

class _StoreSummary extends StatelessWidget {
  const _StoreSummary({required this.store});

  final Store store;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final turnaround = localizedTurnaround(context, store.turnaroundHours);
    final hasDescription = (store.description ?? '').trim().isNotEmpty;
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDescription) ...[
            Text(
              store.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 9),
          ],
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              if ((store.workingHours ?? '').trim().isNotEmpty)
                _InfoPill(
                  icon: Icons.schedule_rounded,
                  label: store.workingHours!,
                ),
              if (store.minOrderTotal > 0)
                _InfoPill(
                  icon: Icons.shopping_bag_outlined,
                  label: l10n.translate(
                    'store_min_order_value',
                    params: {'amount': store.minOrderTotal.toStringAsFixed(0)},
                  ),
                ),
              if (turnaround.isNotEmpty)
                _InfoPill(
                  icon: Icons.timelapse_rounded,
                  label: l10n.translate(
                    'store_ready_in',
                    params: {'duration': turnaround},
                  ),
                ),
              if (store.hasRating)
                _InfoPill(
                  icon: Icons.star_rounded,
                  label:
                      '${store.rating.toStringAsFixed(1)} (${store.ratingCount})',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.brandAccent),
            const SizedBox(width: 5),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 230),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sfarabicMedium.copyWith(
                  fontSize: 11.5,
                  color: AppColors.gray60,
                ),
              ),
            ),
          ],
        ),
      );
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(18, 2, 18, 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: AppTextStyles.sfarabicRegular.copyWith(
          fontSize: 13.5,
          color: AppColors.gray80,
        ),
        decoration: InputDecoration(
          hintText: l10n.translate('catalog_search_hint'),
          hintStyle: AppTextStyles.sfarabicRegular.copyWith(
            fontSize: 13.5,
            color: AppColors.inactiveColor,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
            color: AppColors.inactiveColor,
          ),
          filled: true,
          fillColor: AppColors.backgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _StickyCategoryBar extends StatelessWidget {
  const _StickyCategoryBar({
    required this.groups,
    required this.activeGroup,
    required this.controller,
    required this.tabKeys,
    required this.onSelected,
  });

  final List<String> groups;
  final String? activeGroup;
  final ScrollController controller;
  final Map<String, GlobalKey> tabKeys;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.shadowColor,
        child: ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
          itemCount: groups.length,
          separatorBuilder: (_, __) => const SizedBox(width: 7),
          itemBuilder: (context, index) {
            final name = groups[index];
            final selected = name == activeGroup;
            return AnimatedContainer(
              key: tabKeys[name],
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                gradient: selected ? AppColors.brandGradient : null,
                color: selected ? null : AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Material(
                color: AppColors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onSelected(name),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Center(
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.sfarabicMedium.copyWith(
                          fontSize: 12.5,
                          height: 1.05,
                          color: selected ? AppColors.white : AppColors.gray60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
}

class _CatalogGroup extends StatelessWidget {
  const _CatalogGroup({
    super.key,
    required this.title,
    required this.products,
    required this.storeId,
    required this.onProductTap,
  });

  final String title;
  final List<CatalogProduct> products;
  final int storeId;
  final ValueChanged<CatalogProduct> onProductTap;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray20.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 9),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.sfarabicBold.copyWith(
                      fontSize: 14.5,
                      color: AppColors.gray80,
                    ),
                  ),
                ),
                if (products.any((product) => product.hasOffer))
                  const _SaleBadge(compact: true),
              ],
            ),
          ),
          ...List.generate(products.length, (index) {
            final product = products[index];
            final quantity = order.storeId == storeId
                ? order.cart
                    .where((item) => item.productId == product.productId)
                    .fold<int>(0, (sum, item) => sum + item.quantity)
                : 0;
            return Column(
              children: [
                if (index > 0)
                  const Divider(height: 1, indent: 14, endIndent: 14),
                _ProductRow(
                  product: product,
                  quantity: quantity,
                  onTap: () => onProductTap(product),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.product,
    required this.quantity,
    required this.onTap,
  });

  final CatalogProduct product;
  final int quantity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: (product.imagePath ?? '').isEmpty
                        ? const _ProductImageFallback()
                        : Image.network(
                            Config.resolveImageUrl(product.imagePath),
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const _ProductImageFallback(),
                          ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.sfarabicMedium.copyWith(
                          fontSize: 13.5,
                          color: AppColors.gray80,
                        ),
                      ),
                      if (product.hasOffer) const _SaleBadge(),
                      if (quantity > 0)
                        Container(
                          width: 19,
                          height: 19,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.brandAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$quantity',
                            style: AppTextStyles.poppinsSemiBold.copyWith(
                              fontSize: 9.5,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: AppColors.brandGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const SizedBox(
                    width: 25,
                    height: 25,
                    child: Icon(Icons.add, size: 16, color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _SaleBadge extends StatelessWidget {
  const _SaleBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final label = _catalogText(context, 'catalog_sale', ar: 'عرض', en: 'Sale');
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 2 : 2.5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB8AE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 10,
            color: Color(0xFFFF7668),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTextStyles.sfarabicMedium.copyWith(
              fontSize: compact ? 8.5 : 9,
              color: const Color(0xFFFF7668),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductServicesPage extends StatefulWidget {
  const _ProductServicesPage({
    required this.product,
    required this.store,
    required this.confirmStoreSwitch,
  });

  final CatalogProduct product;
  final Store store;
  final Future<bool?> Function() confirmStoreSwitch;

  @override
  State<_ProductServicesPage> createState() => _ProductServicesPageState();
}

class _ProductServicesPageState extends State<_ProductServicesPage> {
  final Map<int, int> _quantities = {};
  final Map<int, List<String>> _areas = {};
  bool _initialized = false;
  int _initialTotal = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final order = context.read<OrderProvider>();
    if (order.storeId != widget.store.id) return;

    for (final offering in widget.product.offerings) {
      final lines = order.cart.where(
        (item) =>
            item.productId == widget.product.productId &&
            item.serviceType.id == offering.serviceId,
      );
      if (offering.isPerSquareMeter) {
        final areas = <String>[];
        for (final line in lines) {
          areas.addAll(List.filled(line.quantity, line.area));
        }
        _areas[offering.serviceId] = areas;
        _quantities[offering.serviceId] = areas.length;
      } else {
        _quantities[offering.serviceId] = lines.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        );
      }
    }
    _initialTotal = totalQuantity;
  }

  int get totalQuantity =>
      _quantities.values.fold<int>(0, (sum, value) => sum + value);

  Future<void> _increase(StoreProduct offering) async {
    if (offering.isPerSquareMeter) {
      final area = await showProductSizeSheet(context, product: offering);
      if (area == null || !mounted) return;
      _areas.putIfAbsent(offering.serviceId, () => []).add(area.toString());
    }
    setState(() {
      _quantities[offering.serviceId] =
          (_quantities[offering.serviceId] ?? 0) + 1;
    });
  }

  void _decrease(StoreProduct offering) {
    final current = _quantities[offering.serviceId] ?? 0;
    if (current <= 0) return;
    if (offering.isPerSquareMeter) {
      final areas = _areas[offering.serviceId];
      if (areas != null && areas.isNotEmpty) areas.removeLast();
    }
    setState(() => _quantities[offering.serviceId] = current - 1);
  }

  List<BasketItemData> _buildLines() {
    final result = <BasketItemData>[];
    for (final offering in widget.product.offerings) {
      final quantity = _quantities[offering.serviceId] ?? 0;
      if (quantity <= 0) continue;
      if (offering.isPerSquareMeter) {
        final counts = <String, int>{};
        for (final area in _areas[offering.serviceId] ?? const <String>[]) {
          counts[area] = (counts[area] ?? 0) + 1;
        }
        for (final entry in counts.entries) {
          result.add(_line(offering, entry.value, entry.key));
        }
      } else {
        result.add(_line(offering, quantity, ''));
      }
    }
    return result;
  }

  BasketItemData _line(StoreProduct offering, int quantity, String area) {
    return BasketItemData(
      productId: widget.product.productId,
      productName: widget.product.name,
      category: widget.product.groupName ?? '',
      serviceType: Service(
        id: offering.serviceId,
        serviceName: offering.serviceName,
        price: offering.effectivePrice.toString(),
      ),
      imagePath: widget.product.imagePath ?? '',
      price: offering.effectivePrice,
      unit: offering.unit,
      quantity: quantity,
      subCategory: widget.product.name,
      area: area,
      subtotal: BasketItemData.calculateSubtotal(
        offering.unit,
        offering.effectivePrice,
        quantity,
        area,
      ),
    );
  }

  Future<void> _apply() async {
    final order = context.read<OrderProvider>();
    if (!order.acceptsStore(widget.store.id)) {
      final switchStore = await widget.confirmStoreSwitch();
      if (switchStore != true || !mounted) return;
      order.switchStore(widget.store.id, widget.store.name);
    }
    order.replaceProductLines(
      productId: widget.product.productId,
      storeId: widget.store.id,
      storeName: widget.store.name,
      lines: _buildLines(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final total = totalQuantity;
    final canApply = total > 0 || _initialTotal > 0;
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            _HeaderButton(
              light: true,
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded, color: AppColors.gray80),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.store.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfarabicRegular.copyWith(
                      fontSize: 10.5,
                      color: AppColors.gray50,
                    ),
                  ),
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.sfarabicBold.copyWith(
                      fontSize: 15,
                      color: AppColors.gray80,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 54),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                child: Column(
                  children: [
                    Container(
                      height: 230,
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.gray20),
                      ),
                      child: (widget.product.imagePath ?? '').isEmpty
                          ? const _ProductImageFallback(iconSize: 58)
                          : Image.network(
                              Config.resolveImageUrl(widget.product.imagePath),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) =>
                                  const _ProductImageFallback(iconSize: 58),
                            ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _catalogText(
                              context,
                              'catalog_service_type',
                              ar: 'نوع الخدمة',
                              en: 'Service type',
                            ),
                            style: AppTextStyles.sfarabicBold.copyWith(
                              fontSize: 12,
                              color: AppColors.gray60,
                            ),
                          ),
                        ),
                        Text(
                          _catalogText(
                            context,
                            'catalog_quantity',
                            ar: 'الكمية',
                            en: 'Quantity',
                          ),
                          style: AppTextStyles.sfarabicBold.copyWith(
                            fontSize: 12,
                            color: AppColors.gray60,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...widget.product.offerings.map(
                      (offering) => _ServiceQuantityRow(
                        offering: offering,
                        quantity: _quantities[offering.serviceId] ?? 0,
                        onAdd: () => _increase(offering),
                        onRemove: () => _decrease(offering),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: _GradientActionButton(
                enabled: canApply,
                onTap: _apply,
                label: _catalogText(
                  context,
                  _initialTotal > 0
                      ? 'catalog_update_basket'
                      : 'catalog_add_to_basket',
                  ar: _initialTotal > 0
                      ? 'تحديث السلّة ({count} قطع)'
                      : 'إضافة إلى السلّة ({count} قطع)',
                  en: _initialTotal > 0
                      ? 'Update basket ({count} items)'
                      : 'Add to basket ({count} items)',
                  params: {'count': '$total'},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceQuantityRow extends StatelessWidget {
  const _ServiceQuantityRow({
    required this.offering,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final StoreProduct offering;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final discount = offering.discountPercent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        offering.serviceName,
                        style: AppTextStyles.sfarabicMedium.copyWith(
                          fontSize: 13.5,
                          color: AppColors.gray80,
                        ),
                      ),
                    ),
                    if (discount != null) ...[
                      const SizedBox(width: 6),
                      const _SaleBadge(),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${offering.effectivePrice.toStringAsFixed(2)}₪',
                      style: AppTextStyles.poppinsSemiBold.copyWith(
                        fontSize: 11.5,
                        color: AppColors.brandAccent,
                      ),
                    ),
                    if (discount != null)
                      Text(
                        '${offering.price.toStringAsFixed(2)}₪',
                        style: AppTextStyles.poppinsRegular.copyWith(
                          fontSize: 10.5,
                          color: AppColors.inactiveColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '/ ${offering.isPerSquareMeter ? l10n.translate('unit_square_meter_short') : _catalogText(context, 'catalog_item', ar: 'قطعة', en: 'item')}',
                      style: AppTextStyles.sfarabicRegular.copyWith(
                        fontSize: 10.5,
                        color: AppColors.gray50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _QuantityButton(
                icon: Icons.remove,
                enabled: quantity > 0,
                onTap: onRemove,
              ),
              SizedBox(
                width: 34,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.poppinsSemiBold.copyWith(
                    fontSize: 13,
                    color: AppColors.gray80,
                  ),
                ),
              ),
              _QuantityButton(icon: Icons.add, onTap: onAdd),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Material(
        color: enabled ? AppColors.backgroundColor : AppColors.gray10,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(
              icon,
              size: 16,
              color: enabled ? AppColors.brandAccent : AppColors.gray30,
            ),
          ),
        ),
      );
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.enabled,
    required this.onTap,
    required this.label,
  });

  final bool enabled;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: enabled
              ? AppColors.brandGradient
              : LinearGradient(
                  colors: [
                    AppColors.brandStart.withValues(alpha: 0.35),
                    AppColors.brandEnd.withValues(alpha: 0.35),
                  ],
                ),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Material(
          color: AppColors.transparent,
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(13),
            child: SizedBox(
              height: 50,
              child: Center(
                child: Text(
                  label,
                  style: AppTextStyles.sfarabicBold.copyWith(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback({this.iconSize = 25});

  final double iconSize;

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.backgroundColor,
        alignment: Alignment.center,
        child: Icon(
          Icons.checkroom_rounded,
          size: iconSize,
          color: AppColors.inactiveColor,
        ),
      );
}

class _BasketBar extends StatelessWidget {
  const _BasketBar({required this.storeId, this.onCheckout});

  final int storeId;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final order = context.watch<OrderProvider>();
    final belongsToThisStore =
        order.cart.isNotEmpty && order.storeId == storeId;
    if (!belongsToThisStore) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Material(
            color: AppColors.transparent,
            borderRadius: BorderRadius.circular(15),
            child: InkWell(
              onTap: onCheckout,
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 15,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${order.totalQuantity}',
                        style: AppTextStyles.poppinsSemiBold.copyWith(
                          fontSize: 13,
                          color: AppColors.brandAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Text(
                      l10n.translate('basket_view'),
                      style: AppTextStyles.sfarabicBold.copyWith(
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${order.subtotal.toStringAsFixed(2)}₪',
                      style: AppTextStyles.poppinsSemiBold.copyWith(
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogEmpty extends StatelessWidget {
  const _CatalogEmpty({
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
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 38, color: AppColors.brandAccent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sfarabicBold.copyWith(
                  fontSize: 15.5,
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
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!,
                    style: AppTextStyles.sfarabicBold.copyWith(
                      color: AppColors.brandAccent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}
