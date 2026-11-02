import "package:soccer/features/matches/domain/entities/match.dart";

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String espnDay(DateTime day) {
  final month = day.month.toString().padLeft(2, "0");
  final date = day.day.toString().padLeft(2, "0");
  return "${day.year}$month$date";
}

String clockTime(DateTime time) {
  final local = time.toLocal();
  final hour = local.hour.toString().padLeft(2, "0");
  final minute = local.minute.toString().padLeft(2, "0");
  return "$hour:$minute";
}

String kickoffTime(DateTime kickoff) => clockTime(kickoff);

const _weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
const _weekdayNames = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday",
];
const _months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December",
];
const _shortMonths = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec",
];

String fullDate(DateTime date) {
  final local = date.toLocal();
  return "${_weekdayNames[local.weekday - 1]}, ${local.day} ${_months[local.month - 1]}";
}

String shortDate(DateTime date) {
  final local = date.toLocal();
  return "${_weekdays[local.weekday - 1]} ${local.day} ${_shortMonths[local.month - 1]}";
}

String relativeTime(DateTime time, {DateTime? now}) {
  final local = time.toLocal();
  final delta = (now ?? DateTime.now()).difference(local);
  if (delta.isNegative || delta.inMinutes < 1) return "Just now";
  if (delta.inMinutes < 60) return "${delta.inMinutes}m ago";
  if (delta.inHours < 24) return "${delta.inHours}h ago";
  if (delta.inDays < 7) return "${delta.inDays}d ago";
  return shortDate(local);
}

String? formatReturnDate(String raw) {
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  return "${parsed.day} ${_shortMonths[parsed.month - 1]} ${parsed.year}";
}

String matchLeading(Match match) {
  if (match.state == MatchState.live) {
    return match.clock ??
        (match.statusLabel.isEmpty ? "LIVE" : match.statusLabel);
  }
  if (match.state == MatchState.finished) {
    return match.statusLabel.isEmpty ? "FT" : match.statusLabel;
  }
  if (match.state == MatchState.upcoming && !_isDisrupted(match.statusLabel)) {
    return kickoffTime(match.kickoff);
  }
  return match.statusLabel.isEmpty ? "—" : match.statusLabel;
}

bool _isDisrupted(String label) {
  final value = label.toLowerCase();
  return value.contains("postpon") ||
      value.contains("cancel") ||
      value.contains("suspend") ||
      value.contains("abandon");
}

String goalChip(MatchEvent event) {
  final who = event.playerName;
  if (!event.scoringPlay || who == null || who.isEmpty) return "";
  final clock = event.clock;
  final prefix = clock == null || clock.isEmpty ? "" : "$clock ";
  final suffix = event.penalty
      ? " (pen)"
      : event.ownGoal
      ? " (og)"
      : "";
  return "$prefix$who$suffix";
}

String initials(String name) {
  final parts = name
      .split(RegExp(r"\s+"))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return "?";
  String glyph(String value) {
    final runes = value.runes;
    if (runes.isEmpty) return "";
    return String.fromCharCode(runes.first).toUpperCase();
  }

  if (parts.length == 1) return glyph(parts.first);
  return "${glyph(parts.first)}${glyph(parts.last)}";
}
