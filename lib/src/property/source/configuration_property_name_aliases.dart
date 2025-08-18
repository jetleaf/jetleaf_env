import 'configuration_property_name.dart';

/// {@template configuration_property_name_aliases}
/// Manages aliases for configuration property names.
///
/// This class allows one configuration property name to be referenced by multiple alternative names (aliases),
/// which can be useful when dealing with legacy configuration formats or different naming conventions.
///
/// Aliases are uni-directional and must be registered explicitly using [addAlias].
///
/// ### Example:
/// ```dart
/// final aliases = ConfigurationPropertyNameAliases();
/// aliases.addAlias('server.port', 'server.http.port');
///
/// final all = aliases.getAliases(ConfigurationPropertyName('server.port'));
/// print(all); // Output: [server.port, server.http.port]
/// ```
///
/// When used in conjunction with [AliasedConfigurationPropertySource], this enables
/// fallback resolution of properties through multiple names.
/// {@endtemplate}
class ConfigurationPropertyNameAliases {
  final Map<ConfigurationPropertyName, List<ConfigurationPropertyName>> _aliases = {};

  /// Registers an alias [alias] for the given configuration property [name].
  ///
  /// Aliases must be explicitly defined for each direction you want to support.
  /// For example, to make `foo.bar` and `bar.foo` interchangeable, you must call:
  /// ```dart
  /// aliases.addAlias('foo.bar', 'bar.foo');
  /// aliases.addAlias('bar.foo', 'foo.bar');
  /// ```
  void addAlias(String name, String alias) {
    final original = ConfigurationPropertyName(name);
    final aliasName = ConfigurationPropertyName(alias);
    _aliases.putIfAbsent(original, () => []).add(aliasName);
  }

  /// Returns all aliases for a given [name], including the name itself.
  ///
  /// If no aliases exist, this returns a list containing only the input name.
  Iterable<ConfigurationPropertyName> getAliases(ConfigurationPropertyName name) {
    return [name, ...?_aliases[name]];
  }
}