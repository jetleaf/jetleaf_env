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

import '../core/command_line_args.dart';
import 'property_source.dart';

/// {@template simple_command_line_property_source}
/// A [CommandLinePropertySource] that adapts [CommandLineArgs] into a resolvable
/// [PropertySource].
///
/// This class wraps a parsed list of command-line arguments and exposes them as
/// key-value properties, allowing flexible configuration using flags like:
///
/// - `--key=value`
/// - `--key value`
/// - multiple `--key=value` for lists
///
/// ### Behavior
/// - If a key is not present, the property will be `null`.
/// - If present without value (`--debug`), returns an empty list.
/// - If present with one value, returns that value as a string.
/// - If present multiple times, returns all values as a comma-separated string.
///
/// ### Example usage:
/// ```dart
/// final args = ['--env=prod', '--debug', '--features=a', '--features=b'];
/// final propertySource = SimpleCommandLinePropertySource(args);
///
/// print(propertySource.getProperty('env'));       // "prod"
/// print(propertySource.getProperty('debug'));     // ""
/// print(propertySource.getProperty('features'));  // "a,b"
/// print(propertySource.containsProperty('debug')); // true
/// ```
///
/// This class is often registered within the [MutablePropertySources] collection
/// and resolved through a [PropertyResolver] during app bootstrap.
/// {@endtemplate}
class SimpleCommandLinePropertySource extends CommandLinePropertySource<CommandLineArgs> {
  /// {@macro simple_command_line_property_source}
  SimpleCommandLinePropertySource(List<String> args) : super(SimpleCommandLineArgsParser().parse(args));

  /// {@template simple_command_line_property_source_named}
  /// Creates a [SimpleCommandLinePropertySource] with a custom name.
  ///
  /// Useful when managing multiple argument sources, e.g., merging CLI args
  /// with environment or test inputs under separate namespaces.
  ///
  /// Example:
  /// ```dart
  /// final source = SimpleCommandLinePropertySource.named('cli', ['--port=8080']);
  /// print(source.name); // 'cli'
  /// ```
  /// {@endtemplate}
  SimpleCommandLinePropertySource.named(String name, List<String> args) : super.named(name, SimpleCommandLineArgsParser().parse(args));

  @override
  bool containsProperty(String name) => source.containsOption(name);

  @override
  List<String> getPropertyNames() => source.getOptionNames().toList();

  @override
  bool containsOption(String name) => source.containsOption(name);

  @override
  List<String>? getOptionValues(String name) => source.getOptionValues(name);

  @override
  List<String> getNonOptionArgs() => source.getNonOptionArgs();
}

/// {@template map_property_source}
/// A [PropertySource] implementation backed by a [Map] of key-value pairs.
///
/// This class allows accessing properties from an in-memory map, making it
/// suitable for programmatically defined configurations such as application
/// defaults, test configurations, or runtime-supplied settings.
///
/// It supports property lookup via [containsProperty] and [getProperty].
///
/// ### Example usage:
///
/// ```dart
/// final config = {
///   'app.name': 'JetLeaf',
///   'app.port': 8080,
/// };
///
/// final propertySource = MapPropertySource('defaultConfig', config);
///
/// print(propertySource.containsProperty('app.name')); // true
/// print(propertySource.getProperty('app.port')); // 8080
/// ```
///
/// This can be added to a [MutablePropertySources] collection for use with
/// a [PropertySourcesPropertyResolver].
/// {@endtemplate}
class MapPropertySource extends PropertySource<Map<String, Object>> {
  /// {@macro map_property_source}
  MapPropertySource(super.name, super.source);

  @override
  bool containsProperty(String name) => source.containsKey(name);

  @override
  Object? getProperty(String name) => source[name];
}

/// {@template composite_property_source}
/// A composite implementation of [ListablePropertySource] that aggregates multiple [PropertySource] instances.
///
/// This class allows you to group multiple property sources under a single logical name.
/// When resolving properties, the sources are checked in the order they were added.
///
/// Example:
/// ```dart
/// var composite = CompositePropertySource('applicationConfig');
/// composite.addPropertySource(MapPropertySource('map1', {'foo': 'bar'}));
/// composite.addPropertySource(SystemEnvironmentPropertySource('env'));
/// var value = composite.getProperty('foo'); // searches map1 first, then env
/// ```
/// {@endtemplate}
class CompositePropertySource extends ListablePropertySource<Object> {
  final Set<PropertySource<dynamic>> _propertySources = {};

  /// {@macro composite_property_source}
  CompositePropertySource(super.name) : super.named();

  @override
  Object? getProperty(String name) {
    for (PropertySource propertySource in _propertySources) {
      Object? candidate = propertySource.getProperty(name);
      if (candidate != null) {
        return candidate;
      }
    }
    return null;
  }

  @override
  bool containsProperty(String name) {
    for (PropertySource propertySource in _propertySources) {
      if (propertySource.containsProperty(name)) {
        return true;
      }
    }
    return false;
  }

  @override
  List<String> getPropertyNames() {
    List<List<String>> namesList = ArrayList.withCapacity(_propertySources.length);
    for (PropertySource propertySource in _propertySources) {
      if (propertySource is! ListablePropertySource) {
        throw IllegalStateException("Failed to enumerate property names due to non-enumerable property source: $propertySource");
      }

      List<String> names = propertySource.getPropertyNames();
      namesList.add(names);
    }

    Set<String> allNames = HashSet();
    for (var names in namesList) {
      allNames.addAll(names);
    }

    return allNames.toList();
  }

  /// Adds the given [propertySource] to the end of the composite chain.
  ///
  /// This means it will be consulted *after* all previously added sources.
  void addPropertySource(PropertySource propertySource) {
    _propertySources.add(propertySource);
  }

  /// Adds the given [propertySource] to the *start* of the composite chain.
  ///
  /// This means it will be consulted *before* all previously added sources.
  ///
  /// Useful when overriding existing property values with higher precedence.
  void addFirstPropertySource(PropertySource propertySource) {
    List<PropertySource> existing = ArrayList.from(_propertySources);
    _propertySources.clear();
    _propertySources.add(propertySource);
    _propertySources.addAll(existing);
  }

  /// Returns all [PropertySource] instances currently contained in this composite.
  ///
  /// This is a snapshot of the current state and modifying it will not affect the internal structure.
  List<PropertySource> getPropertySources() => _propertySources.toList();

  @override
  String toString() => "CompositePropertySource {name='$name', propertySources=${_propertySources.toList()}";
}

/// {@template mutable_property_sources}
/// A mutable container for managing an ordered list of [PropertySource] objects.
///
/// This class allows adding, removing, and retrieving property sources dynamically
/// by name or position. It maintains the search order for property resolution,
/// where the first source added has the highest precedence during lookups.
///
/// This container is typically passed to a [PropertySourcesPropertyResolver]
/// to resolve environment or configuration properties.
///
/// ### Example usage:
/// ```dart
/// final sources = MutablePropertySources();
///
/// final defaults = MapPropertySource('defaults', {'debug': 'false'});
/// final env = MapPropertySource('env', {'debug': 'true'});
///
/// sources.addLast(defaults);
/// sources.addFirst(env); // env now has higher precedence
///
/// final value = sources.get('env')?.getProperty('debug'); // 'true'
///
/// sources.remove('defaults');
/// ```
///
/// ### Ordering Methods
/// You can control precedence using:
/// - [addFirst]
/// - [addLast]
/// - [addBefore]
/// - [addAfter]
///
/// This is particularly useful for layered configuration such as:
/// command-line args > environment variables > default config.
/// {@endtemplate}
class MutablePropertySources extends PropertySources {
  final List<PropertySource> _sources = [];

  /// {@macro mutable_property_sources}
  MutablePropertySources();

  /// Creates a new instance from an existing [PropertySources] collection.
  ///
  /// All sources are added with the same ordering.
  MutablePropertySources.from(PropertySources propertySources) {
    for (PropertySource source in propertySources) {
      addLast(source);
    }
  }

  /// Adds a [PropertySource] to the beginning of the list.
  ///
  /// Gives it the highest precedence during resolution.
  ///
  /// Example:
  /// ```dart
  /// sources.addFirst(MapPropertySource('system', {...}));
  /// ```
  void addFirst(PropertySource source) {
    synchronized(_sources, () {
      _removeIfPresent(source);
      _sources.insert(0, source);
    });
  }

  /// Adds a [PropertySource] to the end of the list.
  ///
  /// Gives it the lowest precedence.
  ///
  /// Example:
  /// ```dart
  /// sources.addLast(MapPropertySource('defaults', {...}));
  /// ```
  void addLast(PropertySource source) {
    synchronized(_sources, () {
      _removeIfPresent(source);
      _sources.add(source);
    });
  }

  /// Inserts [newSource] before the named [relativeSourceName] in the list.
  ///
  /// Throws if the referenced source is not found or if the names are equal.
  ///
  /// Example:
  /// ```dart
  /// sources.addBefore('env', MapPropertySource('fallback', {...}));
  /// ```
  void addBefore(String relativeSourceName, PropertySource newSource) {
    _assertLegalRelativeAddition(relativeSourceName, newSource);
    synchronized(_sources, () {
      _removeIfPresent(newSource);
      int index = _assertPresentAndGetIndex(relativeSourceName);
      _addAtIndex(index, newSource);
    });
  }

  /// Inserts [newSource] after the named [relativeSourceName] in the list.
  ///
  /// Throws if the referenced source is not found or if the names are equal.
  ///
  /// Example:
  /// ```dart
  /// sources.addAfter('commandLine', MapPropertySource('logConfig', {...}));
  /// ```
  void addAfter(String relativeSourceName, PropertySource newSource) {
    _assertLegalRelativeAddition(relativeSourceName, newSource);
    synchronized(_sources, () {
      _removeIfPresent(newSource);
      int index = _assertPresentAndGetIndex(relativeSourceName);
      _addAtIndex(index + 1, newSource);
    });
  }

  /// Returns the index position of the given [propertySource] in the list,
  /// or `-1` if it is not present.
  int precedenceOf(PropertySource propertySource) => _sources.indexOf(propertySource);

  /// Removes the [PropertySource] with the given [name], if present.
  ///
  /// Returns the removed source or `null` if not found.
  ///
  /// Example:
  /// ```dart
  /// final removed = sources.remove('env');
  /// ```
  PropertySource? remove(String name) {
    return synchronized(_sources, () {
      int index = _sources.indexOf(PropertySource.namedStatic(name));
      return (index != -1 ? _sources.removeAt(index) : null);
    });
  }

  /// Replaces the [PropertySource] with the given [name] with a new one.
  ///
  /// Throws if the named source is not present.
  ///
  /// Example:
  /// ```dart
  /// sources.replace('env', MapPropertySource('env', {'mode': 'prod'}));
  /// ```
  void replace(String name, PropertySource propertySource) {
    synchronized(_sources, () {
      int index = _assertPresentAndGetIndex(name);
      _sources[index] = propertySource;
    });
  }

  @override
  bool contains(Object? element) {
    for (final propertySource in _sources) {
      if (propertySource == element) {
        return true;
      }
    }
    return false;
  }

  /// Returns `true` if this property sources contains a source with the given [name].
  ///
  /// Example:
  /// ```dart
  /// final hasEnv = sources.containsName('env');
  /// ```
  bool containsName(String name) {
    for (final propertySource in _sources) {
      if (propertySource.name == name) {
        return true;
      }
    }
    return false;
  }

  /// Returns the length of the items in this source
  int get length => _sources.length;

  @override
  PropertySource? get(String name) => _sources.find((s) => s.name.equals(name));

  /// Adds all given [sources] to the list in their original order.
  ///
  /// Does not remove duplicates.
  ///
  /// Example:
  /// ```dart
  /// sources.addAll([source1, source2]);
  /// ```
  void addAll(List<PropertySource> sources) {
    _sources.addAll(sources);
  }

  @override
  Iterator<PropertySource> get iterator => _sources.iterator;

  @override
  GenericStream<PropertySource<dynamic>> stream() => StreamSupport.stream(_sources);

  void _assertLegalRelativeAddition(String relativePropertySourceName, PropertySource propertySource) {
    String newPropertySourceName = propertySource.name;
    if (relativePropertySourceName.equals(newPropertySourceName)) {
      throw IllegalArgumentException("PropertySource named '$newPropertySourceName' cannot be added relative to itself");
    }
  }

  void _removeIfPresent(PropertySource propertySource) {
    _sources.remove(propertySource);
  }

  void _addAtIndex(int index, PropertySource propertySource) {
    _removeIfPresent(propertySource);
    _sources.insert(index, propertySource);
  }

  int _assertPresentAndGetIndex(String name) {
    // First try to find the source by name
    int index = _sources.indexOf(PropertySource.namedStatic(name));
    if (index == -1) {
      // If not found, try to find the source by name
      index = _sources.indexWhere((s) => s.name.equals(name));
      if (index == -1) {
        throw IllegalArgumentException("PropertySource named '$name' does not exist");
      }
    }
    return index;
  }
}

/// {@template properties_property_source}
/// A specialized [MapPropertySource] that represents traditional Java-style
/// `.properties`-like configuration, Dart-style `.dart`-like configuration,
/// Environment `.env`-like configuration, and YAML-style `.yaml`-like
/// configuration as a Dart [Map].
///
/// It provides semantic clarity when you're loading configurations from a
/// `.properties` file or equivalent structured source, and is typically used
/// in environments where key-value pairs are treated as flat string mappings.
///
/// This class does not add new behavior to [MapPropertySource], but helps
/// clearly differentiate the source of configuration in a [MutablePropertySources] stack.
///
/// ### Example usage:
///
/// ```dart
/// final props = {
///   'server.port': '8080',
///   'logging.level': 'INFO',
/// };
///
/// final propertySource = PropertiesPropertySource('application.properties', props);
///
/// print(propertySource.getProperty('server.port')); // 8080
/// ```
///
/// This can be combined with other sources for layered configuration.
/// {@endtemplate}
class PropertiesPropertySource extends MapPropertySource {
  /// {@macro properties_property_source}
  PropertiesPropertySource(super.name, super.properties);
}

/// {@template system_environment_property_source}
/// A [MapPropertySource] that exposes system environment variables as a property source.
///
/// This class wraps a [Map<String, String>] of environment variables, typically obtained
/// from `Platform.environment`, and exposes it through the property resolution system.
///
/// This allows the environment to be queried like any other configuration source,
/// with consistent property access patterns.
///
/// ### Example usage:
///
/// ```dart
/// import 'dart:io';
///
/// final envSource = SystemEnvironmentPropertySource('systemEnv', Platform.environment);
///
/// print(envSource.getProperty('HOME')); // e.g. /Users/yourname
/// print(envSource.containsProperty('PATH')); // true
/// ```
///
/// Can be added to a [MutablePropertySources] stack for prioritized resolution.
///
/// ```dart
/// final sources = MutablePropertySources();
/// sources.addLast(envSource);
/// ```
/// {@endtemplate}
class SystemEnvironmentPropertySource extends MapPropertySource {
  /// {@macro system_environment_property_source}
  SystemEnvironmentPropertySource(String name, Map<String, String> systemEnv) : super(name, Map.from(systemEnv));
}