import 'dart:async';

import 'package:quiver/streams.dart' as streams;

class AsyncSet<T> {
  final _set = new Set<T>();
  final _containsCompleters = <T, Completer<bool>>{};
  final _completer = new Completer();
  final Stream<T> _stream;

  AsyncSet(this._stream) {
    _stream.listen((T value) {
      _set.add(value);
      _containsCompleters.remove(value)?.complete(true);
    }, onDone: () {
      _containsCompleters.values.forEach((c) => c.complete(false));
      _completer.complete();
    });
  }

  Future<Set<T>> toSet() => _completer.future.then((_) => _set);

  Future<bool> contains(T value) {
    if (_set.contains(value)) {
      return new Future.value(true);
    }
    return _containsCompleters
        .putIfAbsent(value, () => new Completer<bool>())
        .future;
  }

  Stream<T> toStream() {
    return streams.concat(
        [new Stream<T>.fromIterable(_set.toList(growable: false)), _stream]);
  }
}
