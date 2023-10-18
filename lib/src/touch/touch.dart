// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:async';

/// Represents a touch of the water.
///
/// The touch consists of one or more [TouchPoint]s, that are contained in the
/// [touchPoints] list.
/// E.g. If you want to touch the water with some triangular shaped object,
/// [touchPoints] would contain multiple [TouchPoint]s that would collectively
/// would form a triangle.
class Touch {
  /// The [TouchPoint]s that make up this touch.
  final List<TouchPoint> touchPoints;

  /// Creates a new [Touch] from the specified [TouchPoint]s.
  const Touch(this.touchPoints);
}

/// A [Touch] that groups together other touches ([_touches]).
///
/// This can be used for occasions when we want to map a touch at one point to
/// more than one [Touch]. E.g. we might want a touch at one point to result in
/// ring of several [Touch]es around the point.
class CompoundTouch implements Touch {
  final List<Touch> _touches;

  /// Creates a new [CompoundTouch] from the specified [Touch]es.
  const CompoundTouch(this._touches);

  /// Returns a list of [TouchPoint]s that represents the combined touches for
  /// this [CompoundTouch].
  @override
  List<TouchPoint> get touchPoints =>
      _touches.expand((touch) => touch.touchPoints).toList();
}

/// Represents a point ([pointX], [pointY]) where a single pixel of the water is
/// touched with a certain strength ([touchStrengthUnit]).
class TouchPoint {
  /// The x offset within the container.
  final int pointX;

  /// The y offset within the container.
  final int pointY;

  /// The strength of the touch. This value must be in the range 0.0 - 1.0,
  /// where 1.0 will cause the largest ripple in the water, and 0.0 will cause
  /// no ripple.
  final double touchStrengthUnit;

  /// Creates a new [TouchPoint] at the specified point and with the specified
  /// strength.
  TouchPoint(
    this.pointX,
    this.pointY, {
    this.touchStrengthUnit = 1,
  }) {
    if (touchStrengthUnit < 0 || touchStrengthUnit > 1) {
      throw ArgumentError.value(
          touchStrengthUnit,
          'touchStrengthUnit'
          'The value must be in the range 0.0 - 1.0.');
    }
  }
}

/// A source of [Touch] objects.
///
/// All touches to components that can produce the WaterFX effect must be
/// emitted from a [TouchSource], via the [touches] stream.
///
/// Note: Implementing classes must implement all of these methods, but
/// depending on the needs of the new touch source, the implementations may be
/// empty.
///
/// Note: New touch sources should consider extending [TouchSourceAdapter]
/// instead of implementing [TouchSource]. This is because TouchSourceAdapter
/// already provides empty implementations for many of the less frequently used
/// methods.
abstract class TouchSource {
  /// The stream of [Touch]es produced by this [TouchSource].
  Stream<Touch> get touches;

  /// Starts the [TouchSource], or restarts it if it was paused.
  void start();

  /// Pauses the [TouchSource].
  void pause();

  /// Disposes the [TouchSource].
  ///
  /// Implementations of this method should clean up any resources that might be
  /// in use within the source. E.g. the [touches] stream.
  void dispose();

  /// Returns true if the [TouchSource] in active, false otherwise.
  bool get isActive;

  /// Returns true if the [TouchSource] in disposed, false otherwise.
  bool get isDisposed;

  /// Called by the [WaterMovementProcessor] when the source image size has been
  /// established.
  void onSourceImageSizeEstablished(
      int sourceImageWidth, int sourceImageHeight);

  /// Called by the [WaterMovementProcessor] when the pointer is over the image
  /// and when either or both of the following are true:
  ///
  /// 1. The pointer has just moved.
  /// 2. The pointer has changed its up/down status.
  ///
  /// Note: On touch screen devices (phones, tablets etc.), [pointerIsDown] will
  /// awlays be true.
  void onPointerOverImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  });

  /// Called by the [WaterMovementProcessor] when the pointer enters the image.
  void onPointerEnteredImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  });

  /// Called by the [WaterMovementProcessor] when the pointer exits the image.
  void onPointerExitedImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  });
}

/// A [TouchSource] that has empty implementations for many of the less
/// frequently needed methods.
///
/// All touches to components that can produce the WaterFX effect must be
/// emitted from a [TouchSource], via the [touches] stream.
///
/// Note: All touch sources must be [TouchSource]s, but most touch sources will
/// not need to use all of the methods in [TouchSource]. So to relieve touch
/// sources from having to implement all of these methods, many of which will be
/// empty implementations anyway (as they are not needed), this class
/// ([TouchSourceAdapter]) is provided as a utility class. It already has empty
/// implementations for many of the less frequently needed methods. It is an
/// abstract base class, which means that it must be extended and not
/// implemented. Extending classes must implement all of the non-implemented
/// methods, but depending on the needs of the touch source, the empty
/// implementations may or may not need to be overridden.
abstract class TouchSourceAdapter implements TouchSource {
  /// The stream of [Touch]es produced by this [TouchSource].
  @override
  Stream<Touch> get touches;

  /// Starts the [TouchSource], or restarts it if it was paused.
  @override
  void start();

  /// Pauses the [TouchSource].
  @override
  void pause();

  /// Disposes the [TouchSource].
  ///
  /// Implementations of this method should clean up any resources that might be
  /// in use within the source. E.g. the [touches] stream.
  @override
  void dispose();

  /// Returns true if the [TouchSource] in active, false otherwise.
  @override
  bool get isActive;

  /// Returns true if the [TouchSource] in disposed, false otherwise.
  @override
  bool get isDisposed;

  /// Called by the [WaterMovementProcessor] when the image size has been
  /// established.
  @override
  void onSourceImageSizeEstablished(
      int sourceImageWidth, int sourceImageHeight) {
    // Extending classes should override this if they need it.
  }

  /// Called by the [WaterMovementProcessor] when the pointer is over the image
  /// and when either or both of the following are true:
  ///
  /// 1. The pointer has just moved.
  /// 2. The pointer has changed its up/down status.
  ///
  /// Note: On touch screen devices (phones, tablets etc.), [pointerIsDown] will
  /// awlays be true.
  @override
  void onPointerOverImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) {
    // Extending classes should override this if they need it.
  }

  /// Called by the [WaterMovementProcessor] when the pointer enters the image.
  @override
  void onPointerEnteredImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) {
    // Extending classes should override this if they need it.
  }

  /// Called by the [WaterMovementProcessor] when the pointer exits the image.
  @override
  void onPointerExitedImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) {
    // Extending classes should override this if they need it.
  }
}

/// A [TouchSource] that groups together multiple touch sources
/// ([_componentTouchSources]).
///
/// E.g. if we want to apply a rain effect to an image, and also respond to
/// pointer touches, we would need to use two [TouchSource]s. We can group these
/// two sources together in a [CompoundTouchSource].
class CompoundTouchSource implements TouchSource {
  /// The [TouchSource]s that will be grouped together in this
  /// [CompoundTouchSource].
  final List<TouchSource> _componentTouchSources;
  final StreamController<Touch> _compoundTouchesStreamController =
      StreamController<Touch>();
  final List<StreamSubscription<Touch>> _componentStreamSubsrciptions = [];
  late final Stream<Touch> _compoundTouchesStream;

  /// Creates a new [CompoundTouchSource] with the specified [TouchSource]s.
  CompoundTouchSource(this._componentTouchSources) {
    _compoundTouchesStream = _getMergedStream(
      _componentTouchSources
          .map((componentTouchSource) => componentTouchSource.touches),
      _compoundTouchesStreamController,
      _componentStreamSubsrciptions,
    ).asBroadcastStream();
  }

  /// The stream of [Touch]es produced by all of the [TouchSource]s in this
  /// [CompoundTouchSource].
  @override
  Stream<Touch> get touches => _compoundTouchesStream;

  /// Calls [onSourceImageSizeEstablished] on all of the [TouchSource]s in this
  /// [CompoundTouchSource].
  @override
  void onSourceImageSizeEstablished(
      int sourceImageWidth, int sourceImageHeight) {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.onSourceImageSizeEstablished(
          sourceImageWidth, sourceImageHeight);
    }
  }

  /// Calls [onPointerOverImage] on all of the [TouchSource]s in this
  /// [CompoundTouchSource].
  @override
  void onPointerOverImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.onPointerOverImage(
        pointX: pointX,
        pointY: pointY,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        pointerIsDown: pointerIsDown,
      );
    }
  }

  /// Calls [onPointerEnteredImage] on all of the [TouchSource]s in this
  /// [CompoundTouchSource].
  @override
  void onPointerEnteredImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.onPointerEnteredImage(
        pointX: pointX,
        pointY: pointY,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        pointerIsDown: pointerIsDown,
      );
    }
  }

  /// Calls [onPointerExitedImage] on all of the [TouchSource]s in this
  /// [CompoundTouchSource].
  @override
  void onPointerExitedImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.onPointerExitedImage(
        pointX: pointX,
        pointY: pointY,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
        pointerIsDown: pointerIsDown,
      );
    }
  }

  /// Starts all [TouchSource]s in this [CompoundTouchSource].
  @override
  void start() {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.start();
    }
  }

  /// Pauses all [TouchSource]s in this [CompoundTouchSource].
  @override
  void pause() {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.pause();
    }
  }

  /// Disposes all [TouchSource]s in this [CompoundTouchSource].
  @override
  void dispose() {
    for (TouchSource componentTouchSource in _componentTouchSources) {
      componentTouchSource.dispose();
    }
    for (StreamSubscription<Touch> componentStreamSubsrciptions
        in _componentStreamSubsrciptions) {
      componentStreamSubsrciptions.cancel();
    }
    _compoundTouchesStreamController.close();
  }

  /// Returns true if all [TouchSource]s in this [CompoundTouchSource] are
  /// active, false otherwise.
  @override
  bool get isActive => _componentTouchSources
      .every((componentTouchSource) => componentTouchSource.isActive);

  /// Returns true if all [TouchSource]s in this [CompoundTouchSource] are
  /// disposed, false otherwise.
  @override
  bool get isDisposed => _componentTouchSources
      .every((componentTouchSource) => componentTouchSource.isDisposed);

  Stream<Touch> _getMergedStream<Touch>(
      Iterable<Stream<Touch>> componentStreams,
      StreamController<Touch> compoundTouchesStreamController,
      List<StreamSubscription<Touch>> componentStreamSubsrciptions) {
    int componentStreamsDoneCount = 0;

    void handleComponentStreamDone() {
      componentStreamsDoneCount++;
      if (componentStreamsDoneCount == componentStreams.length) {
        _compoundTouchesStreamController.close();
      }
    }

    void listenToComponentStream(Stream<Touch> componentStream) =>
        componentStreamSubsrciptions.add(componentStream.listen(
          (data) => compoundTouchesStreamController.add(data),
          onError: (error) {
            _compoundTouchesStreamController.addError(error);
            handleComponentStreamDone();
          },
          onDone: () => handleComponentStreamDone(),
          cancelOnError: false,
        ));

    for (Stream<Touch> componentStream in componentStreams) {
      listenToComponentStream(componentStream);
    }
    return compoundTouchesStreamController.stream;
  }
}

/// Maps touches at specific points (single pixels) within the container to
/// [Touch] objects.
///
/// E.g. if we are trying to simulate a finger touch, we might map a touch at a
/// specific point to a [Touch] that represents a small solid circle of points,
/// in order to simulate a finger tip.
abstract class TouchMapper {
  /// Returns a [Touch] for the specified point.
  Touch getTouchForPoint(
    int pointX,
    int pointY,
    int imageWidth,
    int imageHeight,
  );
}

/// A [TouchMapper] that groups together other touch mappers ([_touchMappers]).
///
/// This can be used for occasions when we want to map a touch at one point (a
/// single pixel) to more than one [Touch]. E.g. we might want a touch at one
/// point to result in ring of several [Touch]es around the point.
class CompoundTouchMapper implements TouchMapper {
  /// The [TouchMapper]s that make up this [CompoundTouchMapper].
  final List<TouchMapper> _touchMappers;

  /// Creates a new [CompoundTouchMapper] from the [TouchMapper]s.
  const CompoundTouchMapper(this._touchMappers);

  /// Returns a [CompoundTouch] that represents the combined touches returned
  /// from all of the [TouchMapper]s in [_touchMappers] for the specified point.
  @override
  Touch getTouchForPoint(
          int pointX, int pointY, int imageWidth, int imageHeight) =>
      CompoundTouch(_touchMappers
          .map<Touch>((touchMapper) => touchMapper.getTouchForPoint(
              pointX, pointY, imageWidth, imageHeight))
          .toList());
}
