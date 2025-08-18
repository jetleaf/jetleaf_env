import 'bind_context.dart';
import 'bind_result.dart';
import '../source/configuration_property_name.dart';
import 'class_binding_schema.dart';
import '../../exceptions.dart';
import 'bind_handler.dart';

/// An abstract base class for [BindHandler] implementations, providing default no-op methods.
/// Subclasses should override specific methods to add behavior.
abstract class AbstractBindHandler implements BindHandler {
  final BindHandler? _delegate;

  AbstractBindHandler([this._delegate]);

  @override
  BindResult<T> onStart<T>(ConfigurationPropertyName name, BindableProperty targetProperty, BindContext context) {
    return _delegate?.onStart(name, targetProperty, context) ?? BindResult.notBound();
  }

  @override
  BindResult<T> onData<T>(ConfigurationPropertyName name, BindableProperty targetProperty, Object? value, BindContext context) {
    return _delegate?.onData(name, targetProperty, value, context) ?? BindResult.notBound();
  }

  @override
  BindResult<T> onSuccess<T>(ConfigurationPropertyName name, BindableProperty targetProperty, T value, BindContext context) {
    return _delegate?.onSuccess(name, targetProperty, value, context) ?? BindResult.of(value);
  }

  @override
  void onFailure(ConfigurationPropertyName name, BindableProperty targetProperty, BindException exception, BindContext context) {
    _delegate?.onFailure(name, targetProperty, exception, context);
  }

  @override
  void onFinish(ConfigurationPropertyName name, BindableProperty targetProperty, BindContext context) {
    _delegate?.onFinish(name, targetProperty, context);
  }
}