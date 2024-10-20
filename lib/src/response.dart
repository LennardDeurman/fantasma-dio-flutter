import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class IFantasmaResponse {
  const IFantasmaResponse({required this.delay});

  final Duration? delay;
}

class FantasmaThrowableResponse implements IFantasmaResponse {
  const FantasmaThrowableResponse(this.throwable, {this.delay});

  final DioException throwable;

  @override
  final Duration? delay;
}

class FantasmaResponseBody extends ResponseBody implements IFantasmaResponse {
  FantasmaResponseBody(
      super.stream,
      super.statusCode, {
        super.headers,
        super.statusMessage,
        super.isRedirect,
        super.redirects,
        this.delay,
      });

  @override
  final Duration? delay;

  factory FantasmaResponseBody.from(
      String response,
      {
        int statusCode = 200,
        Map<String, List<String>> headers = const {},
        String? statusMessage,
        Duration? delay,
        bool isRedirect = false,
      }) =>
      FantasmaResponseBody(
        Stream.fromIterable(
          utf8.encode(response).map((elements) => Uint8List.fromList([elements])).toList(),
        ),
        statusCode,
        headers: headers,
        statusMessage: statusMessage,
        isRedirect: isRedirect,
        delay: delay,
      );

  factory FantasmaResponseBody.fromBytes(
      Uint8List bytes,
      {
        int statusCode = 200,
        Map<String, List<String>> headers = const {},
        String? statusMessage,
        Duration? delay,
        bool isRedirect = false,
      }) =>
      FantasmaResponseBody(
        Stream.value(bytes),
        statusCode,
        headers: headers,
        statusMessage: statusMessage,
        isRedirect: isRedirect,
        delay: delay,
      );
}