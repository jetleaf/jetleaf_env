import 'property_mapper.dart';
import '../source/configuration_property_name.dart';

/// Property mapper for system environment variables.
///
/// Converts names like "my.app.port" to "MY_APP_PORT".
class SystemEnvironmentPropertyMapper implements PropertyMapper {
  @override
  Iterable<String> mapFrom(ConfigurationPropertyName name) {
    return {name.originalName.replaceAll('.', '_').toUpperCase()};
  }
}
