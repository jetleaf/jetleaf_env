import '../source/configuration_property_name.dart';
import '../source/configuration_property_sources.dart';

/// {@template bind_context}
/// Provides contextual information during the property binding process.
///
/// This context object is passed throughout the binding pipeline and holds:
/// - [sources]: The source(s) of configuration properties.
/// - [currentName]: The name of the current property being bound (e.g. `server.port`).
/// - [target]: The object instance being bound into. May be `null` if binding to a constructor.
///
/// Use [forNested] to create a nested binding context when descending into
/// nested object properties.
/// {@endtemplate}
class BindContext {
  /// The sources of configuration properties (e.g. environment variables, maps, etc.).
  final ConfigurationPropertySources sources;

  /// The fully qualified name of the property currently being bound.
  final ConfigurationPropertyName currentName;

  /// The target object being bound into.
  ///
  /// This may be `null` if the binding is happening via constructor-based instantiation.
  final Object? target;

  /// {@macro bind_context}
  BindContext({
    required this.sources,
    required this.currentName,
    this.target,
  });

  /// Returns a new [BindContext] scoped for a nested property name and target.
  ///
  /// This is used when binding a nested property object (e.g., `security.username`).
  ///
  /// [nestedName] is the new configuration property name, and [nestedTarget]
  /// is the object to bind into at that level.
  BindContext forNested(ConfigurationPropertyName nestedName, Object? nestedTarget) {
    return BindContext(
      sources: sources,
      currentName: nestedName,
      target: nestedTarget,
    );
  }
}