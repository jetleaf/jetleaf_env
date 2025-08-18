import '../../exceptions.dart';
import 'class_binding_schema.dart';
import 'object_binder.dart';
import 'binding_registry.dart';
import '../properties/property_mapper.dart';
import '../source/configuration_property_name.dart';
import '../source/configuration_property_sources.dart';
import 'bind_context.dart';
import 'bind_result.dart';
import 'bind_handler.dart';
import 'handler/no_unbound_elements_bind_handler.dart'; // For specific handler interaction

/// The core binder for configuration properties.
///
/// This class orchestrates the binding process, using [ConfigurationPropertySource]s
/// and a chain of [BindHandler]s. It relies on [BindingRegistry] for schema information.
class Binder {
  final ConfigurationPropertySources _sources;
  final BindHandler _bindHandler; // The head of the handler chain
  final PropertyMapper _propertyMapper;
  final BindingRegistry _registry;

  Binder(
    ConfigurationPropertySources sources, {
    required BindHandler bindHandler, // Must provide a chained handler
    PropertyMapper? propertyMapper,
    BindingRegistry? registry,
  })  : _sources = sources,
        _bindHandler = bindHandler,
        _propertyMapper = propertyMapper ?? DefaultPropertyMapper(),
        _registry = registry ?? BindingRegistry();

  /// Binds properties from the configured sources to an object of type [T].
  ///
  /// [name] is the base name/prefix for the properties to bind.
  /// [targetSchema] is the [ClassBindingSchema] describing the target object.
  BindResult<T> bind<T>(ConfigurationPropertyName name, ClassBindingSchema<T> targetSchema) {
    final context = BindContext(sources: _sources, currentName: name);
    final rootProperty = BindableProperty(name: name.originalName, type: T); // Represents the root object

    try {
      // 1. onStart: Allow handlers to short-circuit or prepare
      BindResult<T> result = _bindHandler.onStart(name, rootProperty, context);
      if (result.isBound) {
        _bindHandler.onFinish(name, rootProperty, context);
        return result;
      }

      // 2. Attempt to bind as a data object (nested properties)
      Object? boundObject = _bindDataObject(name, targetSchema, context);

      if (boundObject != null) {
        _bindHandler.onSuccess(name, rootProperty, boundObject as T, context);
        _bindHandler.onFinish(name, rootProperty, context);
        return BindResult.of(boundObject as T);
      }

      // If nothing was bound
      _bindHandler.onFinish(name, rootProperty, context);
      return BindResult.notBound();
    } on BindException catch (e) {
      _bindHandler.onFailure(name, rootProperty, e, context);
      _bindHandler.onFinish(name, rootProperty, context);
      rethrow;
    } catch (e) {
      final bindException = BindException('Unexpected error during binding: $e', name: name, targetType: T, cause: e is Exception ? e : null);
      _bindHandler.onFailure(name, rootProperty, bindException, context);
      _bindHandler.onFinish(name, rootProperty, context);
      rethrow;
    }
  }

  bool isPrimitiveType(Type type) {
    return type == String || type == int || type == double || type == bool || type == num;
  }

  /// Binds a data object (class instance) by populating its fields or using its constructor.
  Object? _bindDataObject<T>(ConfigurationPropertyName prefix, ClassBindingSchema<T> schema, BindContext parentContext) {
    final ObjectBinder<T>? objectBinder = _registry.getObjectBinder<T>(schema.type);
    if (objectBinder == null) {
      throw BindException('No ObjectBinder registered for type ${schema.type}. '
          'Ensure you have registered the schema and binder for this type.');
    }

    final Map<String, dynamic> boundValues = {};

    // If NoUnboundElementsBindHandler is in the chain, inform it about expected properties
    final noUnboundHandler = _bindHandler is NoUnboundElementsBindHandler ? _bindHandler : null;

    // Prioritize constructor binding if a constructor is defined in the schema
    if (schema.constructor != null) {
      for (final param in schema.constructor!.parameters) {
        final paramName = prefix.append(param.name);
        noUnboundHandler?.addExpectedProperty(paramName); // Inform handler about expected property

        Object? boundValue;
        if (param.isNested) {
          final nestedSchema = _registry.getSchema(param.type);
          if (nestedSchema == null) {
            throw BindException('No schema registered for nested type ${param.type} for property ${param.name}');
          }
          boundValue = _bindDataObject(paramName, nestedSchema, parentContext.forNested(paramName, null));
        } else {
          boundValue = _bindProperty(paramName, param, parentContext);
        }

        if (boundValue != null) {
          boundValues[param.name] = boundValue;
        } else if (param.isRequired) {
          throw BindException('Required constructor parameter "${param.name}" not found for ${paramName.originalName}');
        } else if (param.defaultValue != null) {
          boundValues[param.name] = _convertValue(param.defaultValue, param.type);
        }
      }
      return objectBinder.createInstance(boundValues);
    } else {
      // Fallback to field binding if no constructor binding
      final instance = objectBinder.createInstance({}); // Create empty instance first

      for (final entry in schema.properties.entries) {
        final propertyName = entry.key;
        final propertySchema = entry.value;
        final fullPropertyName = prefix.append(propertyName);
        noUnboundHandler?.addExpectedProperty(fullPropertyName); // Inform handler about expected property

        Object? boundValue;
        if (propertySchema.isNested) {
          final nestedSchema = _registry.getSchema(propertySchema.type);
          if (nestedSchema == null) {
            throw BindException('No schema registered for nested type ${propertySchema.type} for property ${propertySchema.name}');
          }
          boundValue = _bindDataObject(fullPropertyName, nestedSchema, parentContext.forNested(fullPropertyName, null));
        } else {
          boundValue = _bindProperty(fullPropertyName, propertySchema, parentContext);
        }

        if (boundValue != null) {
          objectBinder.setField(instance, propertyName, boundValue);
        } else if (propertySchema.defaultValue != null) {
          objectBinder.setField(instance, propertyName, _convertValue(propertySchema.defaultValue, propertySchema.type));
        }
      }
      return instance;
    }
  }

  /// Binds a single property value.
  Object? _bindProperty(ConfigurationPropertyName name, BindableProperty propertySchema, BindContext context) {
    // 1. onStart for this specific property
    BindResult<dynamic> result = _bindHandler.onStart(name, propertySchema, context);
    if (result.isBound) {
      _bindHandler.onSuccess(name, propertySchema, result.get(), context);
      return result.get();
    }

    // 2. Attempt to get direct value from sources
    Object? rawValue = _sources.getProperty(name);

    if (rawValue != null) {
      // 3. onData: Allow handlers to process/convert raw value
      result = _bindHandler.onData(name, propertySchema, rawValue, context);
      if (result.isBound) {
        _bindHandler.onSuccess(name, propertySchema, result.get(), context);
        return result.get();
      }

      // If not handled by onData, perform default conversion
      try {
        final convertedValue = _convertValue(rawValue, propertySchema.type);
        _bindHandler.onSuccess(name, propertySchema, convertedValue, context);
        return convertedValue;
      } on BindException catch (e) {
        _bindHandler.onFailure(name, propertySchema, e, context);
        rethrow;
      } catch (e) {
        final bindException = BindException('Conversion error for ${name.originalName}: $e', name: name, value: rawValue, targetType: propertySchema.type, cause: e is Exception ? e : null);
        _bindHandler.onFailure(name, propertySchema, bindException, context);
        rethrow;
      }
    }

    // If no value found and no default
    return null;
  }

  Object? _convertValue(Object? value, Type targetType) {
    if (value == null) return null;
    if (value.runtimeType == targetType) return value;

    // Basic type conversion (can be extended with a dedicated converter service)
    if (targetType == String) return value.toString();
    if (targetType == int) {
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }
    if (targetType == double) {
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }
    if (targetType == bool) {
      final lower = value.toString().toLowerCase();
      if (lower == 'true' || lower == 'false') return lower == 'true';
    }
    if (targetType == List<String>) { // Basic list conversion
      if (value is String) return value.split(',').map((e) => e.trim()).toList();
      if (value is List) return value.map((e) => e.toString()).toList();
    }
    // Add more complex conversions (e.g., List, Map, custom objects)
    // This is where a `BindConverter` or `ConversionService` would come in.

    throw BindException('Cannot convert value "$value" of type ${value.runtimeType} to $targetType', value: value, targetType: targetType);
  }
}