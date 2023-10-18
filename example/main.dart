// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:water_fx/water_fx.dart';
import 'dart:ui' as dart_ui;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add this image file in a assets/images folder, and reference this in your
  // pubspec.yaml file.
  runApp(WaterFXApp(await loadImageFromAsset('assets/images/london.jpg')));
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
          child: WaterFXContainer.simpleImageInstanceForPointer(
              image: widget._sourceImage),
        ),
      );
}
