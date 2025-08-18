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

import 'command_line_args.dart';

/// {@template simple_command_line_args_parser}
/// A basic parser that splits a list of command-line strings into
/// `CommandLineArgs`, supporting both option and non-option arguments.
///
/// ### Supported Syntax:
/// - `--key=value` → option `key` with value `value`
/// - `--flag` → option `flag` with no value (value is `null`)
/// - `foo.dart` → non-option argument
///
/// ### Example:
/// ```dart
/// final parser = SimpleCommandLineArgsParser();
/// final args = parser.parse(['--env=prod', '--verbose', 'main.dart']);
///
/// print(args.containsOption('env')); // true
/// print(args.getOptionValues('env')); // ['prod']
/// print(args.getOptionValues('verbose')); // []
/// print(args.getNonOptionArgs()); // ['main.dart']
/// ```
/// {@endtemplate}
class SimpleCommandLineArgsParser {
  /// {@template simple_command_line_args_parser_parse}
  /// Parses the raw [args] list into a structured [CommandLineArgs] object.
  ///
  /// - Option arguments must begin with `--`.
  /// - If an `=` is present, the left is treated as the key, the right as the value.
  /// - If no `=`, the key is stored with a `null` value.
  /// - All other arguments are treated as non-option arguments.
  /// {@endtemplate}
  CommandLineArgs parse(List<String> args) {
    final result = CommandLineArgs();

    for (final arg in args) {
      if (arg.startsWith('--')) {
        final eqIndex = arg.indexOf('=');
        if (eqIndex != -1) {
          final name = arg.substring(2, eqIndex);
          final value = arg.substring(eqIndex + 1);
          result.addOptionArg(name, value);
        } else {
          final name = arg.substring(2);
          result.addOptionArg(name, null);
        }
      } else {
        result.addNonOptionArg(arg);
      }
    }

    return result;
  }
}