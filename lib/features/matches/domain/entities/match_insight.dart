import "package:equatable/equatable.dart";
import "package:soccer/features/matches/domain/entities/match.dart";

class StatLine extends Equatable {
  const StatLine({
    required this.id,
    required this.label,
    this.home,
    this.away,
  });

  final String id;
  final String label;
  final String? home;
  final String? away;

  @override
  List<Object?> get props => [id, label, home, away];
}

class LineupPlayer extends Equatable {
  const LineupPlayer({
    required this.id,
    required this.name,
    this.number,
    this.position,
    this.starter = false,
  });

  final String id;
  final String name;
  final String? number;
  final String? position;
  final bool starter;

  @override
  List<Object?> get props => [id, name, number, position, starter];
}

class Lineup extends Equatable {
  const Lineup({
    required this.teamId,
    required this.teamName,
    required this.starters,
    required this.bench,
    this.formation,
  });

  final String teamId;
  final String teamName;
  final String? formation;
  final List<LineupPlayer> starters;
  final List<LineupPlayer> bench;

  @override
  List<Object?> get props => [teamId, teamName, formation, starters, bench];
}

class MatchInsight extends Equatable {
  const MatchInsight({
    this.scoreboard,
    this.events = const [],
    this.stats = const [],
    this.lineups = const [],
    this.venue,
    this.venueCity,
    this.attendance,
    this.referee,
  });

  final Match? scoreboard;
  final List<MatchEvent> events;
  final List<StatLine> stats;
  final List<Lineup> lineups;
  final String? venue;
  final String? venueCity;
  final int? attendance;
  final String? referee;

  @override
  List<Object?> get props => [
    scoreboard,
    events,
    stats,
    lineups,
    venue,
    venueCity,
    attendance,
    referee,
  ];
}
