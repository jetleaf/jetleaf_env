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
import 'package:jetleaf_utils/utils.dart';
import 'package:jetleaf_convert/convert.dart';
import 'package:jetleaf_logging/logging.dart';
import 'package:meta/meta.dart';

import '../exceptions.dart';
import 'configurable_property_resolver.dart';

/// {@template abstract_property_resolver}
/// An abstract base implementation of [ConfigurablePropertyResolver] that provides
/// common functionality for resolving property placeholders, type conversion,
/// and required property validation.
/// 
/// This class handles basic configuration like placeholder syntax, escape
/// characters, and integration with a [ConfigurableConversionService].
///
/// Subclasses are expected to provide concrete implementations of
/// [getProperty], [containsProperty], and related methods.
/// {@endtemplate}
abstract class AbstractPropertyResolver implements ConfigurablePropertyResolver {
  static final Character DEFAULT_ESCAPE_CHARACTER = SystemPropertyUtils.ESCAPE_CHARACTER;

  @protected
  final Log logger = LogFactory.getLog(AbstractPropertyResolver);

  /// The conversion service used for converting property values to target types.
	ConfigurableConversionService? _conversionService;

	PropertyPlaceholderHelper? _nonStrictHelper;

	PropertyPlaceholderHelper? _strictHelper;

  /// If `true`, unresolvable nested placeholders will be ignored
  /// instead of throwing an exception. Default is `false`.
	bool _ignoreUnresolvableNestedPlaceholders = false;

  /// The prefix used to denote the beginning of a placeholder.
  ///
  /// Default is `#{`.
	String _placeholderPrefix = SystemPropertyUtils.PLACEHOLDER_PREFIX;

  /// The suffix used to denote the end of a placeholder.
  ///
  /// Default is `}`.
	String _placeholderSuffix = SystemPropertyUtils.PLACEHOLDER_SUFFIX;

  /// Optional separator between property key and default value in a placeholder.
  ///
  /// For example: `#{my.prop:default}`. Default is `:`. Can be `null`.
	String? _valueSeparator = SystemPropertyUtils.VALUE_SEPARATOR;

  /// Optional character used to escape placeholder syntax. Default is `null`.
	Character? _escapeCharacter;

  /// List of required property keys that must be present in the environment.
  ///
  /// If any are missing, [validateRequiredProperties] will throw.
	final Set<String> _requiredProperties = {};

  /// {@macro abstract_property_resolver}
  @override
  ConfigurableConversionService getConversionService() {
    // Need to provide an independent DefaultConversionService, not the
		// shared DefaultConversionService used by PropertySourcesPropertyResolver.
		ConfigurableConversionService? cs = _conversionService;
		if (cs == null) {
			return synchronized(this, () {
				cs = _conversionService;
				if (cs == null) {
					cs = DefaultConversionService();
					_conversionService = cs;
				}

        return cs!;
			});
		}
		return cs;
  }

  @override
  void setConversionService(ConfigurableConversionService service) {
    _conversionService = service;
  }

  @override
  void setPlaceholderPrefix(String placeholderPrefix) {
		_placeholderPrefix = placeholderPrefix;
	}

  @override
  void setPlaceholderSuffix(String placeholderSuffix) {
		_placeholderSuffix = placeholderSuffix;
	}

  @override
  void setValueSeparator(String? valueSeparator) {
		_valueSeparator = valueSeparator;
	}

  @override
  void setEscapeCharacter(Character? escapeCharacter) {
		_escapeCharacter = escapeCharacter;
	}

  @override
  void setIgnoreUnresolvableNestedPlaceholders(bool ignoreUnresolvableNestedPlaceholders) {
		_ignoreUnresolvableNestedPlaceholders = ignoreUnresolvableNestedPlaceholders;
	}

  @override
  void setRequiredProperties(List<String> requiredProperties) {
		_requiredProperties.addAll(requiredProperties);
	}

  @override
  void validateRequiredProperties() {
    MissingRequiredPropertiesException ex = MissingRequiredPropertiesException();
		for (String key in _requiredProperties) {
			if (getProperty(key) == null) {
				ex.addMissingRequiredProperty(key);
			}
		}
		if (ex.getMissingRequiredProperties().isNotEmpty) {
			throw ex;
		}
  }

  @override
  bool containsProperty(String key) {
		return (getProperty(key) != null);
	}

  @override
  String? getProperty(String key) {
		return getPropertyAs(key, Class.of<String>());
	}

  @override
  String getPropertyWithDefault(String key, String defaultValue) {
		String? value = getProperty(key);
		return (value ?? defaultValue);
	}

  @override
  T getPropertyAsWithDefault<T>(String key, Class<T> targetType, T defaultValue) {
		T? value = getPropertyAs<T>(key, targetType);
		return (value ?? defaultValue);
	}

  @override
  String getRequiredProperty(String key) {
		String? value = getProperty(key);
		if (value == null) {
			throw IllegalStateException("Required key '$key' not found");
		}
		return value;
	}

  @override
  T getRequiredPropertyAs<T>(String key, Class<T> valueType) {
		T? value = getPropertyAs<T>(key, valueType);
		if (value == null) {
			throw IllegalStateException("Required key '$key' not found");
		}
		return value;
	}

  @override
  String resolvePlaceholders(String text) {
		_nonStrictHelper ??= _createPlaceholderHelper(true);
		return _doResolvePlaceholders(text, _nonStrictHelper!);
	}

  @override
  String resolveRequiredPlaceholders(String text) {
		_strictHelper ??= _createPlaceholderHelper(false);
		return _doResolvePlaceholders(text, _strictHelper!);
	}

  @protected
  String resolveNestedPlaceholders(String value) {
		if (value.isEmpty) {
			return value;
		}
		return (_ignoreUnresolvableNestedPlaceholders ? resolvePlaceholders(value) : resolveRequiredPlaceholders(value));
	}

  PropertyPlaceholderHelper _createPlaceholderHelper(bool ignoreUnresolvablePlaceholders) {
		return PropertyPlaceholderHelper.more(
      _placeholderPrefix,
      _placeholderSuffix,
      _valueSeparator,
      _escapeCharacter,
      ignoreUnresolvablePlaceholders
    );
	}

  String _doResolvePlaceholders(String text, PropertyPlaceholderHelper helper) {
		return helper.replacePlaceholdersWithResolver(text, (key) => getPropertyAsRawString(key));
	}

  @protected
  String? getPropertyAsRawString(String key);

  T? convertValueIfNecessary<T>(Object value, Class<T>? targetType) {
		if (targetType == null) {
			return value as T;
		}

		ConversionService? conversionServiceToUse = _conversionService;
		if (conversionServiceToUse == null) {
			// Avoid initialization of shared DefaultConversionService if
			// no standard type conversion is needed in the first place...
			if (targetType.isInstance(value)) {
				return value as T;
			}
			conversionServiceToUse = DefaultConversionService.getSharedInstance();
		}
		return conversionServiceToUse.convert(value, targetType);
	}
}