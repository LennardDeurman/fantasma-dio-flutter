import 'package:dio/dio.dart';

import 'response.dart';
import 'fantasma.dart';

class NoMockFoundException extends DioException {
  NoMockFoundException({required super.requestOptions});
}

class FantasmaInterceptor extends Interceptor {
  const FantasmaInterceptor(this._fantasma, this._dio);

  final Fantasma _fantasma;

  final Dio _dio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requestCustomHandler = _fantasma.findHandler(
      path: options.path,
      method: options.method,
      headers: options.headers,
      queryParameters: options.queryParameters,
      data: options.data,
    );

    if (_fantasma.shouldFailOnMissingMock && requestCustomHandler == null) {
      return handler.reject(NoMockFoundException(requestOptions: options));
    } else if (requestCustomHandler == null) {
      return handler.next(options);
    }

    // Assuming the custom handler provides a mock response in some form
    final fantasmaResponse = await requestCustomHandler.reply(options);

    if (fantasmaResponse is FantasmaThrowableResponse) {
      return handler.reject(fantasmaResponse.throwable);
    } else if (fantasmaResponse is FantasmaResponseBody) {
      handler.resolve(
        Response(
          data: await _dio.transformer.transformResponse(
            options,
            fantasmaResponse,
          ),
          headers: Headers.fromMap(fantasmaResponse.headers),
          isRedirect: fantasmaResponse.isRedirect,
          redirects: fantasmaResponse.redirects ?? [],
          requestOptions: options,
          statusCode: fantasmaResponse.statusCode,
          statusMessage: fantasmaResponse.statusMessage,
        ),
      );
    }
  }
}