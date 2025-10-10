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

import '../property_source/_property_source.dart';
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
  /// The raw argument list provided at startup.
  final List<String> args;

  late final _Source source;

  /// {@macro default_application_arguments}
  DefaultApplicationArguments(this.args) {
    source = _Source(args);
  }

  @override
  List<String> getSourceArgs() => args;

  @override
  Set<String> getOptionNames() {
    List<String> names = source.getPropertyNames();
    return Set.unmodifiable(names.toSet());
  }

  @override
  bool containsOption(String name) => source.containsProperty(name);

  @override
  List<String>? getOptionValues(String name) {
    List<String>? values = source.getOptionValues(name);
    return (values != null) ? List.unmodifiable(values) : null;
  }

  @override
  List<String> getNonOptionArgs() => source.getNonOptionArgs();

  @override
  String getPackageName() => PackageNames.ENV;
}

/// {@template default_application_arguments_internal_source}
/// Internal command-line property source used by [DefaultApplicationArguments].
///
/// This subclass simply delegates to [SimpleCommandLinePropertySource] to parse
/// the raw `List<String>` argument array into a structured form.
///
/// This class is private and not intended for public use.
/// {@endtemplate}
class _Source extends SimpleCommandLinePropertySource {
  /// {@macro default_application_arguments_internal_source}
  _Source(super.args);
}