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

import 'property_source.dart';

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