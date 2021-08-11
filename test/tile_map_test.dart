import 'package:flutter_test/flutter_test.dart';
import 'package:ripple_effect/tile_map.dart';

void main() {
  /// benchmark
  /// TilesMap<T> with List<T> _tiles
  /// min: 90ms | max: 120ms | avg: 99.57ms
  /// Float32List _tiles;
  /// min: 72ms | max: 105ms | avg: 78.26ms
  test('benchmark', () {
    Duration min = Duration(milliseconds: 20000);
    Duration max = Duration(milliseconds: 0);
    Duration sum = Duration(milliseconds: 0);
    var nbTest = 100;
    for (int i = 0; i < nbTest; i++) {
      var d1 = DateTime.now();
      var map = TilesMap.generate(2000, 2000, 0);
      map.forEach((x, y) {
        map.setValue(x, y, 100);
      });
      var duration = DateTime.now().difference(d1);
      if (duration < min) {
        min = duration;
      }
      if (duration > max) {
        max = duration;
      }
      sum += duration;
    }
    print("min: ${min.inMilliseconds}ms | max: ${max.inMilliseconds}ms | avg: ${sum.inMilliseconds / nbTest}ms");
  });
}
