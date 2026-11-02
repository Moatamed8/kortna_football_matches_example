import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/core/time/ticker.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/live_refresh_policy.dart";
import "package:soccer/features/matches/domain/match_repository.dart";

sealed class LiveMatchesEvent extends Equatable {
  const LiveMatchesEvent();

  @override
  List<Object?> get props => [];
}

final class LiveWatchStarted extends LiveMatchesEvent {
  const LiveWatchStarted();
}

final class LiveWatchStopped extends LiveMatchesEvent {
  const LiveWatchStopped();
}

final class LiveAppPaused extends LiveMatchesEvent {
  const LiveAppPaused();
}

final class LiveAppResumed extends LiveMatchesEvent {
  const LiveAppResumed();
}

final class LiveRefreshRequested extends LiveMatchesEvent {
  const LiveRefreshRequested(this.stamp);

  final int stamp;

  @override
  List<Object?> get props => [stamp];
}

final class LiveTick extends LiveMatchesEvent {
  const LiveTick();
}

sealed class LiveMatchesState extends Equatable {
  const LiveMatchesState({required this.stamp});

  final int stamp;

  @override
  List<Object?> get props => [stamp];
}

final class LiveInitial extends LiveMatchesState {
  const LiveInitial() : super(stamp: -1);
}

final class LiveLoading extends LiveMatchesState {
  const LiveLoading({required super.stamp});
}

final class LiveReady extends LiveMatchesState {
  const LiveReady({
    required this.matches,
    required this.updatedAt,
    required super.stamp,
  });

  final List<Match> matches;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [stamp, matches, updatedAt];
}

final class LiveFailure extends LiveMatchesState {
  const LiveFailure({
    required this.failure,
    required super.stamp,
    this.matches,
  });

  final AppFailure failure;
  final List<Match>? matches;

  @override
  List<Object?> get props => [stamp, failure.message, matches];
}

class LiveMatchesBloc extends Bloc<LiveMatchesEvent, LiveMatchesState> {
  LiveMatchesBloc(
    this._repository, {
    LiveRefreshPolicy? policy,
    Ticker? ticker,
  }) : _policy = policy ?? const LiveRefreshPolicy(),
       _ticker = ticker ?? TimerTicker(),
       super(const LiveInitial()) {
    on<LiveWatchStarted>(_onStart);
    on<LiveWatchStopped>(_onStop);
    on<LiveAppPaused>(_onPause);
    on<LiveAppResumed>(_onResume);
    on<LiveRefreshRequested>(_onRefresh);
    on<LiveTick>(_onTick);
  }

  final MatchRepository _repository;
  final LiveRefreshPolicy _policy;
  final Ticker _ticker;
  bool _watching = false;
  bool _foreground = true;
  int _externalStamp = 0;

  Future<void> refresh() {
    final stamp = ++_externalStamp;
    final pending = stream.firstWhere(
      (state) => state.stamp == stamp && state is! LiveLoading,
    );
    add(LiveRefreshRequested(stamp));
    return pending.timeout(const Duration(seconds: 20));
  }

  Future<void> _onStart(LiveWatchStarted event, Emitter<LiveMatchesState> emit) async {
    final alreadyWatching = _watching;
    _watching = true;
    _foreground = true;
    if (!alreadyWatching) {
      await _refresh(emit, stamp: 0);
    }
    _schedule();
  }

  void _onStop(LiveWatchStopped event, Emitter<LiveMatchesState> emit) {
    _watching = false;
    _ticker.cancel();
  }

  void _onPause(LiveAppPaused event, Emitter<LiveMatchesState> emit) {
    _foreground = false;
    _ticker.cancel();
  }

  Future<void> _onResume(LiveAppResumed event, Emitter<LiveMatchesState> emit) async {
    _foreground = true;
    if (!_watching) return;
    await _refresh(emit, stamp: 0);
    _schedule();
  }

  Future<void> _onRefresh(
    LiveRefreshRequested event,
    Emitter<LiveMatchesState> emit,
  ) async {
    await _refresh(emit, stamp: event.stamp);
    _schedule();
  }

  Future<void> _onTick(LiveTick event, Emitter<LiveMatchesState> emit) async {
    if (!_watching || !_foreground) return;
    await _refresh(emit, stamp: 0);
    _schedule();
  }

  Future<void> _refresh(Emitter<LiveMatchesState> emit, {required int stamp}) async {
    final previous = switch (state) {
      LiveReady(:final matches) => matches,
      LiveFailure(:final matches) => matches,
      _ => null,
    };
    if (previous == null) {
      emit(LiveLoading(stamp: stamp));
    }
    try {
      final matches = await _repository.liveMatches(force: true);
      emit(LiveReady(matches: matches, updatedAt: DateTime.now(), stamp: stamp));
    } on AppFailure catch (failure) {
      emit(LiveFailure(failure: failure, matches: previous, stamp: stamp));
    } catch (_) {
      emit(
        LiveFailure(
          failure: const NetworkFailure(),
          matches: previous,
          stamp: stamp,
        ),
      );
    }
  }

  void _schedule() {
    if (!_watching || !_foreground) return;
    final hasLive = switch (state) {
      LiveReady(:final matches) => matches.isNotEmpty,
      LiveFailure(:final matches) => matches != null && matches.isNotEmpty,
      _ => false,
    };
    _ticker.schedule(_policy.delay(hasLiveMatches: hasLive), () {
      add(const LiveTick());
    });
  }

  @override
  Future<void> close() {
    _ticker.cancel();
    return super.close();
  }
}
