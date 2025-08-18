import 'dart:collection';
import '../../source/configuration_property_name.dart';
import '../bind_context.dart';
import '../bind_result.dart';
import '../class_binding_schema.dart';
import '../../../exceptions.dart';
import '../abstract_bind_handler.dart';

/// A [BindHandler] that ensures all expected properties are bound.
/// If not, it throws an [UnboundConfigurationPropertiesException].
///
/// NOTE: This implementation is simplified. A full implementation would
/// require the Binder to pass the expected schema/properties of the target
/// object to this handler, and track all properties that *could* have been bound.
class NoUnboundElementsBindHandler extends AbstractBindHandler {
  NoUnboundElementsBindHandler([super.delegate]);

  final Set<ConfigurationPropertyName> _boundProperties = HashSet();
  final Set<ConfigurationPropertyName> _expectedProperties = HashSet(); // To be populated by the Binder

  // This method would ideally be called by the Binder to inform the handler
  // about all properties it *attempted* to bind for a given schema.
  void addExpectedProperty(ConfigurationPropertyName name) {
    _expectedProperties.add(name);
  }

  @override
  BindResult<T> onSuccess<T>(ConfigurationPropertyName name, BindableProperty targetProperty, T value, BindContext context) {
    _boundProperties.add(name);
    return super.onSuccess(name, targetProperty, value, context);
  }

  @override
  void onFinish(ConfigurationPropertyName name, BindableProperty targetProperty, BindContext context) {
    // This check is very basic. It assumes 'name' is the top-level prefix.
    // A more robust check would compare _boundProperties against _expectedProperties
    // for the entire binding operation.
    if (context.currentName == name && _boundProperties.isEmpty && _expectedProperties.isNotEmpty) {
      throw UnboundConfigurationPropertiesException(
          'No properties were bound for configuration prefix "${name.originalName}". Expected some properties.',
          _expectedProperties);
    }
    super.onFinish(name, targetProperty, context);
  }
}