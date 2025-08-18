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
import 'dart:io';

import 'package:jetleaf_logging/logging.dart';

import 'common_parsers/environment_parser_factory.dart';
import 'common_parsers/json_parser.dart';
import '../property_source/map_property_source.dart';
import '../standard_environment.dart';
import 'resource_loader.dart';

/// {@template json_property_source_loader}
/// Loads `.json` configuration files and parses them into [MapPropertySource]s.
///
/// This loader scans the given base directory for `.json` files and uses a
/// [JsonParser] to convert them into structured key-value pairs.
///
/// JSON is a rich format that supports nested objects and arrays, but the
/// resulting map is expected to be flat or flattened to allow simple key-based
/// access by the environment.
///
/// ### Example
/// ```dart
/// final loader = JsonResourceLoader('/config');
/// final sources = loader.loadResources();
/// ```
///
/// ### Supported Format:
/// ```json
/// {
///   "server.port": 8080,
///   "database.url": "jdbc:postgresql://localhost:5432/test"
/// }
/// ```
///
/// Keys with dots (`.`) are treated as flat keys, not nested objects.
///
/// See also:
/// - [EnvironmentParserFactory]
/// - [JsonParser]
/// {@endtemplate}
class JsonResourceLoader extends ResourceLoader {
  /// The supported file extension for this loader.
  final String fileExtension = ".json";

  /// Logging prefix for this loader instance.
  final String LOG_PREFIX = 'JsonResourceLoader';

  /// The parser responsible for parsing `.json` files into maps.
  final EnvironmentParserFactory _parser = JsonParser();

  /// {@macro property_source_loader}
  JsonResourceLoader(super.baseDirectory, super.baseName, super.loggerFactory);

  @override
  FutureOr<List<MapPropertySource>> loadResources() {
    List<MapPropertySource> result = [];
    _load().forEach((profile, env) => result.add(MapPropertySource(profile, env)));

    return result;
  }

  /// Load environment variables from .json files
  /// 
  /// This method loads environment variables from .json files and returns a map of key-value pairs.
  /// 
  /// ## Example Usage
  /// ```dart
  /// final envResource = JsonResourceLoader('/config', 'application');
  /// final resources = envResource.loadResources();
  /// for (var res in resources) {
  ///   print('${res.key} => ${res.value}');
  /// }
  /// ```
  Map<String, Map<String, Object>> _load() {
    final files = _findFiles();

    if (files.isEmpty) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not find any files to process');
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

  Map<String, Object> _loadContent(File file) {
    try {
      return _parser.parseSingle(file.readAsStringSync());
    } catch (e) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not parse $file file: $e');
    }

    return {};
  }

  List<File> _findFiles() {
    final dir = Directory(baseDirectory);
    if (!dir.existsSync()) return [];

    return dir.listSync().whereType<File>().where((f) => f.path.endsWith(fileExtension)).toList();
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