import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/injuries/domain/entities/injury_report.dart";
import "package:soccer/features/injuries/domain/injury_repository.dart";

sealed class InjuriesState extends Equatable {
  const InjuriesState(this.competition, this.reports);

  final Competition competition;
  final List<InjuryReport>? reports;

  @override
  List<Object?> get props => [competition, reports];
}

final class InjuriesLoading extends InjuriesState {
  const InjuriesLoading(super.competition, [super.reports]);
}

final class InjuriesReady extends InjuriesState {
  const InjuriesReady(super.competition, super.reports);
}

final class InjuriesFailure extends InjuriesState {
  const InjuriesFailure(super.competition, this.failure, [super.reports]);

  final AppFailure failure;

  @override
  List<Object?> get props => [competition, reports, failure.message];
}

class InjuriesCubit extends Cubit<InjuriesState> {
  InjuriesCubit(this._repository)
    : super(const InjuriesLoading(Competition.premierLeague));

  final InjuryRepository _repository;
  Competition competition = Competition.premierLeague;

  Future<void> load({bool force = false}) async {
    final previous = state.reports;
    emit(InjuriesLoading(competition, previous));
    try {
      final reports = await _repository.reports(competition, force: force);
      emit(InjuriesReady(competition, reports));
    } on AppFailure catch (failure) {
      emit(InjuriesFailure(competition, failure, previous));
    } catch (_) {
      emit(InjuriesFailure(competition, const NetworkFailure(), previous));
    }
  }

  Future<void> select(Competition value) {
    competition = value;
    return load();
  }
}
