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
import 'package:jetleaf_convert/convert.dart';

import 'property_resolver.dart';

/// {@template configurable_property_resolver}
/// A specialized [PropertyResolver] that allows full control over property
/// placeholder behavior and type conversion logic using a configurable
/// [ConfigurableConversionService].
///
/// This interface enables:
/// - Custom placeholder syntax configuration (prefix, suffix, separator, escape).
/// - Tolerance or strictness for unresolvable nested placeholders.
/// - Custom [Converter] registration.
/// - Required property validation.
///
/// ---
///
/// ### 🔁 Example:
/// ```dart
/// final resolver = MyPropertyResolver();
/// resolver.setPlaceholderPrefix('#{');
/// resolver.setPlaceholderSuffix('}');
/// resolver.setValueSeparator(':');
/// resolver.setEscapeCharacter(r'\');
/// resolver.setIgnoreUnresolvableNestedPlaceholders(false);
///
/// resolver.getConversionService().addConverter(StringToDurationConverter());
/// ```
///
/// This is intended for internal use by [Environment] implementations and
/// advanced property injection infrastructure.
/// {@endtemplate}
abstract interface class ConfigurablePropertyResolver extends PropertyResolver {
  /// {@macro configurable_property_resolver}
  ConfigurablePropertyResolver();

  /// Returns the [ConfigurableConversionService] used to perform type conversions.
  ///
  /// This allows dynamic registration of custom [Converter] or [ConverterFactory] instances:
  ///
  /// ```dart
  /// configurablePropertyResolver.getConversionService()
  ///     .addConverter(StringToUriConverter());
  /// ```
  ConfigurableConversionService getConversionService();

  /// Replaces the underlying [ConfigurableConversionService] used for type conversions.
  ///
  /// ⚠️ It's usually preferable to mutate the existing conversion service
  /// (via [getConversionService]) rather than replacing it entirely.
  void setConversionService(ConfigurableConversionService conversionService);

  /// Sets the prefix that identifies a placeholder in property values.
  ///
  /// For example, in `#{host}`, the prefix is `'#{'`.
  void setPlaceholderPrefix(String placeholderPrefix);

  /// Sets the suffix that identifies the end of a placeholder in property values.
  ///
  /// For example, in `#{host}`, the suffix is `'}'`.
  void setPlaceholderSuffix(String placeholderSuffix);

  /// Sets the separator for default values within placeholders.
  ///
  /// For example, `#{host:localhost}` uses `':'` as the separator.
  void setValueSeparator(String? valueSeparator);

  /// Sets the escape character used to ignore placeholder prefix and separator.
  ///
  /// For example, `\#{host}` will be treated as a literal instead of a placeholder.
  void setEscapeCharacter(Character? escapeCharacter);

  /// Enables or disables ignoring unresolvable nested placeholders.
  ///
  /// If `false`, unresolved nested placeholders will throw an exception.
  /// If `true`, unresolved placeholders will remain in their original form (e.g., `#{...}`).
  void setIgnoreUnresolvableNestedPlaceholders(bool ignoreUnresolvableNestedPlaceholders);

  /// Sets the list of property names that are required to be present and non-null.
  void setRequiredProperties(List<String> requiredProperties);

  /// Validates that all required properties are present and non-null.
  ///
  /// Throws [MissingRequiredPropertiesException] if any required properties are missing.
  void validateRequiredProperties();
}