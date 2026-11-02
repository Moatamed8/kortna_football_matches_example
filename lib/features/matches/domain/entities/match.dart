import "package:equatable/equatable.dart";

enum MatchState { upcoming, live, finished, other }

class TeamSide extends Equatable {
  const TeamSide({
    required this.id,
    required this.name,
    required this.shortName,
    this.abbreviation,
    this.logoUrl,
    this.score,
    this.form,
    this.record,
  });

  final String id;
  final String name;
  final String shortName;
  final String? abbreviation;
  final String? logoUrl;
  final int? score;
  final String? form;
  final String? record;

  @override
  List<Object?> get props => [
    id,
    name,
    shortName,
    abbreviation,
    logoUrl,
    score,
    form,
    record,
  ];
}

class MatchEvent extends Equatable {
  const MatchEvent({
    required this.id,
    required this.type,
    required this.text,
    this.clock,
    this.teamId,
    this.teamName,
    this.playerName,
    this.assistName,
    this.scoringPlay = false,
    this.ownGoal = false,
    this.penalty = false,
  });

  final String id;
  final String type;
  final String text;
  final String? clock;
  final String? teamId;
  final String? teamName;
  final String? playerName;
  final String? assistName;
  final bool scoringPlay;
  final bool ownGoal;
  final bool penalty;

  @override
  List<Object?> get props => [
    id,
    type,
    text,
    clock,
    teamId,
    teamName,
    playerName,
    assistName,
    scoringPlay,
    ownGoal,
    penalty,
  ];
}

class Match extends Equatable {
  const Match({
    required this.id,
    required this.competitionSlug,
    required this.competitionName,
    required this.kickoff,
    required this.state,
    required this.statusLabel,
    required this.home,
    required this.away,
    this.clock,
    this.venue,
    this.venueCity,
    this.events = const [],
  });

  final String id;
  final String competitionSlug;
  final String competitionName;
  final DateTime kickoff;
  final MatchState state;
  final String statusLabel;
  final String? clock;
  final TeamSide home;
  final TeamSide away;
  final String? venue;
  final String? venueCity;
  final List<MatchEvent> events;

  bool get hasScore => home.score != null && away.score != null;

  String get scoreLabel =>
      hasScore ? "${home.score} – ${away.score}" : "vs";

  @override
  List<Object?> get props => [
    id,
    competitionSlug,
    competitionName,
    kickoff,
    state,
    statusLabel,
    clock,
    home,
    away,
    venue,
    venueCity,
    events,
  ];
}
