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

/// 🍃 **JetLeaf Property System**
///
/// This library provides the core infrastructure for resolving and managing
/// configuration values within the JetLeaf Framework.
///
/// It exposes the property resolution pipeline, property sources, and
/// annotations used to bind configuration into application components.
///
///
/// ## 🔍 What This Library Does
///
/// - Resolves configuration values from multiple sources
/// - Normalizes and queries hierarchical properties
/// - Allows custom property sources to be registered
/// - Supports strongly-typed configuration binding
///
///
/// ## 📦 Exports Overview
///
/// ### 🧩 Property Resolution
///
/// - `PropertyResolver` — contract for resolving property values
/// - `AbstractPropertyResolver` — base implementation with shared logic
/// - `PropertySourcesPropertyResolver` — resolver backed by multiple sources
///
///
/// ### 🏗 Property Sources
///
/// - `_PropertySource` — internal base representation
/// - `PropertySource` — public abstraction of a configuration source
///
/// Examples of property sources may include:
/// - environment variables
/// - system properties
/// - configuration files
/// - in-memory definitions
///
///
/// ### 🔒 Configuration Binding
///
/// - `ConfigurationProperties` — annotation for binding structured config
/// - `JetLeafProperty` — metadata for defining individual config fields
///
/// Used to map external configuration into typed classes, similar to:
/// ```dart
/// @ConfigurationProperties(prefix: 'server')
/// class ServerConfig {
///   final int port;
///
///   const ServerConfig({required this.port});
/// }
/// ```
///
///
/// ## ✅ Intended Usage
///
/// Importing this library grants access to the JetLeaf configuration system:
///
/// ```dart
/// import 'package:jetleaf_env/property.dart';
///
/// final value = resolver.getProperty('app.name');
/// ```
///
/// Typically, applications will not implement resolvers directly—
/// instead, JetLeaf assembles them through the environment layer.
library;

export 'src/property_resolver/abstract_property_resolver.dart';
export 'src/property_resolver/property_sources_property_resolver.dart';
export 'src/property_resolver/property_resolver.dart';

export 'src/property_source/_property_source.dart';
export 'src/property_source/property_source.dart';

export 'src/property/configuration_properties.dart';
export 'src/property/jetleaf_property.dart';