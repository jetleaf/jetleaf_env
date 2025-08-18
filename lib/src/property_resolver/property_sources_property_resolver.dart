// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_lang/lang.dart';

import '../property_source/mutable_property_sources.dart';
import '../property_source/property_source.dart';
import '../property_source/property_sources.dart';
import 'abstract_property_resolver.dart';

/// {@template property_sources_property_resolver}
/// A concrete implementation of [AbstractPropertyResolver] that retrieves
/// property values from a collection of [PropertySource]s managed by a
/// [MutablePropertySources] container.
///
/// This class supports resolving placeholders in property values and converting
/// properties to specific types using a registered [ConversionService].
///
/// ### Example usage:
///
/// ```dart
/// final sources = MutablePropertySources();
/// sources.addPropertySource(MapPropertySource('config', {'app.name': 'JetLeaf'}));
///
/// final resolver = PropertySourcesPropertyResolver(sources);
/// print(resolver.getProperty('app.name')); // JetLeaf
/// print(resolver.getPropertyWithDefault('app.port', '8080')); // 8080
/// ```
///
/// Placeholder resolution:
///
/// ```dart
/// sources.addPropertySource(MapPropertySource('env', {
///   'host': 'localhost',
///   'url': 'http://${host}:8080'
/// }));
///
/// print(resolver.resolvePlaceholders('API: ${url}')); // API: http://localhost:8080
/// ```
/// {@endtemplate}
class PropertySourcesPropertyResolver extends AbstractPropertyResolver {
  /// The list of property sources to retrieve properties from.
  final PropertySources? propertySources;

  /// {@macro property_sources_property_resolver}
  PropertySourcesPropertyResolver(this.propertySources);

  @override
  bool containsProperty(String key) {
    if (propertySources != null) {
			for (PropertySource propertySource in propertySources!) {
				if (propertySource.containsProperty(key)) {
					return true;
				}
			}
		}
		return false;
  }

  @override
  String? getProperty(String key) {
    return _getProperty(key, Class.of<String>(), true);
  }

  @override
  T? getPropertyAs<T>(String key, Class<T> targetType) {
    return _getProperty(key, targetType, true);
  }
  
  @override
  String? getPropertyAsRawString(String key) {
    return _getProperty(key, Class.of<String>(), false);
  }

  T? _getProperty<T>(String key, Class<T> targetValueType, bool resolveNestedPlaceholders) {
		if (propertySources != null) {
			for (PropertySource propertySource in propertySources!) {
				if (logger.getIsTraceEnabled()) {
					logger.trace("Searching for key '$key' in PropertySource '${propertySource.getName()}'");
				}
				Object? value = propertySource.getProperty(key);
				if (value != null) {
					if (resolveNestedPlaceholders) {
						if (value is String) {
							value = super.resolveNestedPlaceholders(value);
						}
						else if (value is String && targetValueType == Class.of<String>()) {
							value = super.resolveNestedPlaceholders(value.toString());
						}
					}
					logKeyFound(key, propertySource, value);
					return convertValueIfNecessary(value, targetValueType);
				}
			}
		}
		if (logger.getIsTraceEnabled()) {
			logger.trace("Could not find key '$key' in any property source");
		}
		return null;
	}

  void logKeyFound(String key, PropertySource propertySource, Object value) {
		if (logger.getIsDebugEnabled()) {
			logger.debug("Found key '$key' in PropertySource '${propertySource.getName()}' with value of type ${value.runtimeType}");
		}
	}
}