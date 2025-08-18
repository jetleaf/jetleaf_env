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

/// {@template property_source}
/// A base abstraction representing a source of key-value properties, such as
/// maps, environment variables, or configuration files.
///
/// Each [PropertySource] has a unique [name] and a backing [source] of type `T`,
/// which holds the actual data. Concrete subclasses implement lookup behavior
/// using [containsProperty] and [getProperty].
///
/// Common implementations include:
/// - [MapPropertySource]
/// - [PropertiesPropertySource]
///
/// This abstraction allows a flexible property resolution system where multiple
/// sources can be layered and resolved by a resolver such as
/// [PropertySourcesPropertyResolver].
///
/// ### Example usage:
///
/// ```dart
/// class MyEnvSource extends PropertySource<Map<String, String>> {
///   MyEnvSource(String name, Map<String, String> source) : super(name, source);
///
///   @override
///   bool containsProperty(String name) => source.containsKey(name);
///
///   @override
///   Object? getProperty(String name) => source[name];
/// }
///
/// final env = MyEnvSource('env', {'APP_ENV': 'prod'});
/// print(env.getProperty('APP_ENV')); // prod
/// ```
/// {@endtemplate}
@Generic(PropertySource)
abstract class PropertySource<T> {
  /// {@template property_source_name}
  /// The unique name that identifies this property source. 
  /// Typically used for logging, debugging, and source resolution order.
  ///
  /// Example: `"applicationConfig"`, `"systemEnvironment"`, etc.
  /// {@endtemplate}
  final String name;

  /// {@template property_source_source}
  /// The underlying object that holds the raw property data.
  ///
  /// For example:
  /// - A `Map<String, Object>` for in-memory key-value sources
  /// - A `Properties` object for Java-style property files
  /// - A file, YAML map, or even a shell environment variable map.
  ///
  /// Subclasses are expected to access this during lookups.
  /// {@endtemplate}
  final T source;

  /// {@macro property_source}
  PropertySource(this.name, this.source);

  /// {@macro property_source}
  ///
  /// Creates a named property source without any backing source.
  /// Useful for stubs or symbolic sources.
  PropertySource.named(String name) : this(name, Object() as T);

  /// Returns `true` if this property source contains the given [name].
  ///
  /// Should check if the underlying [source] holds a value for the property.
  bool containsProperty(String name) => (getProperty(name) != null);

  /// Retrieves the value associated with the given [name], or `null` if not present.
  ///
  /// The resolution logic depends on the [source] type and subclass behavior.
  Object? getProperty(String name);

  /// Returns the name of this property source.
  /// 
  /// {@macro property_source_name}
  String getName() => name;

  /// Returns the underlying source object.
  /// 
  /// {@macro property_source_source}
  T getSource() => source;

  @override
  bool operator ==(Object other) {
    return (this == other || (other is PropertySource && getName().isNotEmpty && other.getName().isNotEmpty));
  }

  @override
  int get hashCode => getName().hashCode;

  /// {@macro property_source}
  static PropertySource namedStatic(String name) {
		return _ComparisonPropertySource(name);
	}
}

/// {@template stub_property_source}
/// A simple stub implementation of [PropertySource] that always returns `null` for property lookups.
///
/// This class is typically used for placeholder or dummy property sources
/// where no actual values are expected.
///
/// It is also extended by internal comparison or marker sources that should
/// not resolve real properties.
/// {@endtemplate}
class _StubPropertySource extends PropertySource<Object> {
  /// {@macro stub_property_source}
  _StubPropertySource(super.name) : super.named();

  @override
  Object? getProperty(String name) {
    return null;
  }
}

/// {@template comparison_property_source}
/// A special-purpose [PropertySource] used only for equality comparison within collections.
///
/// All methods in this class throw [UnsupportedOperationException] to
/// ensure it is never used in actual property resolution.
///
/// Intended usage is only in APIs or structures where comparison by name is required.
///
/// Example:
/// ```dart
/// var stub = _ComparisonPropertySource('test');
/// var isSame = propertySources.contains(stub); // safe for comparison
/// stub.getSource(); // throws UnsupportedOperationException
/// ```
/// {@endtemplate}
class _ComparisonPropertySource extends _StubPropertySource {
  /// Error message thrown for all unsupported method calls.
  static final String USAGE_ERROR = "ComparisonPropertySource instances are for use with collection comparison only";

  /// {@macro comparison_property_source}
  _ComparisonPropertySource(super.name);

  @override
  Object getSource() {
    throw UnsupportedOperationException(USAGE_ERROR);
  }

  @override
  bool containsProperty(String name) {
    throw UnsupportedOperationException(USAGE_ERROR);
  }

  @override
  String getProperty(String name) {
    throw UnsupportedOperationException(USAGE_ERROR);
  }
}