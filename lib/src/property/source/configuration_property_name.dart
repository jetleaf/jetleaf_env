/// {@template configuration_property_name}
/// Represents the name of a configuration property in dot-separated form.
///
/// This class encapsulates structured property names (e.g. `server.port`)
/// into discrete segments, allowing hierarchical resolution and name composition.
///
/// Useful in property resolution systems like JetLeaf's environment engine,
/// where configuration values are nested and mapped through `MapPropertySource`
/// or similar abstractions.
///
/// ### Example:
/// ```dart
/// final name = ConfigurationPropertyName('jetleaf.datasource.url');
/// print(name.elements); // ['jetleaf', 'datasource', 'url']
/// print(name.originalName); // 'jetleaf.datasource.url'
///
/// final dbPrefix = ConfigurationPropertyName('jetleaf.datasource');
/// print(name.startsWith(dbPrefix)); // true
///
/// final appended = name.append('username');
/// print(appended); // jetleaf.datasource.url.username
/// ```
/// {@endtemplate}
class ConfigurationPropertyName {
  final List<String> _elements;

  /// {@macro configuration_property_name}
  ///
  /// Constructs a [ConfigurationPropertyName] from a dot-delimited string.
  ///
  /// Example:
  /// ```dart
  /// final name = ConfigurationPropertyName('server.port');
  /// ```
  ConfigurationPropertyName(String name) : _elements = name.split('.');

  /// Creates a [ConfigurationPropertyName] directly from a list of elements.
  ///
  /// Example:
  /// ```dart
  /// final name = ConfigurationPropertyName.fromElements(['app', 'env', 'mode']);
  /// ```
  ConfigurationPropertyName.fromElements(List<String> elements) : _elements = List.unmodifiable(elements);

  /// The original dot-separated property name.
  ///
  /// Example:
  /// ```dart
  /// ConfigurationPropertyName('a.b').originalName; // 'a.b'
  /// ```
  String get originalName => _elements.join('.');

  /// The individual elements of the property name.
  ///
  /// Example:
  /// ```dart
  /// ConfigurationPropertyName('a.b').elements; // ['a', 'b']
  /// ```
  List<String> get elements => _elements;

  /// Returns a new [ConfigurationPropertyName] with an element appended to the end.
  ///
  /// Example:
  /// ```dart
  /// final name = ConfigurationPropertyName('server');
  /// final full = name.append('port');
  /// print(full); // server.port
  /// ```
  ConfigurationPropertyName append(String element) {
    return ConfigurationPropertyName.fromElements([..._elements, element]);
  }

  /// Returns a subname of this name starting at [start] and ending before [end].
  ///
  /// Example:
  /// ```dart
  /// final name = ConfigurationPropertyName('jetleaf.datasource.url');
  /// final db = name.subName(0, 2); // jetleaf.datasource
  /// print(db); // jetleaf.datasource
  /// ```
  ConfigurationPropertyName subName(int start, [int? end]) {
    return ConfigurationPropertyName.fromElements(_elements.sublist(start, end));
  }

  /// Checks if this name starts with the given [prefix].
  ///
  /// Example:
  /// ```dart
  /// final name = ConfigurationPropertyName('jetleaf.datasource.url');
  /// final prefix = ConfigurationPropertyName('jetleaf.datasource');
  /// print(name.startsWith(prefix)); // true
  /// ```
  bool startsWith(ConfigurationPropertyName prefix) {
    if (prefix._elements.length > _elements.length) {
      return false;
    }
    for (int i = 0; i < prefix._elements.length; i++) {
      if (prefix._elements[i] != _elements[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationPropertyName &&
          runtimeType == other.runtimeType && _elements.length == other._elements.length;

  @override
  int get hashCode => _elements.hashCode;

  @override
  String toString() => originalName;
}