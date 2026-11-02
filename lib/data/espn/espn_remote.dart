import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/core/network/app_http_client.dart";
import "package:soccer/data/espn/espn_parser.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

class EspnRemote
    implements MatchRemote, TeamRemote, PlayerRemote, InjuryRemote, StoryRemote {
  EspnRemote(this._http);

  final AppHttpClient _http;

  Uri _site(String path, [Map<String, String>? query]) {
    return Uri.https(
      "site.api.espn.com",
      "/apis/site/v2/sports/soccer/$path",
      query,
    );
  }

  @override
  Future<List<Match>> scoreboard({
    required Competition competition,
    required DateTime day,
  }) async {
    final json = await _http.getJson(
      _site("${competition.slug}/scoreboard", {"dates": espnDay(day)}),
    );
    return parseScoreboard(json, fallback: competition);
  }

  @override
  Future<MatchInsight> summary({required Match match}) async {
    final json = await _http.getJson(
      _site("${match.competitionSlug}/summary", {"event": match.id}),
    );
    return parseSummary(json, fallback: match);
  }

  @override
  Future<List<TeamSummary>> teams(Competition competition) async {
    final json = await _http.getJson(
      _site("${competition.slug}/teams", {"limit": "80"}),
    );
    return parseTeams(json, competition: competition);
  }

  @override
  Future<TeamFacts> facts({
    required TeamSummary team,
    required Competition competition,
  }) async {
    final json = await _http.getJson(_site("${team.competitionSlug}/teams/${team.id}"));
    return parseTeamFacts(json, competition: competition);
  }

  @override
  Future<Squad> squad(TeamSummary team) async {
    final json = await _http.getJson(
      _site("${team.competitionSlug}/teams/${team.id}/roster"),
    );
    return parseSquad(json, team: team);
  }

  @override
  Future<List<Match>> schedule({
    required TeamSummary team,
    required Competition competition,
  }) async {
    final json = await _http.getJson(
      _site("${team.competitionSlug}/teams/${team.id}/schedule"),
    );
    return parseSchedule(json, fallback: competition);
  }

  @override
  Future<PlayerProfile> player(SquadPlayer player) async {
    final json = await _http.getJson(
      Uri.https(
        "site.api.espn.com",
        "/apis/common/v3/sports/soccer/${player.competitionSlug}/athletes/${player.id}",
      ),
    );
    return parsePlayer(json, fallback: player);
  }

  @override
  Future<List<InjuryReport>> injuries(Competition competition) async {
    final json = await _http.getJson(_site("${competition.slug}/injuries"));
    return parseInjuries(json);
  }

  @override
  Future<List<Story>> stories(Competition competition) async {
    final json = await _http.getJson(
      _site("${competition.slug}/news", {"limit": "20"}),
    );
    return parseStories(json, competition: competition);
  }
}
