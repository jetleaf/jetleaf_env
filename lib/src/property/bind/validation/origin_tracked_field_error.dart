import '../../source/configuration_property_name.dart';

/// Represents a validation error for a specific field.
class OriginTrackedFieldError {
  final ConfigurationPropertyName name;
  final String message;
  final String? origin;

  OriginTrackedFieldError(this.name, this.message, {this.origin});

  @override
  String toString() => 'FieldError(name: $name, message: $message, origin: $origin)';
}