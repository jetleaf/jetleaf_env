# JetLeaf Environment API Reference

Welcome to the API documentation for the JetLeaf Environment library. This documentation provides detailed information about the classes, methods, and types available in the package.

## Core Components

### Environment
- [Environment](environment/README.md) - The core interface for property resolution and profile operations
- [ConfigurableEnvironment](configurable_environment/README.md) - Extends `Environment` with methods for modifying the environment
- [StandardEnvironment](standard_environment/README.md) - Default implementation of `ConfigurableEnvironment`

### Property Sources
- [PropertySource](property_source/README.md) - Abstraction for property sources
- [EnumerablePropertySource](enumerable_property_source/README.md) - Base class for property sources that can enumerate property names
- [MapPropertySource](mapproperty_source/README.md) - Property source backed by a Map

### Property Resolution
- [PropertyResolver](property_resolver/README.md) - Interface for resolving properties
- [ConfigurablePropertyResolver](configurable_property_resolver/README.md) - Extends `PropertyResolver` with methods for modifying resolution behavior

### Profiles
- [Profiles](profiles/README.md) - Profile utilities and constants
- [ActiveProfiles](active_profiles/README.md) - Annotation for specifying active profiles

### Command Line
- [CommandLinePropertySource](command_line/README.md) - Property source for command line arguments
- [SimpleCommandLineArgsParser](command_line/simple_command_line_args_parser/README.md) - Parser for command line arguments

## Getting Started

### Basic Usage

```dart
import 'package:jetleaf_env/jetleaf_env.dart';

void main() {
  // Create a new environment
  final env = StandardEnvironment();
  
  // Access properties
  final value = env.getProperty('some.property');
  
  // Check active profiles
  if (env.acceptsProfiles({'dev', 'test'})) {
    // Development or test specific code
  }
}
```

### Configuration

```dart
final env = StandardEnvironment()
  ..propertySources.add(
    MapPropertySource('custom', {
      'app.name': 'My App',
      'app.version': '1.0.0',
    }),
  );
```

## Advanced Topics

### Property Placeholders

```yaml
database:
  host: 'localhost'
  port: 5432
  url: 'jdbc:postgresql://${database.host}:${database.port}/mydb'
```

### Profile-specific Properties

```yaml
# application.yaml
app:
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

## Best Practices

1. **Profile Naming**: Use clear, descriptive profile names (e.g., 'dev', 'test', 'prod')
2. **Property Organization**: Group related properties using dot notation (e.g., 'database.url', 'server.port')
3. **Sensitive Data**: Never commit sensitive data in property files
4. **Default Values**: Always provide sensible default values
5. **Documentation**: Document available properties and their purposes

## See Also

- [JetLeaf Framework](https://github.com/jetleaf/jetleaf) - The main framework
- [JetLeaf Core](https://github.com/jetleaf/jetleaf_core) - Core utilities
- [JetLeaf Boot](https://github.com/jetleaf/jetleaf_boot) - Application bootstrapping
