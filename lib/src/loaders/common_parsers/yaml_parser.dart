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

import 'environment_parser_factory.dart';

/// {@template yaml_parser}
/// A basic, built-in YAML parser for loading environment properties.
///
/// This implementation supports:
/// - Nested key-value pairs using indentation
/// - Lists with `-` notation
/// - Booleans (`true` / `false`)
/// - Numbers (int and double)
/// - Strings (quoted and unquoted)
/// - Simple null values (`null`)
///
/// **Note:** This is a simplified parser and does **not** fully support
/// YAML spec features like anchors, complex lists, multi-line values, or inline maps.
///
/// ### Example usage:
///
/// ```dart
/// final parser = YamlParser();
/// final content = '''
/// server:
///   port: 8080
///   host: localhost
/// features:
///   - logging
///   - metrics
/// enabled: true
/// '''; 
/// final props = parser.parseSingle(content);
/// print(props['server']); // {port: 8080, host: localhost}
/// print(props['features']); // [logging, metrics]
/// print(props['enabled']); // true
/// ```
///
/// Throws no exceptions on parse errors but may produce incomplete results.
/// Use with caution for production-grade parsing.
/// {@endtemplate}
class YamlParser extends EnvironmentParserFactory {
  /// {@macro yaml_parser}
  YamlParser();

  @override
  Map<String, Object> parseSingle(String line) {
    final result = <String, Object>{};
    final lines = line.split('\n');
    final stack = <Map<String, Object>>[result];
    final indentStack = <int>[0];

    for (var line in lines) {
      final trimmed = line.trim();
      
      // Skip empty lines and comments
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      final indent = line.length - line.trimLeft().length;
      
      // Handle indentation changes
      while (indentStack.length > 1 && indent <= indentStack.last) {
        indentStack.removeLast();
        stack.removeLast();
      }

      if (trimmed.contains(':')) {
        final colonIndex = trimmed.indexOf(':');
        final key = trimmed.substring(0, colonIndex).trim();
        final valueStr = trimmed.substring(colonIndex + 1).trim();

        if (valueStr.isEmpty) {
          // This is a parent key
          final newMap = <String, Object>{};
          stack.last[key] = newMap;
          stack.add(newMap);
          indentStack.add(indent);
        } else {
          // This is a key-value pair
          stack.last[key] = _parseValue(valueStr);
        }
      } else if (trimmed.startsWith('- ')) {
        // Handle simple lists
        final value = trimmed.substring(2).trim();
        final parentKey = stack.length > 1 ? _getLastKey(stack[stack.length - 2]) : null;
        
        if (parentKey != null) {
          final parent = stack[stack.length - 2];
          if (parent[parentKey] is! List) {
            parent[parentKey] = <Object>[];
          }
          (parent[parentKey] as List).add(_parseValue(value));
        }
      }
    }

    return result;
  }

  /// Parses a string value to its Dart representation (int, double, bool, etc.).
  static Object _parseValue(String value) {
    // Handle quoted strings
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) {
      return value.substring(1, value.length - 1);
    }

    // Handle booleans
    if (value.toLowerCase() == 'true') return true;
    if (value.toLowerCase() == 'false') return false;
    if (value.toLowerCase() == 'null') return "";

    // Handle numbers
    if (RegExp(r'^\d+$').hasMatch(value)) {
      return int.tryParse(value) ?? value;
    }
    if (RegExp(r'^\d+\.\d+$').hasMatch(value)) {
      return double.tryParse(value) ?? value;
    }

    return value;
  }

  /// Returns the last key in a map.
  static String? _getLastKey(Map<String, Object> map) {
    return map.keys.isNotEmpty ? map.keys.last : null;
  }
}