import 'configuration_property_name.dart';
import 'configuration_property_source.dart';

/// {@template map_configuration_property_source}
/// A [ConfigurationPropertySource] backed by a simple [Map].
///
/// This class allows you to expose a `Map<String, Object?>` as a
/// configuration property source. Keys in the map are interpreted
/// directly as property names.
///
/// It is ideal for in-memory configurations, test overrides, or
/// programmatically defined settings.
///
/// ### Example:
/// ```dart
/// final map = {
///   'server.port': 8080,
///   'spring.profiles.active': 'dev',
/// };
/// final source = MapConfigurationPropertySource(map);
/// final port = source.getProperty(ConfigurationPropertyName('server.port'));
/// ```
/// {@endtemplate}
class MapConfigurationPropertySource extends ConfigurationPropertySource {
  /// The backing property map.
  final Map<String, Object?> _properties;

  /// {@macro map_configuration_property_source}
  MapConfigurationPropertySource(this._properties);

  /// Returns the value associated with the given [ConfigurationPropertyName],
  /// using the original name as the lookup key.
  @override
  Object? getProperty(ConfigurationPropertyName name) {
    return _properties[name.originalName];
  }

  /// Returns all known configuration property names in this source.
  @override
  Iterable<ConfigurationPropertyName> get names => _properties.keys.map((key) => ConfigurationPropertyName(key));
}