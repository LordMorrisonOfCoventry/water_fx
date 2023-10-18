// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import '../../touch.dart';

/// Maps touches at specific points within the container to [Touch] objects
/// that represent only that same point. So these touches are only one pixel in
/// size, and are at the same location within the container as the specified
/// point.
class SinglePixelTouchMapper implements TouchMapper {
  /// The strength of the touch. This value must be in the range 0.0 - 1.0,
  /// where 1.0 will cause the largest ripple in the water, and 0.0 will cause
  /// no ripple.
  final double touchStrengthUnit;

  /// Creates the [SinglePixelTouchMapper].
  const SinglePixelTouchMapper({
    this.touchStrengthUnit = 1,
  });

  @override
  Touch getTouchForPoint(
          int pointX, int pointY, int imageWidth, int imageHeight) =>
      Touch([TouchPoint(pointX, pointY, touchStrengthUnit: touchStrengthUnit)]);
}
