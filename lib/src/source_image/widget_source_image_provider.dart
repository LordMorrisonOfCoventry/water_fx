// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:ui' as dart_ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'source_image_provider.dart';

/// An [ImageProvider] for the image of a widget.
class WidgetSourceImageProvider implements SourceImageProvider {
  /// A key that identifies a widget.
  final GlobalKey _widgetImageKey;

  /// Whether or not the widget may change over time.
  ///
  /// The widget will not change over time if we are using a still, non-changing
  /// image. It will change over time if it is a video widget or some kind, or
  /// some piece of UI that can change (e.g. if it contains toggle buttons or
  /// sliders).
  ///
  /// This is true by default, in order to cater by default for all types of
  /// widgets (e.g. a video widget). If your widget is static (i.e it will not
  /// change over time), set this to false to improve performance.
  final bool widgetMayChangeOverTime;

  /// Creates this [WidgetSourceImageProvider] with a key that identifies a
  /// widget.
  ///
  /// When [sourceImage] is called, this provider will return an image of the current
  /// state of the widget identified by [_widgetImageKey].
  const WidgetSourceImageProvider(
    this._widgetImageKey, {
    this.widgetMayChangeOverTime = true,
  });

  /// Returns an image of the current state of the widget identified by
  /// [_widgetImageKey].
  @override
  Future<dart_ui.Image?> get sourceImage async {
    RenderObject? renderObject =
        _widgetImageKey.currentContext?.findRenderObject();
    return (renderObject is RenderRepaintBoundary)
        ? await renderObject.toImage()
        : null;
  }

  /// Returns true if the widget may change over time, false otherwise.
  @override
  bool get sourceImagesMayChangeOverTime => widgetMayChangeOverTime;
}
