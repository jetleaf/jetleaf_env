# Property Sources

## Overview
`PropertySource` is a fundamental abstraction representing a source of key-value properties. It provides a unified way to access properties from various sources like maps, environment variables, or configuration files.

## Core Concepts

### PropertySource Hierarchy

```
PropertySource<T>
├── MapPropertySource
├── PropertiesPropertySource
├── SystemEnvironmentPropertySource
└── CompositePropertySource
```

## Core Interfaces

### `PropertySource<T>`

The base interface for all property sources.

**Type Parameters**:
- `T`: The type of the underlying source object

**Key Methods**:
- `bool containsProperty(String name)`: Check if the source contains a property
- `Object? getProperty(String name)`: Get a property value by name
- `String get name`: The name of the property source
- `T get source`: The underlying source object

## Built-in Implementations

### `MapPropertySource`

A `PropertySource` implementation that reads properties from a `Map`.

**Example**:
```dart
final source = MapPropertySource('myProps', {
  'app.name': 'My App',
  'app.version': '1.0.0',
});
```

### `PropertiesPropertySource`

A `PropertySource` implementation that reads from a `Properties` object.

**Example**:
```dart
final props = Properties();
props['db.url'] = 'jdbc:mysql://localhost/mydb';
final source = PropertiesPropertySource('dbProps', props);
```

### `SystemEnvironmentPropertySource`

A `PropertySource` implementation that reads from the system environment variables.

**Example**:
```dart
final envSource = SystemEnvironmentPropertySource('systemEnvironment');
```

### `CompositePropertySource`

A composite property source that delegates to multiple property sources.

**Example**:
```dart
final composite = CompositePropertySource('composite');
composite.addPropertySource(mapSource);
composite.addPropertySource(propertiesSource);
```

## Creating Custom Property Sources

You can create custom property sources by extending `PropertySource<T>`:

```dart
class JsonPropertySource extends PropertySource<Map<String, dynamic>> {
  JsonPropertySource(String name, Map<String, dynamic> json) : super(name, json);

  @override
  bool containsProperty(String name) => source.containsKey(name);

  @override
  Object? getProperty(String name) {
    final value = source[name];
    return value is Map ? JsonPropertySource('$name', value) : value;
  }
}
```

## Property Source Precedence

When multiple property sources are registered, they are searched in order. The first property source that contains the requested property is used.

**Example**:
```dart
final env = StandardEnvironment();
env.propertySources.addFirst(SystemEnvironmentPropertySource('system'));
env.propertySources.addLast(MapPropertySource('defaults', {
  'server.port': '8080',
}));

// System properties take precedence over defaults
final port = env.getProperty('server.port');
```

## Best Practices

1. **Naming**: Use meaningful names for property sources
2. **Ordering**: Add property sources in order of precedence (highest first)
3. **Immutability**: Prefer immutable property sources when possible
4. **Lazy Loading**: Consider lazy loading for expensive property sources
5. **Documentation**: Document available properties in each source

## Usage Examples

### Basic Usage

```dart
// Create a property source from a map
final source = MapPropertySource('app', {
  'app.name': 'My Application',
  'app.version': '1.0.0',
});

// Check if a property exists
if (source.containsProperty('app.name')) {
  // Get a property value
  final name = source.getProperty('app.name');
  print('Application: $name');
}
```

### Composite Property Source

```dart
// Create a composite source
final composite = CompositePropertySource('config');

// Add multiple property sources
composite.addPropertySource(MapPropertySource('defaults', {
  'server.port': '8080',
  'server.host': 'localhost',
}));

composite.addPropertySource(MapPropertySource('overrides', {
  'server.port': '9090', // Override the default port
}));

// The override takes precedence
final port = composite.getProperty('server.port'); // '9090'
```

### Custom Property Source

```dart
class EnvironmentAwarePropertySource extends PropertySource<Map<String, String>> {
  final String environment;

  EnvironmentAwarePropertySource({
    required this.environment,
  }) : super('envAware', {
          'app.environment': environment,
          'db.url': environment == 'prod' 
              ? 'jdbc:mysql://prod-db:3306/app' 
              : 'jdbc:mysql://localhost:3306/app_dev',
        });

  @override
  bool containsProperty(String name) => source.containsKey(name);

  @override
  String? getProperty(String name) => source[name];
}

// Usage
final source = EnvironmentAwarePropertySource(environment: 'prod');
print(source.getProperty('db.url')); // 'jdbc:mysql://prod-db:3306/app'
```

## See Also

- [Environment](environment/README.md) - For using property sources in an environment
- [PropertyResolver](property_resolver/README.md) - For resolving properties from sources
- [ConfigurableEnvironment](configurable_environment/README.md) - For managing property sources
