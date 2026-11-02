import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/teams/domain/entities/team.dart";
import "package:soccer/features/teams/domain/team_repository.dart";

class TeamDetailState extends Equatable {
  const TeamDetailState({
    required this.team,
    this.facts,
    this.players = const [],
    this.fixtures = const [],
    this.loading = false,
    this.failure,
  });

  final TeamSummary team;
  final TeamFacts? facts;
  final List<SquadPlayer> players;
  final List<Match> fixtures;
  final bool loading;
  final AppFailure? failure;

  List<Match> get recent {
    final finished = fixtures
        .where((match) => match.state == MatchState.finished)
        .toList()
      ..sort((a, b) => b.kickoff.compareTo(a.kickoff));
    return finished.take(6).toList();
  }

  List<Match> get upcoming {
    final scheduled = fixtures
        .where((match) => match.state == MatchState.upcoming)
        .toList()
      ..sort((a, b) => a.kickoff.compareTo(b.kickoff));
    final next = facts?.nextMatch;
    if (next == null) return scheduled.take(3).toList();
    final merged = [
      next,
      ...scheduled.where((match) => match.id != next.id),
    ];
    return merged.take(3).toList();
  }

  @override
  List<Object?> get props => [team, facts, players, fixtures, loading, failure?.message];
}

class TeamDetailCubit extends Cubit<TeamDetailState> {
  TeamDetailCubit(this._repository, TeamSummary team)
    : super(TeamDetailState(team: team, loading: true));

  final TeamRepository _repository;

  Future<void> load({bool force = false}) async {
    emit(state.copyWith(loading: true, clearFailure: true));
    try {
      final results = await Future.wait<Object?>([
        _capture(() => _repository.facts(state.team, force: force)),
        _capture(() => _repository.squad(state.team, force: force)),
        _capture(() => _repository.fixtures(state.team, force: force)),
      ]);
      final facts = results[0] as TeamFacts?;
      final squad = results[1] as Squad?;
      final fixtures = results[2] as List<Match>?;
      final failed = facts == null && squad == null && fixtures == null;
      emit(
        TeamDetailState(
          team: state.team,
          facts: facts,
          players: squad?.players ?? const [],
          fixtures: fixtures ?? const [],
          failure: failed ? const NetworkFailure() : null,
        ),
      );
    } catch (_) {
      emit(
        TeamDetailState(
          team: state.team,
          failure: const NetworkFailure(),
        ),
      );
    }
  }
}

extension on TeamDetailState {
  TeamDetailState copyWith({required bool loading, bool clearFailure = false}) {
    return TeamDetailState(
      team: team,
      facts: facts,
      players: players,
      fixtures: fixtures,
      loading: loading,
      failure: clearFailure ? null : failure,
    );
  }
}

Future<T?> _capture<T>(Future<T> Function() load) async {
  try {
    return await load();
  } on AppFailure {
    return null;
  }
}
