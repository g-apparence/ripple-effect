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
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/04.jpg'), fit: BoxFit.cover),
              ),
            ),
          ),
          Positioned.fill(
            child: RippleEffect(
              pulsations: 2.8,
              dampening: .94,
              rippleController: rippleController,
              child: Container(
                alignment: Alignment.topCenter,
                child: ClipRect(
                  child: Image.asset(
                    'assets/04.jpg',
                    width: double.infinity,
                    height: 400,
                    fit: BoxFit.none,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: 240,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotatingButton(
                  icon: Icons.stop,
                  onTap: (Offset position) {
                    rippleController.touch(position, 100, radius: 32);
                  },
                ),
                RotatingButton(
                  icon: Icons.play_arrow,
                  onTap: (Offset position) {
                    rippleController.touch(position, 100, radius: 24);
                  },
                ),
                RotatingButton(
                  icon: Icons.double_arrow,
                  onTap: (Offset position) {
                    rippleController.touch(position, 100, radius: 24);
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
  late final controller = AnimationController(vsync: this, duration: Duration(milliseconds: 350));
  late final rotationAnimation = CurvedAnimation(
    parent: controller,
    curve: Interval(0, 1, curve: Curves.decelerate),
  );
  late final bgAnimation = CurvedAnimation(
    parent: controller,
    curve: Interval(
      0,
      1,
      curve: Curves.easeIn,
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
              color: Colors.white.withOpacity(sin(bgAnimation.value * pi)),
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
