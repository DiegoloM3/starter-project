/// Makes two objects equal when they are of the same type and their [props] are equal, like the `equatable`
/// package. It is written in pure Dart so the domain layer does not depend on a package
/// (docs/APP_ARCHITECTURE.md: the domain layer is implemented purely in Dart, with no outer packages).
///
/// Lists in [props] are compared item by item, so two thumbnails with the same bytes are equal.
mixin ValueEquality {
  /// The values that make two objects equal.
  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ValueEquality && other.runtimeType == runtimeType && _equalValues(props, other.props);

  @override
  int get hashCode => Object.hashAll(props.map(_hashOf));

  @override
  String toString() => '$runtimeType(${props.join(', ')})';
}

bool _equalValues(Object? a, Object? b) {
  if (a is List && b is List) return _equalLists(a, b);
  return a == b;
}

bool _equalLists(List a, List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (!_equalValues(a[i], b[i])) return false;
  }
  return true;
}

int _hashOf(Object? value) => value is List ? Object.hashAll(value.map(_hashOf)) : value.hashCode;
