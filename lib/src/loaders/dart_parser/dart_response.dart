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

/// {@template dart_response}
/// DartResponse holds the result of a Dart file execution.
/// 
/// Contains:
/// - [success]: Whether the execution was successful
/// - [error]: Error message if execution failed
/// - [configurations]: List of extracted configuration data
/// 
/// ## Example
/// ```dart
/// final response = DartResponse(
///   success: true,
///   error: '',
///   configurations: [
///     ConfigurationResponse(
///       profile: 'development',
///       properties: {
///         'server.port': 8080,
///         'database.url': 'localhost:5432',
///       },
///     ),
///   ],
/// );
/// ```
/// {@endtemplate}
class DartResponse {
  /// Whether the execution was successful
  final bool success;
  
  /// Error message if execution failed
  final String error;
  
  /// List of extracted configuration data
  final List<ConfigurationResponse> configurations;

  /// {@macro dart_response}
  const DartResponse({
    this.success = false,
    this.error = '',
    this.configurations = const [],
  });

  /// Creates a DartResponse from a map (typically from JSON)
  /// 
  /// ## Example
  /// ```dart
  /// final map = {
  ///   'success': true,
  ///   'error': '',
  ///   'configurations': [
  ///     {
  ///       'profile': 'dev',
  ///       'properties': {'port': 8080}
  ///     }
  ///   ]
  /// };
  /// 
  /// final response = DartResponse.fromMap(map);
  /// ```
  factory DartResponse.fromMap(Map<String, dynamic> map) {
    return DartResponse(
      success: _parseBool(map['success']),
      error: map['error']?.toString() ?? '',
      configurations: _parseConfigurations(map['configurations']),
    );
  }

  /// Converts the response to a map
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'error': error,
      'configurations': configurations.map((config) => config.toMap()).toList(),
    };
  }
  
  /// Helper method to parse boolean values from various types
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }
  
  /// Helper method to parse configurations list
  static List<ConfigurationResponse> _parseConfigurations(dynamic value) {
    if (value is! List) return const [];
    
    return value
        .map((config) => ConfigurationResponse.fromMap(config as Map<String, dynamic>))
        .toList();
  }
  
  @override
  String toString() {
    return 'DartResponse(success: $success, error: $error, configurations: ${configurations.length})';
  }
}

/// {@template configuration_response}
/// ConfigurationResponse holds the extracted configuration information
/// from a dynamically loaded Dart file.
/// 
/// Contains:
/// - [profile]: The configuration profile name
/// - [properties]: Map of configuration key-value pairs
/// 
/// ## Example
/// ```dart
/// final configData = ConfigurationResponse(
///   profile: 'development',
///   properties: {
///     'server.port': 8080,
///     'database.url': 'localhost:5432',
///   },
/// );
/// ```
/// {@endtemplate}
class ConfigurationResponse {
  /// The configuration profile name
  final String profile;
  
  /// Map of configuration key-value pairs
  final Map<String, Object> properties;
  
  /// {@macro configuration_response}
  const ConfigurationResponse({
    required this.profile,
    required this.properties,
  });
  
  /// Creates a ConfigurationResponse from a map
  /// 
  /// ## Example
  /// ```dart
  /// final map = {
  ///   'profile': 'production',
  ///   'properties': {
  ///     'server.port': 80,
  ///     'database.url': 'prod-db:5432'
  ///   }
  /// };
  /// 
  /// final config = ConfigurationResponse.fromMap(map);
  /// ```
  factory ConfigurationResponse.fromMap(Map<String, dynamic> map) {
    return ConfigurationResponse(
      profile: map['profile'] as String,
      properties: Map<String, Object>.from(map['properties'] as Map),
    );
  }
  
  /// Converts the configuration to a map
  Map<String, Object> toMap() {
    return {
      'profile': profile,
      'properties': properties,
    };
  }
  
  @override
  String toString() {
    return 'ConfigurationResponse(profile: $profile, properties: $properties)';
  }
}
