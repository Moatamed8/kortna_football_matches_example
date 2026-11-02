sealed class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([
    super.message = "Scores are unavailable right now. Check your connection and try again.",
  ]);
}

final class ServerFailure extends AppFailure {
  const ServerFailure(this.statusCode, [String? message])
    : super(message ?? "The data service returned an error ($statusCode).");

  final int statusCode;
}

final class ParseFailure extends AppFailure {
  const ParseFailure([
    super.message = "The data from the server could not be read.",
  ]);
}
