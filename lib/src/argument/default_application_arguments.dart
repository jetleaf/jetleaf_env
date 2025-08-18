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
  /// The raw argument list provided at startup.
  final List<String> args;

  late final _Source source;

  /// {@macro default_application_arguments}
  DefaultApplicationArguments(this.args) {
    source = _Source(args);
  }

  @override
  List<String> getSourceArgs() {
    return args;
  }

  @override
  Set<String> getOptionNames() {
    List<String> names = source.getPropertyNames();
    return Set.unmodifiable(names.toSet());
  }

  @override
  bool containsOption(String name) {
    return source.containsProperty(name);
  }

  @override
  List<String>? getOptionValues(String name) {
    List<String>? values = source.getOptionValues(name);
    return (values != null) ? List.unmodifiable(values) : null;
  }

  @override
  List<String> getNonOptionArgs() {
    return source.getNonOptionArgs();
  }
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