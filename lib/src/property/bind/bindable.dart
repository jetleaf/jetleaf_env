import 'dart:mirrors'; // For illustrative purposes, would be replaced by code generation in production.

import '../../annotations/configuration_properties.dart';

/// {@template bindable}
/// Represents something that can be bound during the configuration binding process,
/// such as a class, field, method parameter, or constructor parameter.
///
/// A [Bindable] encapsulates metadata about the element to bind, including:
/// - Its [type]
/// - Its optional [name]
/// - Whether it is [isNested] (i.e., requires recursive binding)
/// - Whether it participates in constructor-based binding ([isConstructorBinding])
/// - A possible [defaultValue] derived from annotations
///
/// Typically created by reflection during runtime or through code generation at build time.
/// {@endtemplate}
class Bindable<T> {
  /// The type of the bindable element.
  final Type type;

  /// The name of the element (field or parameter).
  ///
  /// This is either inferred from the declaration or provided via the `@Name` annotation.
  final String? name;

  /// The default value for this binding, as defined by the `@DefaultValue` annotation.
  final Object? defaultValue;

  /// Whether the value should be bound recursively, typically for nested configuration objects.
  final bool isNested;

  /// Whether this bindable participates in constructor-based binding
  /// (e.g., the class is annotated with `@ConstructorBinding`).
  final bool isConstructorBinding;

  /// {@macro bindable}
  const Bindable({
    required this.type,
    this.name,
    this.defaultValue,
    this.isNested = false,
    this.isConstructorBinding = false,
  });

  /// Creates a [Bindable] for the generic type [T].
  ///
  /// Useful for manually constructing a binding target.
  ///
  /// Example:
  /// ```dart
  /// final bindable = Bindable.forType<MyClass>();
  /// ```
  static Bindable<T> forType<T>() {
    return Bindable<T>(type: T);
  }

  /// Creates a [Bindable] from a [DeclarationMirror].
  ///
  /// This inspects the provided mirror and extracts:
  /// - The type of the declaration
  /// - Any annotations (`@DefaultValue`, `@Nested`, `@ConstructorBinding`, `@Name`)
  ///
  /// This API is primarily used in development or testing environments and will be replaced
  /// by JetLeaf’s reflection system in production to support AOT-compatible behavior.
  ///
  /// Example:
  /// ```dart
  /// Bindable.fromDeclaration(someMirror);
  /// ```
  /// 
  /// TODO: Replace with JetLeaf's reflection system that supports AOT and JIT
  static Bindable fromDeclaration(DeclarationMirror declaration) {
    final type = (declaration is VariableMirror)
        ? declaration.type.reflectedType
        : (declaration is MethodMirror && declaration.isGetter)
            ? declaration.returnType.reflectedType
            : (declaration is ParameterMirror)
                ? declaration.type.reflectedType
                : Object; // Fallback

    final name = MirrorSystem.getName(declaration.simpleName);
    final defaultValueAnnotation = declaration.metadata
        .whereType<DefaultValue>()
        .firstOrNull;
    final nestedAnnotation = declaration.metadata
        .whereType<Nested>()
        .firstOrNull;
    final constructorBindingAnnotation = declaration.metadata
        .whereType<ConstructorBinding>()
        .firstOrNull;
    final nameAnnotation = declaration.metadata
        .whereType<Name>()
        .firstOrNull;

    return Bindable(
      type: type,
      name: nameAnnotation?.value ?? name,
      defaultValue: defaultValueAnnotation?.value,
      isNested: nestedAnnotation != null,
      isConstructorBinding: constructorBindingAnnotation != null,
    );
  }
}