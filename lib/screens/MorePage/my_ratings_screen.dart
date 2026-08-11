import 'package:flutter/material.dart';
// hide TextDirection: حزمة intl تُصدّر نوعاً بالاسم نفسه بلا `rtl`،
// فيحجب نوع Flutter ويكسر أي اتجاه صريح في الملف
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/AccountExtrasProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/localization.dart';

/// سجلّ تقييمات الزبون السابقة (٢.١.٨).
///
/// ★ لماذا يهمّ ★
///
/// الزبون يقيّم ثم ينسى، ثم يطلب من المحل نفسه بعد شهر ويسأل: هل كانت
/// تجربتي جيّدة؟ والسجلّ يجيبه — وهو أيضاً ما يجعله يثق بأن تقييمه
/// وصل ولم يذهب سدى.
class MyRatingsScreen extends StatefulWidget {
  const MyRatingsScreen({super.key});

  @override
  State<MyRatingsScreen> createState() => _MyRatingsScreenState();
}

class _MyRatingsScreenState extends State<MyRatingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountExtrasProvider>().loadRatings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AccountExtrasProvider>();
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          localizations.translate('my_ratings'),
          style: AppTextStyles.getFontFamily(
            context,
            AppTextStyles.sfarabicBold.copyWith(
              fontSize: 16.5,
              color: AppColors.gray80,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.green,
        onRefresh: () =>
            context.read<AccountExtrasProvider>().loadRatings(force: true),
        child: _body(p, localizations),
      ),
    );
  }

  Widget _body(AccountExtrasProvider p, AppLocalizations localizations) {
    if (p.isLoadingRatings && p.ratings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.green),
      );
    }

    if (p.ratings.isEmpty) {
      // ListView لا Center: السحب للتحديث يحتاج ابناً قابلاً للتمرير
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 70),
          Icon(
            p.ratingsError != null ? Icons.wifi_off_rounded : Icons.star_border,
            size: 54,
            color: AppColors.inactiveColor,
          ),
          const SizedBox(height: 14),
          Text(
            p.ratingsError == null
                ? localizations.translate('more_no_ratings_yet')
                : localizations.translate(p.ratingsError!),
            textAlign: TextAlign.center,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.sfarabicBold.copyWith(
                fontSize: 15,
                color: AppColors.gray80,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            p.ratingsError == null
                ? localizations.translate('more_ratings_empty_hint')
                : localizations.translate('more_pull_to_retry'),
            textAlign: TextAlign.center,
            style: AppTextStyles.getFontFamily(
              context,
              AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12.5,
                color: AppColors.secondaryTextColor,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      itemCount: p.ratings.length,
      itemBuilder: (_, i) => _RatingCard(rating: p.ratings[i]),
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating});
  final MyRating rating;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final ratingLabel = (rating.targetName ?? '').trim().isNotEmpty
        ? rating.targetName!.trim()
        : localizations.translate(rating.labelKey);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                rating.target == 'dryclean'
                    ? Icons.local_laundry_service_outlined
                    : Icons.delivery_dining_outlined,
                size: 19,
                color: AppColors.secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ratingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.sfarabicBold.copyWith(
                      fontSize: 14.5,
                      color: AppColors.gray80,
                    ),
                  ),
                ),
              ),
              _Stars(score: rating.score),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                localizations.translate(
                  'more_order_number',
                  params: {'number': '${rating.orderId}'},
                ),
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.poppinsRegular.copyWith(
                    fontSize: 11.5,
                    color: AppColors.secondaryTextColor,
                  ),
                ),
              ),
              if (rating.at != null) ...[
                const SizedBox(width: 8),
                Text(
                  DateFormat(
                    'd MMMM yyyy',
                    languageCode,
                  ).format(rating.at!.toLocal()),
                  style: AppTextStyles.getFontFamily(
                    context,
                    AppTextStyles.sfarabicRegular.copyWith(
                      fontSize: 11.5,
                      color: AppColors.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if ((rating.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rating.comment!,
                style: AppTextStyles.getFontFamily(
                  context,
                  AppTextStyles.sfarabicRegular.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.gray70,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// النجوم الخمس بالترتيب العربي — الأولى أقصى اليمين.
class _Stars extends StatelessWidget {
  const _Stars({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(5, (i) {
      final filled = i < score;
      return Icon(
        filled ? Icons.star_rounded : Icons.star_border_rounded,
        size: 17,
        color: filled ? AppColors.orangeCard : AppColors.inactiveColor,
      );
    }),
  );
}
