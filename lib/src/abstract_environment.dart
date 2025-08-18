// ---------------------------------------------------------------------------
// 🍃 JetLeaf Framework - https://jetleaf.hapnium.com
//
// Copyright © 2025 Hapnium & JetLeaf Contributors. All rights reserved.
//
// This source file is part of the JetLeaf Framework and is protected
// under copyright law. You may not copy, modify, or distribute this file
// except in compliance with the JetLeaf license.
//
// For licensing terms, see the LICENSE file in the root of this project.
// ---------------------------------------------------------------------------
// 
// 🔧 Powered by Hapnium — the Dart backend engine 🍃

import 'package:jetleaf_lang/lang.dart';
import 'package:jetleaf_logging/logging.dart';
import 'package:jetleaf_utils/utils.dart';
import 'package:jetleaf_convert/convert.dart';
import 'package:meta/meta.dart';

import 'configurable_environment.dart';
import 'exceptions.dart';
import 'profiles/profiles.dart';
import 'property/jetleaf_properties.dart';
import 'property_resolver/configurable_property_resolver.dart';
import 'property_resolver/property_sources_property_resolver.dart';
import 'property_source/mutable_property_sources.dart';
import 'property_source/property_source.dart';

/// {@template abstract_environment}
/// Base class for creating environment implementations in JetLeaf.
///
/// `AbstractEnvironment` is a foundational implementation of [ConfigurableEnvironment]
/// that manages environment properties and profiles via:
/// - A [MutablePropertySources] collection,
/// - A [PropertySourcesPropertyResolver] for resolving properties,
/// - A [ConfigurableConversionService] for type conversions,
/// - and support for placeholder resolution and profile activation.
///
/// Subclasses should override [customizePropertySources] to register their own
/// sources, such as system properties, application config maps, or custom sources.
///
/// ### Example
/// ```dart
/// class MyEnvironment extends AbstractEnvironment {
///   @override
///   void customizePropertySources(MutablePropertySources sources) {
///     sources.addLast(MapPropertySource('my-config', {
///       'server.port': '8080',
///       'debug': 'true',
///     }));
///   }
/// }
///
/// void main() {
///   final env = MyEnvironment();
///   print(env.getProperty('server.port')); // 8080
/// }
/// ```
///
/// ### Profiles
/// JetLeaf supports both *active* and *default* profiles:
/// - Active profiles are those explicitly set using [setActiveProfiles] or [addActiveProfile].
/// - Default profiles are used when no active profile is set, and can be configured using [setDefaultProfiles].
///
/// A default profile name of `"default"` is always used unless overridden.
///
/// ### System properties and environment
/// You can access system properties and environment variables using [getSystemProperties]
/// and [getSystemEnvironment]. To suppress access to `System.getenv()`, set the
/// `jetleaf.getenv.ignore` flag via `JetLeafProperties`.
///
/// {@endtemplate}
abstract class AbstractEnvironment extends ConfigurableEnvironment {
  /// {@macro abstract_environment}
  AbstractEnvironment() : this.source(MutablePropertySources());

  /// Initializes the environment with a pre-created [MutablePropertySources] list.
  ///
  /// This is used internally and by subclasses who want to control the initial
  /// state of the sources.
  @protected
  AbstractEnvironment.source(MutablePropertySources propertySources) {
    _propertySources = propertySources;
    _propertyResolver = createPropertyResolver(propertySources);
    customizePropertySources(propertySources);
    _defaultProfiles.addAll(getReservedDefaultProfiles());
  }

  /// Creates a new [PropertySourcesPropertyResolver] using the given [propertySources].
  @protected
  ConfigurablePropertyResolver createPropertyResolver(MutablePropertySources propertySources) {
    return PropertySourcesPropertyResolver(propertySources);
  }

  /// Returns the configured [ConfigurablePropertyResolver].
  @protected
  ConfigurablePropertyResolver getPropertyResolver() => _propertyResolver;

  /// Returns the reserved default profiles — by default, this is just `"default"`.
  @protected
  Set<String> getReservedDefaultProfiles() => <String>{RESERVED_DEFAULT_PROFILE_NAME};

  /// Property name to disable calls to `System.getenv()`.
  static final String IGNORE_GETENV_PROPERTY_NAME = "jetleaf.getenv.ignore";

  /// Property name used to activate profiles at runtime.
  static final String ACTIVE_PROFILES_PROPERTY_NAME = "jetleaf.profiles.active";

  /// Property name used to declare default profiles.
  static final String DEFAULT_PROFILES_PROPERTY_NAME = "jetleaf.profiles.default";

  /// Reserved profile name always used if no active/default profile is defined.
  static final String RESERVED_DEFAULT_PROFILE_NAME = "default";

  @protected
  final Log logger = LogFactory.getLog(AbstractEnvironment);

  final Set<String> _activeProfiles = <String>{};
  final Set<String> _defaultProfiles = <String>{};

  late final MutablePropertySources _propertySources;
  late final ConfigurablePropertyResolver _propertyResolver;

  /// Checks whether system environment access should be suppressed.
  ///
  /// Reads the [IGNORE_GETENV_PROPERTY_NAME] flag using [JetLeafProperties].
  ///
  /// If true, [getSystemEnvironment] will return an empty map.
  @protected
  bool suppressGetenvAccess() {
    return JetLeafProperties.getFlag(IGNORE_GETENV_PROPERTY_NAME);
  }

  /// Validates that a profile name is not empty, null, or starts with `'!'`.
  ///
  /// Throws [IllegalArgumentException] if invalid.
  @protected
  void validateProfile(String profile) {
    if (!StringUtils.hasText(profile)) {
      throw IllegalArgumentException("Invalid profile [$profile]: must contain text");
    }
    if (profile.startsWith('!')) {
      throw IllegalArgumentException("Invalid profile [$profile]: must not begin with ! operator");
    }
  }

  /// Determines whether the given [profile] is currently active.
  ///
  /// If no active profiles are set, it checks the default profiles instead.
  @protected
  bool isProfileActive(String profile) {
    validateProfile(profile);
    Set<String> currentActiveProfiles = doGetActiveProfiles();
    return (currentActiveProfiles.contains(profile) ||
        (currentActiveProfiles.isEmpty && doGetDefaultProfiles().contains(profile)));
  }

  /// Internal resolution of active profiles using [ACTIVE_PROFILES_PROPERTY_NAME].
  ///
  /// If no profiles are set, it reads from properties and adds them.
  @protected
  Set<String> doGetActiveProfiles() {
    return synchronized(_activeProfiles, () {
      if (_activeProfiles.isEmpty) {
        String? profiles = doGetActiveProfilesProperty();
        if (StringUtils.hasText(profiles)) {
          setActiveProfiles(StringUtils.commaDelimitedListToStringArray(StringUtils.trimAllWhitespace(profiles!)));
        }
      }
      return _activeProfiles;
    });
  }

  /// Reads the `jetleaf.profiles.active` property.
  @protected
  String? doGetActiveProfilesProperty() {
    return getProperty(ACTIVE_PROFILES_PROPERTY_NAME);
  }

  /// Resolves the set of default profiles.
  ///
  /// If the current set only includes the reserved `"default"` profile,
  /// this attempts to read and apply the `jetleaf.profiles.default` property.
  @protected
  Set<String> doGetDefaultProfiles() {
    return synchronized(_defaultProfiles, () {
      if (_defaultProfiles.equals(getReservedDefaultProfiles())) {
        String? profiles = doGetDefaultProfilesProperty();
        if (StringUtils.hasText(profiles)) {
          setDefaultProfiles(StringUtils.commaDelimitedListToStringArray(StringUtils.trimAllWhitespace(profiles!)));
        }
      }
      return _defaultProfiles;
    });
  }

  /// Reads the `jetleaf.profiles.default` property.
  @protected
  String? doGetDefaultProfilesProperty() {
    return getProperty(DEFAULT_PROFILES_PROPERTY_NAME);
  }

  /// {@template customize_property_sources}
  /// Called during construction to allow subclasses to register default property sources.
  ///
  /// Override this method in your custom environment implementation to add
  /// system properties, YAML or map-based configuration sources, etc.
  ///
  /// ### Example
  /// ```dart
  /// @override
  /// void customizePropertySources(MutablePropertySources sources) {
  ///   sources.addLast(MapPropertySource('app', {
  ///     'env': 'production',
  ///     'debug': 'false',
  ///   }));
  /// }
  /// ```
  /// {@endtemplate}
  void customizePropertySources(MutablePropertySources sources);

  @override
	List<String> getActiveProfiles() {
		return doGetActiveProfiles().toList();
	}

  @override
	void setActiveProfiles(List<String> profiles) {
		if (logger.getIsDebugEnabled()) {
			logger.debug("Activating profiles ${profiles.join(", ")}");
		}
		synchronized(_activeProfiles, () {
			_activeProfiles.clear();
			for (String profile in profiles) {
				validateProfile(profile);
				_activeProfiles.add(profile);
			}
		});
	}

	@override
	void addActiveProfile(String profile) {
		if (logger.getIsDebugEnabled()) {
			logger.debug("Activating profile '$profile'");
		}
		validateProfile(profile);
		doGetActiveProfiles();
		synchronized(_activeProfiles, () {
			_activeProfiles.add(profile);
		});
	}

	@override
	List<String> getDefaultProfiles() {
		return doGetDefaultProfiles().toList();
	}

	/// Specify the set of profiles to be made active by default if no other profiles
	/// are explicitly made active through {@link #setActiveProfiles}.
	/// <p>Calling this method removes overrides any reserved default profiles
	/// that may have been added during construction of the environment.
	/// @see #AbstractEnvironment()
	/// @see #getReservedDefaultProfiles()
	@override
	void setDefaultProfiles(List<String> profiles) {
		synchronized(_defaultProfiles, () {
			_defaultProfiles.clear();
			for (String profile in profiles) {
				validateProfile(profile);
				_defaultProfiles.add(profile);
			}
		});
	}

	@override
	bool acceptsProfiles(Profiles profiles) {
		return profiles.matches((profile) => isProfileActive(profile));
	}

	@override
	MutablePropertySources getPropertySources() {
		return _propertySources;
	}

	@override
	Map<String, String> getSystemProperties() {
		return System.getProperties();
	}

	@override
	Map<String, String> getSystemEnvironment() {
		if (suppressGetenvAccess()) {
			return {};
		}
		return System.getEnv();
	}

	@override
	void merge(ConfigurableEnvironment parent) {
		for (PropertySource<dynamic> ps in parent.getPropertySources()) {
			if (!_propertySources.containsName(ps.getName())) {
				_propertySources.addLast(ps);
			}
		}
		List<String> parentActiveProfiles = parent.getActiveProfiles();
		if (parentActiveProfiles.isNotEmpty) {
			synchronized(_activeProfiles, () {
				_activeProfiles.addAll(parentActiveProfiles);
			});
		}
		List<String> parentDefaultProfiles = parent.getDefaultProfiles();
		if (parentDefaultProfiles.isNotEmpty) {
			synchronized(_defaultProfiles, () {
				_defaultProfiles.remove(RESERVED_DEFAULT_PROFILE_NAME);
				_defaultProfiles.addAll(parentDefaultProfiles);
			});
		}
	}


	//---------------------------------------------------------------------
	// Implementation of ConfigurablePropertyResolver interface
	//---------------------------------------------------------------------

	@override
	ConfigurableConversionService getConversionService() {
		return _propertyResolver.getConversionService();
	}

	@override
	void setConversionService(ConfigurableConversionService conversionService) {
		_propertyResolver.setConversionService(conversionService);
	}

	@override
	void setPlaceholderPrefix(String placeholderPrefix) {
		_propertyResolver.setPlaceholderPrefix(placeholderPrefix);
	}

	@override
	void setPlaceholderSuffix(String placeholderSuffix) {
		_propertyResolver.setPlaceholderSuffix(placeholderSuffix);
	}

	@override
	void setValueSeparator(String? valueSeparator) {
		if (valueSeparator != null) {
			_propertyResolver.setValueSeparator(valueSeparator);
		}
	}

	@override
	void setEscapeCharacter(Character? escapeCharacter) {
		if (escapeCharacter != null) {
			_propertyResolver.setEscapeCharacter(escapeCharacter);
		}
	}

	@override
	void setIgnoreUnresolvableNestedPlaceholders(bool ignoreUnresolvableNestedPlaceholders) {
		_propertyResolver.setIgnoreUnresolvableNestedPlaceholders(ignoreUnresolvableNestedPlaceholders);
	}

	@override
	void setRequiredProperties(List<String> requiredProperties) {
		_propertyResolver.setRequiredProperties(requiredProperties);
	}

	@override
	void validateRequiredProperties() {
		_propertyResolver.validateRequiredProperties();
	}


	//---------------------------------------------------------------------
	// Implementation of PropertyResolver interface
	//---------------------------------------------------------------------

	@override
	bool containsProperty(String key) {
		return _propertyResolver.containsProperty(key);
	}

	@override
	String? getProperty(String key) {
		return _propertyResolver.getProperty(key);
	}

	@override
	String getPropertyWithDefault(String key, String defaultValue) {
		return _propertyResolver.getPropertyWithDefault(key, defaultValue);
	}

	@override
	T? getPropertyAs<T>(String key, Class<T> targetType) {
		return _propertyResolver.getPropertyAs(key, targetType);
	}

	@override
	T getPropertyAsWithDefault<T>(String key, Class<T> targetType, T defaultValue) {
		return _propertyResolver.getPropertyAsWithDefault(key, targetType, defaultValue);
	}

	@override
	String getRequiredProperty(String key) {
		return _propertyResolver.getRequiredProperty(key);
	}

	@override
	T getRequiredPropertyAs<T>(String key, Class<T> targetType) {
		return _propertyResolver.getRequiredPropertyAs(key, targetType);
	}

	@override
	String resolvePlaceholders(String text) {
		return _propertyResolver.resolvePlaceholders(text);
	}

	@override
	String resolveRequiredPlaceholders(String text) {
		return _propertyResolver.resolveRequiredPlaceholders(text);
	}

	@override
	String toString() {
		return "${getClass().getSimpleName()} {activeProfiles= $_activeProfiles, defaultProfiles= $_defaultProfiles, propertySources= $_propertySources}";
	}
}