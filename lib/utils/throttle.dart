// lib/utils/throttle.dart

import 'dart:async';

import 'package:flutter/material.dart';

class Throttle {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Throttle({required this.milliseconds});

  run(VoidCallback action) {
    if (_timer?.isActive ?? false) return;
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  cancel() {
    _timer?.cancel();
  }
}
