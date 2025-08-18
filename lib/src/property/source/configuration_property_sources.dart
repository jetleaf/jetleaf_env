import '../../configurable_environment.dart';
import 'configuration_property_name.dart';
import 'configuration_property_source.dart';

/// Manages a collection of [ConfigurationPropertySource]s.
class ConfigurationPropertySources {
  final List<ConfigurationPropertySource> _sources;

  ConfigurationPropertySources(Iterable<ConfigurationPropertySource> sources)
      : _sources = List.unmodifiable(sources);

  /// Attempts to get a property value from the first source that contains it.
  Object? getProperty(ConfigurationPropertyName name) {
    for (final source in _sources) {
      final value = source.getProperty(name);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  static void attach(ConfigurableEnvironment environment) {
    ///
  }

  /// Returns an iterable of all property names across all sources.
  Iterable<ConfigurationPropertyName> get names => _sources.expand((source) => source.names).toSet();
}