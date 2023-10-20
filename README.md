A library for adding water effects to Flutter apps.

Wrap any widget with a `WaterFXContainer`, and it will appear as if it is under
water when touched. You will see water ripples moving across the surface of
your widget. The image below is an animated screenshot of a Flutter app that is
using the WaterFX library. This effect can be applied to any Flutter widget;
image, video, button, table etc. Touches can be applied by the pointer, the
finger, or by code. E.g. you can use code to simulate rain drops falling on
your widget.

<p><img src="https://github.com/LordMorrisonOfCoventry/water_fx/assets/143798899/93ed45b2-a399-4348-92dc-494999204934?raw=true" alt="WaterFX wrapping an image" /></p>

Check out the WaterFX web page - www.jimmorrison101.com/water_fx/

## Getting started

To use this plugin, add `water_fx` as a [dependency in your pubspec.yaml file](https://flutter.dev/docs/development/platform-integration/platform-channels).


## Examples

Example with an image:

```dart
import 'package:water_fx/water_fx.dart';
// ...

@override
Widget build(BuildContext context) => MaterialApp(
      home: Center(
      child: WaterFXContainer.simpleImageInstanceForPointer(
        image: _sourceImage, // _sourceImage is a dart:ui.Image.
      ),
    ),
  );
```


Example with a widget.

```dart
import 'package:water_fx/water_fx.dart';
// ...

@override
Widget build(BuildContext context) => MaterialApp(
     home: Center(
      child: WaterFXContainer.simpleWidgetInstanceForPointer(
        child: _child, // _child is a Widget.
      ),
    ),
  );
```


## Additional information

You can find out more about WaterFX here: www.jimmorrison101.com/water_fx

The original idea for WaterFX is based on an algorithm by Neil Wallis: https://www.neilwallis.com/index.php
