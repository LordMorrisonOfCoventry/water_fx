// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:ui';

import '../../barrier.dart';

/// A solid ellipse [Barrier].
class SolidEllipseBarrier implements Barrier {
  final int centerX;
  final int centerY;
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

  SolidEllipseBarrier({
    required this.centerX,
    required this.centerY,
    required this.width,
    required this.height,
    this.type = BarrierType.rippleAndTouch,
    this.isActive = true,
  });

  SolidEllipseBarrier.fromLTWH(
    int leftX,
    int topY,
    int width,
    int height, {
    BarrierType type = BarrierType.rippleAndTouch,
    bool isActive = true,
  }) : this(
            centerX: leftX + width ~/ 2,
            centerY: topY + height ~/ 2,
            width: width,
            height: height,
            type: type,
            isActive: isActive);

  SolidEllipseBarrier.fromRect(
    Rect rect, {
    BarrierType type = BarrierType.rippleAndTouch,
    bool isActive = true,
  }) : this(
            centerX: rect.left.toInt() + rect.width ~/ 2,
            centerY: rect.top.toInt() + rect.height ~/ 2,
            width: rect.width.toInt(),
            height: rect.height.toInt(),
            type: type,
            isActive: isActive);

  @override
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight) {
    if (!isActive) {
      return false;
    }
    double normalizedX = (pointX - centerX) / width * 2;
    double normalizedY = (pointY - centerY) / height * 2;
    return ((normalizedX * normalizedX) + (normalizedY * normalizedY)) <= 1.0;
  }
}
