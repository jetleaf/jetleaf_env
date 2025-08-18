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

import 'property_source.dart';
import 'property_sources.dart';

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
  int precedenceOf(PropertySource propertySource) {
    return _sources.indexOf(propertySource);
  }

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
    for (PropertySource propertySource in _sources) {
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
    for (PropertySource propertySource in _sources) {
      if (propertySource.name == name) {
        return true;
      }
    }
    return false;
  }

  /// Returns the number of [PropertySource]s in the list.
  ///
  /// Example:
  /// ```dart
  /// print('Total sources: ${sources.size()}');
  /// ```
  int size() {
    return _sources.length;
  }

  @override
  PropertySource? get(String name) {
    return _sources.find((s) => s.name.equals(name));
  }

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
  GenericStream<PropertySource<dynamic>> stream() {
    return StreamSupport.stream(_sources);
  }

  void _assertLegalRelativeAddition(String relativePropertySourceName, PropertySource propertySource) {
    String newPropertySourceName = propertySource.name;
    if (relativePropertySourceName.equals(newPropertySourceName)) {
      throw Exception("PropertySource named '$newPropertySourceName' cannot be added relative to itself");
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
    int index = _sources.indexOf(PropertySource.namedStatic(name));
    if (index == -1) {
      throw Exception("PropertySource named '$name' does not exist");
    }
    return index;
  }
}