import 'package:flutter/material.dart';
import 'package:saleem_dry_clean/theme/AppColors.dart';

class BlankModal extends StatefulWidget {
  final double fem;
  final Widget initialContent;
  final bool isDismissible;

  const BlankModal({
    Key? key,
    required this.fem,
    required this.initialContent,
    this.isDismissible = true, // Default to true if not specified
  }) : super(key: key);

  static void show(BuildContext context, double fem, Widget initialContent,
      {bool isDismissible = true}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag:
          isDismissible, // This prevents dragging to close if not dismissible
      builder: (context) => BlankModal(
          fem: fem,
          initialContent: initialContent,
          isDismissible: isDismissible),
    );
  }

  @override
  BlankModalState createState() => BlankModalState();
}

class BlankModalState extends State<BlankModal> {
  late Widget _content;

  @override
  void initState() {
    super.initState();
    _content = widget.initialContent;
  }

  void updateContent(Widget newContent) {
    setState(() {
      _content = newContent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0 * widget.fem),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.green, width: 2),
        ),
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(16.0 * widget.fem)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height - 56 * widget.fem,
        minHeight: MediaQuery.of(context).size.height - 56 * widget.fem,
      ),
      child: _content,
    );
  }
}
