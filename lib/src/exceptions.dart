import 'dart:collection';

import 'package:jetleaf_lang/lang.dart';

import 'property/source/configuration_property_name.dart';

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

/// {@template missing_env_var_exception}
/// Exception thrown when a required environment variable is not found.
///
/// This is typically used in systems where environment variables are
/// mandatory and their absence should fail-fast during startup or runtime.
///
/// You can optionally attach a [cause] for additional context.
///
/// ---
///
/// ### 📦 Example Usage:
/// ```dart
/// final env = Environment.SYSTEM;
/// try {
///   final token = env.get('API_TOKEN');
/// } on MissingRequiredEnvironmentException catch (e) {
///   print('Missing variable: ${e.message}');
/// }
/// ```
///
/// ---
///
/// Used internally by [SystemEnvironment.get] in the JetLeaf framework.
/// {@endtemplate}
class MissingRequiredEnvironmentException extends RuntimeException {
  /// {@macro missing_env_var_exception}
  ///
  /// Creates a new [MissingRequiredEnvironmentException] with the given [message]
  /// and an optional [cause].
  MissingRequiredEnvironmentException(super.message, {super.cause});
}

/// {@template missing_required_properties_exception}
/// Exception thrown when required properties are not found.
///
/// Typically used by [ConfigurablePropertyResolver] during validation.
///
/// {@macro configurable_property_resolver_set}
/// {@macro configurable_property_resolver_validate}
///
/// See also:
/// - [ConfigurablePropertyResolver.setRequiredProperties]
/// - [ConfigurablePropertyResolver.validateRequiredProperties]
/// {@endtemplate}
class MissingRequiredPropertiesException extends RuntimeException {
  final LinkedHashSet<String> _missingRequiredProperties = LinkedHashSet<String>();

  /// Creates an instance of [MissingRequiredPropertiesException].
  MissingRequiredPropertiesException() : super('');

  /// Adds a missing required property key.
  void addMissingRequiredProperty(String key) {
    _missingRequiredProperties.add(key);
  }

  /// Returns the set of properties marked as required but not present upon validation.
  Set<String> getMissingRequiredProperties() => _missingRequiredProperties;

  @override
  String get message =>
      'The following properties were declared as required but could not be resolved: '
      '${getMissingRequiredProperties()}';
}


/// {@template environment_parsing_exception}
/// An [Exception] thrown when an error occurs during environment property parsing.
///
/// This exception typically indicates that the environment configuration
/// contains invalid or malformed values that cannot be properly interpreted.
///
/// ### Example usage:
///
/// ```dart
/// if (someParsingError) {
///   throw EnvironmentParsingException('Failed to parse environment variable XYZ');
/// }
/// ```
///
/// Catch this exception to handle or report environment parsing failures specifically.
/// {@endtemplate}
class EnvironmentParsingException extends RuntimeException {
  /// {@macro environment_parsing_exception}
  EnvironmentParsingException(super.message);

  @override
  String toString() => 'EnvironmentParsingException: $message';
}

/// {@template dart_loading_exception}
/// Exception thrown when Dart file loading fails.
///
/// This exception is thrown during the loading or parsing of Dart files
/// when an error occurs, such as:
/// 
/// - Invalid Dart syntax
/// - Missing or incorrect import statements
/// - File not found or unreadable
///
/// Typically used in reflection-based systems or runtime file loading
/// processes like those in the JetLeaf framework.
///
/// ### Example
/// ```dart
/// void loadDartFile(String path) {
///   if (!File(path).existsSync()) {
///     throw DartLoadingException('File not found: $path');
///   }
///   // ...parse or load logic
/// }
/// ```
/// {@endtemplate}
class DartLoadingException extends RuntimeException {
  /// {@macro dart_loading_exception}
  DartLoadingException(super.message);
}

/// Base exception for binding failures.
class BindException extends RuntimeException {
  final ConfigurationPropertyName? name;
  final Object? value;
  final Type? targetType;

  BindException(super.message, {this.name, this.value, this.targetType, super.cause});

  @override
  String toString() {
    String details = message;
    if (name != null) details += ' (property: $name)';
    if (value != null) details += ' (value: $value)';
    if (targetType != null) details += ' (target type: $targetType)';
    if (cause != null) details += ' (cause: $cause)';
    return 'BindException: $details';
  }
}

/// {@template configuration_properties_bind_exception}
/// Exception thrown when configuration properties cannot be bound to the target object.
///
/// This is a generic binding exception used when JetLeaf fails to map values
/// from the environment or configuration sources to the expected type or structure.
///
/// ### Example
/// ```dart
/// throw ConfigurationPropertiesBindException(
///   'Failed to bind configuration properties',
///   name: ConfigurationPropertyName.of('app.datasource'),
///   targetType: DataSource,
/// );
/// ```
/// {@endtemplate}
class ConfigurationPropertiesBindException extends BindException {
  /// {@macro configuration_properties_bind_exception}
  ConfigurationPropertiesBindException(
    super.message, {
    super.name,
    super.value,
    super.targetType,
    Exception? super.cause,
  });
}

/// {@template invalid_configuration_property_name_exception}
/// Exception thrown when an invalid configuration property name is encountered.
///
/// This may occur if the name contains illegal characters or formatting,
/// or does not conform to expected naming conventions.
///
/// ### Example
/// ```dart
/// throw InvalidConfigurationPropertyNameException(
///   'Invalid property name: app..name',
///   ConfigurationPropertyName.of('app..name'),
/// );
/// ```
/// {@endtemplate}
class InvalidConfigurationPropertyNameException extends BindException {
  /// {@macro invalid_configuration_property_name_exception}
  InvalidConfigurationPropertyNameException(super.message, ConfigurationPropertyName name) : super(name: name);
}

/// {@template invalid_configuration_property_value_exception}
/// Exception thrown when a configuration property has an invalid or incompatible value.
///
/// This typically occurs when the value cannot be converted or is not allowed
/// based on validation rules for the target type.
///
/// ### Example
/// ```dart
/// throw InvalidConfigurationPropertyValueException(
///   'Value "abc" is not valid for port',
///   ConfigurationPropertyName.of('server.port'),
///   'abc',
/// );
/// ```
/// {@endtemplate}
class InvalidConfigurationPropertyValueException extends BindException {
  /// {@macro invalid_configuration_property_value_exception}
  InvalidConfigurationPropertyValueException(super.message, ConfigurationPropertyName name, Object? value) : super(name: name, value: value);
}

/// {@template mutually_exclusive_configuration_properties_exception}
/// Exception thrown when mutually exclusive configuration properties are defined.
///
/// Used when two or more properties that cannot coexist are present in the
/// configuration (e.g., `url` and `host/port` being set together).
///
/// ### Example
/// ```dart
/// throw MutuallyExclusiveConfigurationPropertiesException(
///   'Cannot use both server.url and server.port',
/// );
/// ```
/// {@endtemplate}
class MutuallyExclusiveConfigurationPropertiesException extends BindException {
  /// {@macro mutually_exclusive_configuration_properties_exception}
  MutuallyExclusiveConfigurationPropertiesException(super.message);
}

/// {@template unbound_configuration_properties_exception}
/// Exception thrown when some configuration properties remain unbound after binding.
///
/// This means some properties were defined but not mapped to any bean or
/// configuration structure in the system.
///
/// ### Example
/// ```dart
/// throw UnboundConfigurationPropertiesException(
///   'Unmapped configuration values',
///   { ConfigurationPropertyName.of('unmapped.key') },
/// );
/// ```
/// {@endtemplate}
class UnboundConfigurationPropertiesException extends BindException {
  /// The set of configuration property names that were not bound.
  final Set<ConfigurationPropertyName> unboundNames;

  /// {@macro unbound_configuration_properties_exception}
  UnboundConfigurationPropertiesException(super.message, this.unboundNames);

  @override
  String toString() =>
      'UnboundConfigurationPropertiesException: $message. '
      'Unbound: ${unboundNames.map((n) => n.originalName).join(', ')}';
}