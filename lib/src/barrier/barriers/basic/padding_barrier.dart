// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'package:flutter/material.dart';
import '../../barrier.dart';

// A [Barrier] around the inside edges of the container.
class PaddingBarrier implements Barrier {
  final EdgeInsets edgeInsets;

  /// The type of this barrier.
  ///
  /// A [Barrier] can block ripples from entering the area of the barrier, it
  /// can block touches within the area of the barrier, or it can do both
  /// things.
  @override
  BarrierType type;

  /// Whether or not this barrier is currently active.
  @override
  bool isActive;

  PaddingBarrier(
    this.edgeInsets, {
    this.type = BarrierType.rippleAndTouch,
    this.isActive = true,
  });

  @override
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight) =>
      isActive
          ? pointX < edgeInsets.left ||
              pointX > (imageWidth - edgeInsets.right) ||
              pointY < edgeInsets.top ||
              pointY > (imageHeight - edgeInsets.bottom)
          : false;
}
