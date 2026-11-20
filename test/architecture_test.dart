import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _package = 'tinla';

/// One import/export directive found in a source file.
typedef ImportEntry = ({String file, String target});

final _directive = RegExp(r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""");

/// Resolves [target] (as written in [file]) to a lib-relative path, or null
/// when it is a dart: or external package import.
String? _resolveInternal(String file, String target) {
  const prefix = 'package:$_package/';
  if (target.startsWith(prefix)) return target.substring(prefix.length);
  if (target.contains(':')) return null;
  final parts = file.split('/')..removeLast();
  for (final segment in target.split('/')) {
    if (segment == '..') {
      if (parts.isNotEmpty) parts.removeLast();
    } else if (segment != '.') {
      parts.add(segment);
    }
  }
  return parts.join('/');
}

bool _isInternalIn(String file, String target, String layer) =>
    _resolveInternal(file, target)?.startsWith('$layer/') ?? false;

/// Returns one message per violation of the layering rule.
/// File paths are lib-relative with forward slashes, e.g. `domain/a.dart`.
List<String> findViolations(Iterable<ImportEntry> entries) {
  final violations = <String>[];
  for (final (:file, :target) in entries) {
    if (file == 'main.dart') continue;
    final isDart = target.startsWith('dart:');
    final isPackage =
        target.startsWith('package:') &&
        !target.startsWith('package:$_package/');
    String? reason;
    if (file.startsWith('domain/')) {
      if (!isDart && !_isInternalIn(file, target, 'domain')) {
        reason = 'domain may import only dart:* and domain files';
      }
    } else if (file.startsWith('data/')) {
      if (_isInternalIn(file, target, 'presentation')) {
        reason = 'data must not import presentation';
      } else if (!isDart &&
          !isPackage &&
          !_isInternalIn(file, target, 'domain') &&
          !_isInternalIn(file, target, 'data')) {
        reason = 'data may import domain, data, dart:* and packages';
      }
    } else if (file.startsWith('presentation/')) {
      final isWiring = file == 'presentation/providers.dart';
      final isAllowedPackage =
          target.startsWith('package:flutter/') ||
          target.startsWith('package:material_ui/') ||
          target.startsWith('package:flutter_riverpod/');
      if (_isInternalIn(file, target, 'data')) {
        if (!isWiring) {
          reason = 'only presentation/providers.dart may import data';
        }
      } else if (!isDart &&
          !isAllowedPackage &&
          !_isInternalIn(file, target, 'domain') &&
          !_isInternalIn(file, target, 'presentation')) {
        reason =
            'presentation may import domain, dart:*, flutter, material_ui, '
            'flutter_riverpod';
      }
    }
    if (reason != null) violations.add('lib/$file imports "$target": $reason');
  }
  return violations;
}

List<ImportEntry> _scanLib() {
  final entries = <ImportEntry>[];
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relative = entity.path.replaceAll(r'\', '/').substring('lib/'.length);
    for (final line in entity.readAsLinesSync()) {
      final match = _directive.firstMatch(line);
      if (match != null) entries.add((file: relative, target: match.group(1)!));
    }
  }
  return entries;
}

void main() {
  final entries = _scanLib();
  List<String> forLayer(String layer) =>
      findViolations(entries.where((e) => e.file.startsWith('$layer/')));

  test('scan finds source files, including domain', () {
    expect(entries, isNotEmpty);
    expect(entries.any((e) => e.file.startsWith('domain/')), isTrue);
  });
  test('domain imports only dart:* and domain', () {
    expect(forLayer('domain'), isEmpty);
  });
  test('data never imports presentation', () {
    expect(forLayer('data'), isEmpty);
  });
  test('presentation never imports data (except providers.dart)', () {
    expect(forLayer('presentation'), isEmpty);
  });

  group('rule detector', () {
    test('flags domain importing flutter or data', () {
      final result = findViolations([
        (file: 'domain/a.dart', target: 'package:flutter/widgets.dart'),
        (file: 'domain/b.dart', target: '../data/x.dart'),
        (file: 'domain/c.dart', target: 'dart:math'),
        (file: 'domain/d.dart', target: 'entities/e.dart'),
        (file: 'domain/e.dart', target: 'package:tinla/domain/f.dart'),
      ]);
      expect(result, hasLength(2));
      expect(result.first, contains('lib/domain/a.dart'));
      expect(result.first, contains('package:flutter/widgets.dart'));
    });
    test('flags presentation importing data except providers.dart', () {
      final result = findViolations([
        (
          file: 'presentation/screen.dart',
          target: 'package:tinla/data/r.dart',
        ),
        (file: 'presentation/x/y.dart', target: '../../data/r.dart'),
        (file: 'presentation/providers.dart', target: '../data/r.dart'),
        (
          file: 'presentation/ok.dart',
          target: 'package:flutter_riverpod/flutter_riverpod.dart',
        ),
      ]);
      expect(result, hasLength(2));
      expect(result.first, contains('lib/presentation/screen.dart'));
    });
    test('flags data importing presentation, exempts main.dart', () {
      final result = findViolations([
        (file: 'data/r.dart', target: '../presentation/p.dart'),
        (file: 'data/ok.dart', target: 'package:record/record.dart'),
        (file: 'main.dart', target: 'package:tinla/data/r.dart'),
      ]);
      expect(result, hasLength(1));
      expect(result.first, contains('lib/data/r.dart'));
    });
  });
}
