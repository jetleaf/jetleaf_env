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
import 'dart:io' show File, Directory;

import 'package:jetleaf_logging/logging.dart';

import 'common_parsers/environment_parser_factory.dart';
import 'common_parsers/yaml_parser.dart';
import '../property_source/map_property_source.dart';
import '../standard_environment.dart';
import 'resource_loader.dart';

/// {@template yaml_property_source_loader}
/// Loads `.yaml` configuration files and parses them into [MapPropertySource]s.
///
/// This loader scans the given base directory for `.yaml` files and uses a
/// [YamlParser] to convert them into structured key-value pairs.
///
/// YAML is a human-friendly data serialization format often used for
/// configuration. Nested structures are expected to be flattened into dot-separated keys.
///
/// ### Example
/// ```dart
/// final loader = YamlResourceLoader('/config');
/// final sources = loader.loadResources();
/// ```
///
/// ### Supported Format:
/// ```yaml
/// server:
///   port: 8080
/// database:
///   url: jdbc:postgresql://localhost:5432/test
/// ```
///
/// Would be parsed as:
/// ```
/// {
///   "server.port": 8080,
///   "database.url": "jdbc:postgresql://localhost:5432/test"
/// }
/// ```
///
/// See also:
/// - [EnvironmentParserFactory]
/// - [YamlParser]
/// {@endtemplate}
class YamlResourceLoader extends ResourceLoader {
  /// The supported file extension for this loader.
  final String fileExtension = ".yaml";

  /// Logging prefix for this loader instance.
  final String LOG_PREFIX = 'YamlResourceLoader';

  /// The parser responsible for parsing `.yaml` files into maps.
  final EnvironmentParserFactory _parser = YamlParser();

  /// {@macro property_source_loader}
  YamlResourceLoader(super.baseDirectory, super.baseName, super.loggerFactory);

  @override
  FutureOr<List<MapPropertySource>> loadResources() {
    List<MapPropertySource> result = [];
    _load().forEach((profile, env) => result.add(MapPropertySource(profile, env)));

    return result;
  }

  Map<String, Map<String, Object>> _load() {
    final files = _findYamlFiles();

    if (files.isEmpty) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not find any yaml files in $baseDirectory');
      return {};
    }

    final result = <String, Map<String, Object>>{};

    for (final file in files) {
      final profile = _profileFromFilename(file.uri.pathSegments.last);
      final content = _loadContent(file);
      result[profile] = content;
    }

    return result;
  }

  List<File> _findYamlFiles() {
    final dir = Directory(baseDirectory);
    if (!dir.existsSync()) return [];

    return dir.listSync().whereType<File>()
      .where((f) => f.path.endsWith('$baseName.yaml') || f.path.endsWith('$baseName.yml'))
      .toList();
  }

  Map<String, Object> _loadContent(File file) {
    final result = <String, Object>{};
    
    try {
      final parsedData = _parser.parseSingle(file.readAsStringSync());
      
      // Flatten everything into dot notation AND preserve top-level keys
      _flattenMap(parsedData, result);
      
    } catch (e, stackTrace) {
      loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX found error while loading $file: $e\n$stackTrace');
    }

    return result;
  }

  /// Recursively flatten a nested map into dot notation
  void _flattenMap(Map<String, Object> source, Map<String, Object> target, [String prefix = '']) {
    source.forEach((key, value) {
      final currentKey = prefix.isEmpty ? key : '$prefix.$key';
      
      if (value is Map<String, Object>) {
        // For nested maps, recursively flatten
        _flattenMap(value, target, currentKey);
      } else if (value is List) {
        // For lists, add indexed access
        target[currentKey] = value;
        for (int i = 0; i < value.length; i++) {
          target['$currentKey.$i'] = value[i];
        }
      } else {
        // For primitive values, add directly
        target[currentKey] = value;
      }
    });
  }

  String _profileFromFilename(String filename) {
    if (filename.startsWith('application_')) {
      return filename.substring('application_'.length); // extract profile part
    }
    
    final parts = filename.split('.');
    if (parts.length > 2) {
      return parts.sublist(1, parts.length - 1).join('_');
    }
    return StandardEnvironment.RESERVED_DEFAULT_PROFILE_NAME;
  }
}