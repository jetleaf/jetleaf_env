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

import 'environment.dart';
import 'property_resolver/configurable_property_resolver.dart';
import 'property_source/mutable_property_sources.dart';

/// {@template configurable_environment}
/// A configurable extension of the [Environment] interface that allows mutation
/// of environment internals such as active profiles and property sources.
///
/// This interface exposes:
/// - `propertySources`: the mutable stack of [PropertySource]s used for
///   resolving properties.
/// - `setActiveProfiles`: to explicitly set the profiles considered active
///   during configuration.
/// - `setDefaultProfiles`: to define fallback profiles when no active profiles
///   are provided.
///
/// It is typically implemented by core environment types like
/// [AbstractEnvironment] and [StandardEnvironment].
///
/// ### Example usage:
///
/// ```dart
/// final env = StandardEnvironment();
///
/// env.setActiveProfiles(['dev']);
/// env.setDefaultProfiles(['default']);
///
/// env.propertySources.addLast(
///   MapPropertySource('app', {'debug': 'true'}),
/// );
///
/// print(env.getProperty('debug')); // true
/// ```
///
/// Use this interface when building frameworks or apps that require profile-based
/// configuration or dynamic property source injection.
/// {@endtemplate}
abstract class ConfigurableEnvironment extends Environment implements ConfigurablePropertyResolver {
  /// {@template configurable_environment_set_active_profiles}
  /// Replaces the current set of active profiles with the given list.
  ///
  /// Active profiles influence conditional configuration, especially with
  /// profile-based beans or property loading.
  ///
  /// Example:
  /// ```dart
  /// env.setActiveProfiles(['production']);
  /// ```
  /// {@endtemplate}
  void setActiveProfiles(List<String> profiles);

  /// {@template configurable_environment_set_default_profiles}
  /// Defines the default profiles to fall back on when no active profiles
  /// have been explicitly set.
  ///
  /// These are used only when `activeProfiles` is empty.
  ///
  /// Example:
  /// ```dart
  /// env.setDefaultProfiles(['default']);
  /// ```
  /// {@endtemplate}
  void setDefaultProfiles(List<String> profiles);

  /// {@template configurable_environment_add_active_profile}
  /// Adds an additional active profile to the current set.
  ///
  /// This can be used to programmatically enrich the environment at runtime.
  ///
  /// Example:
  /// ```dart
  /// env.addActiveProfile('integration-test');
  /// ```
  /// {@endtemplate}
  void addActiveProfile(String profile);

  /// {@template configurable_environment_get_system_properties}
  /// Returns the system properties available to the Dart VM (if any),
  /// such as those passed via `--define` or custom bootstrap logic.
  ///
  /// Keys and values are returned as `String`-`String` pairs.
  /// {@endtemplate}
  Map<String, String> getSystemProperties();

  /// {@template configurable_environment_get_system_environment}
  /// Returns the environment variables of the underlying OS.
  ///
  /// Keys and values are returned as `String`-`String` pairs.
  /// {@endtemplate}
  Map<String, String> getSystemEnvironment();

  /// {@template configurable_environment_merge}
  /// Merges another [ConfigurableEnvironment] into this one.
  ///
  /// Property sources, profiles, and system accessors may be merged
  /// based on implementation logic.
  ///
  /// This is useful when bootstrapping from parent contexts or templates.
  /// {@endtemplate}
  void merge(ConfigurableEnvironment parent);

  /// {@template configurable_environment_get_property_sources}
  /// Returns the [MutablePropertySources] backing this environment.
  ///
  /// This is functionally equivalent to accessing [propertySources],
  /// but may differ in subclasses that override it dynamically.
  /// {@endtemplate}
  MutablePropertySources getPropertySources();
}