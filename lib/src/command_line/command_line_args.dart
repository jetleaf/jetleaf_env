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

/// {@template command_line_args}
/// A utility class for parsing and storing command-line arguments.
///
/// This class separates arguments into **option arguments** (e.g., `--key=value`)
/// and **non-option arguments** (e.g., standalone values like file paths).
///
/// ### Example:
/// ```dart
/// var args = CommandLineArgs();
/// args.addOptionArg('config', 'dev');
/// args.addNonOptionArg('main.dart');
///
/// print(args.containsOption('config')); // true
/// print(args.getOptionValues('config')); // ['dev']
/// print(args.getNonOptionArgs()); // ['main.dart']
/// ```
/// {@endtemplate}
class CommandLineArgs {
  final Map<String, List<String>> _optionArgs = {};
  final List<String> _nonOptionArgs = [];

  /// {@template command_line_args_add_option_arg}
  /// Adds an option argument with an optional value.
  ///
  /// - [optionName] is the name of the option (e.g., `--config` becomes `'config'`).
  /// - [optionValue] is the value associated with the option (can be `null`).
  ///
  /// If [optionValue] is `null`, it is ignored.
  /// {@endtemplate}
  void addOptionArg(String optionName, String? optionValue) {
    _optionArgs.putIfAbsent(optionName, () => []);
    if (optionValue != null) {
      _optionArgs[optionName]!.add(optionValue);
    }
  }

  /// {@template command_line_args_get_option_names}
  /// Returns a set of all option names that were parsed.
  ///
  /// Example: If `--config=dev` was parsed, `'config'` will be included.
  /// {@endtemplate}
  Set<String> getOptionNames() {
    return _optionArgs.keys.toSet();
  }

  /// {@template command_line_args_contains_option}
  /// Returns `true` if the given [optionName] exists among the parsed arguments.
  /// {@endtemplate}
  bool containsOption(String optionName) {
    return _optionArgs.containsKey(optionName);
  }

  /// {@template command_line_args_get_option_values}
  /// Returns the list of values for the given [optionName], or `null` if not found.
  ///
  /// Some options can have multiple values (e.g., `--tag a --tag b`).
  /// {@endtemplate}
  List<String>? getOptionValues(String optionName) {
    return _optionArgs[optionName];
  }

  /// {@template command_line_args_add_non_option_arg}
  /// Adds a non-option argument (e.g., a file name or input path).
  /// {@endtemplate}
  void addNonOptionArg(String value) {
    _nonOptionArgs.add(value);
  }

  /// {@template command_line_args_get_non_option_args}
  /// Returns a read-only list of all non-option arguments in the order they were added.
  /// {@endtemplate}
  List<String> getNonOptionArgs() {
    return List.unmodifiable(_nonOptionArgs);
  }
}