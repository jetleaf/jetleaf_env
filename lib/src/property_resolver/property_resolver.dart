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

import 'package:jetleaf_lang/lang.dart';

/// {@template property_resolver}
/// A service abstraction for resolving application properties and configuration values.
///
/// This interface defines methods for reading, converting, and resolving
/// property values from environment variables, `.env`, YAML, or other sources.
///
/// Useful for configuration loading, dynamic placeholder resolution,
/// and runtime property injection.
///
/// ---
///
/// ### 🔧 Common Use Cases:
/// ```dart
/// final port = resolver.getPropertyAsWithDefault<int>('server.port', 8080);
/// final name = resolver.getRequiredProperty('app.name');
/// final message = resolver.resolvePlaceholders('Running #{app.name} on port #{server.port}');
/// ```
/// ## Supported Patterns
/// 
/// ### Environment Variables:
/// - `${VAR_NAME}` - Standard shell-style environment variable
/// - `#{VAR_NAME}` - Alternative environment variable syntax
/// - `$VAR_NAME` - Short environment variable syntax
/// - `#VAR_NAME` - Alternative short environment variable syntax
/// 
/// ### Property References:
/// - `@property.name@` - Property reference with @ delimiters
/// - `${property.name}` - Property reference using ${} syntax
/// - `#{property.name}` - Property reference using #{} syntax
/// 
/// ## Example Usage
/// ```dart
/// // Environment: BASE_URL=https://api.example.com, API=v1
/// // Properties: server.timeout=30, app.name=MyApp
/// 
/// final interpolator = ResourceInterpolator(resources);
/// 
/// // Various interpolation patterns:
/// interpolator.interpolate('${BASE_URL}/${API}')           // → https://api.example.com/v1
/// interpolator.interpolate('#{BASE_URL}/#{API}')           // → https://api.example.com/v1
/// interpolator.interpolate('$BASE_URL/$API')               // → https://api.example.com/v1
/// interpolator.interpolate('#BASE_URL/#API')               // → https://api.example.com/v1
/// interpolator.interpolate('$BASE_URL/check')              // → https://api.example.com/check
/// interpolator.interpolate('@app.name@ timeout: @server.timeout@s') // → MyApp timeout: 30s
/// ```
///
/// ---
///
/// {@endtemplate}
abstract class PropertyResolver {
  /// {@template contains_property}
  /// Returns whether the given property [key] is defined.
  ///
  /// This is useful when optional configuration might exist.
  ///
  /// ### Example:
  /// ```dart
  /// if (resolver.containsProperty('app.debug')) {
  ///   print('Debug mode enabled');
  /// }
  /// ```
  /// {@endtemplate}
  bool containsProperty(String key);

  /// {@template get_property_nullable}
  /// Retrieves the value for the given property [key], or `null` if not found.
  ///
  /// Equivalent to: `getProperty(key) ?? null`.
  ///
  /// ### Example:
  /// ```dart
  /// final dbUrl = resolver.getProperty('database.url');
  /// ```
  ///
  /// See also:
  /// - [getPropertyWithDefault]
  /// - [getRequiredProperty]
  /// {@endtemplate}
  String? getProperty(String key);

  /// {@template get_property_with_default}
  /// Retrieves the value for the given [key], or returns [defaultValue] if not present.
  ///
  /// ### Example:
  /// ```dart
  /// final host = resolver.getPropertyWithDefault('server.host', 'localhost');
  /// ```
  /// {@endtemplate}
  String getPropertyWithDefault(String key, String defaultValue);

  /// {@template get_property_t_nullable}
  /// Retrieves and converts the value of [key] to the desired type [T].
  ///
  /// Returns `null` if the property is not found or cannot be converted.
  /// 
  /// targetType - the expected type of the property value
  /// key - the property key
  ///
  /// ### Example:
  /// ```dart
  /// final port = resolver.getPropertyAs<int>('server.port');
  /// ```
  /// {@endtemplate}
  T? getPropertyAs<T>(String key, Class<T> targetType);

  /// {@template get_property_t_with_default}
  /// Retrieves and converts the value of [key] to [T], or returns [defaultValue] if missing or invalid.
  /// 
  /// targetType - the expected type of the property value
  /// key - the property key
  /// defaultValue - the default value to return if the property is not found or cannot be converted
  ///
  /// ### Example:
  /// ```dart
  /// final retries = resolver.getPropertyAsWithDefault<int>('http.retries', 3);
  /// ```
  /// {@endtemplate}
  T getPropertyAsWithDefault<T>(String key, Class<T> targetType, T defaultValue);

  /// {@template get_required_property}
  /// Returns the property value for [key], or throws [IllegalStateException] if the property is not defined.
  ///
  /// This is useful for required configuration values such as API keys.
  ///
  /// ### Example:
  /// ```dart
  /// final apiKey = resolver.getRequiredProperty('security.apiKey');
  /// ```
  /// {@endtemplate}
  String getRequiredProperty(String key);

  /// {@template get_required_property_t}
  /// Retrieves and converts the property [key] to type [T], or throws [IllegalStateException] if missing or invalid.
  /// 
  /// targetType - the expected type of the property value
  /// key - the property key
  ///
  /// ### Example:
  /// ```dart
  /// final timeout = resolver.getRequiredPropertyAs<int>('http.timeout');
  /// ```
  /// {@endtemplate}
  T getRequiredPropertyAs<T>(String key, Class<T> targetType);

  /// {@template resolve_placeholders}
  /// Resolves `#{...}` placeholders in the input [text] using available properties.
  ///
  /// If a placeholder has no matching property, it is left unchanged.
  ///
  /// ### Example:
  /// ```dart
  /// // If app.name=JetLeaf
  /// resolver.resolvePlaceholders('Welcome to #{app.name}');
  /// // → "Welcome to JetLeaf"
  /// ```
  /// {@endtemplate}
  String resolvePlaceholders(String text);

  /// {@template resolve_required_placeholders}
  /// Resolves `#{...}` placeholders in the input [text] using available properties.
  ///
  /// Throws [InvalidArgumentException] if any placeholder is unresolved.
  ///
  /// ### Example:
  /// ```dart
  /// // If app.path is not defined, this will throw
  /// resolver.resolveRequiredPlaceholders('Path: #{app.path}');
  /// ```
  /// {@endtemplate}
  String resolveRequiredPlaceholders(String text);
}