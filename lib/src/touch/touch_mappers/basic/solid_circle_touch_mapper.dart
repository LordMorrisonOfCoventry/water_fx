// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import '../../touch.dart';

/// Maps touches at specific points within the container to [Touch] objects,
/// that are circular with a configurable diameter.
class SolidCircleTouchMapper implements TouchMapper {
  final int diameter;

  /// The strength of the touch. This value must be in the range 0.0 - 1.0,
  /// where 1.0 will cause the largest ripple in the water, and 0.0 will cause
  /// no ripple.
  final double touchStrengthUnit;

  /// Creates the [SolidCircleTouchMapper].
  const SolidCircleTouchMapper({
    required this.diameter,
    this.touchStrengthUnit = _defaultTouchStrengthUnit,
  });

  @override
  Touch getTouchForPoint(
      int pointX, int pointY, int imageWidth, int imageHeight) {
    List<TouchPoint> touchPoints = [];
    int radius = diameter ~/ 2;
    for (int x = pointX - radius; x <= pointX + radius; x++) {
      for (int y = pointY - radius; y <= pointY + radius; y++) {
        if (_pointIsWithinContainer(x, y, imageWidth, imageHeight) &&
            _pointIsWithinCircle(x, y, pointX, pointY, radius)) {
          touchPoints
              .add(TouchPoint(x, y, touchStrengthUnit: touchStrengthUnit));
        }
      }
    }
    return Touch(touchPoints);
  }

  bool _pointIsWithinContainer(int x, int y, int imageWidth, int imageHeight) =>
      x >= 0 && x < imageWidth && y >= 0 && y < imageHeight;

  bool _pointIsWithinCircle(
          int x, int y, int centerX, int centerY, int radius) =>
      (x - centerX) * (x - centerX) + (y - centerY) * (y - centerY) <=
      radius * radius;
}

const double _defaultTouchStrengthUnit = 1;
