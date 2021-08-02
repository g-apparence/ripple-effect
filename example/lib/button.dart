import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ripple_effect/ripple_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashColor: Colors.lightBlue[100],
      ),
      home: MyPage(),
    );
  }
}

class MyPage extends StatefulWidget {
  MyPage({Key? key}) : super(key: key) {}

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final RippleController rippleController = RippleController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: RippleEffect(
              rippleController: rippleController,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('assets/mountain.png'), fit: BoxFit.cover),
                ),
              ),
            ),
          ),
          Positioned(
            top: 420,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotatingButton(
                  icon: Icons.stop,
                  onTap: (Offset position) {
                    rippleController.touch(position);
                  },
                ),
                RotatingButton(
                  icon: Icons.play_arrow,
                  onTap: (Offset position) {
                    rippleController.touch(position);
                  },
                ),
                RotatingButton(
                  icon: Icons.double_arrow,
                  onTap: (Offset position) {
                    rippleController.touch(position);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class RotatingButton extends StatefulWidget {
  final IconData icon;
  final Function onTap;

  const RotatingButton({Key? key, required this.icon, required this.onTap}) : super(key: key);

  @override
  _RotatingButtonState createState() => _RotatingButtonState();
}

class _RotatingButtonState extends State<RotatingButton> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
  late final rotationAnimation = CurvedAnimation(
    parent: controller,
    curve: Interval(0, 1, curve: Curves.decelerate),
  );
  late final bgAnimation = CurvedAnimation(
    parent: controller,
    curve: Interval(
      0,
      .2,
      curve: Curves.easeInBack,
    ),
  );

  @override
  void initState() {
    super.initState();
  }

  Rect? _getPositions() {
    var renderBox = context.findRenderObject();
    var translation = renderBox?.getTransformTo(null).getTranslation();
    if (translation != null && renderBox?.paintBounds != null) {
      return renderBox!.paintBounds.shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) async {
        await controller.forward();
        controller.reset();
        var widgetCenter = _getPositions();
        widget.onTap(widgetCenter!.center);
      },
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(bgAnimation.value.clamp(0, .6)),
            ),
            child: Transform.rotate(
              angle: rotationAnimation.value * 2 * pi,
              child: Icon(
                widget.icon,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}
