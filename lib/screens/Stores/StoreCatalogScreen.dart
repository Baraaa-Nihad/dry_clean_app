import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/services/BasketItemData.dart';
import 'package:saleem_dry_clean/services/Models/Service.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Models/StoreProduct.dart';
import 'package:saleem_dry_clean/services/Providers/OrderProvider.dart';
import 'package:saleem_dry_clean/services/Providers/StoreCatalogProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// كتالوج المحل — أصنافه بأسعاره هو.
///
/// ★ بنية الشاشة ★
///
/// غلاف ينزلق تحت شريط علوي يتماسك عند التمرير، ثم تبويب خدمات
/// (غسيل/كيّ/تنظيف جاف)، ثم أقسام حسب المجموعة، وشريط سلّة ثابت أسفل.
///
/// وترتيبها مقصود: الزبون يختار الخدمة أولاً ثم الصنف — لا العكس.
/// «قميص» وحده لا يكفي لتسعيره، فالقميص المكوي غير المغسول غير المنظّف
/// جافاً، ولكلٍّ سعر في هذا المحل.
class StoreCatalogScreen extends StatefulWidget {
  const StoreCatalogScreen({
    super.key,
    required this.store,
    this.onCheckout,
  });

  final Store store;

  /// يُنادى عند الضغط على شريط السلّة — الشاشة لا تعرف مسار الدفع
  final VoidCallback? onCheckout;

  @override
  State<StoreCatalogScreen> createState() => _StoreCatalogScreenState();
}

class _StoreCatalogScreenState extends State<StoreCatalogScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreCatalogProvider>().load(widget.store.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// إضافة صنف مع حراسة «محل واحد لكل طلب».
  ///
  /// السؤال قبل التفريغ لا بعده: سلّة الزبون مجهوده، وتفريغها بلا إذن
  /// خسارة صامتة يكتشفها عند الدفع.
  Future<void> _add(StoreProduct p) async {
    final order = context.read<OrderProvider>();

    if (!order.acceptsStore(widget.store.id)) {
      final ok = await _confirmSwitch(order.storeName);
      if (ok != true) return;
      order.switchStore(widget.store.id, widget.store.name);
    } else {
      order.bindStore(widget.store.id, widget.store.name);
    }

    order.addProduct(BasketItemData(
      productId: p.productId,
      productName: p.name,
      category: p.groupName ?? '',
      // الخدمة تحمل السعر الفعّال لا المعلن: هو ما رآه الزبون وما
      // سيحتسبه الخادم
      serviceType: Service(
        id: p.serviceId,
        serviceName: p.serviceName,
        price: p.effectivePrice.toString(),
      ),
      imagePath: p.imagePath ?? '',
      price: p.effectivePrice,
      unit: 'piece',
      quantity: 1,
      subCategory: p.groupName ?? '',
      subtotal: p.effectivePrice,
    ));
  }

  Future<bool?> _confirmSwitch(String? current) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'سلّتك من مغسلة أخرى',
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 17, color: AppColors.gray80),
        ),
        content: Text(
          current == null
              ? 'الطلب الواحد من مغسلة واحدة. بالمتابعة تُفرَّغ سلّتك الحالية.'
              : 'سلّتك تحتوي أصنافاً من «$current». الطلب الواحد من مغسلة '
                  'واحدة، فبالمتابعة تُفرَّغ سلّتك وتبدأ من «${widget.store.name}».',
          style: AppTextStyles.sfarabicRegular.copyWith(
            fontSize: 13.5,
            height: 1.6,
            color: AppColors.secondaryTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إبقاء سلّتي',
                style: AppTextStyles.sfarabicMedium
                    .copyWith(color: AppColors.gray60)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('تفريغ والمتابعة',
                style:
                    AppTextStyles.sfarabicBold.copyWith(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cat = context.watch<StoreCatalogProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _CoverAppBar(store: widget.store),
          SliverToBoxAdapter(child: _StoreHeadline(store: widget.store)),
          if (cat.services.length > 1)
            SliverToBoxAdapter(
              child: _ServiceTabs(
                services: cat.services,
                selectedId: cat.selectedService?.serviceId,
                onSelect: cat.selectService,
              ),
            ),
          SliverToBoxAdapter(
            child: _SearchField(
              controller: _searchController,
              onChanged: cat.setSearch,
            ),
          ),
          ..._buildBody(cat),
          // فسحة أسفل بقدر شريط السلّة كي لا يغطّي آخر صنف
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
      bottomNavigationBar: _BasketBar(
        storeId: widget.store.id,
        onCheckout: widget.onCheckout,
      ),
    );
  }

  List<Widget> _buildBody(StoreCatalogProvider cat) {
    if (cat.isLoading && cat.services.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator(color: AppColors.green)),
        ),
      ];
    }

    if (cat.error != null && cat.services.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CatalogEmpty(
            icon: Icons.wifi_off_rounded,
            title: cat.error!,
            actionLabel: 'إعادة المحاولة',
            onAction: () => context
                .read<StoreCatalogProvider>()
                .load(widget.store.id, force: true),
          ),
        ),
      ];
    }

    final groups = cat.visibleGroups;
    if (groups.isEmpty) {
      final searching = cat.search.trim().isNotEmpty;
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _CatalogEmpty(
            icon: searching ? Icons.search_off : Icons.inventory_2_outlined,
            title: searching ? 'لا صنف بهذا الاسم' : 'لا أصناف في هذه الخدمة',
            subtitle: searching
                ? 'جرّب اسماً آخر'
                : 'لم تضبط هذه المغسلة أصنافاً لهذه الخدمة بعد',
          ),
        ),
      ];
    }

    final out = <Widget>[];
    groups.forEach((groupName, products) {
      out.add(SliverToBoxAdapter(child: _GroupHeader(title: groupName)));
      out.add(SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => _ProductTile(
              product: products[i],
              onAdd: () => _add(products[i]),
            ),
            childCount: products.length,
          ),
        ),
      ));
    });
    return out;
  }
}

/// الغلاف المنزلق — يتقلّص إلى شريط بالاسم عند التمرير.
class _CoverAppBar extends StatelessWidget {
  const _CoverAppBar({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 170,
      pinned: true,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.gray80,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            if ((store.coverUrl ?? '').isNotEmpty)
              Image.network(
                Config.resolveImageUrl(store.coverUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const DecoratedBox(
                  decoration: BoxDecoration(gradient: AppColors.gradient),
                ),
              )
            else
              const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.gradient),
              ),
            // تدرّج أسفل الغلاف: زر الرجوع الأبيض يختفي فوق صورة فاتحة
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x33000000), Color(0x00000000)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// اسم المحل وتقييمه وبياناته أسفل الغلاف مباشرة.
class _StoreHeadline extends StatelessWidget {
  const _StoreHeadline({required this.store});
  final Store store;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  store.name,
                  style: AppTextStyles.sfarabicBold
                      .copyWith(fontSize: 20, color: AppColors.gray80),
                ),
              ),
              if (store.hasRating)
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 18, color: AppColors.orangeCard),
                    const SizedBox(width: 3),
                    Text(
                      store.rating.toStringAsFixed(1),
                      style: AppTextStyles.poppinsSemiBold
                          .copyWith(fontSize: 14, color: AppColors.gray80),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '(${store.ratingCount})',
                      style: AppTextStyles.poppinsRegular.copyWith(
                          fontSize: 11.5,
                          color: AppColors.secondaryTextColor),
                    ),
                  ],
                ),
            ],
          ),
          if ((store.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              store.description!,
              style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 13,
                height: 1.55,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
          if (store.turnaroundLabel != null || store.minOrderTotal > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (store.turnaroundLabel != null)
                  _Pill(
                    icon: Icons.schedule,
                    label: 'الجاهزية ${store.turnaroundLabel}',
                  ),
                if (store.turnaroundLabel != null && store.minOrderTotal > 0)
                  const SizedBox(width: 8),
                if (store.minOrderTotal > 0)
                  _Pill(
                    icon: Icons.shopping_bag_outlined,
                    label:
                        'أقلّ طلب ${store.minOrderTotal.toStringAsFixed(0)}₪',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.secondaryTextColor),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.sfarabicMedium.copyWith(
                fontSize: 11.5,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ],
        ),
      );
}

class _ServiceTabs extends StatelessWidget {
  const _ServiceTabs({
    required this.services,
    required this.selectedId,
    required this.onSelect,
  });

  final List<StoreService> services;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: 54,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = services[i];
          final selected = s.serviceId == selectedId;
          return Center(
            child: Material(
              color: selected ? AppColors.primaryColor : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelect(s.serviceId),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  child: Text(
                    s.serviceName,
                    style: AppTextStyles.sfarabicMedium.copyWith(
                      fontSize: 13,
                      color: selected ? AppColors.white : AppColors.gray60,
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
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.start,
        style: AppTextStyles.sfarabicRegular
            .copyWith(fontSize: 14, color: AppColors.gray80),
        decoration: InputDecoration(
          hintText: 'ابحث في أصناف المغسلة…',
          hintStyle: AppTextStyles.sfarabicRegular
              .copyWith(fontSize: 14, color: AppColors.inactiveColor),
          prefixIcon: const Icon(Icons.search, color: AppColors.inactiveColor),
          filled: true,
          fillColor: AppColors.backgroundColor,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Text(
          title,
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 15.5, color: AppColors.gray80),
        ),
      );
}

/// سطر الصنف: صورة، اسم، سعر، وعدّاد.
///
/// العدّاد يقرأ الكمية من السلّة لا من حالة محلية: الزبون قد يحذف الصنف
/// من شاشة السلّة ثم يعود، فالعدّاد المحلي يكذب عليه.
class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onAdd});

  final StoreProduct product;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final line = _lineFor(order, product);
    final qty = line?.quantity ?? 0;
    final discount = product.discountPercent;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 62,
              height: 62,
              child: (product.imagePath ?? '').isEmpty
                  ? const _ProductImageFallback()
                  : Image.network(
                      Config.resolveImageUrl(product.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _ProductImageFallback(),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfarabicMedium
                      .copyWith(fontSize: 14, color: AppColors.gray80),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${product.effectivePrice.toStringAsFixed(2)}₪',
                      style: AppTextStyles.poppinsSemiBold
                          .copyWith(fontSize: 14, color: AppColors.green),
                    ),
                    if (discount != null) ...[
                      const SizedBox(width: 7),
                      Text(
                        '${product.price.toStringAsFixed(2)}₪',
                        style: AppTextStyles.poppinsRegular.copyWith(
                          fontSize: 11.5,
                          color: AppColors.secondaryTextColor,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-$discount%',
                          style: AppTextStyles.poppinsSemiBold
                              .copyWith(fontSize: 10, color: AppColors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _Stepper(
            quantity: qty,
            onAdd: onAdd,
            onRemove: line == null
                ? null
                : () => context.read<OrderProvider>().removeProduct(line),
          ),
        ],
      ),
    );
  }

  /// سطر السلّة المطابق: نفس المنتج ونفس الخدمة.
  ///
  /// المطابقة بالاثنين معاً لا بالمنتج وحده — القميص المكوي والقميص
  /// المغسول سطران مستقلّان بسعرين مختلفين.
  BasketItemData? _lineFor(OrderProvider order, StoreProduct p) {
    for (final item in order.cart) {
      if (item.productId == p.productId &&
          item.serviceType.id == p.serviceId) {
        return item;
      }
    }
    return null;
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.backgroundColor,
        alignment: Alignment.center,
        child: const Icon(Icons.checkroom,
            size: 26, color: AppColors.inactiveColor),
      );
}

/// عدّاد الكمية — زر واحد قبل الإضافة، وثلاثة بعدها.
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (quantity == 0) {
      return Material(
        color: AppColors.green,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onAdd,
          child: const Padding(
            padding: EdgeInsets.all(7),
            child: Icon(Icons.add, size: 20, color: AppColors.white),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.greenCardBackgourd,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            // الحذف عند 1 لا التعطيل: العدّاد لا ينزل إلى صفر، فالطريق
            // الوحيد لإزالة الصنف من هنا هو سلّة المهملات
            icon: quantity == 1 ? Icons.delete_outline : Icons.remove,
            onTap: onRemove,
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.poppinsSemiBold
                  .copyWith(fontSize: 14, color: AppColors.gray80),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onAdd),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 18, color: AppColors.green),
          ),
        ),
      );
}

/// شريط السلّة الثابت — يظهر فقط حين تكون السلّة من هذا المحل.
///
/// إخفاؤه عند اختلاف المحل مقصود: عرض «٣ أصناف · ٤٥₪» أسفل كتالوج محل
/// آخر يوهم الزبون أن السلّة من هنا.
class _BasketBar extends StatelessWidget {
  const _BasketBar({required this.storeId, this.onCheckout});

  final int storeId;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>();
    final mine = order.cart.isNotEmpty && order.storeId == storeId;
    if (!mine) return const SizedBox.shrink();

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Material(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onCheckout,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${order.totalQuantity}',
                    style: AppTextStyles.poppinsSemiBold
                        .copyWith(fontSize: 13, color: AppColors.green),
                  ),
                ),
                const SizedBox(width: 11),
                Text(
                  'عرض السلّة',
                  style: AppTextStyles.sfarabicBold
                      .copyWith(fontSize: 15, color: AppColors.white),
                ),
                const Spacer(),
                Text(
                  '${order.subtotal.toStringAsFixed(2)}₪',
                  style: AppTextStyles.poppinsSemiBold
                      .copyWith(fontSize: 15, color: AppColors.white),
                ),
              ],
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
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.blueCardBackgourd,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.blueCard),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.sfarabicBold
                    .copyWith(fontSize: 15.5, color: AppColors.gray80),
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
                const SizedBox(height: 14),
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
        ),
      );
}
