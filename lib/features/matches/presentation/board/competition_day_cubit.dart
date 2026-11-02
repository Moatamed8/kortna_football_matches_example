import "package:equatable/equatable.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:soccer/core/competitions/competition.dart";
import "package:soccer/core/error/app_failure.dart";
import "package:soccer/features/matches/domain/entities/match.dart";
import "package:soccer/features/matches/domain/match_repository.dart";

class DayBoard extends Equatable {
  const DayBoard({
    required this.competition,
    required this.day,
    required this.matches,
  });

  final Competition competition;
  final DateTime day;
  final List<Match> matches;

  @override
  List<Object?> get props => [competition, day, matches];
}

sealed class DayState extends Equatable {
  const DayState({this.board});

  final DayBoard? board;

  @override
  List<Object?> get props => [board];
}

final class DayLoading extends DayState {
  const DayLoading({super.board});
}

final class DayReady extends DayState {
  const DayReady(DayBoard board) : super(board: board);
}

final class DayFailure extends DayState {
  const DayFailure(this.failure, {super.board});

  final AppFailure failure;

  @override
  List<Object?> get props => [board, failure.message];
}

class CompetitionDayCubit extends Cubit<DayState> {
  CompetitionDayCubit(
    this._repository, {
    this.lookAhead = false,
    Competition? competition,
    DateTime? day,
  }) : competition = competition ?? Competition.premierLeague,
       day = _dateOnly(day ?? DateTime.now()),
       super(const DayLoading());

  final MatchRepository _repository;
  final bool lookAhead;
  Competition competition;
  DateTime day;

  Future<void> open({bool force = false}) async {
    final previous = state.board;
    emit(DayLoading(board: previous));
    try {
      var selected = day;
      var matches = await _repository.matchesOn(
        competition: competition,
        day: selected,
        force: force,
      );
      if (matches.isEmpty && lookAhead && isToday(selected)) {
        final tomorrow = selected.add(const Duration(days: 1));
        final next = await _repository.matchesOn(
          competition: competition,
          day: tomorrow,
        );
        if (next.isNotEmpty) {
          selected = tomorrow;
          matches = next;
        }
      }
      day = selected;
      emit(
        DayReady(
          DayBoard(competition: competition, day: selected, matches: matches),
        ),
      );
    } on AppFailure catch (failure) {
      emit(DayFailure(failure, board: previous));
    } catch (_) {
      emit(DayFailure(const NetworkFailure(), board: previous));
    }
  }

  Future<void> selectCompetition(Competition value) {
    competition = value;
    return open();
  }

  Future<void> shiftDay(int delta) {
    day = day.add(Duration(days: delta));
    return open();
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static bool isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }
}
