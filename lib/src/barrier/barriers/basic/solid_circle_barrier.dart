// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import '../../barrier.dart';

// A solid circle [Barrier].
class SolidCircleBarrier implements Barrier {
  final int centerX;
  final int centerY;
  final int radius;

  /// Whether or not this barrier is currently active.
  @override
  bool isActive;

  SolidCircleBarrier({
    required this.centerX,
    required this.centerY,
    required this.radius,
    this.isActive = true,
  });

  @override
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight) {
    if (!isActive) {
      return false;
    }
    int dx = pointX - centerX;
    int dy = pointY - centerY;
    int squaredDistance = (dx * dx) + (dy * dy);
    int squaredRadius = radius * radius;
    return squaredDistance <= squaredRadius;
  }
}
