# Profiles

## Overview
Profiles in JetLeaf Environment provide a powerful way to conditionally activate different sets of configuration based on the current runtime context. This is particularly useful for managing environment-specific settings like development, testing, and production configurations.

## Profile Expressions

### Basic Syntax

- `profile` - Matches when the profile is active
- `!profile` - Logical NOT (matches when profile is not active)
- `profile1 & profile2` - Logical AND (both profiles must be active)
- `profile1 | profile2` - Logical OR (either profile can be active)
- `(expression)` - Grouping with parentheses

### Examples

```dart
// Simple profile check
Profiles.of(['dev']).matches(isProfileActive);

// Negation
Profiles.of(['!prod']).matches(isProfileActive);

// Logical AND
Profiles.of(['dev & debug']).matches(isProfileActive);

// Logical OR
Profiles.of(['dev | test']).matches(isProfileActive);

// Complex expression
Profiles.of(['(dev | test) & !cloud']).matches(isProfileActive);
```

## Core API

### `Profiles` Class

The main class for working with profile expressions.

#### `static Profiles of(List<String> expressions)`

Creates a new `Profiles` instance from a list of profile expressions.

**Parameters**:
- `expressions`: List of profile expressions to parse

**Returns**: A new `Profiles` instance

**Example**:
```dart
final profiles = Profiles.of(['dev', '!test']);
```

#### `bool matches(bool Function(String) isProfileActive)`

Evaluates the profile expressions against a test function.

**Parameters**:
- `isProfileActive`: A function that returns `true` if a given profile is active

**Returns**: `true` if the profile expressions match the active profiles

**Example**:
```dart
final activeProfiles = {'dev', 'debug'};
final matches = Profiles.of(['dev & debug'])
    .matches((p) => activeProfiles.contains(p)); // true
```

## Profile Activation

### Programmatic Activation

```dart
final env = StandardEnvironment();

// Set active profiles
(env as ConfigurableEnvironment).setActiveProfiles('dev', 'debug');

// Check profile activation
if (env.acceptsProfiles(Profiles.of(['dev']))) {
    // Dev-specific configuration
}
```

### Profile-Specific Configuration

Profile-specific properties can be defined in separate files:

```yaml
# application.yaml
app:
  environment: default
  debug: false

# application-dev.yaml
app:
  environment: development
  debug: true

# application-prod.yaml
app:
  environment: production
  debug: false
```

## Best Practices

1. **Use Descriptive Names**: Choose clear, meaningful profile names (e.g., 'dev', 'test', 'prod', 'cloud')
2. **Keep It Simple**: Prefer simple profile expressions when possible
3. **Default Profile**: Always provide a default configuration
4. **Document Profiles**: Document available profiles and their purposes
5. **Test Profile Activation**: Test profile activation in different environments

## Advanced Usage

### Custom Profile Resolver

```dart
class CustomProfileResolver {
  final Set<String> activeProfiles;
  
  CustomProfileResolver(this.activeProfiles);
  
  bool isActive(String profile) {
    // Custom profile resolution logic
    return activeProfiles.contains(profile);
  }
}

// Usage
final resolver = CustomProfileResolver({'dev', 'debug'});
final matches = Profiles.of(['dev & debug'])
    .matches(resolver.isActive);
```

### Dynamic Profile Activation

```dart
void activateProfiles(ConfigurableEnvironment env) {
  // Activate profiles based on system properties
  if (System.getProperty('spring.profiles.active') != null) {
    env.setActiveProfiles(
      ...System.getProperty('spring.profiles.active').split(',')
    );
  }
  
  // Add default profile if none active
  if (env.getActiveProfiles().isEmpty) {
    env.setDefaultProfiles(['default']);
  }
}
```

## Common Patterns

### Feature Flags

```yaml
# application.yaml
features:
  newDashboard: false
  experimentalApi: false

# application-dev.yaml
features:
  newDashboard: true
  experimentalApi: true
```

### Environment-Specific Configuration

```yaml
# application-dev.yaml
server:
  port: 8080
  host: localhost

datasource:
  url: jdbc:h2:mem:devdb
  username: sa
  password: ''

# application-prod.yaml
server:
  port: 80
  host: 0.0.0.0

datasource:
  url: jdbc:postgresql://prod-db:5432/mydb
  username: ${DB_USER}
  password: ${DB_PASSWORD}
```

## Troubleshooting

### Common Issues

1. **Profile Not Activating**
   - Check for typos in profile names
   - Verify the profile is being set before configuration classes are processed
   - Ensure `setActiveProfiles()` is called before the application context is refreshed

2. **Unexpected Profile Activation**
   - Check for default profiles that might be activating
   - Verify profile expressions for logical errors
   - Check system properties and environment variables that might affect profile activation

## See Also

- [Environment](environment/README.md) - For working with profiles in the environment
- [ConfigurableEnvironment](configurable_environment/README.md) - For programmatic profile management
- [PropertySource](property_source/README.md) - For profile-specific property sources
