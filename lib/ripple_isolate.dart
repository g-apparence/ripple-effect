import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'ripple_model.dart';

class WaterRippleProcessData {
  final double width;
  final double height;
  final double pixelRatio;
  final Uint8List? backgroundBytes;
  SendPort sendPort;

  WaterRippleProcessData(this.sendPort, this.width, this.height, this.pixelRatio, {this.backgroundBytes});
}

class TouchData {
  double x;
  double y;
  int radius;

  TouchData(this.x, this.y, this.radius);
}

class WaterRippleProcess {
  Isolate? isolate;
  SendPort? _toIsolate;
  bool running;
  StreamController<img.Image>? _streamController;
  Stream<img.Image>? _stream;

  WaterRippleProcess() : this.running = false;

  Stream<img.Image> runIsolate({
    required double width,
    required double height,
    required pixelRatio,
    Uint8List? backgroundBytes,
  }) {
    if (running) {
      return _stream!;
    }
    running = true;
    var fromIsolate = ReceivePort();
    _streamController = StreamController<img.Image>();
    fromIsolate.listen((data) {
      if (data is SendPort) {
        _toIsolate = data;
      }
      if (data is img.Image) {
        _streamController!.sink.add(data);
      }
    });
    Isolate.spawn(
        _update,
        WaterRippleProcessData(
          fromIsolate.sendPort,
          width,
          height,
          pixelRatio,
          backgroundBytes: backgroundBytes,
        )).then((value) => isolate = value);
    _stream = _streamController!.stream.asBroadcastStream();
    return _stream!;
  }

  void touch(double x, double y, int radius) => _toIsolate?.send(TouchData(x, y, radius));

  void update() {
    if (_toIsolate == null) {
      return;
    }
    _toIsolate!.send("");
  }

  stop() {
    if (isolate != null) {
      isolate!.kill();
    }
    _streamController!.close();
    _toIsolate = null;
    _streamController = null;
    running = false;
  }

  static void _update(WaterRippleProcessData data) async {
    var _toIsolate = ReceivePort();
    var waterRipleController = WaterRipleController.init(
      data.width,
      data.height,
      data.pixelRatio,
      backgroundBytes: data.backgroundBytes!,
    );
    data.sendPort.send(_toIsolate.sendPort);

    _toIsolate.listen((message) {
      if (message is TouchData) {
        waterRipleController.touch(message.x, message.y, message.radius);
      } else {
        waterRipleController.update();
        data.sendPort.send(waterRipleController.image);
      }
    });
  }
}
