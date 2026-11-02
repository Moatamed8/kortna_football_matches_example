import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/teams/domain/entities/team.dart";
import "package:soccer/features/teams/domain/team_repository.dart";

sealed class TeamsState extends Equatable {
  const TeamsState(this.competition, this.teams);

  final Competition competition;
  final List<TeamSummary>? teams;

  @override
  List<Object?> get props => [competition, teams];
}

final class TeamsLoading extends TeamsState {
  const TeamsLoading(super.competition, [super.teams]);
}

final class TeamsReady extends TeamsState {
  const TeamsReady(super.competition, super.teams);
}

final class TeamsFailure extends TeamsState {
  const TeamsFailure(super.competition, this.failure, [super.teams]);

  final AppFailure failure;

  @override
  List<Object?> get props => [competition, teams, failure.message];
}

class TeamsCubit extends Cubit<TeamsState> {
  TeamsCubit(this._repository)
    : super(const TeamsLoading(Competition.premierLeague));

  final TeamRepository _repository;
  Competition competition = Competition.premierLeague;

  Future<void> load({bool force = false}) async {
    final previous = state.teams;
    emit(TeamsLoading(competition, previous));
    try {
      final teams = await _repository.teams(competition, force: force);
      emit(TeamsReady(competition, teams));
    } on AppFailure catch (failure) {
      emit(TeamsFailure(competition, failure, previous));
    } catch (_) {
      emit(TeamsFailure(competition, const NetworkFailure(), previous));
    }
  }

  Future<void> select(Competition value) {
    competition = value;
    return load();
  }
}
