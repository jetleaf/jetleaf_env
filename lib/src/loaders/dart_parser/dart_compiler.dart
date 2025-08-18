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
import '../../standard_environment.dart';

/// {@template dart_compiler}
/// DartCompiler handles the compilation and validation of Dart source files.
/// 
/// This class provides methods to:
/// - Validate Dart syntax
/// - Check for required imports and class structure
/// - Prepare files for dynamic loading
/// 
/// ## Example Usage
/// ```dart
/// final compiler = DartCompiler();
/// final isValid = await compiler.validateFile(File('config.dart'));
/// if (isValid) {
///   final compiledPath = await compiler.prepareForLoading(File('config.dart'));
/// }
/// ```
/// {@endtemplate}
class DartCompiler {
  static const String LOG_PREFIX = 'DartCompiler';

  /// {@macro logger_factory}
  final LogFactory loggerFactory;

  /// {@macro dart_compiler}
  DartCompiler(this.loggerFactory);
  
  /// Validates if a Dart file has correct syntax and required structure
  /// 
  /// Returns `true` if the file:
  /// - Has valid Dart syntax
  /// - Contains at least one class extending ConfigurationProperty
  /// - Has proper imports
  /// 
  /// ## Example
  /// ```dart
  /// final compiler = DartCompiler();
  /// final file = File('resources/dev_config.dart');
  /// 
  /// if (await compiler.validateFile(file)) {
  ///   print('File is valid for loading');
  /// } else {
  ///   print('File has syntax errors or missing requirements');
  /// }
  /// ```
  Future<bool> validateFile(File file) async {
    try {
      final content = await file.readAsString();
      
      // Check for required imports
      if (!content.contains('ConfigurationProperty')) {
        loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX is missing ConfigurationProperty reference in ${file.path}');
        return false;
      }
      
      // Basic syntax validation using dart analyze
      final result = await Process.run('dart', ['analyze', file.path]);
      
      if (result.exitCode != 0) {
        loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX found syntax errors in ${file.path}: ${result.stderr}');
        return false;
      }
      
      return true;
    } catch (e) {
      loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX found error while validating ${file.path}: $e');
      return false;
    }
  }
  
  /// Prepares a Dart file for dynamic loading by creating a wrapper
  /// 
  /// Creates a temporary executable Dart file that can be run in an isolate
  /// to extract configuration properties.
  /// 
  /// ## Example
  /// ```dart
  /// final compiler = DartCompiler();
  /// final originalFile = File('resources/prod_config.dart');
  /// final executablePath = await compiler.prepareForLoading(originalFile);
  /// 
  /// // Now executablePath can be used with dart:isolate
  /// ```
  Future<String> prepareForLoading(File file) async {
    final content = await file.readAsString();
    final fileName = file.path.split('/').last.replaceAll('.dart', '');
    final tempDir = Directory.systemTemp.createTempSync('jetleaf_config_');
    final wrapperFile = File('${tempDir.path}/${fileName}_wrapper.dart');
    
    final wrapperContent = _createWrapper(content, fileName);
    await wrapperFile.writeAsString(wrapperContent);
    
    return wrapperFile.path;
  }
  
  /// Creates a wrapper that can be executed to extract configuration data
  String _createWrapper(String originalContent, String fileName) {
    bool hasConfigurationProperty = _validateConfigurationStructure(originalContent);

    if(hasConfigurationProperty) {
      final classNames = _extractConfigurationClasses(originalContent);
      
      if (classNames.isEmpty) {
        throw DartLoadingException('No classes extending ConfigurationProperty found in $fileName');
      }
      
      final instantiationCode = _generateInstantiationCode(classNames, fileName);

      return '''
import 'dart:isolate';
import 'dart:convert';

// Original content
$originalContent

void main(List<String> args, SendPort sendPort) {
  try {
    final configurations = <Map<String, dynamic>>[];
    
    $instantiationCode
    
    sendPort.send(jsonEncode({
      'success': true,
      'configurations': configurations,
    }));
  } catch (e) {
    sendPort.send(jsonEncode({
      'success': false,
      'error': e.toString(),
    }));
  }
}
''';
    } else {
      throw DartLoadingException('No classes extending ConfigurationProperty found in $fileName');
    }
  }

  /// Validates that the file contains proper ConfigurationProperty usage
  /// 
  /// Checks for:
  /// - At least one class extending ConfigurationProperty
  /// - Proper imports
  /// - Valid Dart syntax
  /// - Required method implementations
  bool _validateConfigurationStructure(String content) {
    // Check for ConfigurationProperty reference
    if (!content.contains('ConfigurationProperty')) {
      loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX is missing ConfigurationProperty reference');
      return false;
    }
    
    // Check for at least one class extending ConfigurationProperty
    final classes = _extractConfigurationClasses(content);
    if (classes.isEmpty) {
      loggerFactory.add(LogLevel.ERROR, '$LOG_PREFIX found no classes extending ConfigurationProperty');
      return false;
    }
    
    // Check that each class likely has the required methods
    for (final className in classes) {
      final classPattern = RegExp(
        r'class\s+' + className + r'\s+extends\s+ConfigurationProperty\s*\{(.*?)\}',
        multiLine: true,
        dotAll: true,
      );
      
      final classMatch = classPattern.firstMatch(content);
      if (classMatch != null) {
        final classBody = classMatch.group(1) ?? '';
        
        // Check for properties() method
        if (!classBody.contains('properties()')) {
          loggerFactory.add(LogLevel.WARN, '$LOG_PREFIX found that class $className may be missing properties() method');
        }
        
        // Check for profile getter (optional but recommended)
        if (!classBody.contains('profile')) {
          loggerFactory.add(LogLevel.INFO, '$LOG_PREFIX found that class $className may be missing profile getter');
        }
      }
    }
    
    return true;
  }

  /// Extracts class names that extend ConfigurationProperty from Dart content
  /// 
  /// This method parses the Dart source code to identify classes that extend
  /// ConfigurationProperty. It handles various syntax patterns including:
  /// - Direct extension: `class MyConfig extends ConfigurationProperty`
  /// - With mixins: `class MyConfig extends ConfigurationProperty with SomeMixin`
  /// - With implementations: `class MyConfig extends ConfigurationProperty implements SomeInterface`
  /// 
  /// ## Example
  /// ```dart
  /// final content = '''
  /// class DevConfig extends ConfigurationProperty {
  ///   // implementation
  /// }
  /// 
  /// class ProdConfig extends ConfigurationProperty with LoggingMixin {
  ///   // implementation
  /// }
  /// ''';
  /// 
  /// final classes = _extractConfigurationClasses(content);
  /// // Returns: ['DevConfig', 'ProdConfig']
  /// ```
  List<String> _extractConfigurationClasses(String content) {
    final classNames = <String>[];
    
    // Regular expression to match class declarations that extend ConfigurationProperty
    final classRegex = RegExp(
      r'class\s+(\w+)\s+extends\s+ConfigurationProperty(?:\s+(?:with|implements)\s+[\w\s,]+)?\s*\{',
      multiLine: true,
    );
    
    final matches = classRegex.allMatches(content);
    
    for (final match in matches) {
      final className = match.group(1);
      if (className != null) {
        classNames.add(className);
        loggerFactory.add(LogLevel.DEBUG, '$LOG_PREFIX found configuration class: $className');
      }
    }
    
    // Additional validation to ensure ConfigurationProperty is imported or available
    if (classNames.isNotEmpty && !content.contains('ConfigurationProperty')) {
      throw DartLoadingException('ConfigurationProperty is referenced but not imported');
    }
    
    return classNames;
  }

  /// Generates instantiation code for the found configuration classes
  /// 
  /// Creates Dart code that:
  /// 1. Instantiates each configuration class
  /// 2. Calls the properties() method to get configuration data
  /// 3. Gets the profile name
  /// 4. Validates that the class properly extends ConfigurationProperty
  /// 5. Adds the configuration to the results list
  /// 
  /// ## Example Generated Code
  /// ```dart
  /// // For class DevConfig extends ConfigurationProperty
  /// try {
  ///   final devConfigInstance = DevConfig();
  ///   if (devConfigInstance is! ConfigurationProperty) {
  ///     throw DartLoadingException('DevConfig does not properly extend ConfigurationProperty');
  ///   }
  ///   
  ///   final devConfigProperties = devConfigInstance.properties();
  ///   final devConfigProfile = devConfigInstance.profile;
  ///   
  ///   configurations.add({
  ///     'profile': devConfigProfile,
  ///     'properties': devConfigProperties.build(),
  ///     'className': 'DevConfig',
  ///   });
  /// } catch (e) {
  ///   throw DartLoadingException('Error instantiating DevConfig: \$e');
  /// }
  /// ```
  String _generateInstantiationCode(List<String> classNames, String fileName) {
    final buffer = StringBuffer();

    
    for (final className in classNames) {
      buffer.writeln('''
      // Instantiate and extract configuration from $className
      try {
        final ${_camelCase(className)}Instance = $className();
        
        // Validate that the class properly extends ConfigurationProperty
        if (${_camelCase(className)}Instance is! ConfigurationProperty) {
          throw DartLoadingException('$className does not properly extend ConfigurationProperty');
        }
        
        // Extract properties and profile
        final ${_camelCase(className)}Properties = ${_camelCase(className)}Instance.properties();
        
        // Validate that properties() returns a valid ConfigurationProperties object
        if (${_camelCase(className)}Properties == null) {
          throw DartLoadingException('$className.properties() returned null');
        }
        
        // Add to configurations list
        configurations.add({
          'profile': '${_extractProfileFromFilename(fileName)}',
          'properties': ${_camelCase(className)}Properties.build(),
          'className': '$className',
        });
        
      } catch (e) {
        throw DartLoadingException('Error processing $className: \$e');
      }
      ''');
    }
    
    return buffer.toString();
  }

  /// Extracts the profile name from an application Dart file name.
  ///
  /// Examples:
  /// - "application.dart" → "default"
  /// - "application_dev.dart" → "dev"
  /// - "application_prod_local.dart" → "prod_local"
  String _extractProfileFromFilename(String filename) {
    // Remove the `.dart` extension
    if (filename.endsWith('.dart')) {
      filename = filename.substring(0, filename.length - 5); // remove ".dart"
    }

    // Check for exact default name
    if (filename == 'application') return StandardEnvironment.RESERVED_DEFAULT_PROFILE_NAME;

    // Handle prefixed profile
    if (filename.startsWith('application_')) {
      return filename.substring('application_'.length); // extract profile part
    }

    // Fallback
    return StandardEnvironment.RESERVED_DEFAULT_PROFILE_NAME;
  }

  /// Converts a class name to camelCase for variable naming
  /// 
  /// ## Example
  /// ```dart
  /// _camelCase('DevConfig') // returns 'devConfig'
  /// _camelCase('DatabaseConnectionConfig') // returns 'databaseConnectionConfig'
  /// ```
  String _camelCase(String className) {
    if (className.isEmpty) return className;
    return className[0].toLowerCase() + className.substring(1);
  }
}