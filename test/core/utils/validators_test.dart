import 'package:flutter_test/flutter_test.dart';
import 'package:toolcab/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid emails', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('a.b+c@sub.domain.co'), isNull);
    });

    test('returns error for invalid emails', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('user@'), isNotNull);
      expect(Validators.email('@example.com'), isNotNull);
    });
  });

  group('Validators.phone', () {
    test('returns null for valid phone numbers', () {
      expect(Validators.phone('+1234567890'), isNull);
      expect(Validators.phone('1234567890'), isNull);
    });

    test('returns error for invalid phone numbers', () {
      expect(Validators.phone(''), isNotNull);
      expect(Validators.phone(null), isNotNull);
      expect(Validators.phone('abc'), isNotNull);
      expect(Validators.phone('123'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('returns null for valid passwords', () {
      expect(Validators.password('abcdef'), isNull);
    });

    test('returns error for short passwords', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
      expect(Validators.password('abc'), isNotNull);
    });
  });

  group('Validators.required', () {
    test('returns null for non-empty values', () {
      expect(Validators.required('value'), isNull);
    });

    test('returns error for empty values', () {
      expect(Validators.required(''), isNotNull);
      expect(Validators.required(null), isNotNull);
    });
  });
}
