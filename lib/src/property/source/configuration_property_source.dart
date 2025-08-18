import 'aliased_configuration_property_source.dart';
import 'configuration_property_name_aliases.dart';
import 'configuration_property_name.dart';
import 'prefixed_configuration_property_source.dart';

/// {@template configuration_property_source}
/// Abstract base class for a source of configuration properties in JetLeaf.
///
/// Implementations of this class provide access to key-value property pairs
/// where keys are represented as [ConfigurationPropertyName] objects. Sources
/// may be backed by maps, environment variables, or other hierarchical stores.
///
/// Subclasses must implement [getProperty] and [names]. Consumers can enhance
/// a source using [withPrefix] or [withAliases] to apply filtering or remapping
/// behavior.
///
/// ### Example:
/// ```dart
/// final source = MapConfigurationPropertySource({'server.port': 8080});
/// final name = ConfigurationPropertyName('server.port');
/// final value = source.getProperty(name); // 8080
/// ```
/// {@endtemplate}
abstract class ConfigurationPropertySource {
  /// {@macro configuration_property_source}
  const ConfigurationPropertySource();

  /// Attempts to resolve the value for the given [name].
  ///
  /// Returns the associated value if present, or `null` if not found.
  Object? getProperty(ConfigurationPropertyName name);

  /// Returns all property names known to this source.
  ///
  /// Used for enumeration, filtering, or alias matching.
  Iterable<ConfigurationPropertyName> get names;

  /// Returns a new [ConfigurationPropertySource] that applies the given [prefix]
  /// to all lookups.
  ///
  /// For example, a prefix of `myapp` will redirect lookups for `server.port` to
  /// `myapp.server.port`.
  ///
  /// Delegates to [PrefixedConfigurationPropertySource].
  ConfigurationPropertySource withPrefix(String prefix) {
    return PrefixedConfigurationPropertySource(this, prefix);
  }

  /// Returns a new [ConfigurationPropertySource] that supports aliases for property names.
  ///
  /// If an alias is defined for a requested name, the aliased name(s) will also be tried.
  ///
  /// Delegates to [AliasedConfigurationPropertySource].
  ConfigurationPropertySource withAliases(ConfigurationPropertyNameAliases aliases) {
    return AliasedConfigurationPropertySource(this, aliases);
  }
}