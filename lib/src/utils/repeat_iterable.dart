class RepeatIterable<T> extends Iterable<List<T>> {
  RepeatIterable({
    required this.repeatCount,
    required this.input,
  });

  final int repeatCount;
  final List<T> input;

  @override
  Iterator<List<T>> get iterator => RepeatIterator(input, repeatCount: repeatCount);
}

class RepeatIterator<T> implements Iterator<List<T>> {
  RepeatIterator(
    this._current, {
    required this.repeatCount,
  });

  final int repeatCount;
  final List<T> _current;
  int _count = 0;

  @override
  List<T> get current => _current;

  @override
  bool moveNext() {
    if (_count < repeatCount) {
      _count += 1;
      return true;
    } else {
      return false;
    }
  }
}
