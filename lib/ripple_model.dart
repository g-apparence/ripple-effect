import 'dart:async';
import 'dart:typed_data';

import 'package:vector_math/vector_math.dart' as v;
import 'package:image/image.dart' as img;

import 'tile_map.dart';

class WaterRipleController {
  late double width;
  late double height;
  late double ratio;
  double dampening;
  bool updating = false;

  late int widthR, heightR;
  late TilesMap<double> current, previous; //V2
  late img.Image _image, _sourceImg;
  DateTime? lastUpdate;

  WaterRipleController._({
    required this.width,
    required this.height,
    required this.ratio,
    required this.dampening,
    required this.widthR,
    required this.heightR,
    required this.current,
    required this.previous,
    required img.Image image,
    required img.Image srcImage,
  })  : updating = false,
        _image = image,
        _sourceImg = srcImage;

  factory WaterRipleController.init(
    double width,
    double height,
    double pixelRatio, {
    required Uint8List backgroundBytes,
    double dampening = .95,
  }) {
    var widthR = width ~/ pixelRatio;
    var heightR = height ~/ pixelRatio;
    var _image = img.Image.fromBytes(width.toInt(), height.toInt(), backgroundBytes, format: img.Format.rgba);
    return WaterRipleController._(
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
    );
  }

  Future update() {
    if (updating) return Future.value();
    updating = true;
    return Future(() {
      for (int y = 1; y < heightR - 1; y += 1) {
        for (int x = 1; x < widthR - 1; x += 1) {
          var c1 = previous.getOne(x - 1, y)!;
          var c2 = previous.getOne(x + 1, y)!;
          var c3 = previous.getOne(x, y - 1)!;
          var c4 = previous.getOne(x, y + 1)!;
          var color = (c1 + c2 + c3 + c4) / 2 - current.getOne(x, y)!;
          color *= dampening;
          current.setValue(x, y, color);
        }
      }
      for (int y = 1; y < heightR - 1; y += 1) {
        for (int x = 1; x < widthR - 1; x += 1) {
          _refraction(x, y);
        }
      }
      // copy current to previous
      var temp = previous;
      previous = current;
      current = temp;
      updating = false;
      lastUpdate = DateTime.now();
    });
  }

  void touch(double x, double y, int radius) {
    var dy = y ~/ ratio;
    var dx = x ~/ ratio;
    var center = v.Vector2(dx.toDouble(), dy.toDouble());
    for (int y = 1; y < heightR - 1; y += 1) {
      for (int x = 1; x < widthR - 1; x += 1) {
        var point = v.Vector2(x.toDouble(), y.toDouble());
        if (point.distanceTo(center) <= radius) {
          previous.setValue(x, y, 1000);
        }
      }
    }
  }

  void _refraction(int x, int y) {
    var xOffset = (current.getOne(x + 1, y)! - current.getOne(x - 1, y)!).toInt();
    var yOffset = (current.getOne(x, y + 1)! - current.getOne(x, y - 1)!).toInt();
    xOffset = xOffset.clamp(-8, 8);
    yOffset = yOffset.clamp(-8, 8);
    var pixel2Src = _sourceImg.getPixel(
      (x + xOffset).clamp(0, widthR - 1),
      (y + yOffset).clamp(0, heightR - 1),
    );

    _image.setPixel(x, y, pixel2Src);
  }

  img.Image get image => _image;
}
