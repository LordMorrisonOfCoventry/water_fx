// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:ui' as dart_ui;
import 'source_image_provider.dart';

/// An [SourceImageProvider] for an image that is static, meaning it will not change.
class StaticSourceImageProvider implements SourceImageProvider {
  /// The [dart_ui.Image] that will be returned when [sourceImage] is called.
  final dart_ui.Image? _image;

  /// Creates this [StaticSourceImageProvider] with a static [dart_ui.Image].
  ///
  /// This provider will always return this same image when [sourceImage] is called.
  const StaticSourceImageProvider(this._image);

  /// Returns [_image].
  @override
  Future<dart_ui.Image?> get sourceImage =>
      Future<dart_ui.Image?>.value(_image);

  /// Returns false, as the source image is static, meaning it will not change
  /// over time.
  @override
  bool get sourceImagesMayChangeOverTime => false;
}
