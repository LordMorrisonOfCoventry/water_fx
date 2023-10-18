// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:async';
import 'dart:math';

import '../../touch.dart';
import '../../touch_mappers/basic/rain_touch_mapper.dart';

class RainTouchSource extends TouchSourceAdapter {
  final double dropsPerSecond;
  final bool autoRun;
  late final Random _random;
  late final Timer _ticker;
  late final StreamController<Touch> _touchesStreamController;
  late final TouchMapper _rainTouchMapper;
  late bool _isActive;
  bool _isDisposed = false;
  int? _sourceImageWidth;
  int? _sourceImageHeight;

  /// Creates the [RainTouchSource].
  RainTouchSource({
    this.dropsPerSecond = _defaultRaindropsPerSecond,
    this.autoRun = true,
  }) {
    _isActive = autoRun;
    _random = Random();
    _ticker = Timer.periodic(
        Duration(milliseconds: 1000 ~/ dropsPerSecond), (timer) => _onTick());
    _touchesStreamController = StreamController<Touch>();
    _rainTouchMapper = RainTouchMapper();
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
    _ticker.cancel();
    _touchesStreamController.close();
  }

  @override
  bool get isActive => _isActive;

  @override
  bool get isDisposed => _isDisposed;

  void _onTick() => _isActive ? _releaseRaindrop() : null;

  void _releaseRaindrop() => _touchesStreamController.add(_newRaindrop);

  @override
  void onSourceImageSizeEstablished(
      int sourceImageWidth, int sourceImageHeight) {
    _sourceImageWidth = sourceImageWidth;
    _sourceImageHeight = sourceImageHeight;
  }

  Touch get _newRaindrop => _rainTouchMapper.getTouchForPoint(_raindropX,
      _raindropY, (_sourceImageWidth ?? 0), (_sourceImageHeight ?? 0));

  int get _raindropX =>
      ((_sourceImageWidth ?? 0) * _random.nextDouble()).toInt();

  int get _raindropY =>
      ((_sourceImageHeight ?? 0) * _random.nextDouble()).toInt();
}

const double _defaultRaindropsPerSecond = 40;
