// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import '../../touch.dart';

/// Maps touches at specific points within the container to [Touch] objects,
/// that are rectangular with a configurable width and height.
class SolidRectTouchMapper implements TouchMapper {
  final int width;
  final int height;

  /// The strength of the touch. This value must be in the range 0.0 - 1.0,
  /// where 1.0 will cause the largest ripple in the water, and 0.0 will cause
  /// no ripple.
  final double touchStrengthUnit;

  /// Creates the [SolidRectTouchMapper].
  const SolidRectTouchMapper({
    required this.width,
    required this.height,
    this.touchStrengthUnit = _defaultTouchStrengthUnit,
  });

  @override
  Touch getTouchForPoint(
      int pointX, int pointY, int imageWidth, int imageHeight) {
    List<TouchPoint> touchPoints = [];
    int halfWidth = width ~/ 2;
    int halfHeight = height ~/ 2;
    for (int x = pointX - halfWidth; x < pointX + halfWidth; x++) {
      for (int y = pointY - halfHeight; y < pointY + halfHeight; y++) {
        if (_pointIsWithinContainer(x, y, imageWidth, imageHeight)) {
          touchPoints
              .add(TouchPoint(x, y, touchStrengthUnit: touchStrengthUnit));
        }
      }
    }
    return Touch(touchPoints);
  }

  bool _pointIsWithinContainer(
          int pointX, int pointY, int imageWidth, int imageHeight) =>
      pointX >= 0 && pointX < imageWidth && pointY >= 0 && pointY < imageHeight;
}

const double _defaultTouchStrengthUnit = 1;
