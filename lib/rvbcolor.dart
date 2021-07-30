import 'dart:ui';
import 'package:image/image.dart' as img;

class RvbColor {
  int r, g, b, a;

  RvbColor(this.r, this.g, this.b, this.a);

  factory RvbColor.empty() => RvbColor(0, 0, 0, 0);

  factory RvbColor.fromRgba(int c1) {
    // int r = (c1 >> 24) & 0xff;
    // int g = (c1 >> 16) & 0xff;
    // int b = (c1 >> 8) & 0xff;
    // int a = (c1) & 0xff;
    int r = (c1 >> 24 & 0xff);
    int g = ((c1 & 0xff0000) >> 16);
    int b = ((c1 & 0xff00) >> 8);
    int a = (c1 & 0xff);
    return RvbColor(r, g, b, a);
  }

  factory RvbColor.fromAbgr(int c1) {
    int a = (c1 >> 24) & 0xff;
    int b = (c1 >> 16) & 0xff;
    int g = (c1 >> 8) & 0xff;
    int r = (c1) & 0xff;
    return RvbColor(r, g, b, a);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RvbColor && runtimeType == other.runtimeType && a == other.a && b == other.b && g == other.g && r == other.r;

  @override
  int get hashCode => a.hashCode;

  RvbColor operator +(RvbColor other) {
    var rPrime = (r + other.r).clamp(0, 255);
    var gPrime = (g + other.g).clamp(0, 255);
    var bPrime = (b + other.b).clamp(0, 255);
    var aPrime = (a + other.a).clamp(0, 255);
    return RvbColor(rPrime, gPrime, bPrime, aPrime);
  }

  RvbColor operator -(RvbColor other) {
    var rPrime = (r - other.r).clamp(0, 255);
    var gPrime = (g - other.g).clamp(0, 255);
    var bPrime = (b - other.b).clamp(0, 255);
    var aPrime = (a - other.a).clamp(0, 255);
    return RvbColor(rPrime, gPrime, bPrime, aPrime);
  }

  RvbColor operator /(RvbColor other) {
    var rPrime = r ~/ other.r;
    var gPrime = g ~/ other.g;
    var bPrime = b ~/ other.b;
    var aPrime = other.a > 0 ? a ~/ other.a : 0;
    return RvbColor(
      rPrime > 255 ? 255 : rPrime,
      gPrime > 255 ? 255 : gPrime,
      bPrime > 255 ? 255 : bPrime,
      aPrime > 255 ? 255 : aPrime,
    );
  }

  RvbColor operator *(RvbColor other) {
    var rPrime = r * other.r;
    var gPrime = g * other.g;
    var bPrime = b * other.b;
    var aPrime = a * other.a;
    return RvbColor(
      rPrime.clamp(0, 255),
      gPrime.clamp(0, 255),
      bPrime.clamp(0, 255),
      aPrime.clamp(0, 255),
    );
  }

  void multiply(double value) {
    r = (r * value).toInt();
    g = (g * value).toInt();
    b = (b * value).toInt();
    a = (a * value).toInt();
  }

  void divide(double value) {
    if (r != 0) r = r ~/ value;
    if (g != 0) g = g ~/ value;
    if (b != 0) b = b ~/ value;
    if (a != 0) a = a ~/ value;
  }

  Color get color => Color.fromARGB(a, r, g, b);

  RvbColor clone() => RvbColor(r, g, b, a);

  int toRgba() => r << 24 | g << 16 | b << 8 | a;

  int toAgbr() => a << 24 | g << 16 | b << 8 | r;

  RvbColor blendColors(RvbColor other, {double ratio = 0.5}) {
    ratio.clamp(0, 1);
    int A = (a + (other.a - a) * ratio).toInt();
    int R = (r + (other.r - r) * ratio).toInt();
    int G = (g + (other.g - g) * ratio).toInt();
    int B = (b + (other.b - b) * ratio).toInt();
    return RvbColor(R, G, B, A);
  }
}
