// (c) 2023 - Jim Morrison
// You may use this code however you want, as long as you show my name and this
// link in your work: http://www.jimmorrison101.com/.

import 'package:flutter/material.dart';
import '../../barrier.dart';

// A [Barrier] around the inside edges of the container.
class PaddingBarrier implements Barrier {
  final EdgeInsets edgeInsets;

  const PaddingBarrier(this.edgeInsets);

  @override
  bool containsPoint(int pointX, int pointY, int imageWidth, int imageHeight) =>
      pointX < edgeInsets.left ||
      pointX > (imageWidth - edgeInsets.right) ||
      pointY < edgeInsets.top ||
      pointY > (imageHeight - edgeInsets.bottom);
}
