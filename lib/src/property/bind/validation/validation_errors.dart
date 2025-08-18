import 'origin_tracked_field_error.dart';

/// A collection of validation errors.
class ValidationErrors {
  final List<OriginTrackedFieldError> _errors = [];

  bool get hasErrors => _errors.isNotEmpty;
  List<OriginTrackedFieldError> get errors => List.unmodifiable(_errors);

  void addError(OriginTrackedFieldError error) {
    _errors.add(error);
  }

  @override
  String toString() => 'ValidationErrors: ${errors.join(', ')}';
}
