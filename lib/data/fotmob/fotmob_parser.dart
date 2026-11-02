import "package:soccer/core/competitions/competition.dart";
import "package:soccer/data/espn/json_read.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

const fotmobLeagueId = "519";

String fotmobTeamLogo(String id) =>
    "https://images.fotmob.com/image_resources/logo/teamlogo/${id}_small.png";

String fotmobPlayerPhoto(String id) =>
    "https://images.fotmob.com/image_resources/playerimages/$id.png";

List<Match> parseFotmobScoreboard(
  Map<String, dynamic> league, {
  required Competition competition,
  required DateTime day,
}) {
  return _fixtures(league)
      .map((raw) => _match(raw, competition))
      .whereType<Match>()
      .where((match) => isSameLocalDay(match.kickoff, day))
      .toList()
    ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
}

MatchInsight parseFotmobSummary(
  Map<String, dynamic> json, {
  required Match fallback,
}) {
  final competition = Competition(
    slug: fallback.competitionSlug,
    name: fallback.competitionName,
    country: Competition.egyptianPremierLeague.country,
  );
  final header = asMap(json["header"]);
  final general = asMap(json["general"]);
  final scoreboard = _matchFromDetail(
    header: header,
    general: general,
    competition: competition,
    fallback: fallback,
  );
  final facts = asMap(asMap(json["content"])?["matchFacts"]);
  final info = asMap(facts?["infoBox"]);
  final stadium = asMap(info?["Stadium"]);
  final referee = asMap(info?["Referee"]);
  return MatchInsight(
    scoreboard: scoreboard,
    events: _events(facts, scoreboard),
    stats: _stats(asMap(asMap(json["content"])?["stats"])),
    lineups: _lineups(asMap(asMap(json["content"])?["lineup"])),
    venue: stringOf(stadium?["name"]),
    venueCity: stringOf(stadium?["city"]),
    attendance: intOf(info?["Attendance"]),
    referee: stringOf(referee?["text"]),
  );
}

List<TeamSummary> parseFotmobTeams(
  Map<String, dynamic> league, {
  required Competition competition,
}) {
  final fromTable = <TeamSummary>[];
  for (final raw in _tableRows(league)) {
    final row = asMap(raw);
    final id = stringOf(row?["id"]);
    final name = stringOf(row?["name"]);
    if (row == null || id == null || name == null) continue;
    fromTable.add(
      TeamSummary(
        id: id,
        name: name,
        shortName: stringOf(row["shortName"]) ?? name,
        competitionSlug: competition.slug,
        competitionName: competition.name,
        country: competition.country,
        logoUrl: fotmobTeamLogo(id),
      ),
    );
  }
  if (fromTable.isNotEmpty) return fromTable;

  final seen = <String>{};
  final fromFixtures = <TeamSummary>[];
  for (final raw in _fixtures(league)) {
    for (final side in ["home", "away"]) {
      final team = asMap(asMap(raw)?[side]);
      final id = stringOf(team?["id"]);
      final name = stringOf(team?["name"]);
      if (id == null || name == null || !seen.add(id)) continue;
      fromFixtures.add(
        TeamSummary(
          id: id,
          name: name,
          shortName: stringOf(team?["shortName"]) ?? name,
          competitionSlug: competition.slug,
          competitionName: competition.name,
          country: competition.country,
          logoUrl: fotmobTeamLogo(id),
        ),
      );
    }
  }
  fromFixtures.sort((a, b) => a.name.compareTo(b.name));
  return fromFixtures;
}

TeamFacts parseFotmobFacts(
  Map<String, dynamic> league, {
  required TeamSummary team,
  required Competition competition,
}) {
  Map<String, dynamic>? row;
  for (final raw in _tableRows(league)) {
    final candidate = asMap(raw);
    if (stringOf(candidate?["id"]) == team.id) {
      row = candidate;
      break;
    }
  }
  final rank = intOf(row?["idx"]);
  final record = SeasonRecord(
    wins: intOf(row?["wins"]),
    draws: intOf(row?["draws"]),
    losses: intOf(row?["losses"]),
    points: intOf(row?["pts"]),
  );
  Match? next;
  for (final raw in _fixtures(league)) {
    final match = _match(raw, competition);
    if (match == null || match.state != MatchState.upcoming) continue;
    if (match.home.id != team.id && match.away.id != team.id) continue;
    if (next == null || match.kickoff.isBefore(next.kickoff)) next = match;
  }
  return TeamFacts(
    standing: rank == null ? null : "#$rank",
    record: record.isEmpty ? null : record,
    nextMatch: next,
  );
}

List<Match> parseFotmobSchedule(
  Map<String, dynamic> league, {
  required TeamSummary team,
  required Competition competition,
}) {
  return _fixtures(league)
      .map((raw) => _match(raw, competition))
      .whereType<Match>()
      .where((match) => match.home.id == team.id || match.away.id == team.id)
      .toList()
    ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
}

Squad parseFotmobSquad(
  Map<String, dynamic> teamJson, {
  required TeamSummary team,
}) {
  final players = <SquadPlayer>[];
  for (final rawGroup in asList(asMap(teamJson["squad"])?["squad"])) {
    final group = asMap(rawGroup);
    final title = stringOf(group?["title"]);
    if (group == null || title == null || title == "coach") continue;
    final position = _squadGroup(title);
    for (final raw in asList(group["members"])) {
      final member = asMap(raw);
      final id = stringOf(member?["id"]);
      final name = stringOf(member?["name"]);
      if (member == null || id == null || name == null) continue;
      if (asMap(member["role"])?["key"] == "coach") continue;
      players.add(
        SquadPlayer(
          id: id,
          name: name,
          teamId: team.id,
          teamName: team.name,
          competitionSlug: team.competitionSlug,
          number: stringOf(member["shirtNumber"]),
          position: position ?? positionLabel(member["role"]),
          nationality: stringOf(member["cname"]),
          age: intOf(member["age"]),
          photoUrl: fotmobPlayerPhoto(id),
          teamLogoUrl: team.logoUrl,
        ),
      );
    }
  }
  return Squad(players: players);
}

List<InjuryReport> parseFotmobInjuries(
  Map<String, dynamic> teamJson, {
  required TeamSummary team,
}) {
  final reports = <InjuryReport>[];
  for (final rawGroup in asList(asMap(teamJson["squad"])?["squad"])) {
    final group = asMap(rawGroup);
    if (group == null || group["title"] == "coach") continue;
    final position = _squadGroup(stringOf(group["title"]));
    for (final raw in asList(group["members"])) {
      final member = asMap(raw);
      final injury = asMap(member?["injury"]);
      final id = stringOf(member?["id"]);
      final name = stringOf(member?["name"]);
      final expected = stringOf(injury?["expectedReturn"]);
      if (member == null || injury == null || id == null || name == null) {
        continue;
      }
      if (expected == null) continue;
      reports.add(
        InjuryReport(
          id: "$id-${stringOf(injury["id"]) ?? expected}",
          playerId: id,
          playerName: name,
          teamId: team.id,
          teamName: team.name,
          status: "",
          photoUrl: fotmobPlayerPhoto(id),
          teamLogoUrl: team.logoUrl,
          position: position ?? positionLabel(member["role"]),
          expectedReturn: expected,
        ),
      );
    }
  }
  return reports;
}

PlayerProfile parseFotmobPlayer(
  Map<String, dynamic> json, {
  required SquadPlayer fallback,
}) {
  final info = _playerInfo(json);
  final injury = asMap(json["injuryInformation"]);
  final expected = asMap(injury?["expectedReturn"]);
  final team = asMap(json["primaryTeam"]);
  final mainLeague = asMap(json["mainLeague"]);
  final stats = <PlayerStat>[];
  for (final raw in asList(mainLeague?["stats"])) {
    final stat = asMap(raw);
    final label = stringOf(stat?["title"]);
    final value = _statText(stat?["value"]);
    if (stat == null || label == null || value == null) continue;
    stats.add(PlayerStat(label: label, value: value));
  }
  final leagueName = stringOf(mainLeague?["leagueName"]);
  final season = stringOf(mainLeague?["season"]);
  final title = [?leagueName, ?season].join(" ");
  return PlayerProfile(
    id: stringOf(json["id"]) ?? fallback.id,
    name: stringOf(json["name"]) ?? fallback.name,
    teamName: stringOf(team?["teamName"]) ?? fallback.teamName,
    number: info.number ?? fallback.number,
    position: _primaryPosition(json) ?? fallback.position,
    nationality: info.country ?? fallback.nationality,
    age: info.age ?? fallback.age,
    height: info.height,
    weight: info.weight,
    photoUrl: fotmobPlayerPhoto(stringOf(json["id"]) ?? fallback.id),
    teamLogoUrl: fallback.teamLogoUrl,
    statsTitle: title.isEmpty ? null : title,
    stats: stats,
    injuryReason: stringOf(injury?["name"]),
    injuryNote: stringOf(expected?["expectedReturnFallback"]),
  );
}

bool isSameLocalDay(DateTime kickoff, DateTime day) {
  final local = kickoff.toLocal();
  return local.year == day.year &&
      local.month == day.month &&
      local.day == day.day;
}

Match? _match(Object? raw, Competition competition) {
  final event = asMap(raw);
  if (event == null) return null;
  final status = asMap(event["status"]) ?? const {};
  final id = stringOf(event["id"]);
  final kickoff = DateTime.tryParse(stringOf(status["utcTime"]) ?? "");
  final home = _side(asMap(event["home"]), score: null);
  final away = _side(asMap(event["away"]), score: null);
  if (id == null || home == null || away == null || kickoff == null) return null;
  return _withStatus(
    id: id,
    competition: competition,
    kickoff: kickoff,
    home: home,
    away: away,
    status: status,
  );
}

Match _matchFromDetail({
  required Map<String, dynamic>? header,
  required Map<String, dynamic>? general,
  required Competition competition,
  required Match fallback,
}) {
  final teams = asList(header?["teams"]);
  final homeRaw = teams.isEmpty ? null : asMap(teams.first);
  final awayRaw = teams.length < 2 ? null : asMap(teams[1]);
  final status = asMap(header?["status"]) ?? const {};
  final kickoff =
      DateTime.tryParse(stringOf(status["utcTime"]) ?? "") ??
      DateTime.tryParse(stringOf(general?["matchTimeUTCDate"]) ?? "") ??
      fallback.kickoff;
  final scores = _scores(stringOf(status["scoreStr"]), started: status["started"] == true);
  final home = _side(homeRaw, score: scores.$1) ?? fallback.home;
  final away = _side(awayRaw, score: scores.$2) ?? fallback.away;
  return _withStatus(
    id: stringOf(general?["matchId"]) ?? fallback.id,
    competition: competition,
    kickoff: kickoff,
    home: home,
    away: away,
    status: status,
  );
}

Match _withStatus({
  required String id,
  required Competition competition,
  required DateTime kickoff,
  required TeamSide home,
  required TeamSide away,
  required Map<String, dynamic> status,
}) {
  final started = status["started"] == true;
  final scores = _scores(stringOf(status["scoreStr"]), started: started);
  final state = _state(status);
  return Match(
    id: id,
    competitionSlug: competition.slug,
    competitionName: competition.name,
    kickoff: kickoff,
    state: state,
    statusLabel: _statusLabel(status, state),
    clock: state == MatchState.live ? _clock(status) : null,
    home: TeamSide(
      id: home.id,
      name: home.name,
      shortName: home.shortName,
      abbreviation: home.abbreviation,
      logoUrl: home.logoUrl ?? fotmobTeamLogo(home.id),
      score: scores.$1,
    ),
    away: TeamSide(
      id: away.id,
      name: away.name,
      shortName: away.shortName,
      abbreviation: away.abbreviation,
      logoUrl: away.logoUrl ?? fotmobTeamLogo(away.id),
      score: scores.$2,
    ),
  );
}

TeamSide? _side(Map<String, dynamic>? team, {required int? score}) {
  final id = stringOf(team?["id"]);
  final name = stringOf(team?["name"]);
  if (team == null || id == null || name == null) return null;
  return TeamSide(
    id: id,
    name: name,
    shortName: stringOf(team["shortName"]) ?? name,
    logoUrl: stringOf(team["imageUrl"]) ?? fotmobTeamLogo(id),
    score: score,
  );
}

(int?, int?) _scores(String? raw, {required bool started}) {
  if (!started || raw == null) return (null, null);
  final match = RegExp(r"(\d+)\s*-\s*(\d+)").firstMatch(raw);
  if (match == null) return (null, null);
  return (int.tryParse(match.group(1)!), int.tryParse(match.group(2)!));
}

MatchState _state(Map<String, dynamic> status) {
  if (status["cancelled"] == true) return MatchState.other;
  final reason = asMap(status["reason"]);
  final key = "${stringOf(reason?["longKey"]) ?? ""} ${stringOf(reason?["shortKey"]) ?? ""} ${stringOf(reason?["long"]) ?? ""}"
      .toLowerCase();
  if (key.contains("postpon") ||
      key.contains("cancel") ||
      key.contains("abandon")) {
    return MatchState.other;
  }
  if (status["finished"] == true) return MatchState.finished;
  if (status["started"] == true) return MatchState.live;
  return MatchState.upcoming;
}

String _statusLabel(Map<String, dynamic> status, MatchState state) {
  final reason = asMap(status["reason"]);
  final short = stringOf(reason?["short"]);
  final long = stringOf(reason?["long"]);
  return switch (state) {
    MatchState.finished => short ?? "FT",
    MatchState.live => _clock(status) ?? short ?? "LIVE",
    MatchState.other => long ?? short ?? "Cancelled",
    MatchState.upcoming => "",
  };
}

String? _clock(Map<String, dynamic> status) {
  final live = asMap(status["liveTime"]);
  final short = stringOf(live?["short"]) ?? stringOf(asMap(status["reason"])?["short"]);
  if (short == null) return null;
  if (RegExp(r"^\d+$").hasMatch(short)) return "$short'";
  return short;
}

List<Object?> _fixtures(Map<String, dynamic> league) {
  return asList(asMap(league["fixtures"])?["allMatches"]);
}

List<Object?> _tableRows(Map<String, dynamic> league) {
  final tables = asList(league["table"]);
  final data = asMap(tables.isEmpty ? null : asMap(tables.first)?["data"]);
  final table = asMap(data?["table"]);
  return asList(table?["all"]);
}

List<MatchEvent> _events(Map<String, dynamic>? facts, Match match) {
  final holder = asMap(facts?["events"]);
  final events = <MatchEvent>[];
  for (final raw in asList(holder?["events"])) {
    final event = _event(asMap(raw), match);
    if (event != null) events.add(event);
  }
  return events;
}

MatchEvent? _event(Map<String, dynamic>? raw, Match match) {
  if (raw == null) return null;
  final type = stringOf(raw["type"]);
  if (type != "Goal" && type != "Card" && type != "Substitution") return null;
  final home = raw["isHome"] == true;
  final teamId = home ? match.home.id : match.away.id;
  final teamName = home ? match.home.name : match.away.name;
  final clock = _eventClock(raw);
  final id = stringOf(raw["reactKey"]) ?? "$type-$clock-${stringOf(raw["playerId"])}";
  if (type == "Substitution") {
    final swap = asList(raw["swap"]);
    final on = stringOf(asMap(swap.isEmpty ? null : swap.first)?["name"]);
    final off = stringOf(asMap(swap.length < 2 ? null : swap[1])?["name"]);
    final text = [?on, if (off != null) "for $off"].join(" ");
    if (text.isEmpty) return null;
    return MatchEvent(
      id: id,
      type: "Substitution",
      text: text,
      clock: clock,
      teamId: teamId,
      teamName: teamName,
      playerName: on,
    );
  }
  if (type == "Card") {
    final player = stringOf(raw["nameStr"]) ?? stringOf(asMap(raw["player"])?["name"]);
    final card = stringOf(raw["card"]);
    final reason = stringOf(asMap(raw["cardReason"])?["defaultText"]);
    final text = [?player, ?reason].join(" · ");
    if (text.isEmpty) return null;
    return MatchEvent(
      id: id,
      type: card == null ? "Card" : "$card card",
      text: text,
      clock: clock,
      teamId: teamId,
      teamName: teamName,
      playerName: player,
    );
  }
  final player = stringOf(raw["nameStr"]) ?? stringOf(asMap(raw["player"])?["name"]);
  final assist = stringOf(raw["assistStr"]);
  final text = [?player, if (assist != null) "assist $assist"].join(", ");
  if (text.isEmpty) return null;
  return MatchEvent(
    id: id,
    type: "Goal",
    text: text,
    clock: clock,
    teamId: teamId,
    teamName: teamName,
    playerName: player,
    assistName: assist,
    scoringPlay: raw["isPenaltyShootoutEvent"] != true,
    ownGoal: _ownGoal(raw),
    penalty: _penalty(raw),
  );
}

String? _eventClock(Map<String, dynamic> raw) {
  final minute = intOf(raw["time"]) ?? intOf(raw["timeStr"]);
  if (minute == null) return stringOf(raw["timeStr"]);
  final added = intOf(raw["overloadTime"]);
  if (added != null && added > 0) return "$minute+$added'";
  return "$minute'";
}

bool _ownGoal(Map<String, dynamic> raw) {
  final value = raw["ownGoal"];
  if (value == true) return true;
  if (value is String && value.toLowerCase().contains("own")) return true;
  return (stringOf(raw["goalDescriptionKey"]) ?? "").toLowerCase().contains("own");
}

bool _penalty(Map<String, dynamic> raw) {
  final values = [
    stringOf(raw["goalDescriptionKey"]),
    stringOf(raw["suffixKey"]),
    stringOf(raw["goalDescription"]),
    stringOf(raw["suffix"]),
  ];
  for (final value in values) {
    if (value == null) continue;
    final text = value.toLowerCase();
    if (text.contains("penalty") || text == "pen" || text.contains("(pen)")) {
      return true;
    }
  }
  return false;
}

List<StatLine> _stats(Map<String, dynamic>? stats) {
  final period = asMap(asMap(stats?["Periods"])?["All"]);
  final lines = <StatLine>[];
  for (final rawGroup in asList(period?["stats"])) {
    for (final raw in asList(asMap(rawGroup)?["stats"])) {
      final stat = asMap(raw);
      final label = stringOf(stat?["title"]);
      final values = asList(stat?["stats"]);
      if (stat == null || label == null || values.length < 2) continue;
      final home = _statText(values[0]);
      final away = _statText(values[1]);
      if (home == null && away == null) continue;
      lines.add(
        StatLine(
          id: stringOf(stat["key"]) ?? label,
          label: label,
          home: home,
          away: away,
        ),
      );
    }
  }
  return lines;
}

List<Lineup> _lineups(Map<String, dynamic>? lineup) {
  final lineups = <Lineup>[];
  for (final side in ["homeTeam", "awayTeam"]) {
    final team = asMap(lineup?[side]);
    final id = stringOf(team?["id"]);
    final name = stringOf(team?["name"]);
    if (team == null || id == null || name == null) continue;
    lineups.add(
      Lineup(
        teamId: id,
        teamName: name,
        formation: stringOf(team["formation"]),
        starters: _lineupPlayers(asList(team["starters"]), starter: true),
        bench: _lineupPlayers(asList(team["subs"]), starter: false),
      ),
    );
  }
  return lineups;
}

List<LineupPlayer> _lineupPlayers(List<Object?> rawPlayers, {required bool starter}) {
  final players = <LineupPlayer>[];
  for (final raw in rawPlayers) {
    final player = asMap(raw);
    final id = stringOf(player?["id"]);
    final name = stringOf(player?["name"]);
    if (player == null || id == null || name == null) continue;
    players.add(
      LineupPlayer(
        id: id,
        name: name,
        number: stringOf(player["shirtNumber"]),
        starter: starter,
      ),
    );
  }
  return players;
}

String? _squadGroup(String? title) {
  return switch (title) {
    "keepers" => "Goalkeeper",
    "defenders" => "Defender",
    "midfielders" => "Midfielder",
    "attackers" => "Forward",
    _ => null,
  };
}

String? _primaryPosition(Map<String, dynamic> json) {
  final description = asMap(json["positionDescription"]);
  return stringOf(asMap(description?["primaryPosition"])?["label"]);
}

({String? number, int? age, String? country, String? height, String? weight})
_playerInfo(Map<String, dynamic> json) {
  String? number;
  int? age;
  String? country;
  String? height;
  String? weight;
  for (final raw in asList(json["playerInformation"])) {
    final item = asMap(raw);
    final key = stringOf(item?["translationKey"]) ?? stringOf(item?["title"]);
    final value = asMap(item?["value"]);
    if (item == null || key == null || value == null) continue;
    switch (key) {
      case "shirt":
      case "Shirt":
        number = stringOf(value["numberValue"]) ?? stringOf(value["fallback"]);
      case "age_sentencecase":
      case "Age":
        age = intOf(value["numberValue"]);
      case "country_sentencecase":
      case "Country":
        country = stringOf(value["fallback"]);
      case "height":
      case "Height":
        height = stringOf(value["fallback"]);
      case "weight":
      case "Weight":
        weight = stringOf(value["fallback"]);
    }
  }
  return (number: number, age: age, country: country, height: height, weight: weight);
}

String? _statText(Object? value) {
  if (value is num) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }
  return stringOf(value);
}
