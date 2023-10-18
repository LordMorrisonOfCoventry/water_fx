// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:async';

import '../../touch.dart';
import '../../touch_mappers/basic/solid_circle_touch_mapper.dart';

/// A [TouchSource] for pointer [Touch]es.
///
/// These are touches made by the pointer or finger.
///
///
class PointerTouchSource extends TouchSourceAdapter {
  final TouchMapper pointerTouchMapper;
  final bool autoRun;
  late final StreamController<Touch> _touchesStreamController;
  late bool _isActive;
  bool _isDisposed = false;

  /// Creates the [PointerTouchSource].
  PointerTouchSource({
    this.pointerTouchMapper = _defaultPointerTouchMapper,
    this.autoRun = true,
  }) {
    _isActive = autoRun;
    _touchesStreamController = StreamController<Touch>();
    start();
  }

  @override
  Stream<Touch> get touches =>
      _touchesStreamController.stream.asBroadcastStream();

  @override
  void start() => _isActive = true;

  @override
  void pause() => _isActive = false;

  @override
  void dispose() {
    _isActive = false;
    _isDisposed = true;
    _touchesStreamController.close();
  }

  @override
  bool get isActive => _isActive;

  @override
  bool get isDisposed => _isDisposed;

  @override
  void onPointerOverImage({
    required int pointX,
    required int pointY,
    required int imageWidth,
    required int imageHeight,
    required bool pointerIsDown,
  }) =>
      _isActive
          ? _handlePointerOverImage(
              pointX, pointY, imageWidth, imageHeight, pointerIsDown)
          : null;

  void _handlePointerOverImage(int pointX, int pointY, int imageWidth,
          int imageHeight, bool pointerIsDown) =>
      _touchesStreamController.add(
        pointerTouchMapper.getTouchForPoint(
            pointX, pointY, imageWidth, imageHeight),
      );
}

const TouchMapper _defaultPointerTouchMapper =
    SolidCircleTouchMapper(diameter: 12);
