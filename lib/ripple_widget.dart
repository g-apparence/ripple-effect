import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'ripple_isolate.dart';
import 'ripple_renderobject.dart';

// check ImageShader
//
// FragmentShader coming soon
// https://github.com/flutter/engine/pull/26996

class RippleController extends ChangeNotifier {
  Offset? _position;

  Offset? get position => _position;

  RippleController() {}

  void touch(Offset offset) {
    _position = offset;
    notifyListeners();
  }
}

class RippleEffect extends StatefulWidget {
  final Widget? child;
  final Size? size;
  final RippleController? rippleController;

  const RippleEffect({Key? key, this.child, this.size, this.rippleController}) : super(key: key);

  @override
  _RippleEffectState createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late WaterRippleProcess _process;
  final GlobalKey _repaintKey = GlobalKey();
  Stream<img.Image>? _stream;
  ui.Image? _image;
  Uint8List? _bgBytes;
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _process = WaterRippleProcess();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )
      ..addListener(() {
        _process.update();
      })
      ..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.rippleController != null) {
      widget.rippleController!.addListener(_onExternalTouch);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.rippleController != null) {
      widget.rippleController!.removeListener(_onExternalTouch);
    }
    _streamSubscription.cancel();
    _process.stop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        _process.touch(details.localPosition.dx, details.localPosition.dy, 1);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          Future.delayed(Duration(seconds: 2), _startProcess);
          // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) => _startProcess());
          return RepaintBoundary(
            key: _repaintKey,
            child: RippleRenderObject(
              child: widget.child,
              image: _image,
            ),
          );
        },
      ),
    );
  }

  Future _startProcess() async {
    if (_stream != null) {
      return;
    }
    var image = await takeScreenshot();
    _bgBytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
    _stream = _process.runIsolate(
      width: image.width.toDouble(),
      height: image.height.toDouble(),
      pixelRatio: 1.0,
      backgroundBytes: _bgBytes,
    );
    _streamSubscription = _stream!.listen(_onNewImage);
  }

  void _onNewImage(img.Image data) {
    ui.decodeImageFromPixels(
      data.getBytes(),
      data.width,
      data.height,
      ui.PixelFormat.rgba8888,
      (imgRes) {
        setState(() => this._image = imgRes);
      },
    );
  }

  void _onExternalTouch() {
    _process.touch(
      widget.rippleController!.position!.dx,
      widget.rippleController!.position!.dy,
      4,
    );
  }

  Future<ui.Image> takeScreenshot() async {
    var boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage();
  }
}
