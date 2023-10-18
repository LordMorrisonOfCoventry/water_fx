// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:math';

import '../../touch.dart';
import '../../touch_mappers/basic/solid_circle_touch_mapper.dart';

/// Maps touches at specific points within the container to [Touch] objects,
/// that are circular with a random touch strength. The diameter of the circle
/// is dependant on the touch strength, simulating bigger rain drops hitting the
/// water with more force.
class RainTouchMapper implements TouchMapper {
  final Random _random = Random();

  @override
  Touch getTouchForPoint(
      int pointX, int pointY, int imageWidth, int imageHeight) {
    double touchStrengthUnit = _touchStrengthUnit;
    return SolidCircleTouchMapper(
            diameter: (touchStrengthUnit * 5).toInt(),
            touchStrengthUnit: touchStrengthUnit)
        .getTouchForPoint(pointX, pointY, imageWidth, imageHeight);
  }

  double get _touchStrengthUnit => _random.nextDouble();
}
