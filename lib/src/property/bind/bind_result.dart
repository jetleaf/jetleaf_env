import 'package:jetleaf_lang/lang.dart';

/// {@template bind_result}
/// Represents the outcome of a property binding operation.
///
/// A [BindResult] encapsulates whether a binding was successful,
/// and the resulting bound value (if any).
///
/// Usage:
/// ```dart
/// var result = BindResult.of('localhost');
/// if (result.isBound) {
///   print(result.get()); // 'localhost'
/// }
/// ```
/// {@endtemplate}
@Generic(BindResult)
class BindResult<T> {
  /// The value resulting from the binding, or `null` if not bound.
  final T? value;

  /// Whether a value was successfully bound.
  final bool isBound;

  /// Internal constructor for creating a [BindResult].
  BindResult._(this.value, this.isBound);

  /// Creates a successful [BindResult] with the given [value].
  factory BindResult.of(T value) => BindResult._(value, true);

  /// Creates a [BindResult] indicating that no value was bound.
  factory BindResult.notBound() => BindResult._(null, false);

  /// Returns the bound value.
  ///
  /// Throws a [IllegalStateException] if no value was bound (i.e., [isBound] is `false`).
  T get() {
    if (!isBound) {
      throw IllegalStateException('Value is not bound.');
    }
    return value as T;
  }
}