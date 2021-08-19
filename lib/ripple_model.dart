import 'dart:async';
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' as v;
import 'package:image/image.dart' as img;

import 'tile_map.dart';

import 'dart:ffi';
import 'package:ffi/ffi.dart';

class WaterRipple {
  final double width;
  final double height;
  final double ratio;
  final double dampening;
  final double pulsations;
  bool updating = false;

  final int widthR, heightR;
  TilesMap current, previous;
  final img.Image _image, _sourceImg;
  final Pointer<Double> f64;
  final Pointer<Int32> i32;

  WaterRipple._({
    required this.width,
    required this.height,
    required this.ratio,
    required this.dampening,
    required this.pulsations,
    required this.widthR,
    required this.heightR,
    required this.current,
    required this.previous,
    required img.Image image,
    required img.Image srcImage,
    required this.f64,
    required this.i32,
  })  : updating = false,
        _image = image,
        _sourceImg = srcImage;

  factory WaterRipple.init(
    double width,
    double height,
    double pixelRatio, {
    required Uint8List backgroundBytes,
    double dampening = .985,
    double pulsations = 2.2,
  }) {
    var widthR = width ~/ pixelRatio;
    var heightR = height ~/ pixelRatio;
    var _image = img.Image.fromBytes(width.toInt(), height.toInt(), backgroundBytes, format: img.Format.rgba);
    final f64 = malloc.allocate(8).cast<Double>();
    final i32 = f64.cast<Int32>();
    return WaterRipple._(
      width: width,
      height: height,
      ratio: pixelRatio,
      widthR: widthR,
      heightR: heightR,
      current: TilesMap.generate(widthR, heightR, 0),
      previous: TilesMap.generate(widthR, heightR, 0),
      image: _image,
      srcImage: _image.clone(),
      dampening: dampening,
      pulsations: pulsations,
      f64: f64,
      i32: i32,
    );
  }

  Future update() {
    if (updating) return Future.value();
    updating = true;
    return Future(_computeUpdate);
  }

  void _computeUpdate() {
    final sw = Stopwatch()..start();
    final yLimit = (heightR - 1) * widthR;
    for (int y = widthR; y < yLimit; y += widthR) {
      for (int x = 1; x < widthR - 1; x += 1) {
        final tileIndex = x + y;
        var c1 = previous[tileIndex - 1];
        var c2 = previous[tileIndex + 1];
        var c3 = previous[tileIndex - widthR];
        var c4 = previous[tileIndex + widthR];
        var color = (c1 + c2 + c3 + c4) / pulsations - current[tileIndex];
        color *= dampening;
        current[tileIndex] = color;
      }
    }

    for (int y = widthR, yi = 1; y < yLimit; y += widthR, yi++) {
      for (int x = 1; x < widthR - 1; x += 1) {
        final tileIndex = x + y;
        var xOffsetD = (current[tileIndex + 1] - current[tileIndex - 1]);
        var yOffsetD = (current[tileIndex + widthR] - current[tileIndex - widthR]);

        var xOffset = round(xOffsetD);
        var yOffset = round(yOffsetD);

        xOffset = clamp(xOffset, -8, 8);
        yOffset = clamp(yOffset, -8, 8);
        final index = x + y;
        final pixel2Src = _sourceImg.getPixel(
          clamp(x + xOffset, 0, widthR - 1),
          clamp(yi + yOffset, 0, heightR - 1),
        );
        _image.data[index] = pixel2Src;
      }
    }
    // copy current to previous
    var temp = previous;
    previous = current;
    current = temp;
    updating = false;
    // print("updated in ${sw.elapsedMilliseconds}ms");
  }

  // HACK: int.clamp is not always inlined. filed http://dartbug.com/46879
  @pragma('vm:prefer-inline')
  static int clamp(int v, int x, int y) {
    if (v < x) {
      return x;
    } else if (v > y) {
      return y;
    }
    return v;
  }

  @pragma('vm:prefer-inline')
  int round(double value) {
    // HACK: work-around lack of fast toInt().
    // Filed http://dartbug.com/46876
    // See https://stackoverflow.com/a/17035583/662844 for an explanation
    // of this trick.
    final f64 = this.f64;
    final i32 = this.i32;
    f64.value = value + 6755399441055744.0;
    return i32.value;
  }

  void touch(double x, double y, int radius, double force) {
    var dy = y ~/ ratio;
    var dx = x ~/ ratio;
    var center = v.Vector2(dx.toDouble(), dy.toDouble());
    for (int y = 1; y < heightR - 1; y += 1) {
      for (int x = 1; x < widthR - 1; x += 1) {
        var point = v.Vector2(x.toDouble(), y.toDouble());
        if (point.distanceTo(center) <= radius) {
          previous.setValue(x, y, force);
        }
      }
    }
  }

  img.Image get image => _image;
}
