// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../barrier/barrier.dart';
import '../source_image/widget_source_image_provider.dart';
import '../source_image/source_image_provider.dart';
import 'dart:ui' as dart_ui;

import '../touch/touch.dart';
import '../touch/touch_sources/basic/rain_touch_source.dart';
import '../touch/touch_sources/basic/pointer_touch_source.dart';
import '../water_fx_components/water_fx_processor.dart';

/// A widget that applies the WaterFX effect to its child widget.
///
/// When [WaterFXContainer] is 'touched', its UI gives the impression of ripples
/// moving across its surface, with the child widget being submerged below the
/// surface.
///
/// The [WaterFXContainer] can be 'touched' in two different ways:
///
/// * Manually - e.g by moving the finger or pointer over the widget.
/// * Programatically - where touches are applied by other code.
///
/// The only way to 'touch' a [WaterFXContainer] is via the [touchSource].
///
/// Example with a [dart_ui.Image].
///
/// ```dart
/// @override
/// Widget build(BuildContext context) => MaterialApp(
///       home: Center(
///       child: WaterFXContainer.simpleImageInstanceForPointer(
///         image: _sourceImage,
///       ),
///     ),
///   );
/// ```
///
/// where _sourceImage is a [dart_ui.Image].
///
/// Example with a [Widget].
///
/// ```dart
/// @override
/// Widget build(BuildContext context) => MaterialApp(
///      home: Center(
///       child: WaterFXContainer.simpleWidgetInstanceForPointer(
///         child: _child,
///       ),
///     ),
///   );
/// ```
///
/// where _child is a [Widget].
///
/// [WaterFXContainer] uses [WaterFXProcessor] to produce the images
/// that, when displayed sequentially, provide the WaterFX effect.
///
/// Note: The [child] of [WaterFXContainer] should ideally always have exactly
/// the same size. If its size changes over time, the WaterFX effect will still
/// work, but the animation will be slowed down.
///
/// Note: The [child] of [WaterFXContainer] should be quite small in order for
/// the water effect to perform well. 300 x 300 pixels seems to usually work
/// quite well, but as it gets bigger than this, the speed and quality of the
/// animation will start to go down.
class WaterFXContainer extends StatefulWidget {
  /// The [Widget] that will have the water effect applied to it.
  ///
  /// For best results, this widget should be quite small. 300 x 300 pixels
  /// seems to usually work quite well, but as it gets bigger than this, the
  /// speed and quality of the animation will start to go down.
  final Widget child;

  /// The source of all touches for this [WaterFXContainer].
  ///
  /// The only way to 'touch' a [WaterFXContainer] is via the [touchSource].
  ///
  /// There are two types of [TouchSource]:
  ///
  /// 1. Manual - touches being produced by a finger or pointer moving over the
  /// widget.
  /// 2. Programatic - touches being produced by other code.
  final TouchSource touchSource;

  /// Whether or not the child widget may change over time.
  ///
  /// The child will not change over time if is a still, non-changing image. It
  /// will change over time if it is a video widget or some kind, or some piece
  /// of UI that can change (e.g. if it contains toggle buttons or sliders).
  ///
  /// This is true by default, in order to cater by default for all types of
  /// widgets (e.g. a video widget). If your widget is static (i.e it will not
  /// change over time), set this to false to improve performance.
  final bool childMayChangeOverTime;

  /// A list of barriers for this [WaterFXContainer].
  ///
  /// These barriers can be used to make sure certain areas of the child widget
  /// can always be seen clearly, to make sure that certain areas cannot be
  /// 'touched', or both of these things.
  ///
  /// Note: [Barrier] implementations should be as efficient as possible. This
  /// is because their [Barrier.containsPoint] method will be called for every
  /// pixel in the image of the child widget. So if the implementation is not
  /// very efficient, it will slow down the animation considerably. For this
  /// reason, barriers should be simple shapes with efficient
  /// [Barrier.containsPoint] methods.
  final List<Barrier>? barriers;

  /// Whether or not this [WaterFXContainer] should produce the water effect
  /// (true by default).
  ///
  /// Note: This takes precedence over the active state of the [touchSource].
  /// So, in order for water effects to be shown, this setting and
  /// [TouchSource.isActive] must both be true.
  final bool isActive;

  /// Creates a [WaterFXContainer].
  const WaterFXContainer({
    required this.child,
    required this.touchSource,
    this.childMayChangeOverTime = true,
    this.barriers,
    this.isActive = true,
    super.key,
  });

  /// Creates a [WaterFXContainer] for a [dart_ui.Image].
  WaterFXContainer.imageInstance({
    required dart_ui.Image image,
    required TouchSource touchSource,
    List<Barrier>? barriers,
    Key? key,
  }) : this(
          child: RawImage(image: image),
          touchSource: touchSource,
          childMayChangeOverTime: false,
          barriers: barriers,
          key: key,
        );

  /// Creates a [WaterFXContainer] for a [dart_ui.Image], that shows ripples
  /// when the pointer is moved over the container.
  WaterFXContainer.simpleImageInstanceForPointer({
    required dart_ui.Image image,
    Key? key,
  }) : this(
          child: RawImage(image: image),
          touchSource: PointerTouchSource(),
          childMayChangeOverTime: false,
          key: key,
        );

  /// Creates a [WaterFXContainer] for a [dart_ui.Image], that shows a rain
  /// effect.
  WaterFXContainer.simpleImageInstanceForRain({
    required dart_ui.Image image,
    double? dropsPerSecond,
    Key? key,
  }) : this(
          child: RawImage(image: image),
          touchSource: dropsPerSecond != null
              ? RainTouchSource(dropsPerSecond: dropsPerSecond)
              : RainTouchSource(),
          childMayChangeOverTime: false,
          key: key,
        );

  /// Creates a [WaterFXContainer] for a [Widget].
  const WaterFXContainer.widgetInstance({
    required Widget child,
    required TouchSource touchSource,
    bool widgetMayChangeOverTime = true,
    List<Barrier>? barriers,
    Key? key,
  }) : this(
          child: child,
          touchSource: touchSource,
          childMayChangeOverTime: widgetMayChangeOverTime,
          barriers: barriers,
          key: key,
        );

  /// Creates a [WaterFXContainer] for a [Widget], that shows ripples when the
  /// pointer is moved over the container.
  WaterFXContainer.simpleWidgetInstanceForPointer({
    required Widget child,
    bool widgetMayChangeOverTime = true,
    Key? key,
  }) : this(
          child: child,
          touchSource: PointerTouchSource(),
          childMayChangeOverTime: widgetMayChangeOverTime,
          key: key,
        );

  /// Creates a [WaterFXContainer] for a [Widget], that shows a rain effect.
  WaterFXContainer.simpleWidgetInstanceForRain({
    required Widget child,
    double? dropsPerSecond,
    bool widgetMayChangeOverTime = true,
    Key? key,
  }) : this(
          child: child,
          touchSource: dropsPerSecond != null
              ? RainTouchSource(dropsPerSecond: dropsPerSecond)
              : RainTouchSource(),
          childMayChangeOverTime: widgetMayChangeOverTime,
          key: key,
        );

  @override
  State<WaterFXContainer> createState() => _WaterFXContainerState();
}

class _WaterFXContainerState extends State<WaterFXContainer> {
  final GlobalKey _childImageKey = GlobalKey();
  late SourceImageProvider _childImageProvider;
  WaterFXProcessor? _waterFXProcessor;

  @override
  void initState() {
    _childImageProvider = WidgetSourceImageProvider(_childImageKey,
        widgetMayChangeOverTime: widget.childMayChangeOverTime);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _onChildBuiltForFirstTime());
    super.initState();
  }

  @override
  void dispose() {
    _waterFXProcessor?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (pointerEnterEvent) => _onPointerEnteredImage(
            pointerEnterEvent.localPosition, pointerEnterEvent.down),
        onExit: (pointerExitEvent) => _onPointerExitedImage(
            pointerExitEvent.localPosition, pointerExitEvent.down),
        child: Listener(
          onPointerDown: (pointerDownEvent) =>
              _onPointerOverImage(pointerDownEvent.localPosition, true),
          onPointerUp: (pointerUpEvent) =>
              _onPointerOverImage(pointerUpEvent.localPosition, false),
          onPointerMove: (pointerMoveEvent) =>
              _onPointerOverImage(pointerMoveEvent.localPosition, true),
          onPointerHover: (pointerHoverEvent) =>
              _onPointerOverImage(pointerHoverEvent.localPosition, false),
          child: Stack(
            children: [
              _buildChildView(),
              if (_waterFXProcessor != null) _buildWaterView(),
            ],
          ),
        ),
      );

  Widget _buildChildView() => Opacity(
        // TODO The opacity here is a hack to stop the stack from resizing its
        // children. Without this, the child was being given one extra pixel in
        // height. I read that the stack widget can sometimes cause its children
        // to expand if their sizes are not explicitly set or constrained, and I
        // don't want to specifically constrain them. For some reason (I don't
        // know why) this opacity prevents the stack from resizing the child.
        // Anyway we never need to see this widget, as it is only needed so its
        // image can be captured. The capturing still works even with the low
        // opacity, but try to find a better way to do this.
        opacity: 0.01,
        child: RepaintBoundary(
          key: _childImageKey,
          child: widget.child,
        ),
      );

  Widget _buildWaterView() => StreamBuilder<dart_ui.Image>(
        stream: _waterFXProcessor!.animationFrames,
        builder: (context, snapshot) => RawImage(image: snapshot.data),
      );

  void _onChildBuiltForFirstTime() {
    _initWaterMovementProcessor();
    setState(() {});
  }

  void _initWaterMovementProcessor() => _waterFXProcessor = WaterFXProcessor(
        sourceImageProvider: _childImageProvider,
        touchSource: widget.touchSource,
        barriers: widget.barriers,
        isActive: widget.isActive,
      );

  void _onPointerOverImage(Offset localPosition, bool pointerIsDown) {
    Size? containerSize = context.size;
    Size? sourceImageSize = _waterFXProcessor?.sourceImageSize;
    if (containerSize != null && sourceImageSize != null) {
      // We need to scale the pointer position in case the container is not the
      // same size as the source image.
      _waterFXProcessor?.onPointerOverImage(
          pointX:
              localPosition.dx * sourceImageSize.width ~/ containerSize.width,
          pointY:
              localPosition.dy * sourceImageSize.height ~/ containerSize.height,
          pointerIsDown: pointerIsDown);
    }
  }

  void _onPointerEnteredImage(Offset localPosition, bool pointerIsDown) {
    Size? containerSize = context.size;
    Size? sourceImageSize = _waterFXProcessor?.sourceImageSize;
    if (containerSize != null && sourceImageSize != null) {
      // We need to scale the pointer position in case the container is not the
      // same size as the source image.
      _waterFXProcessor?.onPointerEnteredImage(
          pointX:
              localPosition.dx * sourceImageSize.width ~/ containerSize.width,
          pointY:
              localPosition.dy * sourceImageSize.height ~/ containerSize.height,
          pointerIsDown: pointerIsDown);
    }
  }

  void _onPointerExitedImage(Offset localPosition, bool pointerIsDown) {
    Size? containerSize = context.size;
    Size? sourceImageSize = _waterFXProcessor?.sourceImageSize;
    if (containerSize != null && sourceImageSize != null) {
      // We need to scale the pointer position in case the container is not the
      // same size as the source image.
      _waterFXProcessor?.onPointerExitedImage(
          pointX:
              localPosition.dx * sourceImageSize.width ~/ containerSize.width,
          pointY:
              localPosition.dy * sourceImageSize.height ~/ containerSize.height,
          pointerIsDown: pointerIsDown);
    }
  }
}
