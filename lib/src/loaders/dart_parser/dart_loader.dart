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
import 'dart:isolate';
import 'dart:convert';

import 'package:jetleaf_logging/logging.dart';

import '../../exceptions.dart';
import 'dart_compiler.dart';
import 'dart_response.dart';

/// {@template dart_loader}
/// DartLoader handles the dynamic loading and execution of compiled Dart files.
/// 
/// This class manages:
/// - Isolate creation and communication
/// - Error handling during execution
/// - Resource cleanup
/// 
/// ## Example Usage
/// ```dart
/// final loader = DartLoader();
/// final configurations = await loader.loadConfigurations(File('config.dart'));
/// 
/// for (final config in configurations) {
///   print('Profile: ${config.profile}');
///   print('Properties: ${config.properties}');
/// }
/// ```
/// {@endtemplate}
class DartLoader {
  static const String LOG_PREFIX = 'DartLoader';

  /// {@macro logger_factory}
  final LogFactory loggerFactory;

  /// {@macro dart_compiler}
  final DartCompiler _compiler;

  /// {@macro dart_loader}
  DartLoader(this.loggerFactory) : _compiler = DartCompiler(loggerFactory);
  
  /// Loads configuration data from a Dart file
  /// 
  /// This method:
  /// 1. Validates the file syntax
  /// 2. Compiles it for execution
  /// 3. Runs it in an isolate
  /// 4. Extracts configuration properties
  /// 
  /// Returns a list of [ConfigurationResponse] objects containing
  /// the profile name and properties map.
  /// 
  /// ## Example
  /// ```dart
  /// final loader = DartLoader();
  /// final file = File('resources/staging_config.dart');
  /// 
  /// try {
  ///   final configs = await loader.loadConfigurations(file);
  ///   
  ///   for (final config in configs) {
  ///     print('Loaded profile: ${config.profile}');
  ///     config.properties.forEach((key, value) {
  ///       print('  $key: $value');
  ///     });
  ///   }
  /// } catch (e) {
  ///   print('Failed to load configurations: $e');
  /// }
  /// ```
  Future<List<ConfigurationResponse>> loadConfigurations(File file) async {
    // Validate file first
    if (!await _compiler.validateFile(file)) {
      throw DartLoadingException('File validation failed: ${file.path}');
    }
    
    // Prepare for loading
    final executablePath = await _compiler.prepareForLoading(file);
    
    try {
      return await _executeInIsolate(executablePath);
    } finally {
      // Cleanup temporary files
      final tempFile = File(executablePath);
      if (tempFile.existsSync()) {
        tempFile.parent.deleteSync(recursive: true);
      }
    }
  }
  
  /// Executes the prepared Dart file in an isolate and extracts results
  Future<List<ConfigurationResponse>> _executeInIsolate(String executablePath) async {
    final receivePort = ReceivePort();
    
    try {
      await Isolate.spawnUri(
        Uri.file(executablePath),
        [],
        receivePort.sendPort,
      );
      
      final response = await receivePort.first;
      final data = DartResponse.fromMap(jsonDecode(response as String));
      
      if (data.success != true) {
        throw DartLoadingException('Execution failed: ${data.error}');
      }
      
      return data.configurations;
          
    } catch (e) {
      loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX found error while executing $executablePath: $e');
      throw DartLoadingException('Execution failed: $e');
    } finally {
      receivePort.close();
    }
  }
}