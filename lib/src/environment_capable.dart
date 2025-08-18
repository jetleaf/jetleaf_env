import 'environment.dart';

/// {@template environment_capable}
/// Interface indicating a component that contains and exposes an [Environment] reference.
///
/// Implement this interface in any component or service that should be able to expose
/// its `Environment` instance to the outside world. This is typically used in application
/// contexts, configuration processors, or frameworks that work with environment profiles,
/// property sources, or configuration keys.
///
/// This helps decouple environment awareness from implementation details, allowing
/// consumers to fetch the environment regardless of the underlying component type.
///
/// ### Example
/// ```dart
/// class MyContext implements EnvironmentCapable {
///   final Environment _env;
///
///   MyContext(this._env);
///
///   @override
///   Environment getEnvironment() => _env;
/// }
///
/// void main() {
///   final env = StandardEnvironment(); // assume a concrete Environment implementation
///   final context = MyContext(env);
///   print(context.getEnvironment().getProperty('app.name'));
/// }
/// ```
/// {@endtemplate}
abstract interface class EnvironmentCapable {
  /// {@macro environment_capable}
  Environment getEnvironment();
}