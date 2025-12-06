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

import '../property_source/simple_command_line_property_source.dart';
import 'application_arguments.dart';

/// {@template default_application_arguments}
/// Default implementation of [ApplicationArguments] that wraps command-line arguments
/// and exposes them via a [PropertySource]-based backing system.
///
/// This class uses [SimpleCommandLinePropertySource] internally to parse arguments,
/// exposing both options and non-option arguments in a read-only fashion.
///
/// ### Example usage:
/// ```dart
/// final args = DefaultApplicationArguments(['--env=prod', '--debug', 'input.txt']);
///
/// print(args.getSourceArgs()); // ['--env=prod', '--debug', 'input.txt']
/// print(args.getOptionNames()); // {'env', 'debug'}
/// print(args.containsOption('debug')); // true
/// print(args.getOptionValues('env')); // ['prod']
/// print(args.getNonOptionArgs()); // ['input.txt']
/// ```
///
/// This is typically used within the JetLeaf application context during startup
/// to extract configuration flags passed to the executable.
/// {@endtemplate}
class DefaultApplicationArguments implements ApplicationArguments {
  /// The raw list of command-line arguments passed to the application at startup.
  ///
  /// These values come directly from the process invocation and include both:
  /// - **option arguments** (e.g., `--env=prod`, `--debug`)
  /// - **non-option arguments** (e.g., positional file names)
  ///
  /// The list is preserved exactly as provided and is never modified.
  final List<String> args;

  /// The parsed command-line argument source backing this implementation.
  ///
  /// Internally, this wraps [SimpleCommandLinePropertySource], which extracts:
  /// - option names  
  /// - option values  
  /// - non-option (positional) arguments  
  ///
  /// This field is initialized lazily during construction and provides the
  /// underlying resolution mechanism for all [ApplicationArguments] methods.
  late final SimpleCommandLinePropertySource source;

  /// {@macro default_application_arguments}
  DefaultApplicationArguments(this.args) {
    source = SimpleCommandLinePropertySource(args);
  }

  @override
  List<String> getSourceArgs() => args;

  @override
  Set<String> getOptionNames() {
    final names = source.getPropertyNames();
    return Set.unmodifiable(names.toSet());
  }

  @override
  bool containsOption(String name) => source.containsProperty(name);

  @override
  List<String>? getOptionValues(String name) {
    final values = source.getOptionValues(name);
    return (values != null) ? List.unmodifiable(values) : null;
  }

  @override
  List<String> getNonOptionArgs() => source.getNonOptionArgs();

  @override
  String getPackageName() => PackageNames.ENV;
}