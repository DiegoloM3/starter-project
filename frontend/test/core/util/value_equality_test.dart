import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/util/value_equality.dart';

class _Point with ValueEquality {
  final int x;
  final int y;

  const _Point(this.x, this.y);

  @override
  List<Object?> get props => [x, y];
}

class _NamedPoint extends _Point {
  const _NamedPoint(super.x, super.y);
}

class _Image with ValueEquality {
  final Uint8List bytes;

  const _Image(this.bytes);

  @override
  List<Object?> get props => [bytes];
}

void main() {
  test('objects with the same values are equal and share their hash code', () {
    expect(const _Point(1, 2), const _Point(1, 2));
    expect(const _Point(1, 2).hashCode, const _Point(1, 2).hashCode);
  });

  test('objects with different values are not equal', () {
    expect(const _Point(1, 2), isNot(const _Point(2, 1)));
  });

  test('objects of different types are not equal, even with the same values', () {
    expect(const _NamedPoint(1, 2), isNot(const _Point(1, 2)));
  });

  test('lists are compared item by item', () {
    final a = _Image(Uint8List.fromList([1, 2, 3])), b = _Image(Uint8List.fromList([1, 2, 3]));

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(_Image(Uint8List.fromList([1, 2, 4]))));
  });

  test('describes itself with its type and values', () {
    expect(const _Point(1, 2).toString(), '_Point(1, 2)');
  });
}
