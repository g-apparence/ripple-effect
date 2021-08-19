import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

class RippleRenderObject extends SingleChildRenderObjectWidget {
  final Widget? child;
  final ui.Image? image;

  RippleRenderObject({this.child, this.image}) : super(child: child);

  @override
  RippleRender createRenderObject(BuildContext context) => RippleRender();

  @override
  void updateRenderObject(BuildContext context, covariant RippleRender renderObject) {
    renderObject.image = image;
    renderObject.markNeedsPaint();
    // renderObject.markNeedsLayout();
  }
}

class RippleRender extends RenderProxyBox {
  bool _alwaysIncludeSemantics;
  ui.Image? image;

  final painter = Paint()..isAntiAlias = true;

  RippleRender({
    this.image,
    bool alwaysIncludeSemantics = false,
    RenderBox? child,
  })  : _alwaysIncludeSemantics = alwaysIncludeSemantics,
        super(child);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
    }
    if (image != null) {
      context.canvas.drawImageRect(
        image!,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()),
        Offset.zero & Size(image!.width.toDouble(), image!.height.toDouble()),
        painter,
      );
    }
  }
}
