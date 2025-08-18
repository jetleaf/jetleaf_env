# ConfigurableEnvironment

## Overview
`ConfigurableEnvironment` is an extension of the [Environment](environment/README.md) interface that provides methods for modifying environment configuration at runtime. It allows dynamic management of property sources, active profiles, and default profiles.

## Key Features

- **Mutable Property Sources**: Add, remove, or reorder property sources
- **Profile Management**: Set active and default profiles programmatically
- **System Integration**: Access to system properties and environment variables
- **Environment Merging**: Combine configurations from multiple environments

## Core Methods

### `setActiveProfiles(List<String> profiles)`

Set the profiles that are currently active. This will replace any previously set active profiles.

**Parameters**:
- `profiles`: The list of profile names to activate

**Example**:
```dart
env.setActiveProfiles(['dev', 'debug']);
```

### `setDefaultProfiles(List<String> profiles)`

Set the profiles to be used when no active profiles are explicitly set.

**Parameters**:
- `profiles`: The list of default profile names

**Example**:
```dart
env.setDefaultProfiles(['default']);
```

### `addActiveProfile(String profile)`

Add a profile to the current set of active profiles.

**Parameters**:
- `profile`: The profile name to add

**Example**:
```dart
env.addActiveProfile('cloud');
```

### `MutablePropertySources get propertySources`

Access the mutable collection of property sources. This allows you to add, remove, or reorder property sources.

**Example**:
```dart
// Add a new property source with highest precedence
env.propertySources.addFirst(
  MapPropertySource('custom', {'app.name': 'My Custom App'}),
);

// Add a property source with lowest precedence
env.propertySources.addLast(
  PropertiesPropertySource('defaults', {'app.version': '1.0.0'}),
);
```

### `Map<String, Object> getSystemProperties()`

Get a map of all system properties.

**Returns**: A map of system properties

**Example**:
```dart
final systemProps = env.getSystemProperties();
print('Java version: ${systemProps['java.version']}');
```

### `Map<String, Object> getSystemEnvironment()`

Get a map of all system environment variables.

**Returns**: A map of environment variables

**Example**:
```dart
final envVars = env.getSystemEnvironment();
print('PATH: ${envVars['PATH']}');
```

### `void merge(ConfigurableEnvironment parent)`

Merge the given parent environment's configuration into this environment.

**Parameters**:
- `parent`: The parent environment to merge from

**Example**:
```dart
final parent = StandardEnvironment()
  ..setActiveProfiles(['parent'])
  ..propertySources.add(MapPropertySource('parent', {'key': 'value'}));

final child = StandardEnvironment()
  ..setActiveProfiles(['child'])
  ..merge(parent);
```

## Usage Examples

### Basic Configuration

```dart
import 'package:jetleaf_env/jetleaf_env.dart';

void main() {
  // Create a configurable environment
  final env = StandardEnvironment();
  
  // Configure active profiles
  env.setActiveProfiles(['dev', 'debug']);
  env.setDefaultProfiles(['default']);
  
  // Add property sources
  env.propertySources.addFirst(
    MapPropertySource('app', {
      'app.name': 'My Application',
      'app.version': '1.0.0',
    }),
  );
  
  // Access properties
  print(env.getProperty('app.name')); // 'My Application'
}
```

### Profile-based Configuration

```dart
void setupEnvironment(ConfigurableEnvironment env) {
  // Set active profiles based on some condition
  if (isDevelopmentMode) {
    env.setActiveProfiles(['dev']);
  } else {
    env.setActiveProfiles(['prod']);
  }
  
  // Add profile-specific property sources
  if (env.acceptsProfiles(Profiles.of(['dev']))) {
    env.propertySources.addFirst(
      MapPropertySource('dev-props', {
        'debug': 'true',
        'logging.level': 'DEBUG',
      }),
    );
  }
}
```

### Property Source Precedence

```dart
void configurePropertySources(ConfigurableEnvironment env) {
  // System properties have highest precedence (can be overridden by user)
  env.propertySources.addFirst(
    SystemEnvironmentPropertySource('systemProperties'),
  );
  
  // Application properties
  env.propertySources.addLast(
    PropertiesPropertySource('application', loadProperties('application.properties')),
  );
  
  // Default values have lowest precedence
  env.propertySources.addLast(
    MapPropertySource('defaults', {
      'server.port': '8080',
      'logging.level': 'INFO',
    }),
  );
}
```

## Best Practices

1. **Order Matters**: Property sources are searched in order of addition (first one wins)
2. **Immutable by Default**: Consider creating immutable snapshots for production
3. **Profile Activation**: Prefer using profiles over environment variables for feature flags
4. **Default Values**: Always provide sensible defaults in the lowest-priority property source
5. **Security**: Be cautious with sensitive data in property sources

## See Also

- [Environment](environment/README.md) - The base environment interface
- [PropertySource](property_source/README.md) - For creating custom property sources
- [Profiles](profiles/README.md) - Working with configuration profiles
