The Fantasma Dio Flutter package offers support for mocking error responses and http responses
via a custom Dio interceptor. 

The idea when making this interceptor was to have as much flexibility in mind. 

- **Pattern matching** This package allows to dynamically match the request options, thereby supporting path parameters.
- **Support for multiple Dio instances** The interceptor can be registered to multiple Dio instances

## Usage

```dart
final dio = Dio();
final fantasma = Fantasma();
fantasma.addCustomHandler(
    (requestOptions) => FantasmaResponseBody.from('Mock Response'),
    matchesPath: (path) => path == '/test',
    matchesMethod: (method) => method == 'GET',
);

final interceptor = FantasmaInterceptor(fantasma, dio);
dio.interceptors.add(FantasmaInterceptor(fantasma, dio));

dio.get('/test');
```
