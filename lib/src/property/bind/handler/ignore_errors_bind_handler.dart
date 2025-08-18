import '../../../exceptions.dart';
import '../../source/configuration_property_name.dart';
import '../bind_context.dart';
import '../class_binding_schema.dart';
import '../abstract_bind_handler.dart';

/// A [BindHandler] that ignores errors during binding.
class IgnoreErrorsBindHandler extends AbstractBindHandler {
  IgnoreErrorsBindHandler([super.delegate]);

  @override
  void onFailure(ConfigurationPropertyName name, BindableProperty targetProperty, BindException exception, BindContext context) {
    // Log or ignore, do not rethrow.
    print('Ignoring binding failure for ${name.originalName}: ${exception.message}');
    // Do not call super.onFailure to prevent delegation of the error.
  }
}