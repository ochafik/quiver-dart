import 'dart:async';

class AsyncSet<T> {
  final _set = new Set<T>();
  final _completers = <T, Completer>{};

  AsyncSet(Stream<T> stream) {
    stream.listen((T value) {
      _set.add(value);
      _completers.remove(value)?.complete(true);
    }, onDone: () {
      _completers.values.forEach((c) => c.complete(false));
    });
  }

  Future<bool> contains(T value) {
    if (_set.contains(value)) {
      return new Future.value(true);
    }
    return _completers.putIfAbsent(value, () => new Completer()).future;
  }
}
