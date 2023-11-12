// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.
//
// This class in based on an algorithm by Neil Wallis:
// https://www.neilwallis.com/index.php.

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../barrier/barrier.dart';
import '../source_image/widget_source_image_provider.dart';
import '../source_image/static_source_image_provider.dart';
import '../source_image/source_image_provider.dart';
import '../touch/touch.dart';
import '../touch/touch_sources/basic/rain_touch_source.dart';
import '../touch/touch_sources/basic/pointer_touch_source.dart';

/// A class that applies the WaterFX effect to an image (the source image).
///
/// This the core class of the WaterFX library, where the water effect is
/// calculated.
///
/// When [WaterFXProcessor] is 'touched', it emits frames via [animationFrames]
/// which, when viewed sequentially in an animation, give the impression of
/// ripples moving across the surface of the image.
///
/// The [WaterFXProcessor] can be 'touched' in two different ways:
///
/// * Manually - e.g by moving the finger or pointer over the widget.
/// * Programatically - where touches are applied by other code.
///
/// The only way to 'touch' [WaterFXProcessor] is via the [touchSource].
///
/// The class provides a stream of frames ([animationFrames]) that may be
/// displayed sequentially in order to show the animation. The frames it emits
/// are [dart_ui.Image]s.
///
/// For each animation frame, the current source image is retrieved from
/// [sourceImageProvider], in order to have the water effect applied to it. The
/// source images may always be the same, like when we want to apply the water
/// effect to a static image. Or they may be different each time
/// [sourceImageProvider] is called, like when we want to apply the water effect
/// to a video or an image of a non-static UI component.
///
/// Note: The source image(s) retrieved from [sourceImageProvider] by
/// [WaterFXProcessor] may be different but they should ideally always have
/// exactly the same size. If they don't, they will be scaled to have the same
/// size as the first image that was retrieved from sourceImageProvider. This
/// works, but it slows down the water animation. E.g. if the first image
/// returned by the provider has a size of 300 x 200 pixels, all subsequent
/// images should ideally also have exactly this size. E.g. a video is fine as,
/// even though it will produce different images over time, they will all be the
/// same size.
///
/// Note: The source image(s) should always be quite small in order for the
/// water effect to perform well. 300 x 300 pixels seems to usually work quite
/// well, but as it gets bigger than this, the speed and quality of the
/// animation will start to go down.
class WaterFXProcessor {
  /// A provider which provides [dart_ui.Image]s on demand.
  ///
  /// These are the source images, which will have the water effect applied to
  /// them. The source images may always be the same, like when we want to apply
  /// the water effect to a static image. Or they may be different each time
  /// [sourceImageProvider] is called, like when we want to apply the water
  /// effect to a video or an image of a non-static UI component.
  ///
  /// Note: The source image(s) retrieved from [sourceImageProvider] by
  /// [WaterFXProcessor] may be different but they should ideally always
  /// have exactly the same size. If they don't, they will be scaled to have the
  /// same size as the first image that was retrieved from sourceImageProvider.
  /// This works, but it slows down the water animation. E.g. if the first image
  /// returned by the provider has a size of 300 x 200 pixels, all subsequent
  /// images should ideally also have exactly this size. E.g. a video is fine
  /// as, even though it will produce different images over time, they will all
  /// be the same size.
  ///
  /// Note: The source image(s) should always be quite small in order for the
  /// water effect to perform well. 300 x 300 pixels seems to usually work quite
  /// well, but as it gets bigger than this, the speed and quality of the
  /// animation will start to go down.
  final SourceImageProvider sourceImageProvider;

  /// The source of all touches for this [WaterFXProcessor].
  ///
  /// The only way to 'touch' a [WaterFXProcessor] is via the
  /// [touchSource].
  ///
  /// There are two types of [TouchSource]:
  ///
  /// 1. Manual - touches being produced by a finger or pointer moving over the
  /// widget.
  /// 2. Programatic - touches being produced by other code.
  final TouchSource touchSource;

  /// A list of barriers for this [WaterFXProcessor].
  ///
  /// These barriers can be used to make sure certain areas of the child widget
  /// can always be seen clearly, to make sure that certain areas cannot be
  /// 'touched', or both of these things.
  ///
  /// Note: [Barrier] implementations should be as efficient as possible. This
  /// is because their [Barrier.containsPoint] method will be called for every
  /// pixel in the source image. So if the implementation is not very efficient,
  /// it will slow down the animation considerably. For this reason, barriers
  /// should be simple shapes with efficient [Barrier.containsPoint] methods.
  final List<Barrier>? barriers;

  /// Whether or not this [WaterFXProcessor] should produce the water
  /// effect (true by default).
  ///
  /// Note: This takes precedence over the active state of the [touchSource].
  /// So, in order for water effects to be shown, this setting and
  /// [TouchSource.isActive] must both be true.
  bool isActive;

  late final int _sourceImageWidth;
  late final int _sourceImageHeight;
  late final double _sourceImageHalfWidth;
  late final double _sourceImageHalfHeight;
  late final Int16List _rippleHeightMap1;
  late final Int16List _rippleHeightMap2;
  late final Uint32List _sourceImageColorMap;
  late final Uint32List _frameImageColorMap;
  late final Ticker _ticker;
  late final StreamController<dart_ui.Image> _framesStreamController;
  late final StreamSubscription<Touch> _touchStreamSubscription;
  late Int16List _currentRippleHeightSourceMap;
  late Int16List _currentRippleHeightSinkMap;
  late bool _sourceImageColorMapHasBeenUpdatedAtLeastOnce;
  late bool _sourceImageSizeHasBeenEstablished;

  /// Creates a [WaterFXProcessor].
  WaterFXProcessor({
    required this.sourceImageProvider,
    required this.touchSource,
    this.barriers,
    this.isActive = true,
  }) {
    _sourceImageSizeHasBeenEstablished = false;
    _framesStreamController = StreamController();
    _establishSourceImageSize().then((_) => _onSourceImageSizeEstablished());
  }

  /// Creates a [WaterFXProcessor] for a [dart_ui.Image].
  WaterFXProcessor.imageInstance({
    required dart_ui.Image image,
    required TouchSource touchSource,
    List<Barrier>? barriers,
  }) : this(
          sourceImageProvider: StaticSourceImageProvider(image),
          touchSource: touchSource,
          barriers: barriers,
        );

  /// Creates a [WaterFXProcessor] for a [dart_ui.Image], that produces
  /// ripples when the pointer is moved over the image.
  WaterFXProcessor.simpleImageInstanceForPointer({
    required dart_ui.Image image,
  }) : this(
          sourceImageProvider: StaticSourceImageProvider(image),
          touchSource: PointerTouchSource(),
        );

  /// Creates a [WaterFXProcessor] for a [dart_ui.Image], that produces
  /// a rain effect on the image.
  WaterFXProcessor.simpleImageInstanceForRain({
    required dart_ui.Image image,
    double? dropsPerSecond,
  }) : this(
          sourceImageProvider: StaticSourceImageProvider(image),
          touchSource: dropsPerSecond != null
              ? RainTouchSource(dropsPerSecond: dropsPerSecond)
              : RainTouchSource(),
        );

  /// Creates a [WaterFXProcessor] for a [Widget].
  WaterFXProcessor.widgetInstance({
    required GlobalKey<State<StatefulWidget>> widgetImageKey,
    required TouchSource touchSource,
    List<Barrier>? barriers,
  }) : this(
          sourceImageProvider: WidgetSourceImageProvider(widgetImageKey),
          touchSource: PointerTouchSource(),
          barriers: barriers,
        );

  /// Creates a [WaterFXProcessor] for a [Widget], that produces ripples
  /// when the pointer is moved over the widget.
  WaterFXProcessor.simpleWidgetInstanceForPointer({
    required GlobalKey<State<StatefulWidget>> widgetImageKey,
  }) : this(
          sourceImageProvider: WidgetSourceImageProvider(widgetImageKey),
          touchSource: PointerTouchSource(),
        );

  /// Creates a [WaterFXProcessor] for a [Widget], that produces a rain
  /// effect on the widget.
  WaterFXProcessor.simpleWidgetInstanceForRain({
    required GlobalKey<State<StatefulWidget>> widgetImageKey,
    double? dropsPerSecond,
  }) : this(
          sourceImageProvider: WidgetSourceImageProvider(widgetImageKey),
          touchSource: dropsPerSecond != null
              ? RainTouchSource(dropsPerSecond: dropsPerSecond)
              : RainTouchSource(),
        );

  /// The source of frames ([dart_ui.Image]s) which, when viewed sequentially in
  /// an animation, give the impression of ripples moving across the surface of
  /// the image.
  Stream<dart_ui.Image> get animationFrames => _framesStreamController.stream;

  /// Called when the pointer is over the image and when either or both of the
  /// following are true:
  ///
  /// 1. The pointer has just moved.
  /// 2. The pointer has changed its up/down status.
  void onPointerOverImage({
    required int pointX,
    required int pointY,
    required bool pointerIsDown,
  }) =>
      touchSource.onPointerOverImage(
        pointX: pointX,
        pointY: pointY,
        imageWidth: _sourceImageWidth,
        imageHeight: _sourceImageHeight,
        pointerIsDown: pointerIsDown,
      );

  /// Called when the pointer enters the image.
  void onPointerEnteredImage({
    required int pointX,
    required int pointY,
    required bool pointerIsDown,
  }) =>
      touchSource.onPointerEnteredImage(
        pointX: pointX,
        pointY: pointY,
        imageWidth: _sourceImageWidth,
        imageHeight: _sourceImageHeight,
        pointerIsDown: pointerIsDown,
      );

  /// Called when the pointer exits the image.
  void onPointerExitedImage({
    required int pointX,
    required int pointY,
    required bool pointerIsDown,
  }) =>
      touchSource.onPointerExitedImage(
        pointX: pointX,
        pointY: pointY,
        imageWidth: _sourceImageWidth,
        imageHeight: _sourceImageHeight,
        pointerIsDown: pointerIsDown,
      );

  /// The size of the source image that is being used in the calculations within
  /// this class.
  ///
  /// Returns null if the size has not yet been established.
  Size? get sourceImageSize => _sourceImageSizeHasBeenEstablished
      ? Size(_sourceImageWidth.toDouble(), _sourceImageHeight.toDouble())
      : null;

  /// Sets whether or not this [WaterFXProcessor] should produce the
  /// water effect.
  ///
  /// Note: This takes precedence over the active state of the [touchSource].
  /// So, in order for water effects to be shown, this setting and
  /// [TouchSource.isActive] must both be true.
  void setActive(bool isActive) => this.isActive = isActive;

  /// Disposes the resources used by this class.
  void dispose() {
    if (!_sourceImageSizeHasBeenEstablished) {
      throw StateError(
          'dispose() called before source image size has been established.');
    }
    _ticker.stop();
    _ticker.dispose();
    _touchStreamSubscription.cancel();
  }

  Future<void> _establishSourceImageSize() async {
    dart_ui.Image? firstSourceImage = await sourceImageProvider.sourceImage;
    if (firstSourceImage == null) {
      throw StateError('Could not establish source image size as it was null.');
    }
    _sourceImageWidth = firstSourceImage.width;
    _sourceImageHeight = firstSourceImage.height;
    _sourceImageSizeHasBeenEstablished = true;
  }

  void _onSourceImageSizeEstablished() {
    touchSource.onSourceImageSizeEstablished(
        _sourceImageWidth, _sourceImageHeight);
    _initFields();
    _ticker.start();
  }

  void _initFields() {
    _sourceImageHalfWidth = _sourceImageWidth / 2;
    _sourceImageHalfHeight = _sourceImageHeight / 2;
    _touchStreamSubscription =
        touchSource.touches.listen((touch) => _applyTouchToWater(touch));
    _rippleHeightMap1 = Int16List.fromList(
        List.filled(_sourceImageWidth * _sourceImageHeight, 0));
    _rippleHeightMap2 = Int16List.fromList(
        List.filled(_sourceImageWidth * _sourceImageHeight, 0));
    _sourceImageColorMap = Uint32List.fromList(
        List.filled(_sourceImageWidth * _sourceImageHeight, 0));
    _frameImageColorMap = Uint32List.fromList(
        List.filled(_sourceImageWidth * _sourceImageHeight, 0));
    _ticker = Ticker((elapsed) => _generateNextFrameImage(
        onNewFrameImageReadyCallback: (image) =>
            _handleNewFrameImageGenerated(image)));
    _currentRippleHeightSourceMap = _rippleHeightMap1;
    _currentRippleHeightSinkMap = _rippleHeightMap2;
    _sourceImageColorMapHasBeenUpdatedAtLeastOnce = false;
  }

  /// This method is called with the latest touch emitted from the
  /// [touchSource].
  void _applyTouchToWater(Touch touch) {
    if (_shouldAllowTouchToDisturbWater(touch)) {
      _applyTouchToCurrentRippleHeightSourceMap(touch);
    }
  }

  bool _shouldAllowTouchToDisturbWater(Touch touch) =>
      isActive &&
      _sourceImageSizeHasBeenEstablished &&
      touch.touchPoints.every((touchPoint) =>
          _shouldAllowTouchAtPointToDisturbWater(
              touchPoint.pointX, touchPoint.pointY));

  bool _shouldAllowTouchAtPointToDisturbWater(int pointX, int pointY) =>
      _ticker.isActive && !_pixelIsInsideATouchBarrier(pointX, pointY);

  Future<void> _generateNextFrameImage({
    required void Function(dart_ui.Image) onNewFrameImageReadyCallback,
  }) async {
    if (_shouldUpdateSourceImageColorMap) {
      await _updateSourceImageColorMap();
    }
    _updateRippleHeightSinkMapAndFrameImageColorMap();
    _generateFrameImage(
        onNewFrameImageReadyCallback: onNewFrameImageReadyCallback);
    _switchRippleHeightSourceAndSinkMaps();
  }

  void _handleNewFrameImageGenerated(dart_ui.Image image) =>
      _framesStreamController.add(image);

  Future<void> _updateSourceImageColorMap() async {
    dart_ui.Image? nextSourceImage = await _nextSourceImage;
    if (nextSourceImage != null) {
      await _updateSourceImageColorMapForImage(nextSourceImage);
      _sourceImageColorMapHasBeenUpdatedAtLeastOnce = true;
    }
  }

  Future<dart_ui.Image?> get _nextSourceImage async {
    dart_ui.Image? nextSourceImage = await sourceImageProvider.sourceImage;
    if (nextSourceImage == null) {
      return null;
    }
    if (nextSourceImage.width == _sourceImageWidth &&
        nextSourceImage.height == _sourceImageHeight) {
      return nextSourceImage;
    }
    // The size of the the new source image is not the same as that of the first
    // source image that was retrieved from the sourceImageProvider. So it must
    // be scaled to make sure it is the same size as the first one.
    return await _getScaledImage(
        nextSourceImage, _sourceImageWidth, _sourceImageHeight);
  }

  bool get _shouldUpdateSourceImageColorMap =>
      sourceImageProvider.sourceImagesMayChangeOverTime
          ? true
          : !_sourceImageColorMapHasBeenUpdatedAtLeastOnce;

  // This method does two things, but this is for efficiency. We have to check
  // [_pixelIsInsideBarrier] once for every pixel in the source image. This can
  // be quite an expensive call. If we updated [_currentRippleHeightSinkMap] and
  // [_frameImageColorMap] in separate methods, we would have to do the
  // [_pixelIsInsideBarrier] check twice for every pixel.
  void _updateRippleHeightSinkMapAndFrameImageColorMap() {
    int mapIndexOfCurrentPixel = 0;
    for (int pixelY = 0; pixelY < _sourceImageHeight; pixelY++) {
      for (int pixelX = 0; pixelX < _sourceImageWidth; pixelX++) {
        if (_pixelIsInsideARippleBarrier(pixelX, pixelY)) {
          _updatePixelInsideBarrierInRippleHeightSinkMapWithRippleHeight(
              mapIndexOfCurrentPixel);
          _updatePixelInsideBarrierInFrameImageColorMapWithNewColorFromSourceImage(
              mapIndexOfCurrentPixel);
        } else {
          _updatePixelInRippleHeightSinkMapWithNewRippleHeight(
              pixelX, pixelY, mapIndexOfCurrentPixel);
          _updatePixelInFrameImageColorMapWithNewColorFromSourceImage(
              pixelX, pixelY, mapIndexOfCurrentPixel);
        }
        mapIndexOfCurrentPixel++;
      }
    }
  }

  void _updatePixelInsideBarrierInRippleHeightSinkMapWithRippleHeight(
          int mapIndexOfPixel) =>
      _currentRippleHeightSinkMap[mapIndexOfPixel] = 0;

  void _updatePixelInsideBarrierInFrameImageColorMapWithNewColorFromSourceImage(
          int mapIndexOfPixel) =>
      // Set the current pixel color in _frameImageColorMap to the color of the
      // same pixel in _sourceImageColorMap.
      _frameImageColorMap[mapIndexOfPixel] =
          _sourceImageColorMap[mapIndexOfPixel];

  void _updatePixelInRippleHeightSinkMapWithNewRippleHeight(
          int pixelX, int pixelY, int mapIndexOfPixel) =>
      _currentRippleHeightSinkMap[mapIndexOfPixel] =
          _getNewRippleHeightForPixelInSinkMap(pixelX, pixelY, mapIndexOfPixel);

  /// The value for the new ripple height at the pixel in the sink map is
  /// calculated as follows:
  ///
  /// 1. Get the sum of the ripple heights of the neighbouring pixels in the
  /// source map.
  /// 2. Divide this value by two, and subtract from it the height value of the
  /// pixel in the sink map. This gives a base height that is like an average
  /// from both maps.
  /// 3. Reduce the base height by a fraction of itself. This allows the heights
  /// held in the maps to gradually return to zero, simulating the dissipation
  /// of the ripples in the water.
  int _getNewRippleHeightForPixelInSinkMap(
      int pixelX, int pixelY, int mapIndexOfPixel) {
    int sumOfRippleHeightsOfNeighbouringPixelsInSourceMap =
        _getSumOfRippleHeightsOfNeighbouringPixelsInSourceMap(
            pixelX, pixelY, mapIndexOfPixel);

    int baseRippleHeightForPixelInSinkMap =
        (sumOfRippleHeightsOfNeighbouringPixelsInSourceMap >> 1) -
            _currentRippleHeightSinkMap[mapIndexOfPixel];

    int reducedRippleHeightForPixelInSinkMap =
        baseRippleHeightForPixelInSinkMap -
            (baseRippleHeightForPixelInSinkMap >> 5);

    return reducedRippleHeightForPixelInSinkMap;
  }

  void _updatePixelInFrameImageColorMapWithNewColorFromSourceImage(
      int pixelX, int pixelY, int mapIndexOfPixel) {
    int newRippleHeightForPixelFromSourcePerspective =
        _maxRippleHeight - _currentRippleHeightSinkMap[mapIndexOfPixel];

    // Set the current pixel color in _frameImageColorMap to the color of the
    // source image pixel to use.
    _frameImageColorMap[mapIndexOfPixel] = _sourceImageColorMap[
        _getMapIndexOfSourceImagePixelToUse(
            pixelX, pixelY, newRippleHeightForPixelFromSourcePerspective)];
  }

  void _generateFrameImage({
    required void Function(dart_ui.Image) onNewFrameImageReadyCallback,
  }) =>
      dart_ui.decodeImageFromPixels(
          _frameImageColorMap.buffer.asUint8List(),
          _sourceImageWidth,
          _sourceImageHeight,
          dart_ui.PixelFormat.rgba8888,
          (newFrameImage) => onNewFrameImageReadyCallback.call(newFrameImage));

  Future<void> _updateSourceImageColorMapForImage(
          dart_ui.Image sourceImage) async =>
      _sourceImageColorMap.setAll(
          0, await _getImageColorMapFromImage(sourceImage));

  Future<Uint32List> _getImageColorMapFromImage(dart_ui.Image image) async =>
      (await image.toByteData())?.buffer.asUint32List() ??
      Uint32List.fromList([]);

  void _switchRippleHeightSourceAndSinkMaps() {
    Int16List oldRippleHeightSourceMap = _currentRippleHeightSourceMap;
    _currentRippleHeightSourceMap = _currentRippleHeightSinkMap;
    _currentRippleHeightSinkMap = oldRippleHeightSourceMap;
  }

  int _getMapIndexOfSourceImagePixelToUse(
      int pixelX, int pixelY, int rippleHeightAtPixel) {
    // Calculate the offsets of the source image pixel to use, based on the
    // current distance from the centre of the image and the height of the
    // ripple at this point. Also constrain the offsets to be within the bounds
    // of the image. This algorithm approximates the process of refraction in
    // water.
    int xOffsetOfSourceImagePixelToUse = (_sourceImageHalfWidth +
            ((pixelX - _sourceImageHalfWidth) *
                rippleHeightAtPixel /
                _maxRippleHeight))
        .clamp(0, _sourceImageWidth - 1)
        .toInt();
    int yOffsetOfSourceImagePixelToUse = (_sourceImageHalfHeight +
            ((pixelY - _sourceImageHalfHeight) *
                rippleHeightAtPixel /
                _maxRippleHeight))
        .clamp(0, _sourceImageHeight - 1)
        .toInt();

    return _getMapIndexForPixel(
        xOffsetOfSourceImagePixelToUse, yOffsetOfSourceImagePixelToUse);
  }

  int _getSumOfRippleHeightsOfNeighbouringPixelsInSourceMap(
    int pixelX,
    int pixelY,
    int mapIndexOfPixel,
  ) {
    int heightOfPixelAboveThisOne = pixelY == 0
        ? 0
        : _currentRippleHeightSourceMap[mapIndexOfPixel - _sourceImageWidth];
    int heightOfPixelBelowThisOne = pixelY == (_sourceImageHeight - 1)
        ? 0
        : _currentRippleHeightSourceMap[mapIndexOfPixel + _sourceImageWidth];
    int heightOfPixelToTheLeftOfThisOne =
        pixelX == 0 ? 0 : _currentRippleHeightSourceMap[mapIndexOfPixel - 1];
    int heightOfPixelToTheRightOfThisOne = pixelX == (_sourceImageWidth - 1)
        ? 0
        : _currentRippleHeightSourceMap[mapIndexOfPixel + 1];
    return heightOfPixelAboveThisOne +
        heightOfPixelBelowThisOne +
        heightOfPixelToTheLeftOfThisOne +
        heightOfPixelToTheRightOfThisOne;
  }

  void _applyTouchToCurrentRippleHeightSourceMap(Touch touch) =>
      touch.touchPoints.forEach(_applyTouchPointToCurrentRippleHeightSourceMap);

  void _applyTouchPointToCurrentRippleHeightSourceMap(TouchPoint touchPoint) =>
      _currentRippleHeightSourceMap[
              _getMapIndexForPixelAtTouchPoint(touchPoint)] +=
          touchPoint.touchStrengthUnit * _maxRippleHeight ~/ 2;

  bool _pixelIsInsideARippleBarrier(int pixelX, int pixelY) {
    if (barriers == null) {
      return false;
    }
    return barriers!.any((barrier) =>
        _isARippleBarrier(barrier) &&
        barrier.containsPoint(
            pixelX, pixelY, _sourceImageWidth, _sourceImageHeight));
  }

  bool _pixelIsInsideATouchBarrier(int pixelX, int pixelY) {
    if (barriers == null) {
      return false;
    }
    return barriers!.any((barrier) =>
        _isATouchBarrier(barrier) &&
        barrier.containsPoint(
            pixelX, pixelY, _sourceImageWidth, _sourceImageHeight));
  }

  bool _isARippleBarrier(Barrier barrier) =>
      barrier.type == BarrierType.ripple ||
      barrier.type == BarrierType.rippleAndTouch;

  bool _isATouchBarrier(Barrier barrier) =>
      barrier.type == BarrierType.touch ||
      barrier.type == BarrierType.rippleAndTouch;

  int _getMapIndexForPixelAtTouchPoint(TouchPoint touchPoint) =>
      _getMapIndexForPixel(touchPoint.pointX, touchPoint.pointY);

  int _getMapIndexForPixel(int pixelX, int pixelY) =>
      pixelX + (pixelY * _sourceImageWidth);

  Future<dart_ui.Image> _getScaledImage(
      dart_ui.Image originalImage, int newWidth, int newHeight) async {
    Rect originalSizeRect = Rect.fromLTWH(
        0, 0, originalImage.width.toDouble(), originalImage.height.toDouble());
    Rect newSizeRect =
        Rect.fromLTWH(0, 0, newWidth.toDouble(), newHeight.toDouble());
    dart_ui.PictureRecorder recorder = dart_ui.PictureRecorder();
    dart_ui.Canvas canvas = dart_ui.Canvas(recorder, newSizeRect);
    canvas.drawImageRect(originalImage, originalSizeRect, newSizeRect, Paint());
    Picture picture = recorder.endRecording();
    return await picture.toImage(newWidth, newHeight);
  }
}

const int _maxRippleHeight = 1024;
