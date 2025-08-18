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

/// {@template env_parser_factory}
/// Abstract interface for parsing environment variables from `.env`, `.properties`, `.json` or `.yaml` files
/// or raw strings into a key-value map.
///
/// Implementations must support:
/// - Parsing multiple lines
/// - Parsing individual lines
/// - Interpolating bash-style variables (`$VAR`, `${VAR}` syntax)
/// - Stripping comments and normalizing quotes
/// {@endtemplate}
abstract class EnvironmentParserFactory {
  /// {@macro env_parser_factory}
  const EnvironmentParserFactory();

  /// Parses a list of `.env`, `.properties`, `.json` or `.yaml`-style lines into a map of environment variables.
  ///
  /// ### Parameters:
  /// - [lines]: An iterable of strings, each representing a single env line.
  ///
  /// ### Returns:
  /// A `Map<String, Object>` of key-value pairs, after removing comments,
  /// handling quotes, and performing variable interpolation.
  Map<String, Object> parse(Iterable<String> lines) => {};

  /// Parses a single `.env`, `.properties`, `.json` or `.yaml`-style line into a map of environment variables.
  ///
  /// ### Parameters:
  /// - [line]: A string representing a single env line.
  ///
  /// ### Returns:
  /// A `Map<String, Object>` of key-value pairs, after removing comments,
  /// handling quotes, and performing variable interpolation.
  Map<String, Object> parseSingle(String line) => {};
}