import 'configuration_property_name.dart';
import 'configuration_property_source.dart';

/// {@template prefixed_configuration_property_source}
/// A [ConfigurationPropertySource] that exposes a delegate source with a fixed prefix.
///
/// This class allows isolating configuration properties under a specific namespace.
/// When a property is requested (e.g., `server.port`), the prefix is prepended
/// before lookup in the delegate source (e.g., `myapp.server.port`).
///
/// It is useful for grouping configuration under logical boundaries or
/// reusing shared property sources with contextual segmentation.
///
/// ### Example:
/// ```dart
/// final base = MapConfigurationPropertySource({
///   'jetleaf.server.port': 8080,
/// });
/// final prefixed = PrefixedConfigurationPropertySource(base, 'jetleaf');
/// final value = prefixed.getProperty(ConfigurationPropertyName('server.port')); // 8080
/// ```
/// {@endtemplate}
class PrefixedConfigurationPropertySource extends ConfigurationPropertySource {
  /// The wrapped delegate configuration source.
  final ConfigurationPropertySource _delegate;

  /// The prefix to apply to property lookups.
  final ConfigurationPropertyName _prefix;

  /// {@macro prefixed_configuration_property_source}
  PrefixedConfigurationPropertySource(this._delegate, String prefix)
      : _prefix = ConfigurationPropertyName(prefix);

  @override
  Object? getProperty(ConfigurationPropertyName name) {
    final prefixedName = ConfigurationPropertyName.fromElements(
      [..._prefix.elements, ...name.elements],
    );
    return _delegate.getProperty(prefixedName);
  }

  @override
  Iterable<ConfigurationPropertyName> get names => _delegate.names
      .where((name) => name.startsWith(_prefix))
      .map((name) => name.subName(_prefix.elements.length));
}