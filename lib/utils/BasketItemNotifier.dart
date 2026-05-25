import 'package:flutter/material.dart';

class BasketItemNotifier {
  ValueNotifier<_BasketItemState?> currentlyOpenItem =
      ValueNotifier<_BasketItemState?>(null);
}

class _BasketItemState {
  void close() {}
}

final basketItemNotifier = BasketItemNotifier();
