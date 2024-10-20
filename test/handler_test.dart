import 'package:dio/dio.dart';
import 'package:fantasma_dio_flutter/fantasma_dio_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockFantasmaResponse extends Mock implements IFantasmaResponse {}

void main() {
  group('RequestCustomHandler', () {
    late RequestOptions requestOptions;
    late MockFantasmaResponse mockFantasmaResponse;

    setUp(() {
      requestOptions = RequestOptions(path: '/test');
      mockFantasmaResponse = MockFantasmaResponse();
    });

    test('Matches when all conditions are satisfied', () {
      final handler = RequestCustomHandler(
            (_) => mockFantasmaResponse,
        matchesPath: (path) => path == '/test',
        matchesMethod: (method) => method == 'GET',
        matchesHeaders: (headers) => headers['Authorization'] == 'Bearer token',
        matchesQueryParameters: (queryParameters) => queryParameters['id'] == '123',
        matchesData: (data) => data == null,
      );

      final matches = handler.matches(
        path: '/test',
        method: 'GET',
        headers: {'Authorization': 'Bearer token'},
        queryParameters: {'id': '123'},
        data: null,
      );

      expect(matches, isTrue);
    });

    test('Does not match when conditions are not satisfied', () {
      final handler = RequestCustomHandler(
            (_) => mockFantasmaResponse,
        matchesPath: (path) => path == '/test',
        matchesMethod: (method) => method == 'POST', // Expecting POST instead of GET
        matchesHeaders: (headers) => headers['Authorization'] == 'Bearer token',
        matchesQueryParameters: (queryParameters) => queryParameters['id'] == '123',
        matchesData: (data) => data == null,
      );

      final matches = handler.matches(
        path: '/test',
        method: 'GET', // Method is GET, but handler expects POST
        headers: {'Authorization': 'Bearer token'},
        queryParameters: {'id': '123'},
        data: null,
      );

      expect(matches, isFalse);
    });

    test('Matches with default matcher when no specific matcher is provided', () {
      final handler = RequestCustomHandler(
            (_) => mockFantasmaResponse,
        matchesPath: (path) => path == '/test',
      );

      final matches = handler.matches(
        path: '/test',
        method: 'ANY_METHOD',
        headers: {},
        queryParameters: {},
        data: null,
      );

      expect(matches, isTrue);
    });

    test('Reply returns mock response with delay', () async {
      when(() => mockFantasmaResponse.delay).thenReturn(const Duration(milliseconds: 100));

      final handler = RequestCustomHandler((_) => mockFantasmaResponse);

      final stopwatch = Stopwatch()..start();
      await handler.reply(requestOptions);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('Reply returns mock response without delay', () async {
      when(() => mockFantasmaResponse.delay).thenReturn(null); // No delay

      final handler = RequestCustomHandler((_) => mockFantasmaResponse);

      final stopwatch = Stopwatch()..start();
      await handler.reply(requestOptions);

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should return quickly
    });
  });
}
