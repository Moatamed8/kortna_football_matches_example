import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/players/domain/entities/player.dart";
import "package:soccer/features/players/domain/player_repository.dart";

class PlayerState extends Equatable {
  const PlayerState({
    required this.player,
    this.profile,
    this.loading = false,
    this.failure,
  });

  final SquadPlayer player;
  final PlayerProfile? profile;
  final bool loading;
  final AppFailure? failure;

  @override
  List<Object?> get props => [player, profile, loading, failure?.message];
}

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit(this._repository, SquadPlayer player)
    : super(PlayerState(player: player, loading: true));

  final PlayerRepository _repository;

  Future<void> load({bool force = false}) async {
    emit(PlayerState(player: state.player, profile: state.profile, loading: true));
    try {
      final profile = await _repository.profile(state.player, force: force);
      emit(PlayerState(player: state.player, profile: profile));
    } on AppFailure catch (failure) {
      emit(
        PlayerState(
          player: state.player,
          profile: state.profile,
          failure: failure,
        ),
      );
    } catch (_) {
      emit(
        PlayerState(
          player: state.player,
          profile: state.profile,
          failure: const NetworkFailure(),
        ),
      );
    }
  }
}
