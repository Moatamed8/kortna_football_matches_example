import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/data/espn/json_read.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

List<Match> parseScoreboard(
  Map<String, dynamic> json, {
  required Competition fallback,
}) {
  if (!json.containsKey("events")) {
    throw const ParseFailure("The fixture list was missing from the response.");
  }
  final matches = <Match>[];
  for (final raw in asList(json["events"])) {
    final match = parseEvent(asMap(raw), fallback: fallback);
    if (match != null) matches.add(match);
  }
  return matches;
}

List<Match> parseSchedule(
  Map<String, dynamic> json, {
  required Competition fallback,
}) {
  return parseScoreboard(json, fallback: fallback);
}

Match? parseEvent(Map<String, dynamic>? event, {required Competition fallback}) {
  if (event == null) return null;
  final competition = _firstMap(event["competitions"]);
  if (competition == null) return null;
  final id = stringOf(event["id"]) ?? stringOf(competition["id"]);
  if (id == null) return null;

  final kickoff = DateTime.tryParse(
    stringOf(event["date"]) ?? stringOf(competition["date"]) ?? "",
  );
  if (kickoff == null) return null;

  final status = asMap(competition["status"]) ?? asMap(event["status"]) ?? const {};
  final type = asMap(status["type"]) ?? const {};
  final state = switch (stringOf(type["state"])) {
    "in" => MatchState.live,
    "pre" => MatchState.upcoming,
    "post" => MatchState.finished,
    _ => MatchState.other,
  };
  final displayClock = stringOf(status["displayClock"]);
  final clock = state == MatchState.live && displayClock != null
      ? displayClock
      : null;
  final shortDetail = stringOf(type["shortDetail"]) ?? "";
  final description = stringOf(type["description"]) ?? "";

  final started = state == MatchState.live || state == MatchState.finished;
  TeamSide? home;
  TeamSide? away;
  for (final raw in asList(competition["competitors"])) {
    final side = asMap(raw);
    if (side == null) continue;
    final team = asMap(side["team"]);
    final name = teamNameOf(team);
    final teamId = stringOf(team?["id"]) ?? stringOf(side["id"]);
    if (name == null || teamId == null) continue;
    final parsed = TeamSide(
      id: teamId,
      name: name,
      shortName:
          stringOf(team?["shortDisplayName"]) ??
          stringOf(team?["abbreviation"]) ??
          name,
      abbreviation: stringOf(team?["abbreviation"]),
      logoUrl: logoUrl(team),
      score: _score(side["score"], started: started),
      form: stringOf(side["form"]),
      record: _recordSummary(side["records"]),
    );
    switch (stringOf(side["homeAway"])) {
      case "home":
        home = parsed;
      case "away":
        away = parsed;
    }
  }
  if (home == null || away == null) return null;

  final venueMap = asMap(competition["venue"]) ?? asMap(event["venue"]);
  final league = asMap(event["league"]);
  final events = <MatchEvent>[];
  for (final raw in asList(competition["details"])) {
    final parsed = parseTimelineEvent(asMap(raw));
    if (parsed != null) events.add(parsed);
  }

  return Match(
    id: id,
    competitionSlug: stringOf(league?["slug"]) ?? fallback.slug,
    competitionName:
        stringOf(league?["name"]) ??
        stringOf(league?["abbreviation"]) ??
        fallback.name,
    kickoff: kickoff,
    state: state,
    statusLabel: shortDetail.isNotEmpty ? shortDetail : description,
    clock: clock,
    home: home,
    away: away,
    venue: stringOf(venueMap?["fullName"]) ?? stringOf(venueMap?["displayName"]),
    venueCity: stringOf(asMap(venueMap?["address"])?["city"]),
    events: events,
  );
}

MatchEvent? parseTimelineEvent(Map<String, dynamic>? raw) {
  if (raw == null) return null;
  final type = asMap(raw["type"]);
  final label = stringOf(type?["text"]) ?? "";
  final text = stringOf(raw["text"]) ?? stringOf(raw["shortText"]) ?? label;
  if (text.isEmpty && label.isEmpty) return null;

  final names = <String>[];
  for (final rawPerson in asList(raw["athletesInvolved"] ?? raw["participants"])) {
    final person = asMap(rawPerson);
    final athlete = asMap(person?["athlete"]) ?? person;
    final name = stringOf(athlete?["displayName"]) ?? stringOf(athlete?["fullName"]);
    if (name != null) names.add(name);
  }
  final clock = stringOf(asMap(raw["clock"])?["displayValue"]);
  final team = asMap(raw["team"]);
  return MatchEvent(
    id: stringOf(raw["id"]) ?? "$label-$clock-${names.join()}",
    type: label,
    text: text,
    clock: clock,
    teamId: stringOf(team?["id"]),
    teamName: stringOf(team?["displayName"]),
    playerName: names.isEmpty ? null : names.first,
    assistName: names.length > 1 ? names[1] : null,
    scoringPlay: raw["scoringPlay"] == true,
    ownGoal: raw["ownGoal"] == true,
    penalty: raw["penaltyKick"] == true,
  );
}

MatchInsight parseSummary(
  Map<String, dynamic> json, {
  required Match fallback,
}) {
  final competition = Competition(
    slug: fallback.competitionSlug,
    name: fallback.competitionName,
    country: "",
  );
  final headerCompetition = _firstMap(asMap(json["header"])?["competitions"]);
  final updated = headerCompetition == null
      ? null
      : parseEvent({
          "id": fallback.id,
          "date":
              stringOf(headerCompetition["date"]) ??
              fallback.kickoff.toIso8601String(),
          "competitions": [headerCompetition],
        }, fallback: competition);

  final keyEvents = <MatchEvent>[];
  for (final raw in asList(json["keyEvents"])) {
    final event = parseTimelineEvent(asMap(raw));
    if (event != null) keyEvents.add(event);
  }

  final info = asMap(json["gameInfo"]);
  final venueMap = asMap(info?["venue"]);
  final attendance = intOf(info?["attendance"]);
  return MatchInsight(
    scoreboard: updated,
    events: keyEvents.isNotEmpty
        ? keyEvents
        : (updated?.events ?? fallback.events),
    stats: _stats(asList(asMap(json["boxscore"])?["teams"])),
    lineups: _lineups(asList(json["rosters"])),
    venue: stringOf(venueMap?["fullName"]) ?? updated?.venue ?? fallback.venue,
    venueCity:
        stringOf(asMap(venueMap?["address"])?["city"]) ??
        updated?.venueCity ??
        fallback.venueCity,
    attendance: attendance != null && attendance > 0 ? attendance : null,
    referee: _referee(info),
  );
}

List<TeamSummary> parseTeams(
  Map<String, dynamic> json, {
  required Competition competition,
}) {
  final league = _firstMap(_firstMap(json["sports"])?["leagues"]);
  if (league == null || !league.containsKey("teams")) {
    throw const ParseFailure("The team list was missing from the response.");
  }
  final teams = <TeamSummary>[];
  for (final raw in asList(league["teams"])) {
    final wrapper = asMap(raw);
    final team = asMap(wrapper?["team"]) ?? wrapper;
    final id = stringOf(team?["id"]);
    final name = teamNameOf(team);
    if (team == null || id == null || name == null) continue;
    teams.add(
      TeamSummary(
        id: id,
        name: name,
        shortName: stringOf(team["shortDisplayName"]) ?? name,
        abbreviation: stringOf(team["abbreviation"]),
        logoUrl: logoUrl(team),
        colorHex: stringOf(team["color"]),
        competitionSlug: competition.slug,
        competitionName: stringOf(league["name"]) ?? competition.name,
        country: competition.country,
      ),
    );
  }
  teams.sort((a, b) => a.name.compareTo(b.name));
  return teams;
}

TeamFacts parseTeamFacts(
  Map<String, dynamic> json, {
  required Competition competition,
}) {
  final team = asMap(json["team"]) ?? json;
  return TeamFacts(
    standing: stringOf(team["standingSummary"]),
    record: _seasonRecord(team["record"]),
    nextMatch: parseEvent(_firstMap(team["nextEvent"]), fallback: competition),
    colorHex: stringOf(team["color"]),
  );
}

/// Squad lists are read from `athletes` only. The roster `coach` array is an
/// unordered history with no current-role flag, so it is not shown.
Squad parseSquad(Map<String, dynamic> json, {required TeamSummary team}) {
  final players = <SquadPlayer>[];
  for (final raw in asList(json["athletes"])) {
    _collectPlayers(raw, players, team, null);
  }
  players.sort((a, b) {
    final number = (int.tryParse(a.number ?? "") ?? 999).compareTo(
      int.tryParse(b.number ?? "") ?? 999,
    );
    if (number != 0) return number;
    return a.name.compareTo(b.name);
  });
  return Squad(players: players);
}

PlayerProfile parsePlayer(
  Map<String, dynamic> json, {
  required SquadPlayer fallback,
}) {
  final athlete = asMap(json["athlete"]) ?? json;
  final summary = asMap(athlete["statsSummary"]);
  final stats = <PlayerStat>[];
  for (final raw in asList(summary?["statistics"])) {
    final stat = asMap(raw);
    final label =
        stringOf(stat?["displayName"]) ?? stringOf(stat?["shortDisplayName"]);
    final value = stringOf(stat?["displayValue"]);
    if (label == null || value == null) continue;
    stats.add(PlayerStat(label: label, value: value));
  }
  final injury = _firstInjury(athlete);
  final team = asMap(athlete["team"]);
  return PlayerProfile(
    id: stringOf(athlete["id"]) ?? fallback.id,
    name: stringOf(athlete["displayName"]) ?? fallback.name,
    number:
        stringOf(athlete["jersey"]) ??
        stringOf(athlete["displayJersey"]) ??
        fallback.number,
    position: positionLabel(athlete["position"]) ?? fallback.position,
    nationality: stringOf(athlete["citizenship"]) ?? fallback.nationality,
    flagUrl: flagUrl(athlete) ?? fallback.flagUrl,
    age: intOf(athlete["age"]) ?? fallback.age,
    height: stringOf(athlete["displayHeight"]),
    weight: stringOf(athlete["displayWeight"]),
    photoUrl: headshotUrl(athlete) ?? fallback.photoUrl,
    teamName: teamNameOf(team) ?? fallback.teamName,
    teamLogoUrl: logoUrl(team) ?? fallback.teamLogoUrl,
    statsTitle: stringOf(summary?["displayName"]),
    stats: stats,
    injuryStatus: injury?.status,
    injuryReason: injury?.reason,
    injuryNote: injury?.note,
  );
}

List<InjuryReport> parseInjuries(Map<String, dynamic> json) {
  if (!json.containsKey("injuries")) {
    throw const ParseFailure("The injury list was missing from the response.");
  }
  final reports = <InjuryReport>[];
  for (final raw in asList(json["injuries"])) {
    final node = asMap(raw);
    if (node == null) continue;
    final nested = asList(node["injuries"]);
    if (nested.isNotEmpty && node["athlete"] == null) {
      final teamName = stringOf(node["displayName"]) ?? "";
      final teamId = stringOf(node["id"]) ?? "";
      for (final item in nested) {
        final report = parseInjuryItem(
          asMap(item),
          teamName: teamName,
          teamId: teamId,
        );
        if (report != null) reports.add(report);
      }
      continue;
    }
    final report = parseInjuryItem(node);
    if (report != null) reports.add(report);
  }
  return reports;
}

InjuryReport? parseInjuryItem(
  Map<String, dynamic>? item, {
  String? teamName,
  String? teamId,
}) {
  if (item == null) return null;
  final athlete = asMap(item["athlete"]);
  final name =
      stringOf(athlete?["displayName"]) ?? stringOf(athlete?["fullName"]);
  if (name == null) return null;
  final team = asMap(athlete?["team"]);
  final details = asMap(item["details"]);
  final side = stringOf(details?["side"]);
  final type = stringOf(details?["type"]);
  final reason = [?side, ?type].join(" ");
  final status =
      stringOf(item["status"]) ?? stringOf(asMap(item["type"])?["description"]) ?? "";
  final note = cleanText(stringOf(item["shortComment"])) ??
      cleanText(stringOf(item["longComment"]));
  if (status.isEmpty && reason.isEmpty && note == null) return null;
  return InjuryReport(
    id: stringOf(item["id"]) ?? stringOf(athlete?["id"]) ?? name,
    playerId: stringOf(athlete?["id"]) ?? "",
    playerName: name,
    photoUrl: headshotUrl(athlete),
    teamId: teamId ?? stringOf(team?["id"]) ?? "",
    teamName: teamName ?? teamNameOf(team) ?? "",
    teamLogoUrl: logoUrl(team),
    position: positionLabel(athlete?["position"]),
    status: status,
    reason: reason.isEmpty ? null : reason,
    note: note,
    expectedReturn: stringOf(details?["returnDate"]),
    updatedAt: DateTime.tryParse(stringOf(item["date"]) ?? ""),
  );
}

List<Story> parseStories(
  Map<String, dynamic> json, {
  required Competition competition,
}) {
  if (!json.containsKey("articles")) {
    throw const ParseFailure("The story list was missing from the response.");
  }
  final stories = <Story>[];
  for (final raw in asList(json["articles"])) {
    final article = asMap(raw);
    final headline = stringOf(article?["headline"]);
    if (article == null || headline == null) continue;
    String? image;
    for (final rawImage in asList(article["images"])) {
      final url = stringOf(asMap(rawImage)?["url"]);
      if (url != null) {
        image = url;
        break;
      }
    }
    final links = asMap(article["links"]);
    stories.add(
      Story(
        id: stringOf(article["id"]) ?? headline,
        headline: headline,
        summary: cleanText(stringOf(article["description"])),
        imageUrl: image,
        publishedAt: DateTime.tryParse(
          stringOf(article["published"]) ?? stringOf(article["lastModified"]) ?? "",
        ),
        source: stringOf(article["byline"]) ?? "ESPN",
        url: stringOf(asMap(links?["web"])?["href"]),
        competitionName: competition.name,
      ),
    );
  }
  return stories;
}

int? _score(Object? value, {required bool started}) {
  if (!started || value == null) return null;
  if (value is num) return value.round();
  if (value is String) return int.tryParse(value.trim());
  final map = asMap(value);
  if (map == null) return null;
  final display = stringOf(map["displayValue"]);
  if (display != null) {
    final parsed = int.tryParse(display);
    if (parsed != null) return parsed;
  }
  final raw = map["value"];
  if (raw is num) return raw.round();
  return null;
}

String? _recordSummary(Object? records) {
  for (final raw in asList(records)) {
    final record = asMap(raw);
    if (record?["type"] == "total") return stringOf(record?["summary"]);
  }
  return null;
}

SeasonRecord? _seasonRecord(Object? raw) {
  final record = asMap(raw);
  if (record == null) return null;
  Map<String, dynamic>? holder;
  for (final item in asList(record["items"])) {
    final map = asMap(item);
    if (map == null) continue;
    holder ??= map;
    final description = (stringOf(map["description"]) ?? "").toLowerCase();
    if (description.contains("overall")) {
      holder = map;
      break;
    }
  }
  if (holder == null) return null;
  int? read(String name) {
    for (final rawStat in asList(holder!["stats"])) {
      final stat = asMap(rawStat);
      if (stat?["name"] == name) return intOf(stat?["value"]);
    }
    return null;
  }

  final season = SeasonRecord(
    wins: read("wins"),
    draws: read("ties") ?? read("draws"),
    losses: read("losses"),
    points: read("points"),
  );
  return season.isEmpty ? null : season;
}

Map<String, dynamic>? _firstMap(Object? value) {
  final items = asList(value);
  if (items.isEmpty) return null;
  return asMap(items.first);
}

void _collectPlayers(
  Object? raw,
  List<SquadPlayer> into,
  TeamSummary team,
  String? groupPosition,
) {
  final node = asMap(raw);
  if (node == null) return;
  if (node.containsKey("items")) {
    final position = positionLabel(node["position"]) ?? groupPosition;
    for (final item in asList(node["items"])) {
      _collectPlayers(item, into, team, position);
    }
    return;
  }
  final name = stringOf(node["displayName"]) ?? stringOf(node["fullName"]);
  final id = stringOf(node["id"]);
  if (name == null || id == null) return;
  into.add(
    SquadPlayer(
      id: id,
      name: name,
      number: stringOf(node["jersey"]),
      position: positionLabel(node["position"]) ?? groupPosition,
      nationality: stringOf(node["citizenship"]),
      flagUrl: flagUrl(node),
      age: intOf(node["age"]),
      photoUrl: headshotUrl(node),
      teamId: team.id,
      teamName: team.name,
      teamLogoUrl: team.logoUrl,
      competitionSlug: team.competitionSlug,
    ),
  );
}

class _StatValue {
  const _StatValue(this.label, this.value);
  final String label;
  final String value;
}

List<StatLine> _stats(List<Object?> teams) {
  final columns = <Map<String, _StatValue>>[];
  for (final raw in teams) {
    final team = asMap(raw);
    if (team == null) continue;
    final values = <String, _StatValue>{};
    for (final rawStat in asList(team["statistics"])) {
      final stat = asMap(rawStat);
      final name = stringOf(stat?["name"]);
      final display = stringOf(stat?["displayValue"]);
      if (name == null || display == null) continue;
      values[name] = _StatValue(
        stringOf(stat?["displayName"]) ??
            stringOf(stat?["abbreviation"]) ??
            name,
        display,
      );
    }
    columns.add(values);
  }
  if (columns.isEmpty) return const [];
  final home = columns.first;
  final away = columns.length > 1 ? columns[1] : const <String, _StatValue>{};
  const preferred = [
    "possessionPct",
    "totalShots",
    "shotsOnTarget",
    "foulsCommitted",
    "yellowCards",
    "redCards",
    "wonCorners",
    "offsides",
    "saves",
    "passPct",
  ];
  final names = <String>[];
  void add(String name) {
    if (!names.contains(name) && (home.containsKey(name) || away.containsKey(name))) {
      names.add(name);
    }
  }

  for (final name in preferred) {
    add(name);
  }
  for (final name in [...home.keys, ...away.keys]) {
    add(name);
  }
  return [
    for (final name in names)
      StatLine(
        id: name,
        label: home[name]?.label ?? away[name]!.label,
        home: home[name]?.value,
        away: away[name]?.value,
      ),
  ];
}

List<Lineup> _lineups(List<Object?> rosters) {
  final lineups = <Lineup>[];
  for (final raw in rosters) {
    final roster = asMap(raw);
    if (roster == null) continue;
    final team = asMap(roster["team"]);
    final starters = <LineupPlayer>[];
    final bench = <LineupPlayer>[];
    for (final rawPlayer in asList(roster["roster"])) {
      final player = asMap(rawPlayer);
      final athlete = asMap(player?["athlete"]);
      final name =
          stringOf(athlete?["displayName"]) ?? stringOf(athlete?["fullName"]);
      final id = stringOf(athlete?["id"]);
      if (player == null || name == null || id == null) continue;
      final entry = LineupPlayer(
        id: id,
        name: name,
        number: stringOf(player["jersey"]),
        position:
            positionLabel(player["position"]) ?? positionLabel(athlete?["position"]),
        starter: player["starter"] == true,
      );
      if (entry.starter) {
        starters.add(entry);
      } else {
        bench.add(entry);
      }
    }
    if (starters.isEmpty && bench.isEmpty) continue;
    lineups.add(
      Lineup(
        teamId: stringOf(team?["id"]) ?? stringOf(roster["homeAway"]) ?? "team",
        teamName: teamNameOf(team) ?? "Team",
        formation: stringOf(roster["formation"]),
        starters: starters,
        bench: bench,
      ),
    );
  }
  return lineups;
}

String? _referee(Map<String, dynamic>? info) {
  if (info == null) return null;
  for (final raw in asList(info["officials"])) {
    final official = asMap(raw);
    if (official == null) continue;
    final role = (stringOf(asMap(official["position"])?["displayName"]) ??
            stringOf(official["role"]) ??
            "")
        .toLowerCase();
    if (!role.contains("referee") || role.contains("assistant")) continue;
    final name =
        stringOf(official["displayName"]) ??
        stringOf(asMap(official["athlete"])?["displayName"]);
    if (name != null) return name;
  }
  return null;
}

InjuryReport? _firstInjury(Map<String, dynamic> athlete) {
  final first = _firstMap(athlete["injuries"]);
  if (first == null) return null;
  final team = asMap(athlete["team"]);
  return parseInjuryItem(
    first,
    teamName: teamNameOf(team),
    teamId: stringOf(team?["id"]),
  );
}
