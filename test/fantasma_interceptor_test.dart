import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fantasma_dio_flutter/fantasma_dio_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Dio dio;
  late Fantasma fantasma;

  setUp(() {
    dio = Dio();
    fantasma = Fantasma();
  });

  group('When calling an endpoint that has a custom handler the mocked response is returned', () {
    test('Reply with FantasmaResponseBody', () async {
      dio.interceptors.add(FantasmaInterceptor(fantasma, dio));

      fantasma.addCustomHandler((_) => FantasmaResponseBody.from('{}'));

      final response = await dio.get('/test');

      expect(response.data, '{}');
    });

    test('Reply with FantasmaResponseBody using fromBytes', () async {
      dio.interceptors.add(FantasmaInterceptor(fantasma, dio));

      final bytes = Uint8List.fromList([123, 34, 107, 101, 121, 34, 58, 34, 118, 97, 108, 117, 101, 34, 125]); // {"key":"value"}

      fantasma.addCustomHandler(
            (_) => FantasmaResponseBody.fromBytes(bytes),
      );

      final response = await dio.get('/test');

      expect(response.data, '{"key":"value"}');
    });

    test('Reply with FantasmaThrowableResponse', () async {
      final requestOptions = RequestOptions(path: '/test', method: 'GET');

      dio.interceptors.add(FantasmaInterceptor(fantasma, dio));

      // Mock the `addCustomHandler` to add a handler that returns a `FantasmaThrowableResponse`.
      fantasma.addCustomHandler(
        (_) => FantasmaThrowableResponse(DioException(requestOptions: requestOptions)),
        matchesPath: (path) => path == '/test',
        matchesMethod: (method) => method == 'GET',
      );

      try {
        // Expect an exception to be thrown during the request.
        await dio.get('/test');
        fail('Should have thrown a DioException');
      } catch (e) {
        // Assert that the exception is indeed a DioException.
        expect(e, isA<DioException>());
        final dioException = e as DioException;
        expect(dioException.requestOptions.path, '/test');
      }
    });
  });

  test('When shouldFailOnMissingMock = true, expect MockNotFoundException', () async {
    fantasma.shouldFailOnMissingMock = true;

    dio.interceptors.add(FantasmaInterceptor(fantasma, dio));

    fantasma.addCustomHandler((_) => FantasmaResponseBody.from('{}'), matchesPath: (path) => false);

    try {
      await dio.get('/test');
      fail('Expected exception to be thrown');
    } catch (e) {
      expect(e, isA<NoMockFoundException>());
    }
  });

  test('When no handler matches, call handler.next', () async {
    dio.interceptors.add(FantasmaInterceptor(fantasma, dio));

    // Simulate no handler being found by not adding any custom handlers
    final response = await dio.get('https://jsonplaceholder.typicode.com/todos/1');

    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
  });
}
