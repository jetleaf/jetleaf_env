# Property Resolver

## Overview
The `PropertyResolver` interface provides a flexible way to resolve properties from various sources, including environment variables, property files, and in-memory maps. It supports type conversion, placeholder resolution, and default values.

## Key Features

- **Type-Safe Property Access**: Get properties as specific types
- **Placeholder Resolution**: Support for `${...}`, `#{...}`, and `@...@` syntax
- **Default Values**: Fallback values for missing properties
- **Required Properties**: Explicit handling of required configuration
- **Environment Variable Integration**: Seamless access to system environment variables

## Core Methods

### `bool containsProperty(String key)`

Check if a property with the given key exists.

**Parameters**:
- `key`: The property key to check

**Returns**: `true` if the property exists, `false` otherwise

**Example**:
```dart
if (resolver.containsProperty('app.name')) {
  print('Application name is configured');
}
```

### `String? getProperty(String key)`

Get a property value as a string, or `null` if the property doesn't exist.

**Parameters**:
- `key`: The property key to look up

**Returns**: The property value, or `null` if not found

**Example**:
```dart
final name = resolver.getProperty('app.name');
```

### `T getPropertyAs<T>(String key, Class<T> targetType)`

Get a property value converted to the specified type.

**Type Parameters**:
- `T`: The target type to convert to

**Parameters**:
- `key`: The property key to look up
- `targetType`: The target type class

**Returns**: The converted property value

**Throws**:
- `IllegalStateException` if the property doesn't exist or can't be converted

**Example**:
```dart
final port = resolver.getPropertyAs('server.port', int);
final enabled = resolver.getPropertyAs('feature.flag', bool);
```

### `T getPropertyAsWithDefault<T>(String key, Class<T> targetType, T defaultValue)`

Get a property value converted to the specified type, with a fallback default value.

**Type Parameters**:
- `T`: The target type to convert to

**Parameters**:
- `key`: The property key to look up
- `targetType`: The target type class
- `defaultValue`: The default value to return if the property doesn't exist

**Returns**: The converted property value, or the default value if not found

**Example**:
```dart
final port = resolver.getPropertyAsWithDefault('server.port', int, 8080);
```

### `String getRequiredProperty(String key)`

Get a required property value as a string.

**Parameters**:
- `key`: The property key to look up

**Returns**: The property value

**Throws**:
- `IllegalStateException` if the property doesn't exist

**Example**:
```dart
final name = resolver.getRequiredProperty('app.name');
```

### `T getRequiredPropertyAs<T>(String key, Class<T> targetType)`

Get a required property value converted to the specified type.

**Type Parameters**:
- `T`: The target type to convert to

**Parameters**:
- `key`: The property key to look up
- `targetType`: The target type class

**Returns**: The converted property value

**Throws**:
- `IllegalStateException` if the property doesn't exist or can't be converted

**Example**:
```dart
final port = resolver.getRequiredPropertyAs('server.port', int);
```

### `String resolvePlaceholders(String text)`

Resolve placeholders in the given text.

**Parameters**:
- `text`: The text containing placeholders to resolve

**Returns**: The text with placeholders replaced by their values

**Example**:
```dart
// With property 'app.name=MyApp' and environment variable 'ENV=dev'
final result = resolver.resolvePlaceholders(
  'Running ${app.name} in #{ENV} mode'
);
// Result: 'Running MyApp in dev mode'
```

## Supported Placeholder Formats

### Environment Variables
- `${VAR_NAME}` - Standard shell-style
- `#{VAR_NAME}` - Alternative syntax
- `$VAR_NAME` - Short form
- `#VAR_NAME` - Alternative short form

### Property References
- `@property.name@` - With @ delimiters
- `${property.name}` - With ${} syntax
- `#{property.name}` - With #{} syntax

## Usage Examples

### Basic Property Access

```dart
// Get a required string property
final appName = resolver.getRequiredProperty('app.name');

// Get an optional integer with default
final port = resolver.getPropertyAsWithDefault('server.port', int, 8080);

// Get a boolean flag (supports 'true'/'false', 'yes'/'no', 'on'/'off', '1'/'0')
final debug = resolver.getPropertyAs('app.debug', bool);
```

### Placeholder Resolution

```dart
// application.properties:
// db.url=jdbc:mysql://${DB_HOST:localhost}:${DB_PORT:3306}/mydb

// Resolve with environment variables
final dbUrl = resolver.resolvePlaceholders('${db.url}');
// If DB_HOST=db.example.com and DB_PORT is not set:
// → 'jdbc:mysql://db.example.com:3306/mydb'
```

### Type Conversion

```dart
// Get a list of strings from comma-separated value
final features = resolver.getPropertyAs('app.features', List<String>);
// For app.features=auth,logging,caching
// → ['auth', 'logging', 'caching']

// Get a map from properties with prefix
final config = resolver.getPropertyAs<Map<String, String>>('app.config');
```

## Best Practices

1. **Use Strong Typing**: Prefer `getPropertyAs` over `getProperty` for type safety
2. **Provide Defaults**: Use `getPropertyAsWithDefault` for optional configuration
3. **Validate Early**: Use `getRequiredProperty` for mandatory configuration
4. **Use Placeholders**: Externalize environment-specific values
5. **Document Properties**: Document available properties and their expected formats

## See Also

- [Environment](environment/README.md) - For profile-aware property resolution
- [PropertySource](property_source/README.md) - For custom property sources
- [ConfigurablePropertyResolver](configurable_property_resolver/README.md) - For advanced property resolution configuration
