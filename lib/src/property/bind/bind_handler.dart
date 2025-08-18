import '../source/configuration_property_name.dart';
import 'bind_context.dart';
import 'bind_result.dart';
import 'class_binding_schema.dart'; // Using schema now
import '../../exceptions.dart';

/// Interface for handling the binding process.
///
/// Bind handlers can intercept and modify the binding behavior.
abstract class BindHandler {
  /// Called before a property is bound.
  /// Returns a [BindResult] indicating if the handler has already bound the value.
  BindResult<T> onStart<T>(ConfigurationPropertyName name, BindableProperty targetProperty, BindContext context);

  /// Called when a property value is found from a source.
  /// Returns a [BindResult] indicating if the handler has processed/converted the value.
  BindResult<T> onData<T>(ConfigurationPropertyName name, BindableProperty targetProperty, Object? value, BindContext context);

  /// Called when a property is successfully bound.
  /// Returns a [BindResult] with the final bound value.
  BindResult<T> onSuccess<T>(ConfigurationPropertyName name, BindableProperty targetProperty, T value, BindContext context);

  /// Called when a property binding fails.
  void onFailure(ConfigurationPropertyName name, BindableProperty targetProperty, BindException exception, BindContext context);

  /// Called after the binding process for a property is complete (success or failure).
  void onFinish(ConfigurationPropertyName name, BindableProperty targetProperty, BindContext context);
}