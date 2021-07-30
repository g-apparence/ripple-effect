typedef ForEachIterator = void Function(int x, int y);

class TilesMap<T> {
  final int width, height;
  final List<T> _tiles;

  TilesMap._(this._tiles, this.width, this.height);

  factory TilesMap.generate(int width, int height, T defaultContent) {
    List<T> _tiles = List.filled(width * height, defaultContent);
    return TilesMap._(_tiles, width, height);
  }

  // utilities

  T? getOne(int x, int y) => _tiles[index(x, y)];

  T? query(int x, int y) {
    x = x.round().clamp(0, width - 1);
    y = y.round().clamp(0, height - 1);
    return getOne(x, y);
  }

  void setValue(int x, int y, T data) {
    _tiles[index(x, y)] = data;
  }

  int index(int x, int y) => x + y * width;

  T? operator [](int index) => _tiles[index];

  void forEach(ForEachIterator it) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        it(x, y);
      }
    }
  }

  TilesMap clone() => TilesMap._([..._tiles], width, height);

  int get length => _tiles.length;
}
