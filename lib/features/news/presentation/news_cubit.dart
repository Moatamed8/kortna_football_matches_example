import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/news/domain/entities/story.dart";
import "package:soccer/features/news/domain/story_repository.dart";

sealed class NewsState extends Equatable {
  const NewsState(this.competition, this.stories);

  final Competition competition;
  final List<Story>? stories;

  @override
  List<Object?> get props => [competition, stories];
}

final class NewsLoading extends NewsState {
  const NewsLoading(super.competition, [super.stories]);
}

final class NewsReady extends NewsState {
  const NewsReady(super.competition, super.stories);
}

final class NewsFailure extends NewsState {
  const NewsFailure(super.competition, this.failure, [super.stories]);

  final AppFailure failure;

  @override
  List<Object?> get props => [competition, stories, failure.message];
}

class NewsCubit extends Cubit<NewsState> {
  NewsCubit(this._repository, {Competition? competition})
    : competition = competition ?? Competition.premierLeague,
      super(NewsLoading(competition ?? Competition.premierLeague));

  final StoryRepository _repository;
  Competition competition;

  Future<void> load({bool force = false}) async {
    final previous = state.stories;
    emit(NewsLoading(competition, previous));
    try {
      final stories = await _repository.stories(competition, force: force);
      emit(NewsReady(competition, stories));
    } on AppFailure catch (failure) {
      emit(NewsFailure(competition, failure, previous));
    } catch (_) {
      emit(NewsFailure(competition, const NetworkFailure(), previous));
    }
  }

  Future<void> select(Competition value) {
    competition = value;
    return load();
  }
}
