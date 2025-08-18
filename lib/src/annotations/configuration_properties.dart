import 'package:jetleaf_lang/lang.dart';
import 'package:meta/meta_meta.dart';

/// {@template configuration_properties}
/// Marks a class as a configuration properties holder.
///
/// The framework will attempt to bind values from configuration sources
/// to fields in this class based on the specified [prefix].
///
/// Advanced binding flags:
/// - [ignoreErrors] – ignore errors during binding.
/// - [ignoreTopLevelConverterNotFound] – ignore if no converter is found for the top-level type.
/// - [noUnboundElements] – fail if unknown properties are found.
///
/// ### Example:
/// ```dart
/// @ConfigurationProperties(prefix: 'server')
/// class ServerProperties {
///   final int port;
///
///   ServerProperties(this.port);
/// }
/// ```
/// {@endtemplate}
@Target({TargetKind.classType})
class ConfigurationProperties extends ReflectableAnnotation {
  /// The prefix for configuration properties.
  /// 
  /// ### Example:
  /// ```dart
  /// @ConfigurationProperties(prefix: 'server')
  /// class ServerProperties {
  ///   final int port;
  ///
  ///   ServerProperties(this.port);
  /// }
  /// ```
  final String prefix;
  
  /// Whether to ignore errors during binding.
  /// 
  /// ### Example:
  /// ```dart
  /// @ConfigurationProperties(prefix: 'server', ignoreErrors: true)
  /// class ServerProperties {
  ///   final int port;
  ///
  ///   ServerProperties(this.port);
  /// }
  /// ```
  final bool ignoreErrors;
  
  /// Whether to ignore if no converter is found for the top-level type.
  /// 
  /// ### Example:
  /// ```dart
  /// @ConfigurationProperties(prefix: 'server', ignoreTopLevelConverterNotFound: true)
  /// class ServerProperties {
  ///   final int port;
  ///
  ///   ServerProperties(this.port);
  /// }
  /// ```
  final bool ignoreTopLevelConverterNotFound;
  
  /// Whether to make sure that no unknown properties are bound.
  /// 
  /// ### Example:
  /// ```dart
  /// @ConfigurationProperties(prefix: 'server', noUnboundElements: true)
  /// class ServerProperties {
  ///   final int port;
  ///
  ///   ServerProperties(this.port);
  /// }
  /// ```
  final bool noUnboundElements;

  /// {@macro configuration_properties}
  const ConfigurationProperties({
    required this.prefix,
    this.ignoreErrors = false,
    this.ignoreTopLevelConverterNotFound = false,
    this.noUnboundElements = false,
  });

  @override
  String toString() => 'ConfigurationProperties(prefix: $prefix, ignoreErrors: $ignoreErrors, ignoreTopLevelConverterNotFound: $ignoreTopLevelConverterNotFound, noUnboundElements: $noUnboundElements)';

  @override
  Type get annotationType => ConfigurationProperties;
}

/// {@template configuration_name}
/// Specifies the configuration property name for a field or constructor parameter.
///
/// Use this when the Dart field or parameter name differs from the name in
/// the configuration file.
///
/// ### Example:
/// ```dart
/// class Example {
///   @Name('custom.enabled')
///   final bool isEnabled;
/// }
/// ```
/// {@endtemplate}
@Target({TargetKind.field, TargetKind.constructor, TargetKind.parameter})
class Name extends ReflectableAnnotation {
  /// The configuration property name.
  /// 
  /// ### Example:
  /// ```dart
  /// class Example {
  ///   @Name('custom.enabled')
  ///   final bool isEnabled;
  /// }
  /// ```
  final String value;

  /// {@macro configuration_name}
  const Name(this.value);

  @override
  Type get annotationType => Name;
}

/// {@template default_value}
/// Provides a fallback value for a configuration property if it is not present
/// in any configuration source.
///
/// ### Example:
/// ```dart
/// class Example {
///   @DefaultValue(true)
///   final bool enabled;
/// }
/// ```
/// {@endtemplate}
@Target({TargetKind.field, TargetKind.constructor, TargetKind.parameter})
class DefaultValue extends ReflectableAnnotation {
  /// The default value.
  /// 
  /// ### Example:
  /// ```dart
  /// class Example {
  ///   @DefaultValue(true)
  ///   final bool enabled;
  /// }
  /// ```
  final Object value;

  /// {@macro default_value}
  const DefaultValue(this.value);

  @override
  Type get annotationType => DefaultValue;
}

/// {@template nested}
/// Indicates that a field represents a nested configuration object.
///
/// Useful when binding a complex object hierarchy:
/// ```dart
/// class ServerProperties {
///   @Nested()
///   final Ssl ssl;
/// }
/// ```
/// {@endtemplate}
@Target({TargetKind.field, TargetKind.constructor, TargetKind.parameter})
class Nested extends ReflectableAnnotation {
  /// {@macro nested}
  const Nested();

  @override
  Type get annotationType => Nested;
}

/// {@template constructor_binding}
/// Marks a constructor to be used for binding this configuration class.
///
/// By default, the default constructor (or first public one) is used.
/// Use this when explicit binding via a constructor is required.
///
/// ### Example:
/// ```dart
/// class Credentials {
///   final String username;
///   final String password;
///
///   @ConstructorBinding()
///   Credentials(this.username, this.password);
/// }
/// ```
/// {@endtemplate}
@Target({TargetKind.constructor})
class ConstructorBinding extends ReflectableAnnotation {
  /// {@macro constructor_binding}
  const ConstructorBinding();

  @override
  Type get annotationType => ConstructorBinding;
}