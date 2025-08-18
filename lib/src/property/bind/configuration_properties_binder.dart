import 'binder.dart';
import '../../exceptions.dart';
import 'bind_handler.dart';
import 'default_bind_handler.dart';
import 'handler/ignore_errors_bind_handler.dart';
import 'handler/ignore_top_level_converter_not_found_bind_handler.dart';
import 'handler/no_unbound_elements_bind_handler.dart';
import 'validation/validation_bind_handler.dart';
import '../source/configuration_property_name.dart';
import '../source/configuration_property_sources.dart';
import 'binding_registry.dart';
import 'class_binding_schema.dart';

/// The main entry point for binding objects annotated with [ConfigurationProperties].
///
/// This class orchestrates the binding process by looking up [ClassBindingSchema]
/// from the [BindingRegistry] and constructing the appropriate [BindHandler] chain.
class ConfigurationPropertiesBinder {
  final ConfigurationPropertySources _sources;
  final List<BindHandler> _additionalBindHandlers;
  final BindingRegistry _registry;

  ConfigurationPropertiesBinder(
    ConfigurationPropertySources sources, {
    List<BindHandler>? additionalBindHandlers,
    BindingRegistry? registry,
  })  : _sources = sources,
        _additionalBindHandlers = additionalBindHandlers ?? [],
        _registry = registry ?? BindingRegistry();

  /// Binds properties to an instance of a class of type [T].
  ///
  /// [type] is the [Type] of the class to bind (e.g., `MyAppConfig`).
  /// Returns the bound instance.
  T bind<T>(Type type) {
    final ClassBindingSchema<T>? schema = _registry.getSchema<T>(type);

    if (schema == null) {
      throw MutuallyExclusiveConfigurationPropertiesException('No ClassBindingSchema registered for type $type. '
          'Ensure you have registered the schema for this configuration class.');
    }

    final prefix = ConfigurationPropertyName(schema.configAnnotation.prefix);

    // Build the chain of bind handlers
    BindHandler currentHandler = DefaultBindHandler();

    // Add user-provided additional handlers first (they wrap the default)
    // Handlers are applied in reverse order of the list to ensure the first handler
    // in the list is the outermost wrapper.
    for (final handler in _additionalBindHandlers.reversed) {
      currentHandler = handler;
    }

    // Add handlers based on ConfigurationProperties annotation flags
    // Order matters: error ignoring usually first, validation last.
    if (schema.configAnnotation.ignoreErrors) {
      currentHandler = IgnoreErrorsBindHandler(currentHandler);
    }
    if (schema.configAnnotation.ignoreTopLevelConverterNotFound) {
      currentHandler = IgnoreTopLevelConverterNotFoundBindHandler(currentHandler);
    }

    // Validation handler should typically be near the end of the chain
    currentHandler = ValidationBindHandler(currentHandler);

    // NoUnboundElementsBindHandler should be one of the last to check everything
    if (schema.configAnnotation.noUnboundElements) {
      currentHandler = NoUnboundElementsBindHandler(currentHandler);
    }

    final binder = Binder(_sources, bindHandler: currentHandler, registry: _registry);
    final result = binder.bind(prefix, schema);

    if (!result.isBound) {
      throw ConfigurationPropertiesBindException('Failed to bind configuration properties for ${prefix.originalName}');
    }
    return result.get();
  }
}