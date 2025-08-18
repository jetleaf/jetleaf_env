import 'package:jetleaf_lang/lang.dart';
import 'properties.dart';

/// {@template jetleaf_properties}
/// A centralized utility for managing internal JetLeaf properties and flags.
///
/// This class wraps a static `Properties` instance and provides helpers for accessing
/// configuration-like values throughout the JetLeaf runtime.
///
/// It supports setting, retrieving, and removing properties as strings or booleans,
/// and attempts to fall back to system properties when a key isn't found.
///
/// ### Example
/// ```dart
/// // Set a string property
/// JetLeafProperties.setProperty('jetleaf.server.port', '8080');
///
/// // Get the value
/// final port = JetLeafProperties.getProperty('jetleaf.server.port');
///
/// // Set a boolean flag
/// JetLeafProperties.setBooleanFlag('jetleaf.cache.enabled', true);
///
/// // Check if flag is enabled
/// if (JetLeafProperties.getBooleanFlag('jetleaf.cache.enabled')) {
///   print('Caching is enabled');
/// }
/// ```
///
/// This utility is internal to JetLeaf and not intended for external use unless
/// customizing low-level runtime flags.
///
/// Note: It gracefully handles missing system properties and converts values
/// using the JetLeaf `Boolean` utility.
/// {@endtemplate}
final class JetLeafProperties {
  static final Properties _properties = Properties();

  /// {@macro jetleaf_properties}
  JetLeafProperties._() {
    _load();
  }

  void _load() {
    /// TODO: Load the default properties from jet leaf and add it the the _properties instance
  }

  /// Retrieves the boolean value of a property with the given [key].
  ///
  /// Returns `true` if the property is present and parses to `true`,
  /// otherwise returns `false`.
  ///
  /// ### Example
  /// ```dart
  /// if (JetLeafProperties.getFlag('jetleaf.logging.debug')) {
  ///   print('Debug logging is on');
  /// }
  /// ```
  static bool getFlag(String key) {
    return Boolean.parseBoolean(_properties.getProperty(key) ?? "false").value;
  }

  /// Sets a property with the given [key] and [value].
  ///
  /// If [value] is `null`, the property will be removed from the internal storage.
  ///
  /// ### Example
  /// ```dart
  /// JetLeafProperties.setProperty('jetleaf.mode', 'dev');
  /// JetLeafProperties.setProperty('jetleaf.debug', null); // removes the key
  /// ```
  static void setProperty(String key, String? value) {
    if (value != null) {
      _properties.setProperty(key, value);
    } else {
      _properties.remove(key);
    }
  }

  /// Retrieves a property with the given [key] from internal storage or system properties.
  ///
  /// If the property is not found in internal storage, it attempts to fall back
  /// to the system properties using `System.getProperty`.
  ///
  /// If an error occurs while accessing system properties, it logs the error to `System.err`.
  ///
  /// ### Example
  /// ```dart
  /// final logLevel = JetLeafProperties.getProperty('jetleaf.logging.level');
  /// ```
  static String? getProperty(String key) {
    String? value = _properties.getProperty(key);
    if (value == null) {
      try {
        value = System.getProperty(key);
      } catch (ex) {
        System.err.println("Could not retrieve system property '$key': $ex");
      }
    }

    return value;
  }

  /// Sets a property flag with the given [key] to `true`.
  ///
  /// This is equivalent to calling:
  /// ```dart
  /// JetLeafProperties.setBooleanFlag(key, true);
  /// ```
  ///
  /// ### Example
  /// ```dart
  /// JetLeafProperties.setFlag('jetleaf.metrics.enabled');
  /// ```
  static void setFlag(String key) {
    _properties.setProperty(key, Boolean.TRUE.toString());
  }

  /// Sets a boolean flag for the given [key] to the specified [value].
  ///
  /// ### Example
  /// ```dart
  /// JetLeafProperties.setBooleanFlag('jetleaf.http.compression', false);
  /// ```
  static void setBooleanFlag(String key, bool value) {
    _properties.setProperty(key, value.toString());
  }

  /// Retrieves the boolean value of a flag for the given [key].
  ///
  /// If the property does not exist, or cannot be parsed, it returns `false`.
  ///
  /// ### Example
  /// ```dart
  /// final enabled = JetLeafProperties.getBooleanFlag('jetleaf.cors.enabled');
  /// ```
  static bool getBooleanFlag(String key) {
    return Boolean.parseBoolean(getProperty(key) ?? "false").value;
  }

  /// Attempts to retrieve a `Boolean` object from a property value for the given [key].
  ///
  /// If the key doesn't exist or cannot be parsed, returns `null`.
  ///
  /// ### Example
  /// ```dart
  /// final boolFlag = JetLeafProperties.checkFlag('jetleaf.experimental.feature');
  /// if (boolFlag?.value == true) {
  ///   // do something experimental
  /// }
  /// ```
  static Boolean? checkFlag(String key) {
    String? flag = getProperty(key);
    return (flag != null ? Boolean.valueOfString(flag) : null);
  }
}