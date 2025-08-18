import 'class_binding_schema.dart';
import 'object_binder.dart';

/// A central registry for [ClassBindingSchema] and [ObjectBinder] instances.
///
/// This allows the [Binder] to look up how to bind a specific type
/// without relying on `dart:mirrors`.
class BindingRegistry {
  static final BindingRegistry _instance = BindingRegistry._internal();

  factory BindingRegistry() {
    return _instance;
  }

  BindingRegistry._internal();

  final Map<Type, ClassBindingSchema> _schemas = {};
  final Map<Type, ObjectBinder> _objectBinders = {};

  /// Registers a [ClassBindingSchema] and its corresponding [ObjectBinder].
  void register<T>(ClassBindingSchema<T> schema, ObjectBinder<T> objectBinder) {
    _schemas[T] = schema;
    _objectBinders[T] = objectBinder;
  }

  /// Retrieves the [ClassBindingSchema] for a given [type].
  ClassBindingSchema<T>? getSchema<T>(Type type) {
    return _schemas[type] as ClassBindingSchema<T>?;
  }

  /// Retrieves the [ObjectBinder] for a given [type].
  ObjectBinder<T>? getObjectBinder<T>(Type type) {
    return _objectBinders[type] as ObjectBinder<T>?;
  }
}