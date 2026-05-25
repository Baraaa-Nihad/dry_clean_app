import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:saleem_dry_clean/components/buttons/ActionButtons.dart';
import 'package:saleem_dry_clean/components/buttons/SecondaryButton.dart';
import 'package:saleem_dry_clean/components/inputs/SizeInputCard.dart';
import 'package:saleem_dry_clean/style/AppTextStyles.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';
import 'package:saleem_dry_clean/utils/KeyboardUtils/KeyboardUtils.dart';

class CustomSizeComponent extends StatefulWidget {
  final String title;
  final String subTitle;
  final List<Map<String, dynamic>> items;
  final double fem;
  final ScrollController scrollController;

  const CustomSizeComponent({
    Key? key,
    required this.title,
    required this.subTitle,
    required this.items,
    required this.fem,
    required this.scrollController,
  }) : super(key: key);

  @override
  _CustomSizeComponentState createState() => _CustomSizeComponentState();
}

class _CustomSizeComponentState extends State<CustomSizeComponent> {
  bool isExpanded = false;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final FocusNode _heightFocusNode = FocusNode();
  final FocusNode _widthFocusNode = FocusNode();

  @override
  void dispose() {
    _heightController.dispose();
    _widthController.dispose();
    _heightFocusNode.dispose();
    _widthFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (mounted) {
      setState(() {
        isExpanded = !isExpanded;
        if (isExpanded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (widget.scrollController.hasClients) {
              widget.scrollController.animateTo(
                widget.scrollController.position.maxScrollExtent + 200,
                duration: Duration(milliseconds: 800),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        dismissKeyboard(context);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * widget.fem),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12 * widget.fem),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GestureDetector(
              //   onTap: _toggleExpanded,
              //   child: Padding(
              //     padding: EdgeInsets.all(16 * widget.fem),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           widget.title,
              //           style: AppTextStyles.getFontFamily(
              //             context,
              //             AppTextStyles.bold16Gray80(context).copyWith(
              //               fontSize: 16.0 * widget.fem,
              //             ),
              //           ),
              //         ),
              //         Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              //       ],
              //     ),
              //   ),
              // ),
              Divider(
                color: AppColors.gray20,
                thickness: 0.5,
                height: 0.5,
              ),
              Padding(
                padding: EdgeInsets.all(12 * widget.fem),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.items.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> item = entry.value;

                      return Column(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(12 * widget.fem),
                                child: CachedNetworkImage(
                                  imageUrl: item['imagePath'] ?? '',
                                  width: 48 * widget.fem,
                                  height: 48 * widget.fem,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 48 * widget.fem,
                                    height: 48 * widget.fem,
                                    color: AppColors.gray10,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16 * widget.fem),
                              Expanded(
                                child: Text(
                                  item['label']!,
                                  style: AppTextStyles.getFontFamily(
                                    context,
                                    AppTextStyles.regular16Gray70(context)
                                        .copyWith(
                                      fontSize: 16.0 * widget.fem,
                                    ),
                                  ),
                                ),
                              ),
                              SvgPicture.asset(
                                'assets/vectors/plus_icon.svg',
                                width: 48 * widget.fem,
                                height: 48 * widget.fem,
                              ),
                            ],
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              Divider(
                color: AppColors.gray20,
                thickness: 0.5,
              ),
              AnimatedCrossFade(
                duration: Duration(milliseconds: 400),
                firstChild: Padding(
                  padding: EdgeInsets.all(16 * widget.fem),
                  child: SecondaryButton(
                    buttonWidth: "full",
                    fem: widget.fem,
                    text: 'Add Custom Size',
                    onPressed: _toggleExpanded,
                  ),
                ),
                secondChild: Padding(
                  padding: EdgeInsets.all(16 * widget.fem),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        transform: isExpanded
                            ? Matrix4.translationValues(0, 0, 0)
                            : Matrix4.translationValues(0, -200, 0),
                        child: SizeInputCard(
                          fem: widget.fem,
                          heightController: _heightController,
                          widthController: _widthController,
                          heightFocusNode: _heightFocusNode,
                          widthFocusNode: _widthFocusNode,
                          onCancel: _toggleExpanded,
                          onAdd: () {
                            setState(() {
                              isExpanded = false;
                            });
                          },
                          isFullWidth: false,
                          isExpanded: isExpanded,
                        ),
                      ),
                    ],
                  ),
                ),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
