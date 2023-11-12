// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

/// A barrier for a WaterFX component.
///
/// This can be used to make sure certain areas of the child widget can always
/// be seen clearly, to make sure that certain areas cannot be 'touched', or
/// both of these things.
abstract class Barrier {
  /// Returns true if this barrier contains the point, false otherwise.
  ///
  /// Note: Implementations of this method should be as efficient as possible.
  /// This is because this method will be called for every pixel in the image of
  /// the child widget. So if the implementation is not very efficient, it will
  /// slow down the animation considerably. For this reason, [Barrier]s should
  /// be simple shapes with efficient [containsPoint] methods.
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight);

  /// The type of this barrier.
  BarrierType type = BarrierType.rippleAndTouch;

  /// Whether or not this barrier is currently active.
  bool isActive = true;
}

/// The type of barrier.
///
/// A [Barrier] can block ripples from entering the area of the barrier, it can
/// block touches within the area of the barrier, or it can do both things.
enum BarrierType {
  /// A [Barrier] of this type blocks ripples from entering the area of the
  /// barrier. It does not block touches within the area of the barrier, but any
  /// ripples created by touches within the barrier will only be shown outside
  /// the barrier.
  ripple,

  /// A [Barrier] of this type blocks touches within the area of the barrier. No
  /// ripples will be created as a result of a touch within a barrier of this
  /// type, but any ripples created by touches outside the barrier may be shown
  /// inside the barrier.
  touch,

  /// A [Barrier] of this type blocks ripples from entering the area of the
  /// barrier, as well as blocking touches within this area. No ripples will be
  /// created as a result of a touch within a barrier of this type, and any
  /// ripples created by touches outside the barrier will not be shown inside
  /// the barrier.
  rippleAndTouch,
}
