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

// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:jetleaf_logging/logging.dart';

import '../../exceptions.dart';
import 'dart_loader.dart';
import 'dart_response.dart';

/// {@template configuration_extractor}
/// ConfigurationExtractor provides high-level methods for extracting
/// configuration data from Dart files.
/// 
/// This class abstracts the complexity of:
/// - File discovery and filtering
/// - Batch processing of multiple files
/// - Error handling and logging
/// - Result aggregation
/// 
/// ## Example Usage
/// ```dart
/// final extractor = ConfigurationExtractor();
/// 
/// // Extract from single file
/// final singleConfig = await extractor.extractFromFile(
///   File('resources/prod_config.dart')
/// );
/// 
/// // Extract from directory
/// final allConfigs = await extractor.extractFromDirectory(
///   Directory('resources')
/// );
/// 
/// // Extract with filtering
/// final devConfigs = await extractor.extractFromDirectory(
///   Directory('resources'),
///   filter: (file) => file.path.contains('dev'),
/// );
/// ```
/// {@endtemplate}
class ConfigurationExtractor {
  static const String LOG_PREFIX = 'ConfigurationExtractor';

  /// {@macro logger_factory}
  final LogFactory loggerFactory;

  /// {@macro dart_loader}
  final DartLoader _loader;
  
  /// {@macro configuration_extractor}
  ConfigurationExtractor(this.loggerFactory) : _loader = DartLoader(loggerFactory);
  
  /// Extracts configuration data from all Dart files in a directory
  /// 
  /// ## Example
  /// ```dart
  /// final extractor = ConfigurationExtractor();
  /// final configs = await extractor.extractFromDirectory(Directory('resources'));
  /// ```
  Future<List<ConfigurationResponse>> extractFromDirectory(Directory directory) async {
    if (!directory.existsSync()) {
      loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX could not find ${directory.path} directory');
      return [];
    }
    
    loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX is scanning ${directory.path} directory');
    
    final dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart') && file.path.split('/').last.startsWith('application'))
        .toList();
    
    loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX found ${dartFiles.length} dart files to process');
    
    final allConfigurations = <ConfigurationResponse>[];
    
    for (final file in dartFiles) {
      try {
        final configurations = await extractFromFile(file);
        allConfigurations.addAll(configurations);
      } catch (e) {
        loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX failed to process ${file.path}: $e');
        throw DartLoadingException('Failed to process ${file.path}: $e');
      }
    }
    
    loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX extracted ${allConfigurations.length} total configurations');
    return allConfigurations;
  }

  /// Extracts configuration data from a single Dart file
  /// 
  /// ## Example
  /// ```dart
  /// final extractor = ConfigurationExtractor();
  /// final configs = await extractor.extractFromFile(File('resources/prod_config.dart'));
  /// ```
  Future<List<ConfigurationResponse>> extractFromFile(File file) async {
    loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX is extracting configurations from ${file.path}');
    
    final configurations = await _loader.loadConfigurations(file);
    loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX found ${configurations.length} configurations in ${file.path}');
    return configurations;
  }
  
  /// Extracts configurations and groups them by profile
  /// 
  /// ## Example
  /// ```dart
  /// final extractor = ConfigurationExtractor();
  /// final configs = await extractor.extractGroupedByProfile(Directory('resources'));
  /// ```
  Future<Map<String, List<ConfigurationResponse>>> extractGroupedByProfile(Directory directory) async {
    final configurations = await extractFromDirectory(directory);
    
    final grouped = <String, List<ConfigurationResponse>>{};
    
    for (final config in configurations) {
      grouped.putIfAbsent(config.profile, () => []).add(config);
    }
    
    return grouped;
  }
}