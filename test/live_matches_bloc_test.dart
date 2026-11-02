import "package:bloc_test/bloc_test.dart";
import "package:flutter_test/flutter_test.dart";
import "package:soccer/features/matches/domain/live_refresh_policy.dart";
import "package:soccer/features/matches/presentation/live/live_matches_bloc.dart";

import "support/fakes.dart";

void main() {
  late ManualTicker ticker;
  late FakeMatchRepository repository;

  setUp(() {
    ticker = ManualTicker();
    repository = FakeMatchRepository();
  });

  LiveMatchesBloc build() {
    return LiveMatchesBloc(
      repository,
      ticker: ticker,
      policy: const LiveRefreshPolicy(
        liveInterval: Duration(seconds: 45),
        idleInterval: Duration(minutes: 5),
      ),
    );
  }

  blocTest<LiveMatchesBloc, LiveMatchesState>(
    "loads live matches and polls on the live interval",
    build: build,
    setUp: () => repository.live = [sampleMatch()],
    act: (bloc) => bloc.add(const LiveWatchStarted()),
    expect: () => [
      const LiveLoading(stamp: 0),
      isA<LiveReady>().having((state) => state.matches.single.home.name, "home", "Arsenal"),
    ],
    verify: (_) => expect(ticker.lastDelay, const Duration(seconds: 45)),
  );

  blocTest<LiveMatchesBloc, LiveMatchesState>(
    "backs off when nothing is live and stops when watching ends",
    build: build,
    act: (bloc) async {
      bloc.add(const LiveWatchStarted());
      await bloc.stream.firstWhere((state) => state is LiveReady);
      bloc.add(const LiveWatchStopped());
    },
    verify: (_) {
      expect(ticker.lastDelay, const Duration(minutes: 5));
      expect(ticker.pending, isFalse);
    },
  );

  blocTest<LiveMatchesBloc, LiveMatchesState>(
    "keeps the last scoreboard when a refresh fails",
    build: build,
    setUp: () => repository.live = [sampleMatch()],
    act: (bloc) async {
      bloc.add(const LiveWatchStarted());
      await bloc.stream.firstWhere((state) => state is LiveReady);
      repository.failLive = true;
      bloc.add(const LiveRefreshRequested(7));
    },
    expect: () => [
      const LiveLoading(stamp: 0),
      isA<LiveReady>(),
      isA<LiveFailure>().having((state) => state.matches, "matches", isNotEmpty),
    ],
  );

  test("a manual tick refreshes only while watching", () async {
    repository.live = [sampleMatch()];
    final bloc = build();
    bloc.add(const LiveWatchStarted());
    await bloc.stream.firstWhere((state) => state is LiveReady);
    expect(repository.liveCalls, 1);
    ticker.fire();
    await bloc.stream.firstWhere((state) => state is LiveReady && repository.liveCalls == 2);
    expect(repository.liveCalls, 2);
    bloc.add(const LiveWatchStopped());
    await pumpEventQueue();
    expect(ticker.pending, isFalse);
    ticker.fire();
    await pumpEventQueue();
    expect(repository.liveCalls, 2);
    await bloc.close();
  });

  test("refresh completes on the matching stamp, not an earlier load", () async {
    repository.live = [sampleMatch()];
    final bloc = build();
    final pending = bloc.refresh();
    await expectLater(pending, completes);
    expect(bloc.state, isA<LiveReady>());
    await bloc.close();
  });
}
