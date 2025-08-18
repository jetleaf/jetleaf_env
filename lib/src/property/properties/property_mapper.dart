import '../source/configuration_property_name.dart';

/// Abstract base class for mapping configuration property names.
abstract class PropertyMapper {
  /// Maps a canonical [ConfigurationPropertyName] to a list of possible
  /// source names (e.g., "my.property" -> ["my.property", "my_property", "MY_PROPERTY"]).
  Iterable<String> mapFrom(ConfigurationPropertyName name);
}

/// Default property mapper that handles common conventions like kebab-case to camelCase.
class DefaultPropertyMapper implements PropertyMapper {
  @override
  Iterable<String> mapFrom(ConfigurationPropertyName name) {
    final original = name.originalName;
    final kebabCase = original.replaceAll('.', '-');
    final snakeCase = original.replaceAll('.', '_');
    final upperSnakeCase = snakeCase.toUpperCase();

    return {original, kebabCase, snakeCase, upperSnakeCase};
  }
}