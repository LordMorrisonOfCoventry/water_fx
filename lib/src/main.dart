// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'touch/touch_sources/basic/pointer_touch_source.dart';
import 'water_fx_components/water_fx_container.dart';
import 'dart:ui' as dart_ui;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(WaterFXApp(
      await loadImageFromAsset('assets/images/space_girl_medium.jpg')));
}

Future<dart_ui.Image> loadImageFromAsset(String assetPath) async {
  ByteData assetData = await rootBundle.load(assetPath);
  List<int> assetBytes = assetData.buffer.asUint8List();
  Completer<dart_ui.Image> completer = Completer();
  dart_ui.decodeImageFromList(Uint8List.fromList(assetBytes),
      (dart_ui.Image img) => completer.complete(img));
  return completer.future;
}

class WaterFXApp extends StatefulWidget {
  final dart_ui.Image _sourceImage;

  const WaterFXApp(
    this._sourceImage, {
    super.key,
  });

  @override
  State<WaterFXApp> createState() => _WaterFXAppState();
}

class _WaterFXAppState extends State<WaterFXApp> {
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Center(
          // child: WaterFXContainer.widgetInstance(
          //   touchSource: CompoundTouchSource([
          //     PointerTouchSource(),
          //     RainTouchSource(),
          //   ]),
          //   child: RawImage(image: widget._sourceImage),
          // ),
          child: WaterFXContainer.imageInstance(
            image: widget._sourceImage,
            touchSource: PointerTouchSource(),
          ),
        ),
      );
}
