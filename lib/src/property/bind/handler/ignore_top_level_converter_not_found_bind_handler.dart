import '../../source/configuration_property_name.dart';
import '../bind_context.dart';
import '../class_binding_schema.dart';
import '../../../exceptions.dart';
import '../abstract_bind_handler.dart';

/// A [BindHandler] that ignores converter not found errors at the top level.
class IgnoreTopLevelConverterNotFoundBindHandler extends AbstractBindHandler {
  IgnoreTopLevelConverterNotFoundBindHandler([super.delegate]);

  @override
  void onFailure(ConfigurationPropertyName name, BindableProperty targetProperty, BindException exception, BindContext context) {
    // This is a simplified check for "top-level" and "converter not found"
    // A more robust check would involve knowing if this is the root object's property.
    // if (exception is ConverterNotFoundException && exception.message.contains('Cannot convert value') && context.currentName == name) {
    //   print('Ignoring top-level converter not found error for ${name.originalName}: ${exception.message}');
    //   // Do not call super.onFailure to prevent delegation of the error.
    // } else {
    //   super.onFailure(name, targetProperty, exception, context);
    // }

    // if (context.getDepth() == 0 && error is ConverterNotFoundException) {
		// 	return null;
		// }
		// throw error;
  }
}
