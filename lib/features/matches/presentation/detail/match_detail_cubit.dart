import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/entities/match_insight.dart";
import "package:soccer/features/matches/domain/match_repository.dart";

class MatchDetailState extends Equatable {
  const MatchDetailState({
    required this.match,
    this.insight,
    this.loading = false,
    this.failure,
  });

  final Match match;
  final MatchInsight? insight;
  final bool loading;
  final AppFailure? failure;

  Match get scoreboard => insight?.scoreboard ?? match;

  @override
  List<Object?> get props => [match, insight, loading, failure?.message];
}

class MatchDetailCubit extends Cubit<MatchDetailState> {
  MatchDetailCubit(this._repository, Match match)
    : super(MatchDetailState(match: match, loading: true));

  final MatchRepository _repository;

  Future<void> load({bool force = false}) async {
    emit(MatchDetailState(match: state.match, insight: state.insight, loading: true));
    try {
      final insight = await _repository.insight(state.match, force: force);
      emit(MatchDetailState(match: state.match, insight: insight));
    } on AppFailure catch (failure) {
      emit(
        MatchDetailState(
          match: state.match,
          insight: state.insight,
          failure: failure,
        ),
      );
    } catch (_) {
      emit(
        MatchDetailState(
          match: state.match,
          insight: state.insight,
          failure: const NetworkFailure(),
        ),
      );
    }
  }
}
