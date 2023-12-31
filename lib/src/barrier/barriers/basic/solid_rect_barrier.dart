// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:ui';

import '../../barrier.dart';

// A solid rectangle [Barrier].
class SolidRectBarrier implements Barrier {
  final int leftX;
  final int topY;
  final int width;
  final int height;

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

  SolidRectBarrier({
    required this.leftX,
    required this.topY,
    required this.width,
    required this.height,
    this.type = BarrierType.rippleAndTouch,
    this.isActive = true,
  });

  SolidRectBarrier.fromLTWH(
    int leftX,
    int topY,
    int width,
    int height, {
    BarrierType type = BarrierType.rippleAndTouch,
    bool isActive = true,
  }) : this(
            leftX: leftX,
            topY: topY,
            width: width,
            height: height,
            type: type,
            isActive: isActive);

  SolidRectBarrier.fromRect(
    Rect rect, {
    BarrierType type = BarrierType.rippleAndTouch,
    bool isActive = true,
  }) : this(
            leftX: rect.left.toInt(),
            topY: rect.top.toInt(),
            width: rect.width.toInt(),
            height: rect.height.toInt(),
            type: type,
            isActive: isActive);

  @override
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight) =>
      isActive
          ? pointX >= leftX &&
              pointX < (leftX + width) &&
              pointY >= topY &&
              pointY < (topY + height)
          : false;
}
