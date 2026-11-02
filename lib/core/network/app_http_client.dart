import "dart:async";
import "dart:convert";

import "package:http/http.dart" as http;
import "package:soccer/core/error/app_failure.dart";

class AppHttpClient {
  AppHttpClient({http.Client? client, Duration? timeout})
    : _client = client ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 12);

  final http.Client _client;
  final Duration _timeout;

  static const _headers = {
    "accept": "application/json",
    "user-agent": "Kortna/1.0",
  };

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw const NetworkFailure("The request timed out.");
    } catch (_) {
      throw const NetworkFailure();
    }

    if (response.statusCode == 429) {
      throw const ServerFailure(
        429,
        "The data service is limiting requests. Try again in a moment.",
      );
    }
    if (response.statusCode != 200) {
      throw ServerFailure(response.statusCode);
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const ParseFailure();
    } on AppFailure {
      rethrow;
    } on FormatException {
      throw const ParseFailure();
    }
  }
}
