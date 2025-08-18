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

import 'dart:async';

import 'package:jetleaf_logging/logging.dart';

import '../property_source/map_property_source.dart';

/// {@template property_source_loader}
/// Strategy interface for loading `PropertySource` instances from external configuration resources.
///
/// Implementations of this interface handle locating and parsing files from a base directory,
/// producing a list of [MapPropertySource]s that can be registered in the environment.
///
/// The [baseDirectory] defines the root path where the configuration files should be read from.
///
/// Example:
/// ```dart
/// final loader = JsonFileResourceLoader('/config', 'application', loggerFactory);
/// final sources = loader.loadResources();
/// for (var source in sources) {
///   environment.propertySources.addLast(source);
/// }
/// ```
///
/// This abstraction allows loading properties from formats like `.json`, `.yaml`, `.properties`, etc.
/// {@endtemplate}
abstract class ResourceLoader {
  /// The root directory where configuration files are located.
  final String baseDirectory;

  /// The base name of the YAML file to load (e.g., `pubspec`, `application`)
  final String baseName;

  /// {@macro logger_factory}
  final LogFactory loggerFactory;

  /// {@macro property_source_loader}
  ResourceLoader(this.baseDirectory, this.baseName, this.loggerFactory);

  /// Loads a list of [MapPropertySource]s from the base directory.
  ///
  /// Each implementation should locate one or more files and return a list of parsed sources,
  /// each containing key-value pairs for property resolution.
  ///
  /// Throws [EnvironmentParsingException] if parsing fails.
  FutureOr<List<MapPropertySource>> loadResources();
}