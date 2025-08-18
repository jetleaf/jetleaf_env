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

import '../exceptions.dart';
import 'profiles.dart';

/// {@template profiles_parser}
/// Parses a list of profile expressions into a [Profiles] instance.
///
/// Supports logical expressions using:
/// - `&` (AND)
/// - `|` (OR)
/// - `!` (NOT)
/// - Parentheses for grouping
///
/// Example:
/// ```dart
/// final profiles = ProfilesParser.parse(['dev & !prod', 'test | staging']);
/// final isMatch = profiles.matches((name) => ['dev'].contains(name)); // true
/// ```
/// {@endtemplate}
class ProfilesParser {
  /// {@macro profiles_parser}
  static Profiles parse(List<String> expressions) {
    final parsed = expressions.map(_parseExpression).toList();
    return _CompositeProfiles(parsed);
  }

  static _Expr _parseExpression(String expression) {
    return _ExprParser(expression).parse();
  }
}

/// {@template expr}
/// Represents a logical expression that can evaluate itself
/// against an active profile function.
/// {@endtemplate}
abstract class _Expr {
  /// {@macro expr}
  bool eval(bool Function(String) isActive);
}

/// {@template composite_profiles}
/// A composite [Profiles] implementation backed by a list of [_Expr] trees.
/// Returns true if **any** expression evaluates to true.
/// {@endtemplate}
class _CompositeProfiles implements Profiles {
  final List<_Expr> expressions;

  /// {@macro composite_profiles}
  _CompositeProfiles(this.expressions);

  @override
  bool matches(bool Function(String) isProfileActive) {
    for (final expr in expressions) {
      if (expr.eval(isProfileActive)) return true;
    }
    return false;
  }
}

/// {@template expr_parser}
/// A recursive descent parser for logical profile expressions.
/// 
/// Supports:
/// - AND: `a & b`
/// - OR: `a | b`
/// - NOT: `!a`
/// - Grouping: `(a | b) & c`
/// {@endtemplate}
class _ExprParser {
  final String source;
  late final List<String> _tokens;
  int _pos = 0;

  /// {@macro expr_parser}
  _ExprParser(this.source) {
    _tokens = _tokenize(source);
  }

  /// Parses the full expression from the input source.
  _Expr parse() {
    final expr = _parseOr();
    if (_pos != _tokens.length) {
      throw EnvironmentParsingException('Unexpected token: ${_tokens[_pos]}');
    }
    return expr;
  }

  _Expr _parseOr() {
    var left = _parseAnd();
    while (_match('|')) {
      final right = _parseAnd();
      left = _OrExpr(left, right);
    }
    return left;
  }

  _Expr _parseAnd() {
    var left = _parseUnary();
    while (_match('&')) {
      final right = _parseUnary();
      left = _AndExpr(left, right);
    }
    return left;
  }

  _Expr _parseUnary() {
    if (_match('!')) {
      return _NotExpr(_parseUnary());
    }
    if (_match('(')) {
      final expr = _parseOr();
      if (!_match(')')) {
        throw EnvironmentParsingException('Expected )');
      }
      return expr;
    }
    return _LiteralExpr(_next());
  }

  bool _match(String expected) {
    if (_pos < _tokens.length && _tokens[_pos] == expected) {
      _pos++;
      return true;
    }
    return false;
  }

  String _next() {
    if (_pos >= _tokens.length) throw EnvironmentParsingException('Unexpected end of input');
    return _tokens[_pos++];
  }

  List<String> _tokenize(String src) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    for (int i = 0; i < src.length; i++) {
      final c = src[i];
      if ('()!&|'.contains(c)) {
        if (buffer.isNotEmpty) {
          tokens.add(buffer.toString().trim());
          buffer.clear();
        }
        tokens.add(c);
      } else {
        buffer.write(c);
      }
    }
    if (buffer.isNotEmpty) {
      tokens.add(buffer.toString().trim());
    }
    return tokens.where((t) => t.isNotEmpty).toList();
  }
}

/// {@template literal_expr}
/// A literal expression representing a single profile name.
/// {@endtemplate}
class _LiteralExpr extends _Expr {
  final String name;

  /// {@macro literal_expr}
  _LiteralExpr(this.name);

  @override
  bool eval(bool Function(String) isActive) => isActive(name);
}

/// {@template not_expr}
/// A logical NOT expression, inverts the result of its subexpression.
/// {@endtemplate}
class _NotExpr extends _Expr {
  final _Expr expr;

  /// {@macro not_expr}
  _NotExpr(this.expr);

  @override
  bool eval(bool Function(String) isActive) => !expr.eval(isActive);
}

/// {@template and_expr}
/// A logical AND expression combining two subexpressions.
/// {@endtemplate}
class _AndExpr extends _Expr {
  final _Expr left, right;

  /// {@macro and_expr}
  _AndExpr(this.left, this.right);

  @override
  bool eval(bool Function(String) isActive) => left.eval(isActive) && right.eval(isActive);
}

/// {@template or_expr}
/// A logical OR expression combining two subexpressions.
/// {@endtemplate}
class _OrExpr extends _Expr {
  final _Expr left, right;

  /// {@macro or_expr}
  _OrExpr(this.left, this.right);

  @override
  bool eval(bool Function(String) isActive) => left.eval(isActive) || right.eval(isActive);
}