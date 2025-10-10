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

import 'package:jetleaf_env/env.dart';
import 'package:jetleaf_env/property.dart';
import 'package:test/test.dart';

void main() {
  group('StandardEnvironment', () {
    late GlobalEnvironment env;

    setUp(() {
      env = GlobalEnvironment();
      env.getPropertySources().addFirst(MapPropertySource('testSource', {
        'app.name': 'JetLeaf',
        'app.version': '1.0.0',
        'server.port': '8080',
        'greeting': 'Hello, \${app.name}!',
        'welcome': 'Welcome to @app.name@ version \${app.version}',
      }));
    });

    test('containsProperty returns true for existing key', () {
      expect(env.containsProperty('app.name'), isTrue);
    });

    test('getProperty returns correct value', () {
      expect(env.getProperty('app.name'), equals('JetLeaf'));
    });

    test('getRequiredProperty throws on missing key', () {
      expect(() => env.getRequiredProperty('missing.key'), throwsA(isA<Exception>()));
    });

    test('resolvePlaceholders resolves nested placeholders', () {
      final resolved = env.resolvePlaceholders(r'${greeting}');
      expect(resolved, equals('Hello, JetLeaf!'));
    });

    test('resolvePlaceholders with @ syntax', () {
      final resolved = env.resolvePlaceholders(r'@app.name@');
      expect(resolved, equals('JetLeaf'));
    });

    test('resolvePlaceholders with mixed syntax', () {
      final resolved = env.resolvePlaceholders(r'Welcome: @app.name@ v${app.version}');
      expect(resolved, equals('Welcome: JetLeaf v1.0.0'));
    });

    test('activeProfiles is initially empty', () {
      expect(env.getActiveProfiles(), isEmpty);
    });

    test('can set active and default profiles', () {
      env.setDefaultProfiles(['dev']);
      env.setActiveProfiles(['prod']);
      expect(env.getActiveProfiles(), contains('prod'));
      expect(env.getDefaultProfiles(), contains('dev'));
    });
  });
}