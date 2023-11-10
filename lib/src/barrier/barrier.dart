// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

/// A barrier through which the ripples of the [WaterFXContainer] cannot pass.
///
/// This can be used to make sure certain areas of the child widget can always
/// be seen clearly. It can also be used to observe how waves move around solid
/// objects.
abstract class Barrier {
  /// Returns true if this barrier contains the point, false otherwise.
  ///
  /// Note: Implementations of this method should be as efficient as possible.
  /// This is because this method will be called for every pixel in the image of
  /// the child widget. So if the implementation is not very efficient, it will
  /// slow down the animation considerably. For this reason, [Barrier]s should
  /// be simple shapes with efficient [containsPoint] methods.
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight);

  /// Whether or not this barrier is currently active.
  bool isActive = true;
}

/// A [Barrier] that groups together other barriers ([_barriers]).
///
/// The [containsPoint] method returns true if the point is contained within any
/// of the barriers in [_barriers].
class CompoundBarrier implements Barrier {
  /// The barriers that make up this compound barrier.
  final List<Barrier> _barriers;

  /// Whether or not this barrier is currently active.
  @override
  bool isActive;

  CompoundBarrier(this._barriers, {this.isActive = true});

  /// Returns true if this barrier contains the point, false otherwise.
  @override
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight) =>
      isActive
          ? _barriers.any((barrier) =>
              barrier.containsPoint(pointX, pointY, imageWidth, imageHeight))
          : false;
}
