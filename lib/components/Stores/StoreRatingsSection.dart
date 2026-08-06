import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:saleem_dry_clean/services/ApiClient/config.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

/// كتلة تقييم المحل (٢.١.٣): متوسّط عام، ثلاثة محاور، وتعليقات تُفتح
/// بزرّ.
///
/// ★ لماذا التعليقات مطويّة ★
///
/// الوثيقة تطلب زرّ Expand. والسبب أن الزبون في هذه الشاشة يريد أن
/// يطلب: الأرقام تحسم قراره في ثانيتين، والتعليقات لمن يريد التدقيق.
/// عرضها مفتوحة يدفع قائمة الأصناف — وهي غرض الشاشة — إلى أسفل الشاشة.
class StoreRatingsSection extends StatefulWidget {
  const StoreRatingsSection({super.key, required this.storeId});
  final int storeId;

  @override
  State<StoreRatingsSection> createState() => _StoreRatingsSectionState();
}

class _StoreRatingsSectionState extends State<StoreRatingsSection> {
  final _client = http.Client();

  bool _loading = true;
  bool _expanded = false;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await _client.get(Uri.parse(
          '${Config.storeDetailsApi}/${widget.storeId}/ratings?limit=10'));
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() => _data = Map<String, dynamic>.from(
            jsonDecode(res.body) as Map));
      }
    } catch (_) {
      // فشل التقييمات لا يُسقط صفحة المحل: الكتلة تختفي والأصناف تبقى
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double? _avg(String axis) {
    final a = (_data?['axes'] as Map?)?[axis] as Map?;
    final v = a?['average'];
    return v == null ? null : double.tryParse('$v');
  }

  int _count(String axis) {
    final a = (_data?['axes'] as Map?)?[axis] as Map?;
    return int.tryParse('${a?['count'] ?? 0}') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const SizedBox.shrink();

    final total = int.tryParse('${_data?['totalCount'] ?? 0}') ?? 0;
    // محل بلا تقييمات: لا كتلة فارغة ولا «٠٫٠ ★» — الصفر يقرأ كأسوأ
    // تقييم ممكن لا كغياب تقييم
    if (total == 0) return const SizedBox.shrink();

    final overall = double.tryParse('${_data?['overall'] ?? 0}') ?? 0;
    final comments = (_data?['comments'] as List?) ?? const [];

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'التقييم',
                style: AppTextStyles.sfarabicBold
                    .copyWith(fontSize: 15, color: AppColors.gray80),
              ),
              const SizedBox(width: 8),
              Text(
                '(${overall.toStringAsFixed(1)})',
                style: AppTextStyles.poppinsSemiBold
                    .copyWith(fontSize: 14, color: AppColors.green),
              ),
              const Spacer(),
              Text(
                '$total تقييم',
                style: AppTextStyles.sfarabicRegular.copyWith(
                    fontSize: 12, color: AppColors.secondaryTextColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AxisRow(
            icon: Icons.local_laundry_service_outlined,
            label: 'جودة الخدمة',
            score: _avg('service'),
            count: _count('service'),
          ),
          _AxisRow(
            icon: Icons.inventory_2_outlined,
            label: 'الاستلام',
            score: _avg('pickup'),
            count: _count('pickup'),
          ),
          _AxisRow(
            icon: Icons.delivery_dining_outlined,
            label: 'التوصيل',
            score: _avg('delivery'),
            count: _count('delivery'),
          ),
          if (comments.isNotEmpty) ...[
            const SizedBox(height: 4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 19,
                  color: AppColors.green,
                ),
                label: Text(
                  _expanded
                      ? 'إخفاء التعليقات'
                      : 'عرض التعليقات (${comments.length})',
                  style: AppTextStyles.sfarabicMedium
                      .copyWith(fontSize: 13, color: AppColors.green),
                ),
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 8),
              ...comments.map((c) => _CommentTile(
                    data: Map<String, dynamic>.from(c as Map),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _AxisRow extends StatelessWidget {
  const _AxisRow({
    required this.icon,
    required this.label,
    required this.score,
    required this.count,
  });

  final IconData icon;
  final String label;
  final double? score;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppColors.secondaryTextColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.sfarabicMedium
                  .copyWith(fontSize: 13.5, color: AppColors.gray70),
            ),
          ),
          if (score == null)
            Text(
              // محور بلا تقييم يُقال صراحةً: صفر يقرأ كأسوأ تقييم
              'لا تقييم بعد',
              style: AppTextStyles.sfarabicRegular.copyWith(
                  fontSize: 11.5, color: AppColors.inactiveColor),
            )
          else ...[
            Text(
              score!.toStringAsFixed(1),
              style: AppTextStyles.poppinsSemiBold
                  .copyWith(fontSize: 13.5, color: AppColors.gray80),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.star_rounded,
                size: 16, color: AppColors.orangeCard),
            const SizedBox(width: 5),
            Text(
              '($count)',
              style: AppTextStyles.poppinsRegular.copyWith(
                  fontSize: 11, color: AppColors.secondaryTextColor),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final score = int.tryParse('${data['score'] ?? 0}') ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                (data['author'] ?? 'زبون').toString(),
                style: AppTextStyles.sfarabicMedium
                    .copyWith(fontSize: 12.5, color: AppColors.gray80),
              ),
              const SizedBox(width: 8),
              Row(
                textDirection: TextDirection.rtl,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < score ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 13,
                    color: i < score
                        ? AppColors.orangeCard
                        : AppColors.inactiveColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (data['comment'] ?? '').toString(),
            style: AppTextStyles.sfarabicRegular.copyWith(
                fontSize: 12.5, height: 1.5, color: AppColors.gray70),
          ),
        ],
      ),
    );
  }
}
