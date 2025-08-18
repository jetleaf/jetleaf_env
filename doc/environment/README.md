# Environment

## Overview
The `Environment` interface is the central abstraction for accessing environment configuration and active profiles in the JetLeaf framework. It extends `PropertyResolver` and adds support for profile activation and resolution, enabling conditional configuration based on the runtime context.

## Key Features

- **Profile Management**: Manage active and default profiles
- **Property Resolution**: Resolve properties with support for placeholders and type conversion
- **Profile Expressions**: Support for complex profile activation rules
- **Environment-aware**: Built-in support for different runtime environments

## Core Methods

### `List<String> getActiveProfiles()`

Returns the list of explicitly activated profiles. Profiles are logical configuration sets (like 'dev', 'prod', etc.) used to load different beans or properties at runtime.

**Returns**: A list of active profile names

**Example**:
```dart
final activeProfiles = env.getActiveProfiles();
print('Active profiles: $activeProfiles');
```

### `List<String> getDefaultProfiles()`

Returns the list of default profiles that will be used when no profiles are explicitly activated.

**Returns**: A list of default profile names (typically `['default']`)

**Example**:
```dart
final defaultProfiles = env.getDefaultProfiles();
print('Default profiles: $defaultProfiles');
```

### `bool acceptsProfiles(Profiles profiles)`

Checks if the given profile expressions match the active or default profiles.

**Parameters**:
- `profiles`: The profile expressions to match against

**Returns**: `true` if the profiles match, `false` otherwise

**Example**:
```dart
// Check for 'dev' profile
if (env.acceptsProfiles(Profiles.of(['dev']))) {
  // Development-specific configuration
}

// Check for 'dev' but not 'test'
if (env.acceptsProfiles(Profiles.of(['dev', '!test']))) {
  // Dev-only configuration
}
```

### `bool matchesProfiles(String... profiles)`

Convenience method to check if any of the given profiles are active.

**Parameters**:
- `profiles`: One or more profile names to check

**Returns**: `true` if any of the profiles are active, `false` otherwise

**Example**:
```dart
if (env.matchesProfiles('dev', 'test')) {
  // Either 'dev' or 'test' profile is active
}
```

## Profile Expressions

Profile expressions allow for complex profile activation rules:

- `dev` - Active when 'dev' profile is active
- `!test` - Active when 'test' profile is NOT active
- `dev & cloud` - Active when both 'dev' AND 'cloud' profiles are active
- `dev | test` - Active when either 'dev' OR 'test' profile is active
- `dev & !cloud` - Active when 'dev' is active AND 'cloud' is NOT active

## Usage Examples

### Basic Profile Activation

```dart
final env = StandardEnvironment();

// Set active profiles programmatically
(env as ConfigurableEnvironment).setActiveProfiles('dev', 'debug');

// Check active profiles
if (env.acceptsProfiles(Profiles.of(['dev']))) {
  print('Running in development mode');
}
```

### Property Resolution with Profiles

```yaml
# application.yaml
app:
  name: 'My App'
  environment: 'default'

# application-dev.yaml
app:
  environment: 'development'
  debug: true

# application-prod.yaml
app:
  environment: 'production'
  debug: false
```

```dart
final env = StandardEnvironment()
  ..propertySources.add(
    YamlPropertySource('application.yaml', loadYaml('application.yaml')),
  );

// With 'dev' profile active
print(env.getProperty('app.environment')); // 'development'
print(env.getProperty('app.debug', bool)); // true
```

### Conditional Configuration

```dart
@Configuration
class AppConfig {
  @Bean
  @Profile('dev')
  DataSource devDataSource() {
    return EmbeddedDatabaseBuilder()
        .setType(EmbeddedDatabaseType.H2)
        .build();
  }

  @Bean
  @Profile('!dev')
  DataSource dataSource() {
    return DataSourceBuilder.create()
        .url('jdbc:mysql://localhost:3306/mydb')
        .username('user')
        .password('password')
        .build();
  }
}
```

## Best Practices

1. **Profile Naming**: Use consistent, descriptive profile names (e.g., 'dev', 'test', 'prod')
2. **Default Configuration**: Provide sensible defaults in `application.yaml`
3. **Profile-specific Overrides**: Use profile-specific files (e.g., `application-dev.yaml`) for environment-specific overrides
4. **Minimal Active Profiles**: Activate only the profiles you need
5. **Documentation**: Document available profiles and their purposes

## See Also

- [ConfigurableEnvironment](configurable_environment/README.md) - For modifying the environment
- [PropertyResolver](property_resolver/README.md) - For property resolution functionality
- [Profiles](profiles/README.md) - For working with profile expressions
