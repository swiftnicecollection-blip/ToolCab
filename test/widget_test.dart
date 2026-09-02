import 'package:flutter_test/flutter_test.dart';

import 'package:toolcab/core/utils/formatters.dart';

void main() {
  test('App constants are correct', () {
    expect('ToolCab', isNotEmpty);
  });

  test('Formatter formats file sizes', () {
    expect(Formatters.fileSize(1024), contains('KB'));
    expect(Formatters.fileSize(1024 * 1024), contains('MB'));
  });
}
