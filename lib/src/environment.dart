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

import 'property_resolver/property_resolver.dart';
import 'profiles/profiles.dart';

/// {@template environment}
/// A contract for accessing environment configuration and active profiles.
///
/// This interface builds on [PropertyResolver] and adds support for
/// profile activation and resolution—typically used for conditional
/// configuration based on the current runtime context.
///
/// Similar to Spring's `Environment`.
/// {@endtemplate}
abstract class Environment extends PropertyResolver {
  /// {@template environment_active_profiles}
  /// Returns the list of explicitly activated profiles.
  ///
  /// Profiles are logical configuration sets like `dev`, `prod`, etc.,
  /// typically used to load different beans or properties at runtime.
  ///
  /// If no profiles are explicitly active, [defaultProfiles] is used.
  /// {@endtemplate}
  List<String> getActiveProfiles();

  /// {@template environment_default_profiles}
  /// Returns the list of default profiles used when none are explicitly active.
  ///
  /// Example default: `['default']`
  /// {@endtemplate}
  List<String> getDefaultProfiles();

  /// {@template environment_matches_profiles}
  /// Returns true if the given profile expressions match the active or default profiles.
  ///
  /// This is a convenience shortcut for:
  /// ```dart
  /// environment.acceptsProfiles(Profiles.of(['dev', '!test']))
  /// ```
  /// {@endtemplate}
  bool matchesProfiles(List<String> profileExpressions) {
    return acceptsProfiles(Profiles.of(profileExpressions));
  }

  /// {@template environment_accepts_profiles}
  /// Returns true if the [Profiles] predicate matches the environment.
  ///
  /// This is the preferred way to evaluate profile logic.
  /// {@endtemplate}
  bool acceptsProfiles(Profiles profiles);
}