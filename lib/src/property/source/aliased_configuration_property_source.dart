import 'configuration_property_name.dart';
import 'configuration_property_source.dart';
import 'configuration_property_name_aliases.dart';

/// {@template aliased_configuration_property_source}
/// A [ConfigurationPropertySource] wrapper that supports alias resolution for configuration keys.
///
/// This class allows multiple aliases (alternative keys) to be resolved for a given configuration property.
/// It delegates the actual property lookup to another [ConfigurationPropertySource] but attempts to resolve
/// the given name using a set of predefined aliases.
///
/// This is particularly useful when migrating or supporting legacy property names.
/// 
/// ### Example:
/// ```dart
/// final source = MapConfigurationPropertySource({
///   'server.port': 8080,
/// });
///
/// final aliases = ConfigurationPropertyNameAliases()
///   ..addAlias(ConfigurationPropertyName('server.http.port'), ConfigurationPropertyName('server.port'));
///
/// final aliasedSource = AliasedConfigurationPropertySource(source, aliases);
///
/// final value = aliasedSource.getProperty(ConfigurationPropertyName('server.http.port'));
/// print(value); // Output: 8080
/// ```
/// {@endtemplate}
class AliasedConfigurationPropertySource extends ConfigurationPropertySource {
  final ConfigurationPropertySource _delegate;
  final ConfigurationPropertyNameAliases _aliases;

  /// {@macro aliased_configuration_property_source}
  ///
  /// - [delegate] is the underlying source where actual values are stored.
  /// - [aliases] is the alias mapping for resolving alternative property names.
  AliasedConfigurationPropertySource(this._delegate, this._aliases);

  @override
  Object? getProperty(ConfigurationPropertyName name) {
    for (final alias in _aliases.getAliases(name)) {
      final value = _delegate.getProperty(alias);
      if (value != null) {
        return value;
      }
    }
    return null;
  }

  /// TODO: This is not correct, but it's a placeholder for now.
  @override
  Iterable<ConfigurationPropertyName> get names => _delegate.names;
}