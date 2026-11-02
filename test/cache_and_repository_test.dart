import "package:flutter_test/flutter_test.dart";
import "package:soccer/core/cache/ttl_cache.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/data/espn/remotes.dart";
import "package:soccer/features/matches/data/match_repository_impl.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/matches/domain/live_refresh_policy.dart";

import "support/fakes.dart";

void main() {
  test("cache expires when the clock passes the ttl", () {
    var now = DateTime(2026, 11, 2, 12);
    final cache = TtlCache(clock: () => now);
    cache.set("scores", 1, const Duration(minutes: 2));
    expect(cache.get<int>("scores"), 1);
    now = now.add(const Duration(minutes: 3));
    expect(cache.get<int>("scores"), isNull);
  });

  test("live polling is faster only while matches are in play", () {
    const policy = LiveRefreshPolicy();
    expect(policy.delay(hasLiveMatches: true), const Duration(seconds: 45));
    expect(policy.delay(hasLiveMatches: false), const Duration(minutes: 5));
  });

  test("a failed league does not hide live matches from the others", () async {
    var now = DateTime(2026, 11, 2, 18);
    final cache = TtlCache(clock: () => now);
    final remote = _Remote()
      ..boards[Competition.premierLeague.slug] = [
        sampleMatch(),
        sampleMatch(
          id: "scheduled",
          state: MatchState.upcoming,
          homeScore: null,
          awayScore: null,
          home: "Everton",
          away: "Newcastle United",
        ),
      ]
      ..failing.add(Competition.laLiga.slug);
    final repository = MatchRepositoryImpl(
      remote,
      cache: cache,
      clock: () => now,
      tracked: const [Competition.premierLeague, Competition.laLiga],
    );

    final live = await repository.liveMatches(force: true);
    expect(live.map((match) => match.id), ["401"]);

    final again = await repository.matchesOn(
      competition: Competition.premierLeague,
      day: now,
    );
    expect(remote.calls, 2);
    expect(again, hasLength(2));
  });

  test("every tracked competition failing surfaces an error", () async {
    final repository = MatchRepositoryImpl(
      _Remote()..failing.add(Competition.premierLeague.slug),
      tracked: const [Competition.premierLeague],
    );
    await expectLater(repository.liveMatches(), throwsA(isA<NetworkFailure>()));
  });
}

class _Remote implements MatchRemote {
  final boards = <String, List<Match>>{};
  final failing = <String>{};
  int calls = 0;

  @override
  Future<List<Match>> scoreboard({
    required Competition competition,
    required DateTime day,
  }) async {
    calls++;
    if (failing.contains(competition.slug)) {
      throw const NetworkFailure();
    }
    return boards[competition.slug] ?? const [];
  }

  @override
  Future<MatchInsight> summary({required Match match}) async {
    return const MatchInsight();
  }
}
