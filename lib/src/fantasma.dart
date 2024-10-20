import 'handler.dart';

class Fantasma {
  final List<RequestCustomHandler> _handlers = [];

  bool shouldFailOnMissingMock = false;

  void addCustomHandler(FantasmaResponseCallback callback, {
    Matcher<String>? matchesPath,
    Matcher<String>? matchesMethod,
    Matcher<Map<String, dynamic>>? matchesHeaders,
    Matcher<Map<String, dynamic>>? matchesQueryParameters,
    Matcher<dynamic>? matchesData,
  }) {
    _handlers.add(
      RequestCustomHandler(
        callback,
        matchesPath: matchesPath,
        matchesMethod: matchesMethod,
        matchesHeaders: matchesHeaders,
        matchesQueryParameters: matchesQueryParameters,
        matchesData: matchesData,
      ),
    );
  }

  RequestCustomHandler? findHandler({
    required String path,
    required String method,
    required Map<String, dynamic> headers,
    required Map<String, dynamic> queryParameters,
    dynamic data,
  }) {
    for (final handler in _handlers) {
      if (handler.matches(
        path: path,
        method: method,
        headers: headers,
        queryParameters: queryParameters,
        data: data,
      )) {
        return handler;
      }
    }
    return null;
  }
}
