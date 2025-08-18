import 'configuration_property_name.dart';

/// {@template configuration_property}
/// Represents a resolved configuration property in JetLeaf.
///
/// A configuration property holds:
/// - A canonical name ([name]) like `server.port`
/// - A resolved value ([value]) from a configuration source
/// - An optional origin ([origin]) for diagnostics, such as
///   `env:SERVER_PORT` or `application.properties:12`
///
/// This class is immutable and useful for tracing where values came from.
///
/// ### Example:
/// ```dart
/// final prop = ConfigurationProperty(
///   ConfigurationPropertyName('server.port'),
///   8080,
///   origin: 'env:SERVER_PORT',
/// );
/// print(prop.name);   // server.port
/// print(prop.value);  // 8080
/// print(prop.origin); // env:SERVER_PORT
/// ```
/// {@endtemplate}
class ConfigurationProperty {
  /// The canonical name of the configuration property (e.g., `server.port`).
  final ConfigurationPropertyName name;

  /// The resolved value of the configuration property, or a default.
  final Object? value;

  /// Optional origin metadata (e.g., `env:SERVER_PORT`) for diagnostics.
  final String? origin;

  /// {@macro configuration_property}
  const ConfigurationProperty(this.name, this.value, {this.origin});

  @override
  String toString() => 'ConfigurationProperty(name: $name, value: $value, origin: $origin)';
}