// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of quiver.iterables;

/**
 * Returns the result of merging an [Iterable] of [Iterable]s, according to
 * the order specified by the [compare] function. This function assumes the
 * provided iterables are already sorted according to the provided [compare]
 * function. It will not check for this condition or sort the iterables.
 *
 * The compare function must act as a [Comparator]. If [compare] is omitted,
 * [Comparable.compare] is used.
 *
 * If any of the [iterables] contain null elements, an exception will be
 * thrown.
 */
Iterable merge(Iterable<Iterable> iterables,
               [Comparator compare = Comparable.compare]) =>
    (iterables.isEmpty) ? const [] : new _Merge(iterables, compare);

class _Merge extends IterableBase {
  final Iterable<Iterable> _iterables;
  final Comparator _compare;

  _Merge(this._iterables, this._compare);

  Iterator get iterator =>
      new _MergeIterator(
          _iterables.map((i) => i.iterator),
          _compare);

  String toString() => this.toList().toString();
}

class _MergeIterator<T> implements Iterator<T> {
  MinHeap<Iterator<T>> _heap;
  T _current;

  _MergeIterator(Iterable<Iterator<T>> iterators, Comparator<T> comparator) {
    _heap = new MinHeap<Iterator<T>>(comparator: (Iterator<T> a, Iterator<T> b) {
      return comparator(a.current, b.current);
    });
    _heap.addAll(iterators.where((it) => it.moveNext()));
  }
  
  @override bool moveNext() {
    if (_heap.isEmpty) {
      return false;
    }
    var it = _heap.removeMin();
    _current = it.current;
    if (it.moveNext()) {
      _heap.add(it);
    }
    return true;
  }

  @override get current => _current;
}
