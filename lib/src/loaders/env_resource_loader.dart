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
import 'common_parsers/env_parser.dart';
import '../property_source/map_property_source.dart';
import '../standard_environment.dart';
import 'resource_loader.dart';

/// {@template env_property_source_loader}
/// Loads `.env` configuration files and parses them into [MapPropertySource]s.
///
/// This loader searches the configured base directory for `.env` files,
/// parses them using the [EnvParser], and converts their contents into
/// key-value pairs accessible via the environment.
///
/// Each `.env` file typically represents a different profile or environment,
/// such as `application.env`, `application-dev.env`, etc.
///
/// ### Example
/// ```dart
/// final loader = EnvResourceLoader('/config');
/// final sources = loader.loadResources();
/// ```
///
/// ### Supported Format:
/// ```env
/// KEY1=value1
/// KEY2=value2
/// ```
///
/// Lines starting with `#` or `!` are treated as comments.
///
/// The `.env` format is commonly used for local development or Docker environments.
///
/// See also:
/// - [EnvironmentParserFactory]
/// - [EnvParser]
/// {@endtemplate}
class EnvResourceLoader extends ResourceLoader {
  /// The supported file extension for this loader.
  final String fileExtension = ".env";

  /// Logging prefix for this loader instance.
  final String LOG_PREFIX = 'EnvResourceLoader';

  /// The parser responsible for parsing `.env` files into maps.
  final EnvironmentParserFactory _parser = EnvParser();

  /// {@macro property_source_loader}
  EnvResourceLoader(super.baseDirectory, super.baseName, super.loggerFactory);

  @override
  FutureOr<List<MapPropertySource>> loadResources() {
    List<MapPropertySource> result = [];
    _load().forEach((profile, env) => result.add(MapPropertySource(profile, env)));

    return result;
  }

  /// Load environment variables from .env files
  /// 
  /// This method loads environment variables from .env files and returns a map of key-value pairs.
  /// 
  /// ## Example Usage
  /// ```dart
  /// final envResource = EnvResourceLoader('/config', '', loggerFactory);
  /// final resources = envResource.loadResources();
  /// for (var res in resources) {
  ///   print('${res.key} => ${res.value}');
  /// }
  /// ```
  Map<String, Map<String, Object>> _load() {
    Map<String, Map<String, Object>> result = {};
    final directory = Directory(baseDirectory);

    if (!directory.existsSync()) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not find ${directory.path} directory');
      return result;
    }

    final envFiles = directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith(fileExtension))
      .toList();

    // Sort to ensure .env is loaded first (lowest priority)
    envFiles.sort((a, b) {
      if (a.path.endsWith(fileExtension)) return -1;
      if (b.path.endsWith(fileExtension)) return 1;
      return a.path.compareTo(b.path);
    });

    for (final file in envFiles) {
      final filename = file.uri.pathSegments.last;
      final profile = _extractProfileFromFilename(filename);
      result.putIfAbsent(profile, () => _loadEnvContent(file.path));
    }

    loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX found ${result.length} env files to process');

    return result;
  }

  /// Extracts the profile name from an env file name.
  ///
  /// Examples:
  /// - ".env" → "default"
  /// - ".env.dev" → "dev"
  /// - ".env.prod.local" → "prod_local"
  String _extractProfileFromFilename(String filename) {
    if (filename == fileExtension) return StandardEnvironment.RESERVED_DEFAULT_PROFILE_NAME;

    // Remove the '.env.' prefix and join remaining parts with underscore
    final parts = filename.split('.');

    if (parts.length > 2 && parts[0] == '' && parts[1] == 'env') {
      return parts.sublist(2).join('_'); // handles .env.dev.local → dev_local
    }

    return StandardEnvironment.RESERVED_DEFAULT_PROFILE_NAME; // fallback if format doesn't match
  }

  /// Load environment variables from a .env file
  /// 
  /// This method loads environment variables from a .env file and returns a map of key-value pairs.
  /// 
  /// ## Example Usage
  /// ```dart
  /// final envResource = EnvResource();
  /// final resources = envResource.loadResources();
  /// for (var res in resources) {
  ///   print('${res.key} => ${res.value}');
  /// }
  /// ```
  Map<String, Object> _loadEnvContent(String filePath) {
    final file = File.fromUri(Uri.parse(filePath));
    
    if (!file.existsSync()) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not find $filePath file');
      return {};
    }

    try {
      final lines = file.readAsLinesSync();
      return _parser.parse(lines);
    } catch (e) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not parse $filePath file: $e');
    }

    return {};
  }
}