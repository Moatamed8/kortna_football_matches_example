import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/core/format/format.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/matches/domain/match_repository.dart";

class MatchRepositoryImpl implements MatchRepository {
  MatchRepositoryImpl(
    this._remote, {
    TtlCache? cache,
    DateTime Function()? clock,
    this.tracked = Competition.liveSweep,
  }) : _cache = cache ?? TtlCache(),
       _clock = clock ?? DateTime.now;

  final MatchRemote _remote;
  final TtlCache _cache;
  final DateTime Function() _clock;
  final List<Competition> tracked;

  @override
  Future<List<Match>> liveMatches({bool force = false}) async {
    final day = _clock();
    final results = await Future.wait(
      tracked.map((competition) async {
        try {
          return await matchesOn(
            competition: competition,
            day: day,
            force: force,
          );
        } on AppFailure {
          return null;
        }
      }),
    );
    final boards = results.whereType<List<Match>>().toList();
    if (boards.isEmpty) {
      throw const NetworkFailure("Live scores are unavailable right now.");
    }
    return boards
        .expand((board) => board)
        .where((match) => match.state == MatchState.live)
        .toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
  }

  @override
  Future<List<Match>> matchesOn({
    required Competition competition,
    required DateTime day,
    bool force = false,
  }) {
    final localDay = DateTime(day.year, day.month, day.day);
    final ttl = isSameDay(localDay, _clock())
        ? const Duration(minutes: 2)
        : const Duration(hours: 12);
    return remember(
      cache: _cache,
      key: "scoreboard:${competition.slug}:${espnDay(localDay)}",
      ttl: ttl,
      force: force,
      load: () => _remote.scoreboard(competition: competition, day: localDay),
    );
  }

  @override
  Future<MatchInsight> insight(Match match, {bool force = false}) {
    final ttl = switch (match.state) {
      MatchState.live => const Duration(seconds: 30),
      MatchState.upcoming => const Duration(minutes: 10),
      _ => const Duration(hours: 12),
    };
    return remember(
      cache: _cache,
      key: "summary:${match.id}",
      ttl: ttl,
      force: force,
      load: () => _remote.summary(match: match),
    );
  }
}
