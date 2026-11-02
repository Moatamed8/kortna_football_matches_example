import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/time/ticker.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/injuries/domain/injury_repository.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/matches/domain/match_repository.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/news/domain/story_repository.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/players/domain/player_repository.dart";
import "package:soccer/features/teams/domain/entities/team.dart";
import "package:soccer/features/teams/domain/team_repository.dart";

class ManualTicker implements Ticker {
  Duration? lastDelay;
  void Function()? _callback;

  bool get pending => _callback != null;

  void fire() => _callback?.call();

  @override
  void schedule(Duration delay, void Function() callback) {
    lastDelay = delay;
    _callback = callback;
  }

  @override
  void cancel() {
    _callback = null;
  }
}

class FakeMatchRepository implements MatchRepository {
  FakeMatchRepository({
    this.live = const [],
    this.day = const [],
    MatchInsight? detail,
  }) : detail =
           detail ??
           const MatchInsight(
             stats: [
               StatLine(
                 id: "possessionPct",
                 label: "Possession",
                 home: "56.4",
                 away: "43.6",
               ),
             ],
           );

  List<Match> live;
  List<Match> day;
  final MatchInsight detail;
  bool failLive = false;
  int liveCalls = 0;

  @override
  Future<List<Match>> liveMatches({bool force = false}) async {
    liveCalls++;
    if (failLive) throw Exception("offline");
    return live;
  }

  @override
  Future<List<Match>> matchesOn({
    required Competition competition,
    required DateTime day,
    bool force = false,
  }) async {
    return this.day;
  }

  @override
  Future<MatchInsight> insight(Match match, {bool force = false}) async => detail;
}

class FakeStoryRepository implements StoryRepository {
  FakeStoryRepository(this.items);

  final List<Story> items;

  @override
  Future<List<Story>> stories(Competition competition, {bool force = false}) async {
    return items;
  }
}

class FakeTeamRepository implements TeamRepository {
  @override
  Future<TeamFacts> facts(TeamSummary team, {bool force = false}) async {
    return const TeamFacts();
  }

  @override
  Future<List<Match>> fixtures(TeamSummary team, {bool force = false}) async => const [];

  @override
  Future<Squad> squad(TeamSummary team, {bool force = false}) async {
    return const Squad(players: []);
  }

  @override
  Future<List<TeamSummary>> teams(Competition competition, {bool force = false}) async {
    return const [];
  }
}

class FakePlayerRepository implements PlayerRepository {
  @override
  Future<PlayerProfile> profile(SquadPlayer player, {bool force = false}) async {
    return PlayerProfile(id: player.id, name: player.name, teamName: player.teamName);
  }
}

class FakeInjuryRepository implements InjuryRepository {
  @override
  Future<List<InjuryReport>> reports(
    Competition competition, {
    bool force = false,
  }) async {
    return const [];
  }
}

Match sampleMatch({
  String id = "401",
  MatchState state = MatchState.live,
  int? homeScore = 2,
  int? awayScore = 1,
  String home = "Arsenal",
  String away = "Liverpool",
  String clock = "45'",
  List<MatchEvent> events = const [],
}) {
  return Match(
    id: id,
    competitionSlug: "eng.1",
    competitionName: "Premier League",
    kickoff: DateTime.utc(2026, 11, 2, 16, 30),
    state: state,
    statusLabel: state == MatchState.live ? "45'" : "FT",
    clock: state == MatchState.live ? clock : null,
    home: TeamSide(id: "359", name: home, shortName: home, score: homeScore),
    away: TeamSide(id: "364", name: away, shortName: away, score: awayScore),
    events: events,
  );
}
