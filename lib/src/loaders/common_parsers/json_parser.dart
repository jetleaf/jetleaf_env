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

import 'dart:convert';

import '../../exceptions.dart';
import 'environment_parser_factory.dart';

/// {@template json_parser}
/// A built-in [EnvironmentParserFactory] for parsing environment properties from JSON.
///
/// This parser uses Dart's built-in `dart:convert` library and does **not** rely
/// on any external dependencies. It expects the entire content to be a valid JSON
/// object (i.e., the root must be a `Map<String, Object>`).
///
/// ### Example usage:
///
/// ```dart
/// final parser = JsonParser();
/// final content = '{"server.port": "8080", "env": "prod"}';
/// final props = parser.parseSingle(content);
/// print(props['server.port']); // 8080
/// ```
///
/// Throws [EnvironmentParsingException] if the content is not valid JSON
/// or if the root is not an object.
/// {@endtemplate}
class JsonParser extends EnvironmentParserFactory {
  /// {@macro json_parser}
  JsonParser();

  @override
  Map<String, Object> parseSingle(String line) {
    try {
      final decoded = json.decode(line);
      if (decoded is Map<String, Object>) {
        return decoded;
      } else {
        throw EnvironmentParsingException('JSON root must be an object');
      }
    } catch (e) {
      throw EnvironmentParsingException('Invalid JSON: $e');
    }
  }
}