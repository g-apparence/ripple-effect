import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'ripple_isolate.dart';
import 'ripple_renderobject.dart';

class RippleController extends ChangeNotifier {
  Offset? _position;
  double? _force;
  int? _radius;

  Offset? get position => _position;

  double? get force => _force;

  int? get radius => _radius;

  RippleController();

  void touch(Offset offset, double force, {int radius = 1}) {
    _position = offset;
    _force = force;
    _radius = radius;
    notifyListeners();
  }
}

enum RippleEffectBehavior {
  /// the ripple effect will be shown whenever you touch the child
  onTouch,

  /// no effect on touch, you may use this with a [RippleController] to show a
  /// ripple using reflection on child where you want manually.
  none,
}

class RippleEffect extends StatefulWidget {
  final Widget? child;
  final Size? size;
  final RippleEffectBehavior behavior;
  final RippleController? rippleController;
  final double dampening;
  final double pulsations;

  const RippleEffect({
    Key? key,
    this.child,
    this.size,
    this.rippleController,
    this.dampening = .985,
    this.pulsations = 2.2,
    this.behavior = RippleEffectBehavior.onTouch,
  }) : super(key: key);

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
        if (widget.behavior == RippleEffectBehavior.onTouch) {
          _process.touch(details.localPosition.dx, details.localPosition.dy, 1, 1000);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance!.addPostFrameCallback((_) => Future.delayed(
                Duration(milliseconds: 500),
                _startProcess,
              ));
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
      dampening: widget.dampening,
      pulsations: widget.pulsations,
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
      widget.rippleController!.radius!,
      widget.rippleController!.force!,
    );
  }

  Future<ui.Image> takeScreenshot() async {
    var boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage();
  }
}
