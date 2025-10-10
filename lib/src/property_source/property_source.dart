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
import 'package:jetleaf_utils/utils.dart';
import 'package:meta/meta.dart';

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
abstract class PropertySource<T> with EqualsAndHashCode {
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
  List<Object?> equalizedProperties() => [name, source];

  @override
  String toString() => "$runtimeType(name: $name, source: $source)";

  /// {@macro property_source}
  static PropertySource namedStatic(String name) => _ComparisonPropertySource(name);
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
  Object? getProperty(String name) => null;
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

// =========================================== PROPERTY SOURCES =========================================

/// {@template property_sources}
/// A collection of [PropertySource]s that provides lookup and stream support.
///
/// This abstract class is used in the JetLeaf environment system to hold
/// multiple `PropertySource` instances, such as system environment variables,
/// command-line arguments, or custom maps.
///
/// You can use this class to:
/// - Stream through all available property sources
/// - Check whether a named property source exists
/// - Retrieve a property source by name
///
/// Example usage:
/// ```dart
/// final sources = MyPropertySources(); // your custom implementation
/// if (sources.contains('systemEnv')) {
///   final envSource = sources.get('systemEnv');
///   print(envSource?.getProperty('HOME'));
/// }
/// ```
///
/// Subclasses must implement the [contains] and [get] methods to define how
/// sources are stored and accessed.
///
/// {@endtemplate}
abstract class PropertySources extends Iterable<PropertySource> {
  /// {@macro property_sources}
  const PropertySources();

  /// {@template property_sources_stream}
  /// Returns a [GenericStream] over all [PropertySource]s in this collection.
  ///
  /// This method allows functional-style operations over the property sources.
  /// It uses [StreamSupport.stream] internally to create the stream from
  /// the iterable.
  ///
  /// Example:
  /// ```dart
  /// sources.stream()
  ///   .filter((s) => s.name.startsWith('system'))
  ///   .forEach((s) => print(s.name));
  /// ```
  /// {@endtemplate}
  GenericStream<PropertySource> stream() {
    return StreamSupport.stream(this);
  }

  @override
  bool contains(Object? element);

  /// {@template property_sources_get}
  /// Returns the [PropertySource] with the given name, or `null` if not found.
  ///
  /// This method performs a lookup for a source by its name (as returned by
  /// `PropertySource.getName()`).
  ///
  /// Example:
  /// ```dart
  /// final source = sources.get('applicationConfig');
  /// if (source != null) {
  ///   print(source.getProperty('app.name'));
  /// }
  /// ```
  ///
  /// - [name]: the name of the property source to find
  /// - Returns: the [PropertySource] if present, otherwise `null`
  /// {@endtemplate}
  PropertySource? get(String name);
}

// ======================================== LISTABLE PROPERTY SOURCES ========================================

/// {@template enumerable_property_source}
/// A specialized [PropertySource] capable of enumerating all available property keys,
/// allowing efficient lookup operations.
///
/// Unlike generic property sources, this class supports retrieval of all known
/// property names through [getPropertyNames]. This makes methods like
/// [containsProperty] fast and lightweight, as they can check membership without
/// calling [getProperty].
///
/// Framework-level sources like environment variables, maps, or configuration files
/// often extend this class to benefit from key enumeration.
///
/// Example:
/// ```dart
/// class MapPropertySource extends ListablePropertySource<Map<String, Object>> {
///   MapPropertySource(super.name, super.source);
///
///   @override
///   List<String> getPropertyNames() => source.keys.toList();
///
///   @override
///   Object? getProperty(String name) => source[name];
/// }
/// ```
///
/// {@endtemplate}
@Generic(ListablePropertySource)
abstract class ListablePropertySource<T> extends PropertySource<T> {
  /// {@macro enumerable_property_source}
  ListablePropertySource(super.name, super.source);

  /// {@macro enumerable_property_source}
  ListablePropertySource.named(super.name) : super.named();

  @override
  bool containsProperty(String name) => getPropertyNames().contains(name);

  /// {@template enumerable_property_source_get_property_names}
  /// Returns the full list of property names known to this [PropertySource].
  ///
  /// Subclasses must implement this method to return all available keys.
  ///
  /// Example:
  /// ```dart
  /// final propertyNames = mySource.getPropertyNames();
  /// print(propertyNames); // ['host', 'port', 'username']
  /// ```
  ///
  /// This is used internally by [containsProperty] and other introspection features.
  /// {@endtemplate}
  List<String> getPropertyNames();
}

// ====================================== COMMAND LINE PROPERTY SOURCES ======================================

/// {@template command_line_property_source}
/// A base class for property sources that are backed by command line arguments.
///
/// This class is capable of handling both option arguments (e.g., `--port=8080`)
/// and non-option arguments (e.g., positional values like `input.txt`).
///
/// It supports retrieving these arguments as properties through the familiar
/// [getProperty] interface and allows customization of the key used to
/// access non-option arguments.
///
/// Commonly extended by concrete sources such as argument parsers.
///
/// Example:
/// ```dart
/// class SimpleCommandLinePropertySource extends CommandLinePropertySource<MyArgsParser> {
///   SimpleCommandLinePropertySource(MyArgsParser parser) : super(parser);
///
///   @override
///   bool containsOption(String name) => source.hasOption(name);
///
///   @override
///   List<String>? getOptionValues(String name) => source.getOptionValues(name);
///
///   @override
///   List<String> getNonOptionArgs() => source.getNonOptionArgs();
/// }
///
/// final source = SimpleCommandLinePropertySource(parser);
/// print(source.getProperty('host')); // "localhost"
/// print(source.getProperty('nonOptionArgs')); // "input.txt,config.json"
/// ```
/// {@endtemplate}
@Generic(CommandLinePropertySource)
abstract class CommandLinePropertySource<T> extends ListablePropertySource<T> {
  /// {@macro command_line_property_source}
  CommandLinePropertySource(T source) : super(CommandLinePropertySource.COMMAND_LINE_PROPERTY_SOURCE_NAME, source);

  /// {@template command_line_property_source_named}
  /// Creates a [CommandLinePropertySource] with a custom name.
  ///
  /// This can be useful if you are managing multiple sources of arguments.
  ///
  /// Example:
  /// ```dart
  /// CommandLinePropertySource.named('myArgs', parser);
  /// ```
  /// {@endtemplate}
  CommandLinePropertySource.named(super.name, super.source);

  /// {@template command_line_property_source_name}
  /// The default name used to register this property source in the environment.
  ///
  /// Default value is `'commandLineArgs'`.
  /// {@endtemplate}
  static const String COMMAND_LINE_PROPERTY_SOURCE_NAME = 'commandLineArgs';

  /// {@template command_line_property_source_name}
  /// The default name used to register this property source in the environment.
  ///
  /// Default value is `'jlaCommandLineArgs'`.
  /// {@endtemplate}
  static const String JETLEAF_COMMAND_LINE_PROPERTY_SOURCE_NAME = "jlaCommandLineArgs";

  /// {@template command_line_property_source_non_option_key}
  /// The default key used to access non-option arguments from [getProperty].
  ///
  /// The value of this key is a comma-delimited string of all non-option args.
  /// Default value is `'nonOptionArgs'`.
  /// {@endtemplate}
  static const String DEFAULT_NON_OPTION_ARGS_PROPERTY_NAME = 'nonOptionArgs';

  /// {@template command_line_property_source_non_option_property}
  /// The current key used to access non-option arguments.
  ///
  /// You can customize this using [setNonOptionArgsPropertyName].
  /// {@endtemplate}
  String nonOptionArgsPropertyName = DEFAULT_NON_OPTION_ARGS_PROPERTY_NAME;

  /// {@template command_line_property_source_set_non_option_key}
  /// Allows setting a custom property name for non-option arguments.
  ///
  /// Example:
  /// ```dart
  /// source.setNonOptionArgsPropertyName('positionalArgs');
  /// ```
  /// {@endtemplate}
  void setNonOptionArgsPropertyName(String name) {
    nonOptionArgsPropertyName = name;
  }

  @override
  bool containsProperty(String name) {
    if (nonOptionArgsPropertyName == name) {
      return getNonOptionArgs().isNotEmpty;
    }
    return containsOption(name);
  }

  @override
  String? getProperty(String name) {
    if (nonOptionArgsPropertyName == name) {
      final args = getNonOptionArgs();
      return args.isEmpty
          ? null
          : StringUtils.collectionToCommaDelimitedString(args);
    }

    final optionValues = getOptionValues(name);
    return optionValues == null
        ? null
        : StringUtils.collectionToCommaDelimitedString(optionValues);
  }

  /// {@template command_line_property_source_contains_option}
  /// Returns whether the set of parsed options includes the given name.
  ///
  /// Implementations must define how option presence is detected.
  ///
  /// Example:
  /// ```dart
  /// if (containsOption('debug')) {
  ///   print('Debug mode enabled.');
  /// }
  /// ```
  /// {@endtemplate}
  @protected
  bool containsOption(String name);

  /// {@template command_line_property_source_get_option_values}
  /// Returns the values for a given option name.
  ///
  /// Behavior:
  /// - `--flag` returns `[]`
  /// - `--key=value` returns `["value"]`
  /// - multiple occurrences (`--key=1 --key=2`) return `["1", "2"]`
  /// - if the key is missing, returns `null`
  ///
  /// Example:
  /// ```dart
  /// final values = getOptionValues('files');
  /// if (values != null) {
  ///   print(values.join(', '));
  /// }
  /// ```
  /// {@endtemplate}
  @protected
  List<String>? getOptionValues(String name);

  /// {@template command_line_property_source_get_non_option_args}
  /// Returns the list of arguments that are not in `--key=value` format.
  ///
  /// These are typically positional or unnamed arguments.
  ///
  /// Example:
  /// ```dart
  /// final extras = getNonOptionArgs();
  /// print(extras); // ['input.txt', 'output.log']
  /// ```
  /// {@endtemplate}
  @protected
  List<String> getNonOptionArgs();
}