import 'package:flutter_test/flutter_test.dart';
import 'package:fantasma_dio_flutter/fantasma_dio_flutter.dart';

void main() {
  late Fantasma fantasma;

  setUp(() {
    fantasma = Fantasma();
  });

  test('Should add a handler and find it based on path and method', () {
    // Arrange
    fantasma.addCustomHandler(
      (requestOptions) => FantasmaResponseBody.from('Mock Response'),
      matchesPath: (path) => path == '/test',
      matchesMethod: (method) => method == 'GET',
    );

    // Act
    final handler = fantasma.findHandler(
      path: '/test',
      method: 'GET',
      headers: {},
      queryParameters: {},
      data: null,
    );

    // Assert
    expect(handler, isNotNull);
  });

  test('Should not find a handler when path does not match', () {
    // Arrange
    fantasma.addCustomHandler(
      (requestOptions) => FantasmaResponseBody.from('Mock Response'),
      matchesPath: (path) => path == '/test',
      matchesMethod: (method) => method == 'GET',
    );

    // Act
    final handler = fantasma.findHandler(
      path: '/unknown-path',
      method: 'GET',
      headers: {},
      queryParameters: {},
      data: null,
    );

    // Assert
    expect(handler, isNull);
  });

  test('Should match based on headers and query parameters', () {
    // Arrange
    fantasma.addCustomHandler(
      (requestOptions) => FantasmaResponseBody.from('Mock Response'),
      matchesHeaders: (headers) => headers['Authorization'] == 'Bearer mockToken',
      matchesQueryParameters: (queryParameters) => queryParameters['page'] == '1',
    );

    // Act
    final handler = fantasma.findHandler(
      path: '/test',
      method: 'GET',
      headers: {'Authorization': 'Bearer mockToken'},
      queryParameters: {'page': '1'},
      data: null,
    );

    // Assert
    expect(handler, isNotNull);
  });

  test('Should not match if headers or query parameters do not match', () {
    // Arrange
    fantasma.addCustomHandler(
      (requestOptions) => FantasmaResponseBody.from('Mock Response'),
      matchesHeaders: (headers) => headers['Authorization'] == 'Bearer mockToken',
      matchesQueryParameters: (queryParameters) => queryParameters['page'] == '1',
    );

    // Act
    final handler = fantasma.findHandler(
      path: '/test',
      method: 'GET',
      headers: {'Authorization': 'WrongToken'},
      queryParameters: {'page': '2'},
      data: null,
    );

    // Assert
    expect(handler, isNull);
  });
}
