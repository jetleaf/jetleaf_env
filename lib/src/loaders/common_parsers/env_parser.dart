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

import 'dart:io';

import 'environment_parser_factory.dart';

/// {@template environment_parser}
/// Creates key-value pairs from strings formatted as environment
/// variable definitions.
/// 
/// The [EnvParser] class implements the [EnvironmentParserFactory]
/// interface and provides a way to parse environment variable definitions.
/// 
/// ## Example Usage
/// ```dart
/// final env = EnvParser().parse(['foo=bar', 'baz=qux']);
/// print(env); // {foo: bar, baz: qux}
/// ```
/// 
/// {@endtemplate}
class EnvParser implements EnvironmentParserFactory {
  /// {@macro environment_parser}
  const EnvParser();

  static const _singleQuot = "'";
  static const _keyword = 'export';

  static final _comment = RegExp(r'''#.*(?:[^'"])$''');
  static final _surroundQuotes = RegExp(r'''^(['"])(.*)\1$''');
  static final _bashVar = RegExp(r'(?:\\)?(\$)(?:{)?([a-zA-Z_][\w]*)+(?:})?');

  /// Creates a [Map] suitable for merging with [Platform.environment].
  /// Duplicate keys are silently discarded.
  @override
  Map<String, String> parse(Iterable<String> lines) {
    var out = <String, String>{};
    for (var line in lines) {
      var kv = _parseOne(line, env: out);
      if (kv.isEmpty) continue;
      out[kv.keys.single] = kv.values.single;
    }

    return out;
  }

  String _interpolate(String val, Map<String, String> env) {
    return val.replaceAllMapped(_bashVar, (m) {
      var k = m.group(2)!;
      return (!_has(env, k)) ? _tryPlatformEnv(k) ?? '' : env[k] ?? '';
    });
  }

  Map<String, String> _parseOne(String line, {Map<String, String> env = const {}}) {
    var stripped = _strip(line);
    if (!_isValid(stripped)) return {};

    var idx = stripped.indexOf('=');
    var lhs = stripped.substring(0, idx);
    var k = _swallow(lhs);
    if (k.isEmpty) return {};

    var rhs = stripped.substring(idx + 1, stripped.length).trim();
    var quotChar = _surroundingQuote(rhs);
    var v = _unquote(rhs);

    if (quotChar == _singleQuot) {
      // skip substitution in single-quoted values
      return {k: v};
    }

    return {k: _interpolate(v, env)};
  }

  String _strip(String line) => line.replaceAll(_comment, '').trim();

  String _surroundingQuote(String val) {
    if (!_surroundQuotes.hasMatch(val)) return '';
    return _surroundQuotes.firstMatch(val)!.group(1)!;
  }

  String _swallow(String line) => line.replaceAll(_keyword, '').trim();

  String _unquote(String val) => val.replaceFirstMapped(_surroundQuotes, (m) => m[2]!).trim();

  /// [null] is a valid value in a Dart map, but the env var representation is empty string, not the string 'null'
  bool _has(Map<String, String> map, String key) => map.containsKey(key) && map[key] != null;

  bool _isValid(String s) => s.isNotEmpty && s.contains('=');

  String? _tryPlatformEnv(String key) {
    if (!_has(Platform.environment, key)) return null;
    return Platform.environment[key];
  }
  
  @override
  Map<String, Object> parseSingle(String line) {
    return {};
  }
}