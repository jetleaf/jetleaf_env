// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_lang/lang.dart';

/// {@template jet_property}
/// Base class for all Jet framework configuration properties.
///
/// A [JetProperty] defines a typed configuration entry used within
/// JetLeaf and related Jet-based frameworks. Each property has:
///
/// - A unique [key] used for lookup in the environment.
/// - An optional [value] when the property is not set.
/// - An optional [description] to document its purpose.
///
/// Properties are strongly typed using generics. For example:
///
/// ```dart
/// const JetProperty serverPort = JetProperty("server.port", 8080, "The TCP port the server will bind to.");
/// ```
///
/// Jet also supports user-defined properties via
/// [JetProperty.custom].
/// {@endtemplate}
abstract class JetProperty with EqualsAndHashCode {
  /// The unique key used to look up this property in the environment.
  final String key;

  /// The default value of this property if no explicit value is provided.
  final Object value;

  /// A human-readable description of the property.
  final String? description;

  /// {@macro jet_property}
  const JetProperty(this.key, this.value, [this.description]);

  /// Creates a user-defined custom property.
  ///
  /// Example:
  /// ```dart
  /// final JetProperty myProp = JetProperty.custom("custom.prop", "hello");
  /// ```
  static JetProperty custom(String key, Object value, [String? description]) => _JetProperty(key, value, description);

  /// Creates a copy of this property with the specified properties changed.
  /// 
  /// {@macro jet_property}
  JetProperty copyWith({String? key, Object? value, String? description}) => _JetProperty(key ?? this.key, value ?? this.value, description ?? this.description);

  @override
  String toString() => '$runtimeType(key: $key, value: $value, description: $description)';

  @override
  List<Object?> equalizedProperties() => [key, value, description];
}

/// Internal private subclass used for [JetProperty.custom].
///
/// This allows end users to define properties dynamically
/// without needing to subclass [JetProperty].
class _JetProperty extends JetProperty {
  /// Creates a new custom property instance.
  const _JetProperty(super.key, super.value, [super.description]);
}