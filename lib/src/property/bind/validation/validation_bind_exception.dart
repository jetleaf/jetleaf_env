import '../../../exceptions.dart';
import 'validation_errors.dart';

/// Exception thrown when validation fails during binding.
class ValidationBindException extends BindException {
  final ValidationErrors validationErrors;

  ValidationBindException(String message, this.validationErrors)
      : super(message);

  @override
  String toString() => 'ValidationBindException: $message. Errors: $validationErrors';
}