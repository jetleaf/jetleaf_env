/// {@template properties}
/// A simple key-value store for managing local string-based properties.
///
/// This is useful for storing and retrieving configuration values
/// in-memory, particularly in testing, bootstrapping, or local overrides.
///
/// ### Example
/// ```dart
/// final props = LocalProperties();
/// props.load({'env': 'dev', 'timeout': '30'});
///
/// print(props.getProperty('env')); // dev
///
/// props.setProperty('host', 'localhost');
/// print(props.containsProperty('host')); // true
/// ```
///
/// Values are stored internally as a [Map<String, String>].
/// {@endtemplate}
final class Properties {
  /// Internal map for holding the key-value properties.
  final Map<String, String> _properties = {};

  /// {@macro properties}
  ///
  /// Creates an empty instance of [Properties].
  Properties();

  /// Loads multiple [properties] into the store, merging them into the current state.
  ///
  /// Existing keys will be overwritten if they already exist.
  ///
  /// ### Example
  /// ```dart
  /// props.load({'foo': 'bar', 'baz': 'qux'});
  /// ```
  void load(Map<String, String> properties) {
    _properties.addAll(properties);
  }

  /// Sets a single property key and its [value].
  ///
  /// If the key already exists, it will be overwritten.
  ///
  /// ### Example
  /// ```dart
  /// props.setProperty('debug', 'true');
  /// ```
  void setProperty(String key, String value) {
    _properties[key] = value;
  }

  /// Returns the value for a given [key], or `null` if it is not present.
  ///
  /// ### Example
  /// ```dart
  /// final timeout = props.getProperty('timeout');
  /// ```
  String? getProperty(String key) {
    return _properties[key];
  }

  /// Returns `true` if the given [key] exists in the properties map.
  ///
  /// ### Example
  /// ```dart
  /// if (props.containsProperty('env')) {
  ///   print('Environment is defined.');
  /// }
  /// ```
  bool containsProperty(String key) {
    return _properties.containsKey(key);
  }

  /// Removes the property with the given [key] from the map.
  ///
  /// ### Example
  /// ```dart
  /// props.remove('debug');
  /// ```
  void remove(String key) {
    _properties.remove(key);
  }
}