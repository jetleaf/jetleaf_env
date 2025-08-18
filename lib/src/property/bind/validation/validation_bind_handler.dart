import '../../source/configuration_property_name.dart';
import '../bind_context.dart';
import '../bind_result.dart';
import '../class_binding_schema.dart';
import '../abstract_bind_handler.dart';
import 'validation_bind_exception.dart';
import 'validation_errors.dart';
import 'origin_tracked_field_error.dart';

/// A [BindHandler] that performs validation after a property is bound.
///
/// This would typically integrate with a Dart validation library.
class ValidationBindHandler extends AbstractBindHandler {
  final ValidationErrors _currentErrors = ValidationErrors();

  ValidationBindHandler([super.delegate]);

  @override
  BindResult<T> onSuccess<T>(ConfigurationPropertyName name, BindableProperty targetProperty, T value, BindContext context) {
    // Simulate a simple validation: non-nullable fields marked as required must have a value.
    if (targetProperty.isRequired && value == null) {
      _currentErrors.addError(OriginTrackedFieldError(
        name,
        'Required property "${targetProperty.name}" cannot be null.',
        origin: context.sources.getProperty(name).toString(),
      ));
    }

    // Delegate to the next handler in the chain
    return super.onSuccess(name, targetProperty, value, context);
  }

  @override
  void onFinish(ConfigurationPropertyName name, BindableProperty targetProperty, BindContext context) {
    // This check should ideally happen once at the very end of the top-level binding.
    // For simplicity, we'll check if there are errors and throw.
    if (_currentErrors.hasErrors) {
      throw ValidationBindException('Validation failed for configuration properties.', _currentErrors);
    }
    super.onFinish(name, targetProperty, context);
  }
}