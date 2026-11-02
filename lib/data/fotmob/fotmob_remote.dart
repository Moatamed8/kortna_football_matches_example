import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/core/network/app_http_client.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/data/fotmob/fotmob_parser.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";

/// Egyptian Premier League via FotMob league 519.
///
/// The league document is the whole season, so it is reused for a short
/// window instead of downloaded again for every day on the fixture board.
class FotmobEgyptianRemote
    implements MatchRemote, TeamRemote, PlayerRemote, InjuryRemote, StoryRemote {
  FotmobEgyptianRemote(this._http, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppHttpClient _http;
  final DateTime Function() _clock;

  static const _leagueTtl = Duration(seconds: 20);

  Map<String, dynamic>? _league;
  DateTime? _leagueAt;
  Future<Map<String, dynamic>>? _leagueInflight;

  @override
  Future<List<Match>> scoreboard({
    required Competition competition,
    required DateTime day,
  }) async {
    final league = await _leagueDocument();
    return parseFotmobScoreboard(league, competition: competition, day: day);
  }

  @override
  Future<MatchInsight> summary({required Match match}) async {
    final json = await _http.getJson(
      Uri.https("www.fotmob.com", "/api/data/matchDetails", {
        "matchId": match.id,
      }),
    );
    return parseFotmobSummary(json, fallback: match);
  }

  @override
  Future<List<TeamSummary>> teams(Competition competition) async {
    final league = await _leagueDocument();
    final clubs = parseFotmobTeams(league, competition: competition);
    if (clubs.isEmpty) throw const ParseFailure();
    return clubs;
  }

  @override
  Future<TeamFacts> facts({
    required TeamSummary team,
    required Competition competition,
  }) async {
    final league = await _leagueDocument();
    return parseFotmobFacts(league, team: team, competition: competition);
  }

  @override
  Future<Squad> squad(TeamSummary team) async {
    final json = await _teamDocument(team.id);
    return parseFotmobSquad(json, team: team);
  }

  @override
  Future<List<Match>> schedule({
    required TeamSummary team,
    required Competition competition,
  }) async {
    final league = await _leagueDocument();
    return parseFotmobSchedule(league, team: team, competition: competition);
  }

  @override
  Future<PlayerProfile> player(SquadPlayer player) async {
    final json = await _http.getJson(
      Uri.https("www.fotmob.com", "/api/data/playerData", {"id": player.id}),
    );
    return parseFotmobPlayer(json, fallback: player);
  }

  @override
  Future<List<InjuryReport>> injuries(Competition competition) async {
    final clubs = await teams(competition);
    final reports = <InjuryReport>[];
    var failures = 0;
    AppFailure? last;
    const width = 4;
    for (var index = 0; index < clubs.length; index += width) {
      final end = index + width > clubs.length ? clubs.length : index + width;
      final batch = await Future.wait(
        clubs.sublist(index, end).map((club) async {
          try {
            final json = await _teamDocument(club.id);
            return parseFotmobInjuries(json, team: club);
          } on AppFailure catch (failure) {
            return failure;
          }
        }),
      );
      for (final result in batch) {
        if (result is AppFailure) {
          failures += 1;
          last = result;
        } else if (result is List<InjuryReport>) {
          reports.addAll(result);
        }
      }
    }
    if (failures == clubs.length && last != null) throw last;
    reports.sort((a, b) => a.playerName.compareTo(b.playerName));
    return reports;
  }

  @override
  Future<List<Story>> stories(Competition competition) async => const [];

  Future<Map<String, dynamic>> _leagueDocument() {
    final cached = _league;
    final at = _leagueAt;
    if (cached != null &&
        at != null &&
        _clock().difference(at) < _leagueTtl) {
      return Future.value(cached);
    }
    final inflight = _leagueInflight;
    if (inflight != null) return inflight;
    final future = _http
        .getJson(
          Uri.https("www.fotmob.com", "/api/data/leagues", {
            "id": fotmobLeagueId,
          }),
        )
        .then((json) {
          _league = json;
          _leagueAt = _clock();
          return json;
        })
        .whenComplete(() => _leagueInflight = null);
    _leagueInflight = future;
    return future;
  }

  Future<Map<String, dynamic>> _teamDocument(String id) {
    return _http.getJson(
      Uri.https("www.fotmob.com", "/api/data/teams", {"id": id}),
    );
  }
}
