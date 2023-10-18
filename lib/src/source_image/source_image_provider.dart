// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:ui' as dart_ui;

/// Provides [dart_ui.Image]s on demand.
///
/// These are the source images, which will have the water effect applied to
/// them. The source images may always be the same, like when we want to apply
/// the water effect to a static image. Or they may be different each time
/// [sourceImage] is called, like when we want to apply the water effect to a
/// video or an image of a non-static UI component. Even though the images can
/// be different, they should always be quite small in order for the water
/// effect to perform well. 300 x 300 pixels seems to usually work quite well,
/// but as it gets bigger than this, the speed and quality of the animation will
/// start to go down.
abstract class SourceImageProvider {
  /// Returns a source image, that will have the water effect applied to it.
  Future<dart_ui.Image?> get sourceImage;

  /// Whether or not the source images may change on subsequent calls.
  ///
  /// The source images will not change over time if we are using a still,
  /// non-changing image. They will change over time if they are images of a
  /// video, or some piece of UI that can change (e.g. if it contains toggle
  /// buttons or sliders).
  ///
  /// To ensure best performance of the water animation, this is should always
  /// return true if your image is static (i.e it will not change over time).
  bool get sourceImagesMayChangeOverTime;
}
