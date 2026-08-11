import 'package:saleem_dry_clean/ui.dart';
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/components/Stores/StoresBrowser.dart';
import 'package:saleem_dry_clean/services/Models/Store.dart';
import 'package:saleem_dry_clean/services/Providers/StoresProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

/// قائمة المغاسل كشاشة مستقلّة.
///
/// ★ لماذا لم تعد تحمل منطقها بنفسها ★
///
/// الرئيسية صارت تعرض القائمة نفسها (٢.١.١)، ونسختان من البحث والفلاتر
/// تنفردان عن بعضهما عند أول تعديل. فالمحتوى انتقل إلى [StoresBrowser]،
/// وما تبقّى هنا شريط علوي وزرّ رجوع.
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key, this.areaId, this.onStoreSelected});

  final int? areaId;

  /// محفوظة لمن يستدعي الشاشة بمسار خاص — التوجيه الافتراضي داخل
  /// [StoresBrowser] يفتح كتالوج المحل
  final void Function(Store store)? onStoreSelected;

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.areaId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StoresProvider>().setArea(widget.areaId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          l10n.translate('stores_screen_title'),
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 16.5, color: AppColors.gray80),
        ),
      ),
      body: SafeArea(
        child: StoresBrowser(
          subtitle: l10n.translate('stores_choose_subtitle'),
        ),
      ),
    );
  }
}
