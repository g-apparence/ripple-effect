import 'dart:typed_data';

typedef ForEachIterator = void Function(int x, int y);

class TilesMap {
  final int width, height;
  final Float64List _tiles;

  TilesMap._(this._tiles, this.width, this.height);

  factory TilesMap.generate(int width, int height, double defaultContent) {
    final _tiles = Float64List(width * height);
    for (var i = 0; i < _tiles.length; i++) _tiles[i] = defaultContent;
    return TilesMap._(_tiles, width, height);
  }

  // utilities

  @pragma('vm:prefer-inline')
  double getOne(int x, int y) => _tiles[index(x, y)];

  @pragma('vm:prefer-inline')
  double query(int x, int y) {
    x = x.round().clamp(0, width - 1);
    y = y.round().clamp(0, height - 1);
    return getOne(x, y);
  }

  @pragma('vm:prefer-inline')
  void setValue(int x, int y, double data) {
    _tiles[index(x, y)] = data;
  }

  @pragma('vm:prefer-inline')
  int index(int x, int y) => x + y * width;

  @pragma('vm:prefer-inline')
  double operator [](int index) => _tiles[index];

  @pragma('vm:prefer-inline')
  void operator []=(int index, double value) {
    _tiles[index] = value;
  }

  void forEach(ForEachIterator it) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        it(x, y);
      }
    }
  }

  TilesMap clone() => TilesMap._(
      Float64List(_tiles.length)..setRange(0, _tiles.length, _tiles),
      width,
      height);

  int get length => _tiles.length;
}
