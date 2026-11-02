Map<String, dynamic>? asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return null;
}

List<Object?> asList(Object? value) {
  if (value is List<Object?>) return value;
  if (value is List) return List<Object?>.from(value);
  return const [];
}

String? stringOf(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text == "null") return null;
  return text;
}

int? intOf(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

String? positionLabel(Object? value) {
  final direct = stringOf(value);
  if (value is String) return direct;
  final map = asMap(value);
  if (map == null) return null;
  return stringOf(map["displayName"]) ??
      stringOf(map["name"]) ??
      stringOf(map["abbreviation"]);
}

String? logoUrl(Map<String, dynamic>? source) {
  if (source == null) return null;
  String? fallback;
  for (final raw in asList(source["logos"])) {
    final logo = asMap(raw);
    final href = stringOf(logo?["href"]);
    if (href == null) continue;
    fallback ??= href;
    if (asList(logo?["rel"]).contains("default")) return href;
  }
  if (fallback != null) return fallback;
  return stringOf(source["logo"]);
}

String? headshotUrl(Map<String, dynamic>? person) {
  return stringOf(asMap(person?["headshot"])?["href"]);
}

String? flagUrl(Map<String, dynamic>? person) {
  return stringOf(asMap(person?["flag"])?["href"]);
}

String? teamNameOf(Map<String, dynamic>? team) {
  if (team == null) return null;
  return stringOf(team["displayName"]) ??
      stringOf(team["name"]) ??
      stringOf(team["shortDisplayName"]);
}

String? cleanText(String? value) {
  if (value == null) return null;
  final stripped = value
      .replaceAll(RegExp(r"<[^>]*>"), "")
      .replaceAll("&amp;", "&")
      .replaceAll("&#39;", "'")
      .replaceAll("&quot;", "\"")
      .replaceAll("&nbsp;", " ")
      .trim();
  return stripped.isEmpty ? null : stripped;
}
