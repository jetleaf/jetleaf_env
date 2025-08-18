import 'configuration_property_name.dart';
import 'configuration_property_source.dart';
import '../properties/property_mapper.dart';
import '../properties/system_environment_property_mapper.dart';

/// {@template environment_property_source}
/// A [ConfigurationPropertySource] that reads configuration values
/// from a [Map] of environment variables, such as `Platform.environment`.
///
/// This class supports flexible name mapping using a [PropertyMapper],
/// which transforms property names like `server.port` into potential
/// environment variable keys like `SERVER_PORT`.
///
/// ### Example:
/// ```dart
/// final env = Platform.environment;
/// final source = EnvironmentPropertySource(env);
/// final value = source.getProperty(ConfigurationPropertyName('server.port'));
/// ```
///
/// The default mapper is [SystemEnvironmentPropertyMapper], which
/// handles common transformations such as replacing dots with underscores,
/// converting to uppercase, and stripping invalid characters.
/// {@endtemplate}
class EnvironmentPropertySource extends ConfigurationPropertySource {
  /// The backing environment map (typically from `Platform.environment`).
  final Map<String, String> _environment;

  /// The property name mapper used to convert config names to env keys.
  final PropertyMapper _propertyMapper;

  /// {@macro environment_property_source}
  EnvironmentPropertySource(this._environment, {PropertyMapper? propertyMapper})
      : _propertyMapper = propertyMapper ?? SystemEnvironmentPropertyMapper();

  @override
  Object? getProperty(ConfigurationPropertyName name) {
    final mappedName = _propertyMapper.mapFrom(name);
    for (final candidate in mappedName) {
      if (_environment.containsKey(candidate)) {
        return _environment[candidate];
      }
    }
    return null;
  }

  /// Returns a rough list of all configuration property names
  /// based on the environment keys. This is a best-effort mapping.
  ///
  /// Note: The reverse mapping from env keys to canonical names
  /// is non-trivial and may not be accurate.
  ///
  /// TODO::: This is not correct, but it's a placeholder for now.
  @override
  Iterable<ConfigurationPropertyName> get names => _environment.keys.map((key) => ConfigurationPropertyName(key));
}