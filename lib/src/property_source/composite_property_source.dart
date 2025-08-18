import 'package:jetleaf_lang/lang.dart';

import 'enumerable_property_source.dart';
import 'property_source.dart';

/// {@template composite_property_source}
/// A composite implementation of [EnumerablePropertySource] that aggregates multiple [PropertySource] instances.
///
/// This class allows you to group multiple property sources under a single logical name.
/// When resolving properties, the sources are checked in the order they were added.
///
/// Example:
/// ```dart
/// var composite = CompositePropertySource('applicationConfig');
/// composite.addPropertySource(MapPropertySource('map1', {'foo': 'bar'}));
/// composite.addPropertySource(SystemEnvironmentPropertySource('env'));
/// var value = composite.getProperty('foo'); // searches map1 first, then env
/// ```
/// {@endtemplate}
class CompositePropertySource extends EnumerablePropertySource<Object> {
  final Set<PropertySource<dynamic>> _propertySources = {};

  /// {@macro composite_property_source}
  CompositePropertySource(super.name) : super.named();

  /// {@macro property_source_get_property}
  ///
  /// Iterates through all contained property sources and returns the first non-null value for the given [name].
  @override
  Object? getProperty(String name) {
    for (PropertySource propertySource in _propertySources) {
      Object? candidate = propertySource.getProperty(name);
      if (candidate != null) {
        return candidate;
      }
    }
    return null;
  }

  /// {@macro property_source_contains_property}
  ///
  /// Checks whether any contained property source has a value for the given [name].
  @override
  bool containsProperty(String name) {
    for (PropertySource propertySource in _propertySources) {
      if (propertySource.containsProperty(name)) {
        return true;
      }
    }
    return false;
  }

  /// {@macro enumerable_property_source_get_property_names}
  ///
  /// Returns the union of all property names from contained enumerable property sources.
  /// Throws [IllegalStateException] if any contained source is not enumerable.
  @override
  List<String> getPropertyNames() {
    List<List<String>> namesList = ArrayList.withCapacity(_propertySources.length);
    for (PropertySource propertySource in _propertySources) {
      if (propertySource is! EnumerablePropertySource) {
        throw IllegalStateException("Failed to enumerate property names due to non-enumerable property source: $propertySource");
      }
      List<String> names = propertySource.getPropertyNames();
      namesList.add(names);
    }

    Set<String> allNames = HashSet();
    for (var names in namesList) {
      allNames.addAll(names);
    }

    return allNames.toList();
  }

  /// Adds the given [propertySource] to the end of the composite chain.
  ///
  /// This means it will be consulted *after* all previously added sources.
  void addPropertySource(PropertySource propertySource) {
    _propertySources.add(propertySource);
  }

  /// Adds the given [propertySource] to the *start* of the composite chain.
  ///
  /// This means it will be consulted *before* all previously added sources.
  ///
  /// Useful when overriding existing property values with higher precedence.
  void addFirstPropertySource(PropertySource propertySource) {
    List<PropertySource> existing = ArrayList.from(_propertySources);
    _propertySources.clear();
    _propertySources.add(propertySource);
    _propertySources.addAll(existing);
  }

  /// Returns all [PropertySource] instances currently contained in this composite.
  ///
  /// This is a snapshot of the current state and modifying it will not affect the internal structure.
  List<PropertySource> getPropertySources() {
    return _propertySources.toList();
  }

  @override
  String toString() {
    return "CompositePropertySource {name='$name', propertySources=${_propertySources.toList()}";
  }
}