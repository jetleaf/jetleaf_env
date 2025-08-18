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
  SystemEnvironmentPropertySource(String name, Map<String, String> systemEnv)
      : super(name, Map.from(systemEnv));
}