import 'package:dio/dio.dart';

import 'response.dart';

typedef Matcher<T> = bool Function(T value);

typedef FantasmaResponseCallback = IFantasmaResponse Function(RequestOptions);

class RequestCustomHandler {
  const RequestCustomHandler(this.callback, {
    this.matchesPath,
    this.matchesMethod,
    this.matchesHeaders,
    this.matchesQueryParameters,
    this.matchesData,
  });

  final FantasmaResponseCallback callback;
  final Matcher<String>? matchesPath;
  final Matcher<String>? matchesMethod;
  final Matcher<Map<String, dynamic>>? matchesHeaders;
  final Matcher<Map<String, dynamic>>? matchesQueryParameters;
  final Matcher<dynamic>? matchesData;

  bool matches({
    required String path,
    required String method,
    required Map<String, dynamic> headers,
    required Map<String, dynamic> queryParameters,
    dynamic data,
  }) {
    // Check if the path matcher exists and evaluate it, or default to true
    final hasPathMatch = matchesPath?.call(path) ?? true;

    // Check if the method matcher exists and evaluate it, or default to true
    final hasMethodMatch = matchesMethod?.call(method) ?? true;

    // Check if the headers matcher exists and evaluate it, or default to true
    final hasHeadersMatch = matchesHeaders?.call(headers) ?? true;

    // Check if the query parameters matcher exists and evaluate it, or default to true
    final hasQueryParametersMatch = matchesQueryParameters?.call(queryParameters) ?? true;

    // Check if the data matcher exists and evaluate it, or default to true
    final hasDataMatch = matchesData?.call(data) ?? true;

    // Return true only if all matchers pass their conditions
    return hasPathMatch && hasMethodMatch && hasHeadersMatch && hasQueryParametersMatch && hasDataMatch;
  }

  Future<IFantasmaResponse> reply(RequestOptions requestOptions) async {
    // Generate a mock response
    final IFantasmaResponse mockResponse = callback(requestOptions);

    // If a delay is defined in the response, await the delay
    if (mockResponse.delay != null) {
      await Future.delayed(mockResponse.delay!);
    }

    // Resolve the mock response to the handler
    return mockResponse;
  }
}
