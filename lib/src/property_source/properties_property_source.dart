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

import 'map_property_source.dart';

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