import 'package:flutter/material.dart';
// hide TextDirection: حزمة intl تُصدّر نوعاً بالاسم نفسه بلا `rtl`،
// فيحجب نوع Flutter ويكسر أي اتجاه صريح في الملف
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:saleem_dry_clean/services/Providers/AccountExtrasProvider.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

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

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.gray80,
        elevation: 0,
        title: Text(
          'تقييماتي',
          style: AppTextStyles.sfarabicBold
              .copyWith(fontSize: 16.5, color: AppColors.gray80),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.green,
        onRefresh: () =>
            context.read<AccountExtrasProvider>().loadRatings(force: true),
        child: _body(p),
      ),
    );
  }

  Widget _body(AccountExtrasProvider p) {
    if (p.isLoadingRatings && p.ratings.isEmpty) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.green));
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
            p.ratingsError ?? 'لم تقيّم أي طلب بعد',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicBold
                .copyWith(fontSize: 15, color: AppColors.gray80),
          ),
          const SizedBox(height: 6),
          Text(
            p.ratingsError == null
                ? 'بعد استلام طلبك يمكنك تقييم المغسلة والسائق'
                : 'اسحب للأسفل لإعادة المحاولة',
            textAlign: TextAlign.center,
            style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12.5, color: AppColors.secondaryTextColor),
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
                  rating.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sfarabicBold
                      .copyWith(fontSize: 14.5, color: AppColors.gray80),
                ),
              ),
              _Stars(score: rating.score),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                'طلب #${rating.orderId}',
                style: AppTextStyles.poppinsRegular.copyWith(
                    fontSize: 11.5, color: AppColors.secondaryTextColor),
              ),
              if (rating.at != null) ...[
                const SizedBox(width: 8),
                Text(
                  DateFormat('d MMMM yyyy', 'ar').format(rating.at!.toLocal()),
                  style: AppTextStyles.sfarabicRegular.copyWith(
                      fontSize: 11.5, color: AppColors.secondaryTextColor),
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
                style: AppTextStyles.sfarabicRegular.copyWith(
                    fontSize: 13, height: 1.5, color: AppColors.gray70),
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
        textDirection: TextDirection.rtl,
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
